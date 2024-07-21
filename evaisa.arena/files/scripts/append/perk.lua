local old_perk_get_spawn_order = perk_get_spawn_order

dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")


perk_get_spawn_order = function ( ignore_these_ )
    local oldSetRandomSeed = SetRandomSeed
    SetRandomSeed = function(x, y) 
        local random_seed_x, random_seed_y = get_new_seed(x, y, GameHasFlagRun("perk_sync"))
        oldSetRandomSeed(random_seed_x, random_seed_y)
    end

    

    ignore_these_ = ignore_these_ or {}

    apply_perk_fixes()
    
    for i, perk in ipairs(perk_list)do
        if GameHasFlagRun("perk_blacklist_"..perk.id) then
            table.insert(ignore_these_, perk.id)
        end
    end

    local out =  old_perk_get_spawn_order(ignore_these_)

    SetRandomSeed = oldSetRandomSeed

    return out
end

local old_perk_pickup = perk_pickup

perk_pickup = function( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )
    local oldSetRandomSeed = SetRandomSeed
    SetRandomSeed = function(x, y) 
        local random_seed_x, random_seed_y = get_new_seed(x, y, GameHasFlagRun("perk_sync"))
        oldSetRandomSeed(random_seed_x, random_seed_y)
    end

    GameAddFlagRun("picked_perk")

    local out = old_perk_pickup( entity_item, entity_who_picked, item_name, do_cosmetic_fx, kill_other_perks, no_perk_entity_ )

    SetRandomSeed = oldSetRandomSeed

    local perk_id = ""
	
	if no_perk_entity_ then
		perk_id = item_name
	else
		edit_component( entity_item, "VariableStorageComponent", function(comp,vars)
			perk_id = ComponentGetValue( comp, "value_string" )
		end)
	end

    apply_perk_fixes()

	local perk_data = get_perk_with_id( perk_list, perk_id )
	if perk_data == nil then
		return
	end

	
    local to_remove = perk_data.remove_other_perks or {}

    for i, perk_id in ipairs(to_remove)do
        local flag_name = get_perk_picked_flag_name( perk_id )

        GameRemoveFlagRun( flag_name )
        GlobalsSetValue( flag_name .. "_PICKUP_COUNT", "0" )

    end

    GameAddFlagRun("sync_hm_to_spectators")

    return out
end

local old_perk_spawn_many = perk_spawn_many

perk_spawn_many = function( x, y, dont_remove_others_, ignore_these_ )
    local perk_number = 0
    apply_perk_fixes()
    for i, perk in ipairs(perk_list)do
        if not GameHasFlagRun("perk_blacklist_"..perk.id) then
            perk_number = perk_number + 1
        end
    end
    if(perk_number == 0)then
        return
    end
    old_perk_spawn_many( x, y, dont_remove_others_, ignore_these_ )
end