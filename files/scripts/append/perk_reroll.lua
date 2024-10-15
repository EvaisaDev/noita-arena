local old_reroll = item_pickup

item_pickup = function( entity_item, entity_who_picked, item_name )
    old_reroll( entity_item, entity_who_picked, item_name )
    GameAddFlagRun("sync_hm_to_spectators")
end