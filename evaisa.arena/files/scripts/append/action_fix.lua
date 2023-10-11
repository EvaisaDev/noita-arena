local remove_list = {
    POLYMORPH_FIELD = true,
    CHAOS_POLYMORPH_FIELD = true,
    SUMMON_EGG = true,

}

local hook_list = {
    RANDOM_SPELL = function(orig, ...)
        local oldSetRandomSeed = SetRandomSeed
        SetRandomSeed = function() 
    
            local shooter = EntityGetRootEntity(GetUpdatedEntityID())
    
            --GamePrint(EntityGetName(shooter))
    
            --oldSetRandomSeed(GameGetFrameNum(), GameGetFrameNum())
    
            local seed = 0
            if(EntityHasTag(shooter, "client"))then
                --GamePrint("2: shooter_rng_"..EntityGetName(shooter))
                seed = tonumber(GlobalsGetValue("shooter_rng_"..EntityGetName(shooter), "0")) or 0
            elseif(EntityHasTag(shooter, "player_unit"))then
                seed = tonumber(GlobalsGetValue("player_rng", "0"))
                
            end
    
            --GamePrint("Seed forced to: "..tostring(seed))
    
            oldSetRandomSeed(seed, seed)
        end
    
        print("Got random: "..tostring(Random(0, 100)))

        orig(...)

        SetRandomSeed = oldSetRandomSeed
    end
}

-- loop backwards through perk_list so we can remove entries
for i=#actions,1,-1 do
    local action = actions[i]
    if remove_list[action.id] then
        table.remove(actions, i)
    else
        if hook_list[action.id] then
            local func = action.action
            action.action = function(...)
                return hook_list[action.id](func, ...)
            end
        end
    end
end