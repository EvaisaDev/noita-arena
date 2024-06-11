dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")
local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")

dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")

--[[
local a, b, c, d, e, f = GameGetDateAndTimeLocal()

local worldState = GameGetWorldStateEntity()
local rounds = 0
if(worldState ~= 0)then
    rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
end
local random_seed = (GameGetFrameNum() + GameGetRealWorldTimeSinceStarted() + a + b + c + d + e + f) / 2
if(GameHasFlagRun("shop_sync"))then
    random_seed = ((tonumber(GlobalsGetValue("world_seed", "0")) or 1) * 214) * rounds
end


local random = rng.new(random_seed)
]]

generate_spell_list = function()
    local spell_list = {}

    local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
    -- how many rounds it takes for the shop level to increment
    local shop_scaling = tonumber(GlobalsGetValue("shop_scaling", "2"))
    -- how much the shop level increments by
    local shop_increment = tonumber(GlobalsGetValue("shop_jump", "1"))
    -- the maximum shop level
    local shop_max = tonumber(GlobalsGetValue("max_shop_level", "5"))
    -- shop start level
    local shop_start_level = tonumber(GlobalsGetValue("shop_start_level", "0"))
    -- calculating how many times the shop level has been incremented
    local num_increments = math.floor((rounds - 1) / shop_scaling)
    -- should shops act as true random
    local true_random = (GameHasFlagRun("max_tier_true_random") and (shop_start_level + num_increments * shop_increment > shop_max))

    for _, v in ipairs(actions) do
    
        if GameHasFlagRun("spell_blacklist_"..v.id) then
            goto continue
        end
    

        local spawn_levels = {}
        for spawn_level in string.gmatch(v.spawn_level or "", "([^,]+)") do
            table.insert(spawn_levels, tonumber(spawn_level))
        end
    
        local spawn_probabilities = {}
        for spawn_probability in string.gmatch(v.spawn_probability or "", "([^,]+)") do
            table.insert(spawn_probabilities, tonumber(spawn_probability))
        end

        if(GameHasFlagRun("shop_no_tiers") or true_random)then
            for i = 0, 50 do
                local key = "level_" .. tostring(i)
                spell_list[key] = spell_list[key] or {}
        
                table.insert(spell_list[key], {
                    id = v.id,
                    probability = 1,
                    type = v.type
                })
            end

        else
            for k, level in ipairs(spawn_levels) do
                local key = "level_" .. tostring(level)
                spell_list[key] = spell_list[key] or {}
        
                table.insert(spell_list[key], {
                    id = v.id,
                    probability = spawn_probabilities[k],
                    type = v.type
                })
            end
        end
        
        ::continue::
    end

    return spell_list
end

last_generated = last_generated or 0


function RandomAction(max_level, x, y)

    if(spell_list == nil or GameGetFrameNum() - last_generated > 60)then
        spell_list = generate_spell_list()
        last_generated = GameGetFrameNum()
    end

    --if(GameHasFlagRun("shop_sync"))then
        --[[local seed = get_new_seed(x, y, GameHasFlagRun("shop_sync"))
        if(seed ~= random_seed)then
            random = rng.new(seed)
            random_seed = seed
            print("new seed: "..tostring(seed))
        end]]

        --local seed_x, seed_y = get_new_seed( x, y, GameHasFlagRun("shop_sync") )
        --SetRandomSeed( seed_x, seed_y )
    --end

    local available_actions = {}

    for level = 0, max_level do
        local key = "level_" .. tostring(level)

        for _, action in ipairs(spell_list[key] or {}) do
            table.insert(available_actions, action)
        end 
    end

    local total_probability = 0
    for _, action in ipairs(available_actions) do
        total_probability = total_probability + action.probability
    end

   -- local random_value = random.random() * total_probability
   local random_value = Random() * total_probability

    for _, action in ipairs(available_actions) do
        random_value = random_value - action.probability
        if random_value <= 0 then
            return action.id
        end
    end

    return "LIGHT_BULLET"
end

-- GetRandomActionWithType function to find a random action with the specified action_type and max_level
function RandomActionWithType(max_level, action_type, x, y)
    if(spell_list == nil or GameGetFrameNum() - last_generated > 60)then
        spell_list = generate_spell_list()
        last_generated = GameGetFrameNum()
    end

    local available_actions = {}

    for level = 0, max_level do
        local key = "level_" .. tostring(level)

        --print("checking level: "..tostring(level))

        for _, action in ipairs(spell_list[key] or {}) do
            if(action.type == action_type)then
                --print("found valid spell: "..tostring(action.id))
                table.insert(available_actions, action)
            end
        end 
    end

    local total_probability = 0
    for _, action in ipairs(available_actions) do
        total_probability = total_probability + action.probability
    end

    --local random_value = random.random() * total_probability
    local random_value = Random() * total_probability

    for _, action in ipairs(available_actions) do
        random_value = random_value - action.probability
        if random_value <= 0 then
            return action.id
        end
    end

    return "LIGHT_BULLET"
end