dofile_once("data/scripts/lib/utilities.lua")

local function teleport(root_id, from_x, from_y, to_x, to_y)
	EntitySetTransform(root_id, to_x, to_y)
	EntityLoad("data/entities/particles/teleportation_source.xml", from_x, from_y)
	EntityLoad("data/entities/particles/teleportation_target.xml", to_x, to_y)
	GamePlaySound("data/audio/Desktop/misc.bank","misc/teleport_use", to_x, to_y)
end

local min_range = 128
local max_range = 1024
local aim_variation = 40 -- degrees
local chunk_size = 256
local step_size = 16
local max_search_range = 512
local max_iterations = 10
    
function trigger(entity_id)
    print("triggering teleportitis")
    local root_id = EntityGetRootEntity(entity_id)
    local pos_x, pos_y = EntityGetTransform( entity_id )

    SetRandomSeed(pos_x, pos_y)

    local controls_component = EntityGetFirstComponent(root_id, "ControlsComponent")
    if controls_component == nil then return end


    local range = Random(min_range, max_range)
    
    local aim_x, aim_y = ComponentGetValue2(controls_component, "mAimingVectorNormalized")


    local angle = math.atan2(aim_y, aim_x)
    local angle_variation = math.rad(aim_variation)
    local angle_offset = Random() * angle_variation - angle_variation / 2
    
    local x = pos_x + math.cos(angle + angle_offset) * range
    local y = pos_y + math.sin(angle + angle_offset) * range
    

    local floor = tonumber(GlobalsGetValue("arena_area_floor", "400"))
    local size = tonumber(GlobalsGetValue("arena_area_size", "600"))

    -- make sure we don't teleport further than size + 30 away from 0, 0
    -- make sure we don't teleport under floor + 30
    -- if we do, teleport to the closest edge
    x = math.min(math.max(x, -size), size)
    y = math.min(math.max(y, -size), size)

    if y > floor then
        y = floor
    end

    -- check if chunk is loaded, if not step back by 256

    
    local iterations = 0
    while (not DoesWorldExistAt(x - 5, y - 5, x + 5, y + 5) and iterations <= max_iterations) do
        -- move towards player
        local dx = pos_x - x
        local dy = pos_y - y
        local len = math.sqrt(dx * dx + dy * dy)
        x = x + dx / len * chunk_size
        y = y + dy / len * chunk_size

        iterations = iterations + 1
    end

    if iterations > max_iterations then
        print("Teleportitis: Could not find valid position")
        return
    end

    local valid_positions = {}
    -- do a grid search around the x, y
    for curr_x = x - (max_search_range / 2), x + (max_search_range / 2), step_size do
        for curr_y = y - (max_search_range / 2), y + (max_search_range / 2), step_size do
            local fixed_x = math.min(math.max(curr_x, -size), size)
            local fixed_y = math.min(math.max(curr_y, -size), size)
        
            if fixed_y > floor then
                fixed_y = floor
            end
        
            if(DoesWorldExistAt(fixed_x - 5, fixed_y - 5, fixed_x + 5, fixed_y + 5))then
                local hit = RaytraceSurfaces( fixed_x - 2, fixed_y - 6, fixed_x + 2, fixed_y + 2 )
                if not hit then
                    table.insert(valid_positions, {x = fixed_x, y = fixed_y})
                end
            end
        end
    end

    -- find closest
    local closest = nil
    local closest_dist = 999999
    for _, pos in ipairs(valid_positions) do
        local dx = pos.x - x
        local dy = pos.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < closest_dist then
            closest = pos
            closest_dist = dist
        end
    end

    if closest then
        x = closest.x
        y = closest.y

        teleport(root_id, pos_x, pos_y, x, y)
    end
end