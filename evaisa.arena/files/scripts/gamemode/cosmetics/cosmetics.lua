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
        if(v.type and cosmetic_types[v.type] ~= nil)then
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
                            if(player)then
                                cosmetics_handler.UnloadCosmetic(lobby, data, cosmetic, player)
                            end
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
    CosmeticsGetValidList = function(t, id)
        local v = cosmetic_dict[id]
        if(v.type and cosmetic_types[v.type] ~= nil)then
            print("Checking cosmetics for type: "..v.type.." id: "..id)
            local type_data = cosmetic_types[v.type]
            local max_stack = type_data.max_stack
            if(max_stack ~= nil and max_stack > 0)then
                local count = 0
                for _, cosmetic_id in ipairs(t)do
                    local cosmetic = cosmetic_dict[cosmetic_id]
                    if(cosmetic.type == v.type and cosmetic)then
                        count = count + 1
                        -- print type count
                        print(cosmetic.type.." count: "..count)
                    end
                end

                if(count < max_stack)then
                    return
                end

                -- start disabling cosmetics
                for i = #t, 1, -1 do
                    local cosmetic_id = t[i]
                    if(cosmetic_id ~= id)then
                        local cosmetic = cosmetic_dict[cosmetic_id]
                        if(cosmetic.type == v.type and cosmetic)then
                            -- remove from list
                            table.remove(t, i)
                            print("Removed: "..cosmetic_id)
                            
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
        -- load client cosmetics
        if (is_client and entity and data.players[EntityGetName(entity)] ~= nil and data.players[EntityGetName(entity)].cosmetics[cosmetic.id]) then
            return true
        end

        -- no clients beyond this point
        if(is_client)then
            return false
        end

        -- force enabled player cosmetics
        if ((not is_client and (cosmetic.try_force_enable ~= nil and cosmetic:try_force_enable(lobby, data)))) then
            return true
        end

        -- check if cosmetic is unlocked and enabled??
        if (cosmetics_handler.IsUnlocked(cosmetic) and data.cosmetics[cosmetic.id]) then
            return true
        end
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
            if(cosmetic.sprite)then
                local offset_x, offset_y = 0, 0
                if(cosmetic.sprite_offset)then
                    offset_x = cosmetic.sprite_offset.x or 0
                    offset_y = cosmetic.sprite_offset.y or 0
                end
                local hat_entity = EntityCreateNew(cosmetic.id)
                local hotspot = "hat"
                if(cosmetic.hotspot)then
                    hotspot = cosmetic.hotspot
                end
                EntityAddChild(entity, hat_entity)
                EntityAddComponent2(hat_entity, "SpriteComponent", {
                    _tags="character",
                    alpha=1, 
                    image_file=cosmetic.sprite, 
                    next_rect_animation="", 
                    offset_x=offset_x, 
                    offset_y=offset_y, 
                    z_index=0.4,
                })
                EntityAddComponent2(hat_entity, "SpriteAnimatorComponent")
                EntityAddComponent2(hat_entity, "InheritTransformComponent", {
                    parent_hotspot_tag=hotspot,
                    only_position=cosmetic.sprite_only_inherit_position or false,
                })
                if(cosmetic.sprite_scale)then
                    local x, y, r = EntityGetTransform(hat_entity)
                    EntitySetTransform(hat_entity, x, y, r, cosmetic.sprite_scale.x or 1, cosmetic.sprite_scale.y or 1)
                end
                if(cosmetic.sprite_rotation)then
                    local x, y, r = EntityGetTransform(hat_entity)
                    EntitySetTransform(hat_entity, x, y, cosmetic.sprite_rotation)
                end
            end
            if(cosmetic.on_load ~= nil)then
                cosmetic:on_load(lobby, data, entity)
            end
        end
    end,
    UnloadCosmetic = function(lobby, data, cosmetic, entity)
        -- stacktrace using debug.traceback()
        --local trace = debug.traceback()	
        --print("Unloading cosmetic: "..cosmetic.id.." trace: "..trace)
        
        if(entity)then
            if(cosmetic.sprite_sheet)then
                local sprite_components = EntityGetComponent(entity, "SpriteComponent") or {}
                for k, component in ipairs(sprite_components)do
                    if(ComponentGetValue(component, "image_file") == cosmetic.sprite_sheet)then
                        EntityRemoveComponent(entity, component)
                    end
                end
            end
            if(cosmetic.sprite)then
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
                cosmetic:on_unload(lobby, data, entity)
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
    UnloadClientCosmetics = function(lobby, data, user)
        for cosmetic_id, enabled in pairs(data.players[tostring(user)].cosmetics or {})do
            if(enabled)then
                local cosmetic = cosmetic_dict[cosmetic_id]
                if(cosmetic)then
                    cosmetics_handler.UnloadCosmetic(lobby, data, cosmetic, entity)
                    print ("Unloading cosmetic on client: "..cosmetic_id)
                    data.players[tostring(user)].cosmetics[cosmetic_id] = nil
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
    UnloadPlayerCosmetics = function(lobby, data, entity)
        for cosmetic_id, enabled in pairs(data.cosmetics or {})do
            if(enabled)then
                local cosmetic = cosmetic_dict[cosmetic_id]
                if(cosmetic)then
                    cosmetics_handler.UnloadCosmetic(lobby, data, cosmetic, entity)
                    data.cosmetics[cosmetic_id] = nil
                end
            end
        end
    end,
    ApplyCosmeticsList = function(lobby, data, player, cosmetics_list, is_client, user)

        

        if is_client then
            -- check if list matches current
            local current_list = {}
            for cosmetic_id, enabled in pairs(data.players[tostring(user)].cosmetics or {})do
                if(enabled)then
                    table.insert(current_list, cosmetic_id)
                end
            end
            local match = true

            if(#current_list ~= #cosmetics_list)then
                match = false
            end

            if(match)then
                for k, cosmetic_id in ipairs(cosmetics_list)do
                    if(cosmetic_id ~= current_list[k])then
                        match = false
                        break
                    end
                end
            end

            if(match)then
                return
            end


            cosmetics_handler.UnloadClientCosmetics(lobby, data, user)
        else

            -- check if list matches current
            local current_list = {}
            for cosmetic_id, enabled in pairs(data.cosmetics or {})do
                if(enabled)then
                    table.insert(current_list, cosmetic_id)
                end
            end
            local match = true

            if(#current_list ~= #cosmetics_list)then
                match = false
            end

            if(match)then
                for k, cosmetic_id in ipairs(cosmetics_list)do
                    if(cosmetic_id ~= current_list[k])then
                        match = false
                        break
                    end
                end
            end

            if(match)then
                return
            end

            cosmetics_handler.UnloadPlayerCosmetics(lobby, data, player)
        end
        
        for k, cosmetic_id in ipairs(cosmetics_list)do
            -- unload all cosmetics
            local cosmetic = cosmetic_dict[cosmetic_id]
            if(cosmetic)then
                if(not is_client)then
                    print("Applying cosmetic: "..cosmetic_id)
                    data.cosmetics[cosmetic_id] = true
                    cosmetics_handler.CosmeticCheckLimit(lobby, data, cosmetic_id)
                else
                    data.players[tostring(user)].cosmetics[cosmetic_id] = true
                end
                cosmetics_handler.LoadCosmetic(lobby, data, cosmetic, player, is_client)
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
                            cosmetic:on_arena_unlocked(lobby, data, entity)
                        end
                    end
                end
            end
            local player = player_helper.Get()
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, true)
                if(can_run)then
                    if(cosmetic.on_arena_unlocked ~= nil)then
                        cosmetic:on_arena_unlocked(lobby, data, player)
                    end
                end
            end
        end
    end,
    OnKill = function(lobby, data, player, target)
        for k, cosmetic in ipairs(cosmetics)do
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, true) or cosmetic.always_run_kill_func
                if(can_run)then
                    if(cosmetic.on_kill ~= nil)then
                        cosmetic:on_kill(lobby, data, player, target)
                    end
                end
            end
        end
    end,
    OnWin = function(lobby, data, player)
        for k, cosmetic in ipairs(cosmetics)do
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, true) or cosmetic.always_run_win_func
                if(can_run)then
                    if(cosmetic.on_win ~= nil)then
                        cosmetic:on_win(lobby, data, player)
                    end
                end
            end
        end
    end,
    TryUnlock = function(lobby, data, cosmetic)
        local unlock_flag = "cosmetic_unlocked_"..cosmetic.id
        if(cosmetic.unlocked_default or cosmetic.can_be_unlocked == false or HasFlagPersistent(unlock_flag))then
            return false
        end
        local unlock_attempt = cosmetic.unlocked_default or cosmetic:try_unlock(lobby, data)
        if(unlock_attempt and not HasFlagPersistent(unlock_flag))then
            AddFlagPersistent(unlock_flag)
        end
        return true
    end,
    IsUnlocked = function(cosmetic)
        local unlock_flag = "cosmetic_unlocked_"..cosmetic.id
        return cosmetic.unlocked_default or HasFlagPersistent(unlock_flag)
    end,
    Unlock = function(cosmetic_id)
        local unlock_flag = "cosmetic_unlocked_"..cosmetic_id
        AddFlagPersistent(unlock_flag)
    end,
    EnableCosmetic = function(lobby, data, cosmetic_id)
        local player = player_helper.Get()

        data.cosmetics[cosmetic_id] = true
        cosmetics_handler.CosmeticCheckLimit(lobby, data, cosmetic_id)
        if(player and EntityGetIsAlive(player))then
            cosmetics_handler.LoadCosmetic(lobby, data, cosmetic_dict[cosmetic_id], player, false)
        end
    end,
    Update = function(lobby, data)
        for k, cosmetic in ipairs(cosmetics)do
            if(GameGetFrameNum() % 60 == 0)then
                cosmetics_handler.TryUnlock(lobby, data, cosmetic)
            end

            for id, p in pairs(data.players or {})do
                if(p.entity ~= nil and EntityGetIsAlive(p.entity))then
                    local entity = p.entity
                    local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, entity, true)
                    if(entity and can_run)then
                        if(cosmetic.on_update ~= nil)then
                            cosmetic:on_update(lobby, data, entity)
                        end
                    end
                end
            end
            local player = player_helper.Get()
            if(player and EntityGetIsAlive(player))then
                local can_run = cosmetics_handler.CosmeticValid(lobby, data, cosmetic, player, false)
                if(can_run)then
                    if(cosmetic.on_update ~= nil)then
                        cosmetic:on_update(lobby, data, player)
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