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
		stackable = STACKABLE_NO,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local count = tonumber( GlobalsGetValue( "hamis_explosive_dash_count", "0" ) )
            count = count + 1
            

            GlobalsSetValue( "hamis_explosive_dash_count", tostring( count ) )
		end,
	},
}