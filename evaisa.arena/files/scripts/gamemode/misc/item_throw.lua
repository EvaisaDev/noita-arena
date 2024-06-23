function throw_item( from_x, from_y, to_x, to_y )
    --print("???")
    local thrown_entity = GetUpdatedEntityID()
    local players = EntityGetWithTag("player_unit")
    if(#players <= 0)then return end

    --print("Throwing item from " .. tostring(from_x) .. ", " .. tostring(from_y) .. " to " .. tostring(to_x) .. ", " .. tostring(to_y))

    --print("Entity id: " .. tostring(thrown_entity) .. ", Root Entity: ".. tostring(EntityGetRootEntity(thrown_entity)))

    local was_player_item = EntityHasTag(thrown_entity, "picked_by_player")

    local player = players[1]
    local inventory_2_comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
    if(inventory_2_comp == nil)then return end
    local thrown_item = ComponentGetValue2(inventory_2_comp, "mThrowItem")
    local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

    if( was_player_item or thrown_item == thrown_entity)then
        local id = entity.GetVariable(thrown_entity, "arena_entity_id")

        if(id ~= nil)then
            --local body_ids = PhysicsBodyIDGetFromEntity( thrown_entity )
            --if(body_ids ~= nil and #body_ids > 0)then

            --print("Throwing item with id " .. tostring(id))

            local kicked_item_string = GlobalsGetValue("arena_items_controlled", "")

            kicked_item_string = kicked_item_string .. tostring(thrown_entity) .. ";"
    
            GlobalsSetValue("arena_items_controlled", kicked_item_string)

            GameAddFlagRun("was_item_throw")
            --end
        end
    end
end