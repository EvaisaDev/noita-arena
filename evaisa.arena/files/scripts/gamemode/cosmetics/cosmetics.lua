local player_helper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")

local cosmetic_dict = {}
for k, v in ipairs(cosmetics)do
    cosmetic_dict[v.id] = v
end

cosmetics_handler = {
    
    GetCosmetic = function(id)
        return cosmetic_dict[id]
    end,
    CosmeticCheckLimit = function(lobby, data, id)
        local v = cosmetic_dict[id]
        local player = player_helper.Get()
        if(player and v.type and cosmetic_types[v.type] ~= nil)then
            local type_data = cosmetic_types[v.type]
            local max_stack = type_data.max_stack
            if(max_stack ~= nil and max_stack > 0)then
                local count = 0
                for cosmetic_id, enabled in pairs(data.cosmetics)do
                    if(enabled)then
                        local cosmetic = cosmetic_dict[cosmetic_id]
                        if(cosmetic.type == type_data and cosmetic)then
                            count = count + 1
                        end
                    end
                end

                if(count < max_stack)then
                    return
                end

                -- start disabling cosmetics
                for cosmetic_id, enabled in pairs(data.cosmetics)do
                    if(enabled and cosmetic_id ~= id)then
                        local cosmetic = cosmetic_dict[cosmetic_id]
                        if(cosmetic.type == type_data and cosmetic)then
                            data.cosmetics[cosmetic_id] = false
                            count = count - 1
                            if(count <= max_stack)then
                                break
                            end
                        end
                    end
                end
            end
        end
    end,
    CosmeticValid = function(lobby, data, cosmetic, entity, is_client)
        return (not is_client and (cosmetic.try_force_enable ~= nil and cosmetic.try_force_enable(lobby, data))) or (is_client and entity and data.players[EntityGetName(entity)] ~= nil and data.players[EntityGetName(entity)].cosmetics[cosmetic.id])
    end,
    LoadCosmetic = function(lobby, data, cosmetic, entity, is_client)
        local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, is_client)
        if(entity and can_run)then
            if(cosmetic.sprite_sheet)then
                EntityAddComponent2(entity, "SpriteComponent", {
                    _tags="character",
                    alpha=1, 
                    image_file=cosmetic.sprite_sheet, 
                    next_rect_animation="", 
                    offset_x=6, 
                    offset_y=14, 
                    rect_animation="walk", 
                    z_index=0.6,
                })
            end
            if(cosmetic.hat_sprite)then
                local offset_x, offset_y = 0, 0
                if(cosmetic.hat_offset)then
                    offset_x = cosmetic.hat_offset.x or 0
                    offset_y = cosmetic.hat_offset.y or 0
                end
                local hat_entity = EntityCreateNew(cosmetic.id)
                EntityAddChild(entity, hat_entity)
                EntityAddComponent2(hat_entity, "SpriteComponent", {
                    _tags="character",
                    alpha=1, 
                    image_file=cosmetic.hat_sprite, 
                    next_rect_animation="", 
                    offset_x=offset_x, 
                    offset_y=offset_y, 
                    rect_animation="walk", 
                    z_index=0.4,
                })
                EntityAddComponent2(hat_entity, "InheritTransformComponent", {
                    parent_hotspot_tag="hat"
                })
            end
            if(cosmetic.on_load ~= nil)then
                cosmetic.on_load(lobby, data, entity)
            end
        end
    end,
    UnloadCosmetic = function(lobby, data, cosmetic, entity)
        if(entity)then
            if(cosmetic.sprite_sheet)then
                local sprite_components = EntityGetComponent(entity, "SpriteComponent") or {}
                for k, component in ipairs(sprite_components)do
                    if(ComponentGetValue(component, "image_file") == cosmetic.sprite_sheet)then
                        EntityRemoveComponent(entity, component)
                    end
                end
            end
            if(cosmetic.hat_sprite)then
                local children = EntityGetAllChildren(entity) or {}
                for k, child in ipairs(children)do
                    local name = EntityGetName(child)
                    if(name == cosmetic.id)then
                        EntityKill(child)
                        print("Killed child: "..name)
                    end
                end
            end
            if(cosmetic.on_unload ~= nil)then
                cosmetic.on_unload(lobby, data, entity)
            end
        end
    end,
    LoadClientCosmetics = function(lobby, data, entity)
        for k, cosmetic in ipairs(cosmetics)do
            if(entity ~= nil and EntityGetIsAlive(entity))then

                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, true)
                if(entity and can_run)then
                    cosmetics_handler.LoadCosmetic(lobby, data, cosmetic, entity, true)
                end
            end
        end
    end,
    LoadPlayerCosmetics = function(lobby, data, entity)
        for k, cosmetic in ipairs(cosmetics)do
            if(entity ~= nil and EntityGetIsAlive(entity))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, false)
                if(entity and can_run)then
                    cosmetics_handler.LoadCosmetic(lobby, data, cosmetic, entity, false)
                end
            end
        end
    end,
    ArenaUnlocked = function(lobby, data)
        for k, cosmetic in ipairs(cosmetics)do
            for id, p in pairs(data.players or {})do
                if(p.entity ~= nil and EntityGetIsAlive(p.entity))then
                    local entity = p.entity
                    local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, false)
                    if(entity and can_run)then
                        if(cosmetic.on_arena_unlocked ~= nil)then
                            cosmetic.on_arena_unlocked(lobby, data, entity)
                        end
                    end
                end
            end
            local player = player_helper.Get()
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, true)
                if(can_run)then
                    if(cosmetic.on_arena_unlocked ~= nil)then
                        cosmetic.on_arena_unlocked(lobby, data, player)
                    end
                end
            end
        end
    end,
    TryUnlock = function(lobby, data, cosmetic)
        local unlock_attempt = cosmetic.try_unlock(lobby, data)
        if(unlock_attempt and cosmetic.unlock_flag ~= nil and not GameHasFlagRun(cosmetic.unlock_flag))then
            GameAddFlagRun(cosmetic.unlock_flag)
        end
        return true
    end,
    Update = function(lobby, data)
        for k, cosmetic in ipairs(cosmetics)do
            if(GameGetFrameNum() % 60 == 0)then
                cosmetics_handler.TryUnlock(lobby, data, cosmetic)
            end

            for id, p in pairs(data.players or {})do
                if(p.entity ~= nil and EntityGetIsAlive(p.entity))then
                    local entity = p.entity
                    local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, false)
                    if(entity and can_run)then
                        if(cosmetic.on_update ~= nil)then
                            cosmetic.on_update(lobby, data, entity)
                        end
                    end
                end
            end
            local player = player_helper.Get()
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, true)
                if(can_run)then
                    if(cosmetic.on_update ~= nil)then
                        cosmetic.on_update(lobby, data, player)
                    end
                    if(not data.cosmetics[cosmetic.id])then
                        data.cosmetics[cosmetic.id] = true
                        cosmetics_handler.CosmeticCheckLimit(lobby, data, cosmetic.id)
                        cosmetics_handler.LoadCosmetic(lobby, data, cosmetic, player, false)
                    end
                elseif(not can_run and data.cosmetics[cosmetic.id])then
                    cosmetics_handler.UnloadCosmetic(lobby, data, cosmetic, player)
                    data.cosmetics[cosmetic.id] = nil
                end
            end
        end
    end,
}