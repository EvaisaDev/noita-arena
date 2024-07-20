perk_list_hamis = {
    {
		id = "HAMIS_DAMAGE",
		ui_name = "Stronger Chomps",
		ui_description = "Your attacks deal more damage. (+25% per stack)",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/damage/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/damage/perk_icon.png",
        skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local count = tonumber( GlobalsGetValue( "hamis_damage_mult", "1" ) )
            count = count + 0.25

            GlobalsSetValue( "hamis_damage_mult", tostring( count ) )
		end,
	},
    {
		id = "HAMIS_DASH",
		ui_name = "Extra Dash",
		ui_description = "You can dash an additional time in mid-air.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/dash/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/dash/perk_icon.png",
        skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local count = tonumber( GlobalsGetValue( "hamis_dash_count", "1" ) )
            count = count + 1
            

            GlobalsSetValue( "hamis_dash_count", tostring( count ) )
		end,
	},
    {
		id = "HAMIS_BIG_BITE",
		ui_name = "Big Chomp",
		ui_description = "You are a hungry little guy aren't you?",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/big_bite/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/big_bite/perk_icon.png",
        skip_functions_on_load = true,
		stackable = STACKABLE_NO,
		func = function( entity_perk_item, entity_who_picked, item_name )
            GameAddFlagRun( "hamis_big_bite" )
		end,
	},
	{
		id = "HAMIS_EXPLOSIVE_DASH",
		ui_name = "Explosive Dash",
		ui_description = "There is a chance you cause an explosion upon impact.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/explosive_dash/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/explosive_dash/perk_icon.png",
        skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local count = tonumber( GlobalsGetValue( "hamis_explosive_dash_count", "0" ) )
            count = count + 1
            

            GlobalsSetValue( "hamis_explosive_dash_count", tostring( count ) )
		end,
	},
	{
		id = "HAMIS_LEECH",
		ui_name = "Leeching Bites",
		ui_description = "You regain health upon chomping an enemy.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/leeching_bite/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/leeching_bite/perk_icon.png",
        skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local count = tonumber( GlobalsGetValue( "hamis_leech_count", "0" ) )
            count = count + 1
            

            GlobalsSetValue( "hamis_leech_count", tostring( count ) )
		end,
	},
	-- venomous bite
	{
		id = "HAMIS_VENOM",
		ui_name = "Venomous Bite",
		ui_description = "Your chomps have a chance to poison enemies.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/venom/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/venom/perk_icon.png",
		skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local count = tonumber( GlobalsGetValue( "hamis_venom_count", "0" ) )
			count = count + 1
			

			GlobalsSetValue( "hamis_venom_count", tostring( count ) )
		end,
	},
	{
		id = "ELECTRICITY",
		ui_name = "$perk_electricity",
		ui_description = "$perkdesc_electricity",
		ui_icon = "data/ui_gfx/perk_icons/electricity.png",
		perk_icon = "data/items_gfx/perks/electricity.png",
		game_effect = "PROTECTION_ELECTRICITY",
		stackable = STACKABLE_NO,
		remove_other_perks = {"PROTECTION_ELECTRICITY"},
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
		
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "data/entities/misc/perks/electricity.xml", x, y )
			EntityAddTag( child_id, "perk_entity" )
			EntityAddChild( entity_who_picked, child_id )
			
		end,
	},
	{
		id = "MOVEMENT_FASTER",
		ui_name = "$perk_movement_faster",
		ui_description = "$perkdesc_movement_faster",
		ui_icon = "data/ui_gfx/perk_icons/movement_faster.png",
		perk_icon = "data/items_gfx/perks/movement_faster.png",
		game_effect = "MOVEMENT_FASTER",
		stackable = STACKABLE_YES,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
	},
	--[[{
		id = "FIRE_LEAP",
		ui_name = "Firey Leap",
		ui_description = "You leave a trail of fire when you leap.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/fire_leap/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/fire_leap/perk_icon.png",
		stackable = STACKABLE_YES,
		stackable_is_rare = true,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			EntityAddComponent( entity_who_picked, "LuaComponent", 
			{
				_tags="perk_component",
				script_source_file="mods/evaisa.arena/files/custom/perks/hamis/fire_leap/effect.lua",
				execute_every_n_frame="3"
			} )
		end,
	}]]
	{
		id = "SPARKLY_LEAP",
		ui_name = "Sparkly Leap",
		ui_description = "Leaping leaves a trail of magical sparks that harm passing creatures.",
		ui_icon = "mods/evaisa.arena/files/custom/perks/hamis/sparkly_leap/ui_icon.png",
		perk_icon = "mods/evaisa.arena/files/custom/perks/hamis/sparkly_leap/perk_icon.png",
		stackable = STACKABLE_YES,
		stackable_is_rare = true,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			EntityAddComponent( entity_who_picked, "LuaComponent", 
			{
				_tags="perk_component",
				script_source_file="mods/evaisa.arena/files/custom/perks/hamis/sparkly_leap/effect.lua",
				execute_every_n_frame="3"
			} )
		end,
	}
}