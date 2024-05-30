local entity = GetUpdatedEntityID()

local inventory = EntityGetFirstComponentIncludingDisabled(entity, "Inventory2Component")

if inventory ~= nil then
    local held_item = ComponentGetValue2(inventory, "mActiveItem")

    if held_item ~= nil and held_item ~= 0 then
        -- surely this is sane.
        EntitySetComponentsWithTagEnabled(held_item, "enabled_in_world", false)
        EntitySetComponentsWithTagEnabled(held_item, "enabled_in_hand", false)
        EntitySetComponentsWithTagEnabled(held_item, "enabled_in_inventory", true)
    end
end