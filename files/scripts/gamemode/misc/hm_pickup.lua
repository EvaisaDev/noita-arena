function item_pickup( entity_item, entity_pickupper, item_name )
    if(EntityHasTag(entity_pickupper, "player_unit") == false)then return end
    
    GlobalsSetValue("hm_item_pickup", tostring(EntityGetName(entity_item)))

    if(EntityGetIsAlive(tonumber(entity_item) or 0))then
        print("Entity is alive")
        local entity_pickup = tonumber(entity_item) or 0
        if(EntityHasTag(entity_pickup, "heart"))then
            print("Entity is heart")
            GameAddFlagRun("picked_up_new_heart")
        end
    end
end