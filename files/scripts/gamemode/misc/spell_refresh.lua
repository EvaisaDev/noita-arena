dofile( "data/scripts/game_helpers.lua" )

function interacting( entity_who_interacted, entity_interacted, interactable_name )
	if(EntityHasTag(entity_who_interacted, "player_unit") == false)then return end

	local x, y = EntityGetTransform( entity_interacted)
	EntityLoad("data/entities/particles/image_emitters/spell_refresh_effect.xml", x, y-12)
	GamePrintImportant( "$itemtitle_spell_refresh", "$itemdesc_spell_refresh" )
	
	GameRegenItemActionsInPlayer( entity_who_interacted )

	-- remove the item from the game
	--EntityKill( entity_item )

	
    
    GlobalsSetValue("hm_item_pickup", tostring(EntityGetName(entity_interacted)))
end
