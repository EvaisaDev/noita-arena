local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")
dofile_once("data/scripts/gun/gun_enums.lua")
dofile( "data/scripts/perks/perk.lua" )
local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")

local a, b, c, d, e, f = GameGetDateAndTimeLocal()

local function is_wand(entity_id)
    local ability_component = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
    if ability_component == nil then return false end
	return ComponentGetValue2(ability_component, "use_gun_script") == true
end

local function get_all_wands()
    local player_entity = player.Get()
    if(player_entity == nil)then return {} end
    local items = GameGetAllInventoryItems(player_entity)
    local wands = {}
    for _, item in ipairs(items) do
        if(is_wand(item))then
            table.insert(wands, item)
        end
    end
    return wands
end

local function get_active_or_random_wand()
    local player_entity = player.Get()
    if(player_entity == nil)then return {} end

    local chosen_wand = nil;
    local wands = {};
    local items = GameGetAllInventoryItems( player_entity );
    for key, item in pairs( items ) do
        if is_wand( item ) then
            table.insert( wands, item );
        end
    end
    if #wands > 0 then
        local inventory2 = EntityGetFirstComponent( player_entity, "Inventory2Component" );
        local active_item = ComponentGetValue2( inventory2, "mActiveItem" );
        for _,wand in pairs( wands ) do
            if wand == active_item then
                chosen_wand = wand;
                break;
            end
        end
        if chosen_wand == nil then
            chosen_wand =  wands[Random( 1, #wands )];
        end
        return chosen_wand;
    end
end

upgrades = {
    -- increase max mana all wands
    {
		id = "MAX_MANA_ALL",
		ui_name = "$arena_upgrades_max_mana_all_name",
		ui_description = "$arena_upgrades_max_mana_all_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/max_mana.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
		func = function( entity_who_picked )
			local x,y = EntityGetTransform( entity_who_picked )
			
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local mana_max = ComponentGetValue2( comp, "mana_max" )
                    
                    mana_max = math.min( mana_max + Random( 5, 15 ) * Random( 5, 15 ), 20000 )

                    ComponentSetValue2( comp, "mana_max", mana_max )
                end
 
            end
		end,
	},
    -- increase mana recharge all wands
    {
        id = "MANA_RECHARGE_ALL",
        ui_name = "$arena_upgrades_mana_recharge_all_name",
        ui_description = "$arena_upgrades_mana_recharge_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/mana_recharge.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local mana_charge_speed = ComponentGetValue2( comp, "mana_charge_speed" )
                    
                    mana_charge_speed = math.min( math.min( mana_charge_speed * Random( 100, 175 ) * 0.01, mana_charge_speed + Random( 50, 150 ) ), 20000 )

                    ComponentSetValue2( comp, "mana_charge_speed", mana_charge_speed )
                end
            end
        end,
    },
    -- reduce cast delay all wands
    {
        id = "CAST_DELAY_ALL",
        ui_name = "$arena_upgrades_cast_delay_all_name",
        ui_description = "$arena_upgrades_cast_delay_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/cast_delay.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local cast_delay = ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" )
                    cast_delay = cast_delay * 0.8 - 5
                    ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", cast_delay )
                end
            end
        end,
    },
    -- reduce reload time all wands
    {
        id = "RELOAD_TIME_ALL",
        ui_name = "$arena_upgrades_reload_time_all_name",
        ui_description = "$arena_upgrades_reload_time_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/reload.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local recharge_time = ComponentObjectGetValue2( comp, "gunaction_config", "reload_time" )
                    recharge_time = recharge_time * 0.8 - 5
                    ComponentObjectSetValue2( comp, "gunaction_config", "reload_time", recharge_time)
                end
            end
        end,
    },
    -- increase spread all wands
    {
        id = "INCREASE_SPREAD_ALL",
        ui_name = "$arena_upgrades_increase_spread_all_name",
        ui_description = "$arena_upgrades_increase_spread_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/high_spread.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local spread_degrees = ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" )

                    spread_degrees = spread_degrees + Random( 5, 15 )

                    ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", spread_degrees )
                end
            end
        end,
    },
    -- reduce spread all wands
    {
        id = "REDUCE_SPREAD_ALL",
        ui_name = "$arena_upgrades_reduce_spread_all_name",
        ui_description = "$arena_upgrades_reduce_spread_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/low_spread.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local spread_degrees = ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" )

                    spread_degrees = spread_degrees - Random( 5, 15 )

                    ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", spread_degrees )
                end
            end
        end,
    },
    -- increase multicast count all wands
    {
        id = "INCREASE_MULTICAST_ALL",
        ui_name = "$arena_upgrades_increase_multicast_all_name",
        ui_description = "$arena_upgrades_increase_multicast_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/multicast.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local multicast_count = ComponentObjectGetValue( comp, "gun_config", "actions_per_round" )

                    multicast_count = multicast_count + 1

                    ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", multicast_count )
                end
            end
        end,
    },
    -- reduce multicast count all wands
    {
        id = "REDUCE_MULTICAST_ALL",
        ui_name = "$arena_upgrades_reduce_multicast_all_name",
        ui_description = "$arena_upgrades_reduce_multicast_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/anti_multicast.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_rare.png",
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local multicast_count = ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" )

                    multicast_count = multicast_count - 1

                    if(multicast_count < 1)then
                        multicast_count = 1
                    end

                    ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", multicast_count )
                end
            end
        end,
    },
    -- increase slot count all wands
    {
        id = "SLOTS_ALL",
        ui_name = "$arena_upgrades_slots_all_name",
        ui_description = "$arena_upgrades_slots_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/slots.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function(entity_who_picked)
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local deck_capacity = ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" )

                    deck_capacity = deck_capacity + 1

                    ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", deck_capacity)
                end
            end
        end,
    },
    -- add always cast all wands
    {
        id = "ADD_ALWAYS_CAST_ALL",
        ui_name = "$arena_upgrades_add_always_cast_all_name",
        ui_description = "$arena_upgrades_add_always_cast_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/always_cast.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                dofile("mods/evaisa.arena/files/scripts/misc/random_action.lua")

                

                GetRandomActionWithType = function( x, y, level, type, i)
                    --print("Custom get action called!")
                    return RandomActionWithType( level, type ) or ""
                end
    
                local good_cards = {}
                local good_cards_init = { "DAMAGE", "CRITICAL_HIT", "HOMING", "SPEED", "ACID_TRAIL", "SINEWAVE" }
                
                for k, v in ipairs(good_cards_init)do
                    if(not GameHasFlagRun("spell_blacklist_"..v))then
                        table.insert(good_cards, v)
                    end
                end
                
                local r = Random( 1, 100 )
                local level = 6
    
                local card = good_cards[ Random( 1, #good_cards ) ] or RandomAction(level)
    
                if( r <= 50 ) then
                    local p = Random(1,100)
    
                    if( p <= 86 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_MODIFIER, 666 )
                    elseif( p <= 93 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_STATIC_PROJECTILE, 666 )
                    elseif ( p < 100 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_PROJECTILE, 666 )
                    else
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_UTILITY, 666 )
                    end
                end

                if(card == nil)then
                    goto continue
                end

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local deck_capacity = ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" )
                    local deck_capacity2 = EntityGetWandCapacity( wand )
                    
                    local always_casts = deck_capacity - deck_capacity2
                    
                    if ( always_casts < 4 ) then
                        AddGunActionPermanent( wand, card )
                    else
                        GamePrintImportant( "$log_always_cast_failed", "$logdesc_always_cast_failed" )
                    end
                end
                ::continue::
            end
        end,
    },
    -- unshuffle all wands
    {
        id = "UNSHUFFLE_ALL",
        ui_name = "$arena_upgrades_unshuffle_all_name",
        ui_description = "$arena_upgrades_unshuffle_all_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/unshuffle.png",
        card_background = "mods/evaisa.arena/files/sprites/ui/upgrades/card_blank.png",
        card_border = "mods/evaisa.arena/files/sprites/ui/upgrades/border_default.png",
        card_border_tint = {0.52, 0.31, 0.52},
        card_symbol_tint = {0.52, 0.31, 0.52},
        weight = 0.2,
        func = function(entity_who_picked)
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    ComponentObjectSetValue2( comp, "gun_config", "shuffle_deck_when_empty", false )
                end
            end
        end,
    },
    -- increase max mana current wand
    {
		id = "MAX_MANA",
		ui_name = "$arena_upgrades_max_mana_name",
		ui_description = "$arena_upgrades_max_mana_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/max_mana.png",
        weight = 0.8,
		func = function( entity_who_picked )
			local x,y = EntityGetTransform( entity_who_picked )
			
            -- increase max mana of only active wand
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then
                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local mana_max = ComponentGetValue2( comp, "mana_max" )
                    
                    mana_max = math.min( mana_max + Random( 5, 15 ) * Random( 5, 15 ), 20000 )

                    ComponentSetValue2( comp, "mana_max", mana_max )
                end
            end
		end,
    },
    -- increase mana recharge current wand
    {
        id = "MANA_RECHARGE",
        ui_name = "$arena_upgrades_mana_recharge_name",
        ui_description = "$arena_upgrades_mana_recharge_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/mana_recharge.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local mana_charge_speed = ComponentGetValue2( comp, "mana_charge_speed" )
                    
                    mana_charge_speed = math.min( math.min( mana_charge_speed * Random( 100, 175 ) * 0.01, mana_charge_speed + Random( 50, 150 ) ), 20000 )

                    ComponentSetValue2( comp, "mana_charge_speed", mana_charge_speed )
                end
            end
        end,
    },
    -- reduce cast delay current wand
    {
        id = "CAST_DELAY",
        ui_name = "$arena_upgrades_cast_delay_name",
        ui_description = "$arena_upgrades_cast_delay_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/cast_delay.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local cast_delay = ComponentObjectGetValue2( comp, "gunaction_config", "fire_rate_wait" )
                    cast_delay = cast_delay * 0.8 - 5
                    ComponentObjectSetValue2( comp, "gunaction_config", "fire_rate_wait", cast_delay )
                end
            end
        end,
    },
    -- reduce reload time current wand
    {
        id = "RELOAD_TIME",
        ui_name = "$arena_upgrades_reload_time_name",
        ui_description = "$arena_upgrades_reload_time_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/reload.png",
        weight = 0.8,
        func = function( entity_who_picked )
            --[[
            local x,y = EntityGetTransform( entity_who_picked )
            
            local wands = get_all_wands()

            for k, wand in ipairs(wands)do
            
                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local recharge_time = ComponentObjectGetValue2( comp, "gunaction_config", "reload_time" )
                    recharge_time = recharge_time * 0.8 - 5
                    ComponentObjectSetValue2( comp, "gunaction_config", "reload_time", recharge_time)
                end
            end
            ]]


            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local recharge_time = ComponentObjectGetValue2( comp, "gun_config", "reload_time" )
                    recharge_time = recharge_time * 0.8 - 5
                    ComponentObjectSetValue2( comp, "gun_config", "reload_time", recharge_time)

                    print("recharge_time: " .. recharge_time)
                end
            end
        end,
    },    
    -- increase spread current wand
    {
        id = "INCREASE_SPREAD",
        ui_name = "$arena_upgrades_increase_spread_name",
        ui_description = "$arena_upgrades_increase_spread_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/high_spread.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local spread_degrees = ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" )

                    spread_degrees = spread_degrees + Random( 5, 15 )

                    ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", spread_degrees )
                end
            end
        end,
    },
    -- reduce spread all wands
    {
        id = "REDUCE_SPREAD",
        ui_name = "$arena_upgrades_reduce_spread_name",
        ui_description = "$arena_upgrades_reduce_spread_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/low_spread.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local spread_degrees = ComponentObjectGetValue2( comp, "gunaction_config", "spread_degrees" )

                    spread_degrees = spread_degrees - Random( 5, 15 )

                    ComponentObjectSetValue2( comp, "gunaction_config", "spread_degrees", spread_degrees )
                end
            end
        end,
    },    
    -- increase multicast count all wands
    {
        id = "INCREASE_MULTICAST",
        ui_name = "$arena_upgrades_increase_multicast_name",
        ui_description = "$arena_upgrades_increase_multicast_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/multicast.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local multicast_count = ComponentObjectGetValue( comp, "gun_config", "actions_per_round" )

                    multicast_count = multicast_count + 1

                    ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", multicast_count )
                end
            end
        end,
    },
    -- reduce multicast count all wands
    {
        id = "REDUCE_MULTICAST",
        ui_name = "$arena_upgrades_reduce_multicast_name",
        ui_description = "$arena_upgrades_reduce_multicast_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/anti_multicast.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local multicast_count = ComponentObjectGetValue2( comp, "gun_config", "actions_per_round" )

                    multicast_count = multicast_count - 1

                    if(multicast_count < 1)then
                        multicast_count = 1
                    end

                    ComponentObjectSetValue2( comp, "gun_config", "actions_per_round", multicast_count )
                end
            end
        end,
    },
    -- increase slot count all wands
    {
        id = "SLOTS",
        ui_name = "$arena_upgrades_slots_name",
        ui_description = "$arena_upgrades_slots_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/slots.png",
        weight = 0.8,
        func = function(entity_who_picked)
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local deck_capacity = ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" )

                    deck_capacity = deck_capacity + 1

                    ComponentObjectSetValue2( comp, "gun_config", "deck_capacity", deck_capacity)
                end
            end
        end,
    },
    -- add always cast all wands
    {
        id = "ADD_ALWAYS_CAST",
        ui_name = "$arena_upgrades_add_always_cast_name",
        ui_description = "$arena_upgrades_add_always_cast_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/always_cast.png",
        weight = 0.8,
        func = function( entity_who_picked )
            local x,y = EntityGetTransform( entity_who_picked )
            
            --SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local random = rng.new(entity_who_picked + x + (GameGetFrameNum() + GameGetRealWorldTimeSinceStarted() + a + b + c + d + e + f) / 2)

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), wand + y + GameGetFrameNum() )

                dofile("mods/evaisa.arena/files/scripts/misc/random_action.lua")

                
                
                GetRandomActionWithType = function( x, y, level, type, i)
                    --print("Custom get action called!")
                    return RandomActionWithType( level, type ) or ""
                end
    
                local good_cards = {}
                local good_cards_init = { "DAMAGE", "CRITICAL_HIT", "HOMING", "SPEED", "ACID_TRAIL", "SINEWAVE" }
                
                for k, v in ipairs(good_cards_init)do
                    if(not GameHasFlagRun("spell_blacklist_"..v))then
                        table.insert(good_cards, v)
                    end
                end
                
                local r = Random( 1, 100 )
                local level = 6
    
                local card = good_cards[ Random( 1, #good_cards ) ] or RandomAction(level)
    
                if( r <= 50 ) then
                    local p = Random(1,100)
    
                    if( p <= 86 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_MODIFIER, 666 )
                    elseif( p <= 93 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_STATIC_PROJECTILE, 666 )
                    elseif ( p < 100 ) then
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_PROJECTILE, 666 )
                    else
                        card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_UTILITY, 666 )
                    end
                end

                if(card == nil)then
                    goto continue
                end

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    local deck_capacity = ComponentObjectGetValue2( comp, "gun_config", "deck_capacity" )
                    local deck_capacity2 = EntityGetWandCapacity( wand )
                    
                    local always_casts = deck_capacity - deck_capacity2
                    
                    if ( always_casts < 4 ) then
                        AddGunActionPermanent( wand, card )
                    else
                        GamePrintImportant( "$log_always_cast_failed", "$logdesc_always_cast_failed" )
                    end
                end
                ::continue::
            end
        end,
    },
    -- unshuffle all wands
    {
        id = "UNSHUFFLE",
        ui_name = "$arena_upgrades_unshuffle_name",
        ui_description = "$arena_upgrades_unshuffle_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/unshuffle.png",
        weight = 0.8,
        func = function(entity_who_picked)
            local x,y = EntityGetTransform( entity_who_picked )
            
            SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )

            local wand = get_active_or_random_wand()

            if(wand ~= nil)then

                local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
                
                if ( comp ~= nil ) then
                    ComponentObjectSetValue2( comp, "gun_config", "shuffle_deck_when_empty", false )
                end
            end
        end,
    },    
    {
        id = "GOLD",
        ui_name = "$arena_upgrades_gold_name",
        ui_description = "$arena_upgrades_gold_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/gold.png",
        weight = 1.0,
        func = function(entity_who_picked)
            local gold = ArenaGameplay.GetRoundGold(entity_who_picked)

            player.GiveGold( gold )
        end,
    },
    {
        id = "RANDOM_PERK",
        ui_name = "$arena_upgrades_random_perk_name",
        ui_description = "$arena_upgrades_random_perk_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/random_perk.png",
        weight = 1.0,
        func = function(entity_who_picked)


            local x,y = EntityGetTransform( entity_who_picked )
            local pid = perk_spawn_random(x,y)
            perk_pickup(pid, entity_who_picked, "", false, false )

        end,
    },
    {
        id = "HEALTH",
        ui_name = "$arena_upgrades_health_name",
        ui_description = "$arena_upgrades_health_description",
        card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/health.png",
        weight = 1.0,
        func = function(entity_who_picked)

            local x,y = EntityGetTransform( entity_who_picked )
            local damagemodels = EntityGetComponent( entity_who_picked, "DamageModelComponent" )
            
            if( damagemodels ~= nil ) then
                for i,damagemodel in ipairs(damagemodels) do
                    local max_hp = tonumber( ComponentGetValue( damagemodel, "max_hp" ) )
                    local max_hp_new = max_hp * 1.25
                    ComponentSetValue( damagemodel, "max_hp", max_hp_new )
                    ComponentSetValue( damagemodel, "hp", max_hp_new )
                end
            end

        end
    },
	{
		id = "COPY_WAND",
		ui_name = "$arena_upgrades_copy_wand_name",
		ui_description = "$arena_upgrades_copy_wand_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/dupe_wand.png",
		weight = 0.5,
		func = function(entity_who_picked)
			local wand = get_active_or_random_wand()
			if wand == nil then return end

			local px, py = EntityGetTransform(entity_who_picked)

			local serialized = np.SerializeEntity(wand)
			local new_wand = EntityCreateNew()
			np.DeserializeEntity(new_wand, serialized, px, py)

			local children = EntityGetAllChildren(new_wand) or {}
			for _, child in ipairs(children) do
				EntityKill(child)
			end

			local ability_component = EntityGetFirstComponentIncludingDisabled(new_wand, "AbilityComponent")
			if ability_component ~= nil then
				EntitySetComponentIsEnabled(new_wand, ability_component, true)
			end

			local hotspot_comp = EntityGetFirstComponentIncludingDisabled(new_wand, "HotspotComponent")
			if hotspot_comp ~= nil then
				EntitySetComponentIsEnabled(new_wand, hotspot_comp, true)
			end

			local item_component = EntityGetFirstComponentIncludingDisabled(new_wand, "ItemComponent")
			if item_component ~= nil then
				EntitySetComponentIsEnabled(new_wand, item_component, true)
				ComponentSetValue(item_component, "has_been_picked_by_player", "0")
				ComponentSetValue(item_component, "play_hover_animation", "1")
				ComponentSetValueVector2(item_component, "spawn_pos", px, py)
			end

			local sprite_component = EntityGetFirstComponentIncludingDisabled(new_wand, "SpriteComponent")
			if sprite_component ~= nil then
				EntitySetComponentIsEnabled(new_wand, sprite_component, true)
			end

			local light_component = EntityGetFirstComponentIncludingDisabled(new_wand, "LightComponent")
			if light_component ~= nil then
				EntitySetComponentIsEnabled(new_wand, light_component, true)
			end

			local lua_comp = EntityGetFirstComponentIncludingDisabled(new_wand, "LuaComponent")
			if lua_comp ~= nil then
				EntitySetComponentIsEnabled(new_wand, lua_comp, true)
			end

			local simple_physics_component = EntityGetFirstComponentIncludingDisabled(new_wand, "SimplePhysicsComponent")
			if simple_physics_component ~= nil then
				EntitySetComponentIsEnabled(new_wand, simple_physics_component, false)
			end

			local sprite_particle_emitter_comp = EntityGetFirstComponentIncludingDisabled(new_wand, "SpriteParticleEmitterComponent")
			if sprite_particle_emitter_comp ~= nil then
				EntitySetComponentIsEnabled(new_wand, sprite_particle_emitter_comp, true)
			end

		end,
	},
	{
		id = "DISCOUNT_SHOP",
		ui_name = "$arena_upgrades_discount_shop_name",
		ui_description = "$arena_upgrades_discount_shop_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/discount.png",
		weight = 0.5,
		func = function(entity_who_picked)
			local shop_x = tonumber(GlobalsGetValue("SHOP_SPAWN_X", "0")) or 0
			local shop_y = tonumber(GlobalsGetValue("SHOP_SPAWN_Y", "0")) or 0

			local smallfolk = dofile("mods/evaisa.arena/lib/smallfolk.lua")
			local item_shop_spots = smallfolk.loads(GlobalsGetValue("ITEM_SHOP_SPAWN_SPOTS", "{}"))

			local all_centers = {{shop_x, shop_y}}
			for _, spot in ipairs(item_shop_spots) do
				table.insert(all_centers, spot)
			end

			local discounted = {}
			for _, center in ipairs(all_centers) do
				local entities = EntityGetInRadius(center[1], center[2], 200)
				for _, eid in ipairs(entities) do
					if EntityGetRootEntity(eid) == eid and not discounted[eid] then
						local cost_comp = EntityGetFirstComponentIncludingDisabled(eid, "ItemCostComponent")
						if cost_comp ~= nil and not EntityHasTag(eid, "shop_item_on_sale") then
							local cost = ComponentGetValue2(cost_comp, "cost")
							local new_cost = math.max(math.floor(cost * 0.5), 0)
							ComponentSetValue2(cost_comp, "cost", new_cost)

							local sprite_comps = EntityGetComponentIncludingDisabled(eid, "SpriteComponent") or {}
							for _, sprite_comp in ipairs(sprite_comps) do
								if ComponentGetValue2(sprite_comp, "is_text_sprite") then
									local text = tostring(new_cost)
									local textwidth = 0
									for i = 1, #text do
										local l = string.sub(text, i, i)
										textwidth = textwidth + (l ~= "1" and 6 or 3)
									end
									ComponentSetValue2(sprite_comp, "text", text)
									ComponentSetValue2(sprite_comp, "offset_x", textwidth * 0.5 - 0.5)
								end
							end

							local item_comp = EntityGetFirstComponentIncludingDisabled(eid, "ItemComponent")
							local ix, iy = EntityGetTransform(eid)
							if item_comp ~= nil then
								local sx, sy = ComponentGetValueVector2(item_comp, "spawn_pos")
								if sx ~= 0 or sy ~= 0 then
									ix, iy = sx, sy
								end
							end
							EntityLoad("data/entities/misc/sale_indicator.xml", ix, iy)
							EntityAddTag(eid, "shop_item_on_sale")
							discounted[eid] = true
						end
					end
				end
			end
		end,
	},
	{
		id = "REROLL_SHOP",
		ui_name = "$arena_upgrades_reroll_shop_name",
		ui_description = "$arena_upgrades_reroll_shop_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/restock.png",
		weight = 0.5,
		func = function(entity_who_picked)
			local old_perk_list = perk_list
			local old_actions = actions

			actions = {}
			perk_list = {}


			local shop_x = tonumber(GlobalsGetValue("SHOP_SPAWN_X", "0")) or 0
			local shop_y = tonumber(GlobalsGetValue("SHOP_SPAWN_Y", "0")) or 0

			local reroll_count = (tonumber(GlobalsGetValue("SHOP_REROLL_COUNT", "0")) or 0) + 1
			GlobalsSetValue("SHOP_REROLL_COUNT", tostring(reroll_count))

			local smallfolk = dofile("mods/evaisa.arena/lib/smallfolk.lua")

			local item_shop_spots_raw = GlobalsGetValue("ITEM_SHOP_SPAWN_SPOTS", "{}")
			local item_shop_spots = smallfolk.loads(item_shop_spots_raw)

			local all_centers = {{shop_x, shop_y}}
			for _, spot in ipairs(item_shop_spots) do
				table.insert(all_centers, spot)
			end

			local killed = {}
			for _, center in ipairs(all_centers) do
				local entities = EntityGetInRadius(center[1], center[2], 200)
				for _, eid in ipairs(entities) do
					if EntityGetRootEntity(eid) == eid and not killed[eid] then
						local cost_comp = EntityGetFirstComponentIncludingDisabled(eid, "ItemCostComponent")
						if cost_comp ~= nil then
							EntityKill(eid)
							killed[eid] = true
						end
					end
				end
			end

			local was_deserialized = GameHasFlagRun("DeserializedHolyMountain")
			GameRemoveFlagRun("DeserializedHolyMountain")
			GlobalsSetValue("ITEM_SHOP_SPAWN_SPOTS", "{}")
			GameAddFlagRun("rerolling_shop")

			RegisterSpawnFunction = function() 

			end

			dofile("mods/evaisa.arena/files/scripts/world/biomes/holymountain.lua")
			spawn_all_shopitems(shop_x, shop_y)
			for _, spot in ipairs(item_shop_spots) do
				spawn_item_shop_item(spot[1], spot[2])
			end

			GameRemoveFlagRun("rerolling_shop")
			if was_deserialized then
				GameAddFlagRun("DeserializedHolyMountain")
			end

			actions = old_actions
			perk_list = old_perk_list
		end,
	},
	{
		id = "FUNGAL_SHIFT",
		ui_name = "$arena_upgrades_fungal_shift_name",
		ui_description = "$arena_upgrades_fungal_shift_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/fungal_shift.png",
		weight = 0.5,
		func = function(entity_who_picked)
			dofile_once("data/scripts/magic/fungal_shift.lua")
			local x, y = EntityGetTransform(entity_who_picked)
			SetRandomSeed( entity_who_picked + x + GameGetFrameNum(), y + GameGetFrameNum() )
			local old_rand = rand
			rand = function(a, b)
				return Random(a, b)
			end
			fungal_shift(entity_who_picked, x, y, true)
			rand = old_rand
		end,
	},
	{
		id = "FLASKS",
		ui_name = "$arena_upgrades_flasks_name",
		ui_description = "$arena_upgrades_flasks_description",
		card_symbol = "mods/evaisa.arena/files/sprites/ui/upgrades/symbols/flask.png",
		weight = 0.5,
		func = function(entity_who_picked)
			local x, y = EntityGetTransform(entity_who_picked)
			
			local flask_count = 3

			local start_pos_x = x - ((3 * 16) / 2)

			for i = 1, flask_count do
				local hit, x, y = RaytracePlatforms(start_pos_x + (i - 1) * 16, y, start_pos_x + (i - 1) * 16, y + 200)
				local items = {
					"data/entities/items/pickup/potion.xml",
					"data/entities/items/pickup/powder_stash.xml",
				}

				local item = items[Random(1, #items)]
				
				EntityLoad(item, x, y)

			end
		end,
	}
}