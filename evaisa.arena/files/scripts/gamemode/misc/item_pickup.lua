function item_pickup( entity_item, entity_pickupper, item_name )
    if(EntityHasTag(entity_pickupper, "player_unit") == false)then 
        EntityRemoveTag(entity_item, "picked_by_player")
        return 
    end
    local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

    EntityAddTag(entity_item, "picked_by_player")

    local id = entity.GetVariable(entity_item, "arena_entity_id")

    if(id ~= nil)then
        GlobalsSetValue("arena_item_pickup", tostring(id))
    end
end