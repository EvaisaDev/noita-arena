function kick( entity_who_kicked )
    local item_ent = GetUpdatedEntityID()
    if(not EntityHasTag(entity_who_kicked, "player_unit"))then return end

    local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

    if(item_ent ~= EntityGetRootEntity(item_ent))then
        return
    end

    local id = entity.GetVariable(item_ent, "arena_entity_id")
    if(id ~= nil)then
        local body_ids = PhysicsBodyIDGetFromEntity( item_ent )
        if(body_ids ~= nil and #body_ids > 0)then
           
            
            local kicked_item_string = GlobalsGetValue("arena_items_controlled", "")

            kicked_item_string = kicked_item_string .. tostring(item_ent) .. ";"

            GlobalsSetValue("arena_items_controlled", kicked_item_string)
        end
    end
end