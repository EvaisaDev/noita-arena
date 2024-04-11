function item_pickup( entity_item, entity_pickupper, item_name )
    if(EntityHasTag(entity_pickupper, "player_unit") == false)then return end
    
    GlobalsSetValue("hm_item_pickup", tostring(EntityGetName(entity_item)))
end