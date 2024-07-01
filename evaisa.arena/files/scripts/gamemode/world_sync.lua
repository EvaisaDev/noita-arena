local world_sync = {}

local ffi = require("ffi")

local world_ffi = require("noitapatcher.nsew.world_ffi")
local world = require("noitapatcher.nsew.world")
local rect = require("noitapatcher.nsew.rect")
local rect_optimiser = rect.Optimiser_new()

local PixelRun_const_ptr = ffi.typeof("struct PixelRun const*")
local encoded_area = world.EncodedArea()

world_sync.chunks = function(callback)
    local grid_world = world_ffi.get_grid_world()
    local chunk_map = grid_world.vtable.get_chunk_map(grid_world)
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

    if GameGetFrameNum() % 1 == 0 then
        rect_optimiser:scan()

        local result = {}
        for rect in rect.parts(rect_optimiser:iterate(), 256) do
            local area = world.encode_area(chunk_map, rect.left, rect.top, rect.right, rect.bottom, encoded_area)
            if area ~= nil then
                local str = ffi.string(area, world.encoded_size(area))
                if(#result < 10)then
                    table.insert(result, str)
                end
            end
        end

        callback(result)

        rect_optimiser:reset()
    end
end


world_sync.collect = function(lobby, data)
    local spectators = 0

    for k, v in pairs(data.spectators or {})do
        if(v)then
            spectators = spectators + 1
        end
    end

    if(spectators == 0)then
        return
    end

    world_sync.chunks(function(chunks)
        for k, v in pairs(data.spectators)do
            local user = gameplay_handler.FindUser(lobby, k)
            if(user)then
                networking.send.sync_world(user, chunks)
            else
                data.spectators[k] = false
            end
        end
    end)
end

world_sync.apply = function(received)
    --print("applying world changes")
    local grid_world = world_ffi.get_grid_world()
    local header = ffi.cast("struct EncodedAreaHeader const*", ffi.cast('char const*', received))

    --print(tostring(header.x), tostring(header.y), tostring(header.width), tostring(header.height), tostring(header.pixel_run_count))

    local runs = ffi.cast(PixelRun_const_ptr, ffi.cast("const char*", received) + ffi.sizeof(world.EncodedAreaHeader))
    world.decode(grid_world, header, runs)
end

return world_sync