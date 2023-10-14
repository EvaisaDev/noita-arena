function item_pickup( entity_item, entity_pickupper, item_name )
    local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

    local id = entity.GetVariable(entity_item, "arena_entity_id")

    if(id ~= nil)then
        GamePrint("picked up item "..id.." by "..tostring(entity_pickupper))
        GlobalsSetValue("arena_item_pickup", tostring(id))
    end
end