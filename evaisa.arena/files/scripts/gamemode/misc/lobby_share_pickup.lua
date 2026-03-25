function item_pickup( entity_item, entity_pickupper, item_name )
    if EntityHasTag(entity_pickupper, "player_unit") == false then return end
    GlobalsSetValue("arena_lobby_share_pickup", tostring(EntityGetName(entity_item)))
end
