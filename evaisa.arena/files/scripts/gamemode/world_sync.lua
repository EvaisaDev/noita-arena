local world_sync = {}

local ffi = require("ffi")

local world_ffi = require("noitapatcher.nsew.world_ffi")
local world = require("noitapatcher.nsew.world")
local rect = require("noitapatcher.nsew.rect")
local rect_optimiser = rect.Optimiser_new()

local PixelRun_const_ptr = ffi.typeof("struct PixelRun const*")
local encoded_area = world.EncodedArea()

local area_header_size = ffi.sizeof(world.EncodedAreaHeader)

local chunk_size = 64

-- doesn't seem to work?
world_sync.add_chunks = function(x, y, w, h)

    local grid_world = world_ffi.get_grid_world()
    local chunk_map = grid_world.vtable.get_chunk_map(grid_world)

    for y = y, y + h, chunk_size do
        for x = x, x + w, chunk_size do
            world_sync.sync_world_part(chunk_map, x, y, x + chunk_size, y + chunk_size)
        end
    end
end

-- collects updated chunks and adds them to the rect optimiser
world_sync.collect_chunks = function()
    local grid_world = world_ffi.get_grid_world()

    local thread_impl = grid_world.mThreadImpl

    local begin = thread_impl.updated_grid_worlds.begin
    local end_ = begin + thread_impl.chunk_update_count

    local count = thread_impl.chunk_update_count

    for i = 0, count - 1 do
        local it = begin[i]

        local start_x = it.update_region.top_left.x
        local start_y = it.update_region.top_left.y
        local end_x = it.update_region.bottom_right.x
        local end_y = it.update_region.bottom_right.y

        start_x = start_x - 1
        start_y = start_y - 1
        end_x = end_x + 1
        end_y = end_y + 2

        local rectangle = rect.Rectangle(start_x, start_y, end_x, end_y)
        rect_optimiser:submit(rectangle)
    end

    for i = 0, tonumber(thread_impl.world_update_params_count) - 1 do
        local wup = thread_impl.world_update_params.begin[i]
        local start_x = wup.update_region.top_left.x
        local start_y = wup.update_region.top_left.y
        local end_x = wup.update_region.bottom_right.x
        local end_y = wup.update_region.bottom_right.y

        local rectangle = rect.Rectangle(start_x, start_y, end_x, end_y)
        rect_optimiser:submit(rectangle)
    end
end

-- function with callback that will optimize the chunks and return them
world_sync.chunks = function(callback)
    local grid_world = world_ffi.get_grid_world()
    local chunk_map = grid_world.vtable.get_chunk_map(grid_world)


    rect_optimiser:scan()

    local result = {}
    for rect in rect.parts(rect_optimiser:iterate(), 256) do
        local area = world.encode_area(chunk_map, rect.left, rect.top, rect.right, rect.bottom, encoded_area)
        if area ~= nil then
            local str = ffi.string(area, world.encoded_size(area))

            table.insert(result, str)

        end
    end

    callback(result)

    rect_optimiser:reset()

end

local chunk_stack = {}
local chunks_per_frame = 10

world_sync.sync_world_part = function(chunk_map, start_x, start_y, end_x, end_y)
    if(DoesWorldExistAt(start_x, start_y, end_x, end_y))then
        local area = world.encode_area(chunk_map, start_x, start_y, end_x, end_y, encoded_area)
        if area == nil then
            return
        end

        local str = ffi.string(area, world.encoded_size(area))

        table.insert(chunk_stack, str)
    end
end

world_sync.update = function(lobby, data)
    local spectators = 0

    for k, v in pairs(data.spectators or {})do
        if(v)then
            spectators = spectators + 1
        end
    end

    if(spectators == 0)then
        return
    end
    
    world_sync.collect_chunks()

    if(GameGetFrameNum() % 5 == 0)then
        world_sync.chunks(function(chunks)
            for i, chunk in ipairs(chunks)do
                table.insert(chunk_stack, chunk)
            end
        end)
    end

    if(#chunk_stack > 0)then
        local chunks = {}
        for i = 0, math.min(chunks_per_frame, #chunk_stack) - 1 do
            local chunk = table.remove(chunk_stack, 1)
            table.insert(chunks, chunk)
        end

        local chunk_str = zstd:compress(table.concat(chunks, ""))
        for k, v in pairs(data.spectators)do
            local user = gameplay_handler.FindUser(lobby, k)
            if(user)then
                networking.send.sync_world(user, chunk_str)
            else
                data.spectators[k] = false
            end
        end
    end

end

world_sync.apply = function(msg)
    -- decompress

    local chunks_str = zstd:decompress(msg)

    local grid_world = world_ffi.get_grid_world()
    local world_data = chunks_str
    local data_ptr = ffi.cast('char const*', world_data)
    local index = 0
    while #world_data - index > area_header_size do
        local header = ffi.cast("struct EncodedAreaHeader const*", data_ptr + index)
        local run_length = header.pixel_run_count * ffi.sizeof(world.PixelRun)
        local runs = ffi.cast(ffi.typeof("struct PixelRun const*"), data_ptr + index + area_header_size)
        index = index + run_length + area_header_size
    
        world.decode(grid_world, header, runs)
    end

end

return world_sync