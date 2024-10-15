local remove_list = {
    --POLYMORPH_FIELD = true,
    --CHAOS_POLYMORPH_FIELD = true,
    SUMMON_EGG = true,
    DESTRUCTION = true,
    CESSATION = true,
    --MASS_POLYMORPH = true,
}

local hook_list = {
    --[[RANDOM_SPELL = function(orig, ...)
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
    
        GamePrint("Got random: "..tostring(Random(0, 100)))

        orig(...)

        SetRandomSeed = oldSetRandomSeed
    end]]
}

local replace_list = {
    BLOOD_MAGIC = {
		id          = "BLOOD_MAGIC",
		name 		= "$action_blood_magic",
		description = "$actiondesc_blood_magic",
		sprite 		= "data/ui_gfx/gun_actions/blood_magic.png",
		sprite_unidentified = "data/ui_gfx/gun_actions/spread_reduce_unidentified.png",
		related_extra_entities = { "data/entities/particles/blood_sparks.xml" },
		type 		= ACTION_TYPE_UTILITY,
		spawn_level                       = "5,6,10", -- MANA_REDUCE
		spawn_probability                 = "0.3,0.7,0.5", -- MANA_REDUCE
		price = 150,
		mana = -100,
		custom_xml_file = "data/entities/misc/custom_cards/blood_magic.xml",
		action 		= function()
			c.extra_entities = c.extra_entities .. "data/entities/particles/blood_sparks.xml,"
			c.fire_rate_wait = c.fire_rate_wait - 20
			current_reload_time = current_reload_time - 20
			draw_actions( 1, true )
			
			local entity_id = GetUpdatedEntityID()
			
			local dcomps = EntityGetComponent( entity_id, "DamageModelComponent" )
			
            if(not GameHasFlagRun("Immortal"))then
                if ( dcomps ~= nil ) and ( #dcomps > 0 ) then
                    for a,b in ipairs( dcomps ) do
                        local hp = ComponentGetValue2( b, "hp" )
                        hp = math.max( hp - 0.16, 0.04 )
                        ComponentSetValue2( b, "hp", hp )
                    end
                end
            end
		end,
	},
}

-- loop backwards through perk_list so we can remove entries
for i=#actions,1,-1 do
    local action = actions[i]
    if remove_list[action.id] then
        table.remove(actions, i)
    elseif(replace_list[action.id])then
        actions[i] = replace_list[action.id]
    else
        local func = action.action
        action.action = function(...)
            --[[local oldSetRandomSeed = SetRandomSeed
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
        
                GamePrint("Seed forced to: "..tostring(seed))
        
                oldSetRandomSeed(seed, seed)
            end]]

            if(reflecting)then
                func(...)
                return
            end

            local oldSetRandomSeed = SetRandomSeed

            local shooter = EntityGetRootEntity(GetUpdatedEntityID())
            local x, y = EntityGetTransform(GetUpdatedEntityID())

            local seed = x * y + GameGetFrameNum()

            if(EntityHasTag(shooter, "client"))then
                --GamePrint("2: shooter_rng_"..EntityGetName(shooter))
                seed = tonumber(GlobalsGetValue("action_rng_"..EntityGetName(shooter), "0")) or 0
            else
                if(GlobalsGetValue("player_action_rng", "0") ~= "0")then
                    seed = tonumber(GlobalsGetValue("player_action_rng", "0"))
                else
                    GlobalsSetValue("player_action_rng", tostring(seed))
                end
            end

            SetRandomSeed = function() 
                oldSetRandomSeed(seed, seed)
            end

            func(...)



            SetRandomSeed = oldSetRandomSeed
        end

        --[[if hook_list[action.id] then
            local func = action.action
            action.action = function(...)
                hook_list[action.id](func, ...)
            end
        end]]
    end
end