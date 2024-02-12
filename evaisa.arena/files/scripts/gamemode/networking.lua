-- why is this all here

local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
local playerinfo = dofile("mods/evaisa.arena/files/scripts/gamemode/playerinfo.lua")
local healthbar = dofile("mods/evaisa.arena/files/scripts/utilities/health_bar.lua")
local tween = dofile("mods/evaisa.arena/lib/tween.lua")
local Vector = dofile("mods/evaisa.arena/lib/vector.lua")
local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
local smallfolk = dofile("mods/evaisa.arena/lib/smallfolk.lua")
dofile_once("data/scripts/perks/perk_list.lua")
local player_helper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
-- whatever ill just leave it
dofile("mods/evaisa.arena/lib/status_helper.lua")

local ffi = require("ffi")

-- Controls struct
ffi.cdef([[
#pragma pack(push, 1)
typedef struct A {
    float aim_x;
    float aim_y;
    float aimNormal_x;
    float aimNormal_y;
    float aimNonZero_x;
    float aimNonZero_y;
    float mouse_x;
    float mouse_y;
    float mouseRaw_x;
    float mouseRaw_y;
    float mouseRawPrev_x;
    float mouseRawPrev_y;
    float mouseDelta_x;
    float mouseDelta_y;
    bool kick:1;
    bool fire:1;
    bool fire2:1;
    bool action:1;
    bool throw:1;
    bool interact:1;
    bool left:1;
    bool right:1;
    bool up:1;
    bool down:1;
    bool jump:1;
    bool fly:1;
    bool leftClick:1;
    bool rightClick:1;
} Controls;
#pragma pack(pop)
]])

-- Zone Update Struct
ffi.cdef([[
#pragma pack(push, 1)
typedef struct B {
    float zone_size;
    float shrink_time;
} ZoneUpdate;
#pragma pack(pop)
]])

-- Physics Update
ffi.cdef([[
#pragma pack(push, 1)
typedef struct C {
    int id;
    float x;
    float y;
    float r;
    float vel_x;
    float vel_y;
    float vel_a;
    bool takes_control:1;
} PhysicsUpdate;
#pragma pack(pop)
]])

-- character pos
ffi.cdef([[
#pragma pack(push, 1)
typedef struct D {
    float x;
    float y;
    float vel_x;
    float vel_y;
} CharacterPos;
#pragma pack(pop)
]])


local Controls = ffi.typeof("Controls")
local ZoneUpdate = ffi.typeof("ZoneUpdate")
local PhysicsUpdate = ffi.typeof("PhysicsUpdate")
local CharacterPos = ffi.typeof("CharacterPos")



local function deserialize_damage_details(str)
    local ragdoll_fx, damage_types, knockback_force, impulse_x, impulse_y, world_pos_x, world_pos_y = str:match("(%d+)|(%d+)|([%d%.]+)|([%d%.%-]+)|([%d%.%-]+)|([%d%.%-]+)|([%d%.%-]+)")
    return {
        ragdoll_fx = tonumber(ragdoll_fx),
        damage_types = tonumber(damage_types),
        knockback_force = tonumber(knockback_force),
        impulse = {tonumber(impulse_x), tonumber(impulse_y)},
        world_pos = {tonumber(world_pos_x), tonumber(world_pos_y)}
    }
end

local pack_damage_details = function(details)
    if(details.impulse == nil)then
        return {}
    end

    local data = {
        details.ragdoll_fx,
        details.damage_types,
        details.knockback_force,
        details.blood_multiplier,
        details.impulse[1],
        details.impulse[2],
        details.world_pos[1],
        details.world_pos[2],
    }
    return data
end

local unpack_damage_details = function(data)
    if(data[1] == nil)then
        return nil
    end
    return {
        ragdoll_fx = data[1],
        damage_types = data[2],
        knockback_force = data[3],
        blood_multiplier = data[4],
        impulse = {data[5], data[6]},
        world_pos = {data[7], data[8]},
    }
end

local round_to_decimal = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

networking = {
    receive = {
        ready = function(lobby, message, user, data)
            local username = steamutils.getTranslatedPersonaName(user)

            if(GameHasFlagRun("lock_ready_state"))then
                data.players[tostring(user)].ready = true
                if (steamutils.IsOwner(lobby)) then
                    steam.matchmaking.setLobbyData(lobby, tostring(user) .. "_ready", "true")
                end
                return
            end

            if (message[1]) then
                data.players[tostring(user)].ready = true

                if (not message[2]) then
                    GamePrint(tostring(username) .. " is ready.")
                end

                if (steamutils.IsOwner(lobby)) then
                    arena_log:print(tostring(user) .. "_ready: " .. tostring(message[1]))
                    steam.matchmaking.setLobbyData(lobby, tostring(user) .. "_ready", "true")
                end
            else
                data.players[tostring(user)].ready = false

                if (not message[2]) then
                    GamePrint(tostring(username) .. " is no longer ready.")
                end

                if (steamutils.IsOwner(lobby)) then
                    steam.matchmaking.setLobbyData(lobby, tostring(user) .. "_ready", "false")
                end
            end
        end,
        allow_round_end = function(lobby, message, user, data)
            if(steamutils.IsOwner(lobby, user))then
                data.allow_round_end = true
                print("Allowing round to end.")
            end
        end,
        arena_loaded = function(lobby, message, user, data)
            local username = steamutils.getTranslatedPersonaName(user)

            data.players[tostring(user)].loaded = true

            GamePrint(username .. " has loaded the arena.")
            arena_log:print(username .. " has loaded the arena.")

            if (steamutils.IsOwner(lobby)) then
                steam.matchmaking.setLobbyData(lobby, tostring(user) .. "_loaded", "true")
            end
        end,
        enter_arena = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            if(data.ready_counter)then
                data.ready_counter:cleanup()
                data.ready_counter = nil
            end
            local arena = message[1]
            gameplay_handler.LoadArena(lobby, data, true, arena)
        end,
        start_countdown = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end

            GamePrint("Starting countdown...")

            arena_log:print("Received all clear for starting countdown.")

            data.players_loaded = true
            gameplay_handler.FightCountdown(lobby, data)
    
        end,
        sync_countdown = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            if(data.state == "arena" and data.countdown ~= nil)then
                data.countdown.frame = message[1]
                data.countdown.image_index = message[2]
            end
        end,
        unlock = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            RunWhenPlayerExists(function()
                if (GameHasFlagRun("Immortal") and not GameHasFlagRun("player_died") and data.state == "arena") then
                    --print("Received unlock message, attempting to unlock player.")

                    --player_helper.immortal(false)

                    
                    
                    GameRemoveFlagRun("Immortal")

                    gameplay_handler.AllowFiring(data)
                    --message_handler.send.RequestWandUpdate(lobby, data)
                    networking.send.request_item_update(lobby)
                    if (data.countdown ~= nil) then
                        data.countdown:cleanup()
                        data.countdown = nil
                    end
                end
            end)
        end,
        character_position = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

           
            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                --print("is spectator: " .. tostring(data.spectator_mode) .. "; is unlocked: " .. tostring(GameHasFlagRun("player_is_unlocked")) .. "; no shooting: " .. tostring(GameHasFlagRun("no_shooting")))

                local x, y = message.x, message.y

                local entity = data.players[tostring(user)].entity
                if (entity ~= nil and EntityGetIsAlive(entity)) then
                    local characterData = EntityGetFirstComponentIncludingDisabled(entity, "CharacterDataComponent")

                    ComponentSetValue2(characterData, "mVelocity", message.vel_x, message.vel_y)

                    if ((ModSettingGet("evaisa.arena.predictive_netcode") or false) == true) then
                        local delay = math.floor(data.players[tostring(user)].delay_frames / 2) or 0

                     
                        local last_position_x, last_position_y = nil, nil

                        for k, v in ipairs(data.players[tostring(user)].previous_positions)do
                            if(last_position_x == nil)then
                                last_position_x = x
                            else
                                last_position_x = last_position_x + v.x
                            end
                            if(last_position_y == nil)then
                                last_position_y = y
                            else
                                last_position_y = last_position_y + v.y
                            end
                        end



                        local new_x, new_y = x, y

                        if(last_position_x ~= nil and last_position_y ~= nil)then

                            last_position_x = last_position_x / #data.players[tostring(user)].previous_positions
                            last_position_y = last_position_y / #data.players[tostring(user)].previous_positions


                            -- calculate movement since last update
                            local additional_movement_x = x - last_position_x
                            local additional_movement_y = y - last_position_y

                            -- predict likely movement using delay
                            local predicted_movement_x = additional_movement_x * delay
                            local predicted_movement_y = additional_movement_y * delay

                            -- add predicted movement to current position
                            new_x = x + predicted_movement_x
                            new_y = y + predicted_movement_y

                            local hit, hit_x, hit_y = RaytracePlatforms(x, y, new_x, new_y)

                            if(hit)then
                                new_x = hit_x
                                new_y = hit_y
                            end

                        end

                        if(#data.players[tostring(user)].previous_positions >= 5)then
                            table.remove(data.players[tostring(user)].previous_positions, 1)
                        end
                        table.insert(data.players[tostring(user)].previous_positions, {x = x, y = y} )

                        EntitySetTransform(entity, new_x, new_y)
                        EntityApplyTransform(entity, new_x, new_y)
                        
                        --[[
                        EntitySetTransform(entity, x, y)
                        EntityApplyTransform(entity, x, y)
                        ]]
                    else
                        EntitySetTransform(entity, x, y)
                        EntityApplyTransform(entity, x, y)
                    end
                end
            end
        end,
        handshake = function(lobby, message, user, data)
            steamutils.sendToPlayer("handshake_confirmed", { message[1], message[2] }, user, true)
        end,
        handshake_confirmed = function(lobby, message, user, data)
            if (data.players[tostring(user)] ~= nil) then
                data.players[tostring(user)].ping = game_funcs.GetUnixTimeElapsed(game_funcs.StringToUint(message[2]),
                    game_funcs.GetUnixTimestamp())
                data.players[tostring(user)].delay_frames = GameGetFrameNum() - message[1]
            end
        end,
        wand_update = function(lobby, message, user, data)
            --GamePrint("Wand update!")

            -- LEGACY USE item_update INSTEAD

            --[[
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                local wand_string = message[2]
                local force = message[3]
                local unlimited_spells = message[4]

                local last_inventory_string = data.players[tostring(user)].last_inventory_string

                if (last_inventory_string == nil) then
                    last_inventory_string = ""
                end

                if (last_inventory_string ~= wand_string or force) then
                    if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                        if(unlimited_spells)then
                            EntityAddTag(data.players[tostring(user)].entity, "unlimited_spells")
                        end
                        local items = GameGetAllInventoryItems(data.players[tostring(user)].entity) or {}
                        for i, item_id in ipairs(items) do
                            GameKillInventoryItem(data.players[tostring(user)].entity, item_id)
                            EntityKill(item_id)
                        end
                    end

                    if (message[1] ~= nil) then
                        local username = steamutils.getTranslatedPersonaName(user)

                        arena_log:print("User [" ..
                            username .. "] received inventory: " .. tostring(json.stringify(message[1])))

                        for k, wandInfo in ipairs(message[1]) do
                            local x, y = EntityGetTransform(data.players[tostring(user)].entity)

                            local wand = EZWand(wandInfo.data, x, y)
                            if (wand == nil) then
                                return
                            end

                            wand:PickUp(data.players[tostring(user)].entity)


                            local wand_owner = EntityGetName(EntityGetRootEntity(wand.entity_id))

                            arena_log:print("Wand has been picked up by: [" ..
                                tostring(wand_owner) .. "] was supposed to be: [" .. tostring(user) .. "]")


                            local itemComp = EntityGetFirstComponentIncludingDisabled(wand.entity_id, "ItemComponent")
                            if (itemComp ~= nil) then
                                ComponentSetValue2(itemComp, "inventory_slot", wandInfo.slot_x, wandInfo.slot_y)
                            end

                            if (wandInfo.active) then
                                game_funcs.SetActiveHeldEntity(data.players[tostring(user)].entity, wand.entity_id, false,
                                    false)
                            end

                            GlobalsSetValue(tostring(wand.entity_id) .. "_wand", tostring(wandInfo.id))
                        end
                    end

                    data.players[tostring(user)].last_inventory_string = wand_string
                end
            end
            ]]
        end,
        item_update = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                local items_data = message[1]
                local force = message[2]
                local unlimited_spells = message[3]

                if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                    if(unlimited_spells)then
                        EntityAddTag(data.players[tostring(user)].entity, "unlimited_spells")
                    end
                    local items = GameGetAllInventoryItems(data.players[tostring(user)].entity) or {}
                    for i, item_id in ipairs(items) do
                        GameKillInventoryItem(data.players[tostring(user)].entity, item_id)
                        EntityKill(item_id)
                    end
                end

                if (items_data ~= nil) then
                    for k, itemInfo in ipairs(items_data) do
                        local x, y = EntityGetTransform(data.players[tostring(user)].entity)
                        local item = nil
                        if(itemInfo.is_wand)then
                            item = EZWand(itemInfo.data, x, y)
                            
                        else
                            item = EntityCreateNew()
                            np.DeserializeEntity(item, itemInfo.data, x, y)
            
                        end
            
                        if (item == nil) then
                            return
                        end
            
                        local item_entity = nil
                        if(itemInfo.is_wand)then
                            item:PickUp(data.players[tostring(user)].entity)
                            item_entity = item.entity_id
                        else
                            EntityHelper.PickItem(data.players[tostring(user)].entity, item)
                            item_entity = item
                        end
                        
                        local itemComp = EntityGetFirstComponentIncludingDisabled(item_entity, "ItemComponent")
                        if (itemComp ~= nil) then
                            ComponentSetValue2(itemComp, "inventory_slot", itemInfo.slot_x, itemInfo.slot_y)
                        end

                        if (itemInfo.active) then
                            game_funcs.SetActiveHeldEntity(data.players[tostring(user)].entity, item_entity, false,
                                false)
                        end

                        EntityHelper.SetVariable(item_entity, "arena_entity_id", itemInfo.id)

                        local lua_comps = EntityGetComponentIncludingDisabled(item_entity, "LuaComponent") or {}
                        local has_pickup_script = false
                        for i, lua_comp in ipairs(lua_comps) do
                            if (ComponentGetValue2(lua_comp, "script_item_picked_up") == "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua") then
                                has_pickup_script = true
                            end
                        end

                        if (not has_pickup_script) then
                            EntityAddTag(item_entity, "does_physics_update")
                            EntityAddComponent(item_entity, "LuaComponent", {
                                _tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
                                script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
                                script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
                                script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
                            })
                        end
                    end

                end
            end
        end,
        request_wand_update = function(lobby, message, user, data)
           --[[ if(data.spectator_mode)then
                return
            end
            data.client.previous_wand = nil
            networking.send.wand_update(lobby, data, user, true)
            networking.send.switch_item(lobby, data, user, true)
            ]]
        end,
        request_item_update = function(lobby, message, user, data)
            if(data.spectator_mode)then
                return
            end
            data.client.previous_wand = nil
            networking.send.item_update(lobby, data, user, true)
            networking.send.switch_item(lobby, data, user, true)
        end,
       
        input = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            -- check which inputs have changed
            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                if (data.players[tostring(user)] ~= nil and data.players[tostring(user)].entity ~= nil and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                    --print(json.stringify(message))
                    
                    local controls_data = data.players[tostring(user)].controls
                    local controlsComp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity, "ControlsComponent")

                    if(message.kick)then
                        ComponentSetValue2(controlsComp, "mButtonDownKick", true)
                        if (not controls_data.kick) then
                            ComponentSetValue2(controlsComp, "mButtonFrameKick", GameGetFrameNum() + 1)
                        end
                        controls_data.kick = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownKick", false)
                    end

                    if(message.fire)then
                        ComponentSetValue2(controlsComp, "mButtonDownFire", true)
                        if (not controls_data.fire) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFire", GameGetFrameNum()+1)
                        end
                        ComponentSetValue2(controlsComp, "mButtonLastFrameFire", GameGetFrameNum())
                        controls_data.fire = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFire", false)
                    end

                    if(message.fire2)then
                        ComponentSetValue2(controlsComp, "mButtonDownFire2", true)
                        if (not controls_data.fire2) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFire2", GameGetFrameNum()+1)
                        end
                        controls_data.fire2 = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFire2", false)
                    end

                    if(message.action)then
                        ComponentSetValue2(controlsComp, "mButtonDownAction", true)
                        if (not controls_data.action) then
                            ComponentSetValue2(controlsComp, "mButtonFrameAction", GameGetFrameNum() + 1)
                        end
                        controls_data.action = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownAction", false)
                    end

                    if(message.throw)then
                        ComponentSetValue2(controlsComp, "mButtonDownThrow", true)
                        if (not controls_data.throw) then
                            ComponentSetValue2(controlsComp, "mButtonFrameThrow", GameGetFrameNum() + 1)
                        end
                        controls_data.throw = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownThrow", false)
                    end

                    if(message.interact)then
                        ComponentSetValue2(controlsComp, "mButtonDownInteract", true)
                        if (not controls_data.interact) then
                            ComponentSetValue2(controlsComp, "mButtonFrameInteract", GameGetFrameNum() + 1)
                        end
                        controls_data.interact = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownInteract", false)
                    end

                    if(message.left)then
                        ComponentSetValue2(controlsComp, "mButtonDownLeft", true)
                        if (not controls_data.left) then
                            ComponentSetValue2(controlsComp, "mButtonFrameLeft", GameGetFrameNum() + 1)
                        end
                        controls_data.left = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownLeft", false)
                    end

                    if(message.right)then
                        ComponentSetValue2(controlsComp, "mButtonDownRight", true)
                        if (not controls_data.right) then
                            ComponentSetValue2(controlsComp, "mButtonFrameRight", GameGetFrameNum() + 1)
                        end
                        controls_data.right = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownRight", false)
                    end

                    if(message.up)then
                        ComponentSetValue2(controlsComp, "mButtonDownUp", true)
                        if (not controls_data.up) then
                            ComponentSetValue2(controlsComp, "mButtonFrameUp", GameGetFrameNum() + 1)
                        end
                        controls_data.up = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownUp", false)
                    end

                    if(message.down)then
                        ComponentSetValue2(controlsComp, "mButtonDownDown", true)
                        if (not controls_data.down) then
                            ComponentSetValue2(controlsComp, "mButtonFrameDown", GameGetFrameNum() + 1)
                        end
                        controls_data.down = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownDown", false)
                    end

                    if(message.jump)then
                        ComponentSetValue2(controlsComp, "mButtonDownJump", true)
                        if (not controls_data.jump) then
                            ComponentSetValue2(controlsComp, "mButtonFrameJump", GameGetFrameNum() + 1)
                        end
                        controls_data.jump = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownJump", false)
                    end

                    if(message.fly)then
                        ComponentSetValue2(controlsComp, "mButtonDownFly", true)
                        if (not controls_data.fly) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFly", GameGetFrameNum() + 1)
                        end
                        controls_data.fly = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFly", false)
                    end

                    if(message.leftClick)then
                        ComponentSetValue2(controlsComp, "mButtonDownLeftClick", true)
                        if (not controls_data.leftClick) then
                            ComponentSetValue2(controlsComp, "mButtonFrameLeftClick", GameGetFrameNum() + 1)
                        end
                        controls_data.leftClick = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownLeftClick", false)
                    end

                    if(message.rightClick)then
                        ComponentSetValue2(controlsComp, "mButtonDownRightClick", true)
                        if (not controls_data.rightClick) then
                            ComponentSetValue2(controlsComp, "mButtonFrameRightClick", GameGetFrameNum() + 1)
                        end
                        controls_data.rightClick = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownRightClick", false)
                    end

                    ComponentSetValue2(controlsComp, "mAimingVector", message.aim_x, message.aim_y)
                    ComponentSetValue2(controlsComp, "mAimingNormal", message.aimNormal_x, message.aimNormal_y)
                    ComponentSetValue2(controlsComp, "mAimingNonZero", message.aimNonZero_x, message.aimNonZero_y)
                    ComponentSetValue2(controlsComp, "mMousePos", message.mouse_x, message.mouse_y)
                    ComponentSetValue2(controlsComp, "mMousePosRaw", message.mouseRaw_x, message.mouseRaw_y)
                    ComponentSetValue2(controlsComp, "mMousePosRawPrev", message.mouseRawPrev_x, message.mouseRawPrev_y)
                    ComponentSetValue2(controlsComp, "mMouseDelta", message.mouseDelta_x, message.mouseDelta_y)


                    local children = EntityGetAllChildren(data.players[tostring(user)].entity) or {}
                    for i, child in ipairs(children) do
                        if (EntityGetName(child) == "cursor") then
                            EntitySetTransform(child, message.mouse_x, message.mouse_y)
                            EntityApplyTransform(child, message.mouse_x, message.mouse_y)
                        end
                    end

                end
            end
        end,
        animation_update = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            if (message[1] ~= nil and message[1] ~= "") then
                local entity = data.players[tostring(user)].entity
                if (entity ~= nil) then
                    local spriteComp = EntityGetFirstComponent(entity, "SpriteComponent", "character")
                    if (spriteComp ~= nil) then
                        local lastRect = ComponentGetValue2(spriteComp, "rect_animation")

                        if (lastRect == message[1]) then
                            return
                        end

                        GamePlayAnimation(entity, message[1], 1)
                    end
                end
            end
        end,
        switch_item = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            --GlobalsSetValue(tostring(wand.entity_id).."_wand", wandInfo.id)
            local is_wand, slot_x, slot_y = message[1], message[2], message[3]
           -- GamePrint("Switching item to slot: " .. tostring(slot_x) .. ", " .. tostring(slot_y))
            if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                local items = GameGetAllInventoryItems(data.players[tostring(user)].entity) or {}
                for i, item in ipairs(items) do
                    -- check id
                    --local item_id = tonumber(GlobalsGetValue(tostring(item) .. "_item")) or -1
                    local itemComp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
                    local item_slot_x, item_slot_y = ComponentGetValue2(itemComp, "inventory_slot")

                    local ability_comp = EntityGetFirstComponentIncludingDisabled(item, "AbilityComponent")
                    
                    local item_is_wand = false
                    if(ability_comp and ComponentGetValue2(ability_comp, "use_gun_script"))then
                        item_is_wand = true
                    end

                    if (item_slot_x == slot_x and item_slot_y == slot_y and item_is_wand == is_wand) then
                        local inventory2Comp = EntityGetFirstComponentIncludingDisabled(
                            data.players[tostring(user)].entity, "Inventory2Component")
                        local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                        if (mActiveItem ~= item) then
                            game_funcs.SetActiveHeldEntity(data.players[tostring(user)].entity, item, false, false)
                        end
                        return
                    end
                end
            end
        end,
        sync_wand_stats = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end
            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")

                    -- if no inventory2Comp, return
                    if (inventory2Comp == nil) then
                        return
                    end
                    
                    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                    if (mActiveItem ~= nil) then
                        --[[
                            local msg_data = {
                                mana,
                                GameGetFrameNum() - cast_delay_start_frame,
                                mReloadFramesLeft = reload_frames_left,
                                mReloadNextFrameUsable = reload_next_frame_usable - GameGetFrameNum(),
                                mNextChargeFrame = next_charge_frame - GameGetFrameNum(),
                            }
                        ]]

                        local children = EntityGetAllChildren(mActiveItem) or {}
                        for k, v in ipairs(children)do
                            if(EntityHasTag(v, "card_action"))then
                                --GamePrint("found card action")
                                local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                                if(item_comp ~= nil)then
                                    local slot = ComponentGetValue2(item_comp, "inventory_slot")
                                    -- ComponentSetValue2(item_comp, "uses_remaining", 1)
                                    --GamePrint("card in slot: " .. tostring(slot))
                                    --print("card in slot: " .. tostring(slot))
                                    if(message[6][tostring(slot)] ~= nil)then
                                        ComponentSetValue2(item_comp, "uses_remaining", message[6][tostring(slot)])
                                        --print("wand uses updated!")
                                    end
                                end
                            end
                        end

                        local mana = message[1]
                        local mCastDelayStartFrame = GameGetFrameNum() - message[2]
                        local mReloadFramesLeft = message[3]
                        local mReloadNextFrameUsable = message[4] + GameGetFrameNum()
                        local mNextChargeFrame = message[5] + GameGetFrameNum()

                        local abilityComp = EntityGetFirstComponentIncludingDisabled(mActiveItem, "AbilityComponent")
                        if (abilityComp ~= nil) then
                            ComponentSetValue2(abilityComp, "mana", mana)
                            ComponentSetValue2(abilityComp, "mCastDelayStartFrame", mCastDelayStartFrame)
                            ComponentSetValue2(abilityComp, "mReloadFramesLeft", mReloadFramesLeft)
                            ComponentSetValue2(abilityComp, "mReloadNextFrameUsable", mReloadNextFrameUsable)
                            ComponentSetValue2(abilityComp, "mNextChargeFrame", mNextChargeFrame)
                        end
                    end
                end
            end
        end,
        health_update = function(lobby, message, user, data)
            local health = message[1]
            local maxHealth = message[2]
            local damage_details = unpack_damage_details(message[3])

            if (health ~= nil and maxHealth ~= nil) then
                if (data.players[tostring(user)].entity ~= nil) then
                    local last_health = maxHealth
                    if (data.players[tostring(user)].health) then
                        last_health = data.players[tostring(user)].health
                    end
                    if (health < last_health) then
                        local damage = last_health - health

                        --[[
                            {
                                ragdoll_fx = 1 
                                damage_types = 16 -- bitflag
                                knockback_force = 0    
                                impulse = {0, 0},
                                world_pos = {216.21, 12.583},
                            }
                        ]]

                        if(damage_details ~= nil and damage_details.ragdoll_fx ~= nil)then
                            --print(json.stringify(damage_details))

                            local damage_types = mp_helpers.GetDamageTypes(damage_details.damage_types)
                            local ragdoll_fx = mp_helpers.GetRagdollFX(damage_details.ragdoll_fx)

                            --print("ragdoll_fx: " .. tostring(ragdoll_fx))

                            ragdoll_fx = ragdoll_fx or "NORMAL"

                            if(damage_details.smash_explosion)then  
                                EntityLoad("mods/evaisa.arena/files/entities/misc/smash_explosion.xml", damage_details.explosion_x, damage_details.explosion_y)
                            end

                            -- split the damage into as many parts as there are damage types
                            local damage_per_type = damage / #damage_types

                            local blood_multiplier = damage_details.blood_multiplier

                            local damage_model_comp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity, "DamageModelComponent")

                            if(damage_model_comp == nil)then
                                return
                            end

                            local old_blood_multiplier = ComponentGetValue2(damage_model_comp, "blood_multiplier")
                            ComponentSetValue2(damage_model_comp, "blood_multiplier", blood_multiplier)
                            for i, damage_type in ipairs(damage_types) do
                                EntityInflictDamage(data.players[tostring(user)].entity, damage_per_type, damage_type, "damage_fake",
                                ragdoll_fx, damage_details.impulse[1], damage_details.impulse[2], EntityGetWithName("dummy_damage"), damage_details.world_pos[1], damage_details.world_pos[2], damage_details.knockback_force)
                            end
                            if(old_blood_multiplier ~= nil)then
                                ComponentSetValue2(damage_model_comp, "blood_multiplier", old_blood_multiplier)
                            end
                        else
                            EntityInflictDamage(data.players[tostring(user)].entity, damage, "DAMAGE_DROWNING", "damage_fake",
                            "NONE", 0, 0, EntityGetWithName("dummy_damage"))
                        end

                    end

                    local DamageModelComp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity,
                        "DamageModelComponent")

                    if (DamageModelComp ~= nil) then
                        ComponentSetValue2(DamageModelComp, "max_hp", maxHealth)
                        if(health <= 0)then
                            health = 0.04
                        end
                        --print("hp set to: " .. tostring(health))
                        ComponentSetValue2(DamageModelComp, "hp", health)
                    end


                    if (data.players[tostring(user)].hp_bar) then
                        data.players[tostring(user)].hp_bar:setHealth(health, maxHealth)
                    else
                        local hp_bar = healthbar.create(health, maxHealth, 18, 2)
                        data.players[tostring(user)].hp_bar = hp_bar
                    end
                end

                data.players[tostring(user)].health = health
                data.players[tostring(user)].max_health = maxHealth
            end
        end,
        perk_update = function(lobby, message, user, data)
           -- arena_log:print("Received perk update!!")
            --arena_log:print(json.stringify(message[1]))
            data.players[tostring(user)].perks = message[1]
        end,
        fire_wand = function(lobby, message, user, data)
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))) and data.players[tostring(user)].entity ~= nil and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                data.players[tostring(user)].can_fire = true

                GlobalsSetValue("shooter_rng_" .. tostring(user), tostring(message[5]))
                
                GlobalsSetValue("action_rng_"..tostring(user), tostring(message[6] or 0))


                data.players[tostring(user)].projectile_rng_stack = message[4]

                local controlsComp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity,
                    "ControlsComponent")

                if (controlsComp ~= nil) then
                    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity,
                        "Inventory2Component")

                    if (inventory2Comp == nil) then
                        return
                    end

                    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                    if (mActiveItem ~= nil) then
                        local aimNormal_x, aimNormal_y = ComponentGetValue2(controlsComp, "mAimingVectorNormalized")
                        local aim_x, aim_y = ComponentGetValue2(controlsComp, "mAimingVector")

                        local wand_x, wand_y, wand_r = message[1], message[2], message[3]

                        EntitySetTransform(mActiveItem, wand_x, wand_y, wand_r)
                        EntityApplyTransform(mActiveItem, wand_x, wand_y, wand_r)

                        local x = wand_x + (aimNormal_x * 2)
                        local y = wand_y + (aimNormal_y * 2)
                        y = y - 1

                        local target_x = x + aim_x
                        local target_y = y + aim_y

                        EntityHelper.BlockFiring(data.players[tostring(user)].entity, false)


                        --print("Firing wand at " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(r))

                        EntityAddTag(data.players[tostring(user)].entity, "player_unit")
                        np.UseItem(data.players[tostring(user)].entity, mActiveItem, true, true, true, x, y, target_x,
                            target_y)
                        EntityRemoveTag(data.players[tostring(user)].entity, "player_unit")

                        EntityHelper.BlockFiring(data.players[tostring(user)].entity, true)
                    end
                end
            end
        end,
        death = function(lobby, message, user, data)
            if (data.state == "arena") then
                local username = steamutils.getTranslatedPersonaName(user)

                local killer = message[1]
                -- iterate data.tweens backwards and remove tweens belonging to the dead player
                for i = #data.tweens, 1, -1 do
                    local tween = data.tweens[i]
                    if (tween.id == tostring(user)) then
                        table.remove(data.tweens, i)
                    end
                end

                local damage_details = message[2]
                --print(json.stringify(killer))

                data.players[tostring(user)]:Death(damage_details)
                data.players[tostring(user)].alive = false
                data.deaths = data.deaths + 1

                if (killer == nil) then
                    GamePrint(tostring(username) .. " died.")
                else
                    local killer_id = gameplay_handler.FindUser(lobby, killer)
                    if (killer_id ~= nil) then
                        GamePrint(tostring(username) ..
                            " was killed by " .. steamutils.getTranslatedPersonaName(killer_id))
                    else
                        GamePrint(tostring(username) .. " died.")
                    end
                end
                if(data.spectator_mode)then
                    spectator_handler.WinnerCheck(lobby, data)
                else
                    gameplay_handler.WinnerCheck(lobby, data)
                end

            end
        end,
        zone_update = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end

            GlobalsSetValue("arena_area_size", tostring(message.zone_size))
            GlobalsSetValue("arena_area_size_cap", tostring(message.zone_size + 200))
            data.zone_size = message.zone_size
            data.shrink_time = message.shrink_time
        end,
        request_perk_update = function(lobby, message, user, data)
            if(data.spectator_mode)then
                return
            end
            arena_log:print("Attempting to send perk update")
            local perk_info = {}
            for i, perk_data in ipairs(perk_list) do
                local perk_id = perk_data.id
                local flag_name = get_perk_picked_flag_name(perk_id)

                local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

                if GameHasFlagRun(flag_name) and (pickup_count > 0) then
                    --print("Has flag: " .. perk_id)
                    table.insert(perk_info, { perk_id, pickup_count })
                end
            end

            --if (#perk_info > 0) then
                local message_data = { perk_info }

                arena_log:print("Replied to perk requests!")
                steamutils.sendToPlayer("perk_update", message_data, user, true)
            --end
        end,
        player_data_update = function(lobby, message, user, data)
            --[[
                template:
                local message = {
                    mFlyingTimeLeft = ComponentGetValue2(character_data_comp, "mFlyingTimeLeft"),
                }

            ]]
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked")) and data.players[tostring(user)].entity ~= nil and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                local player = data.players[tostring(user)].entity
                local character_data_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                if (character_data_comp ~= nil) then
                    local player_data = {
                        mFlyingTimeLeft = message[1],
                        status_list = message[2],
                        cosmetics = message[3],
                    }

                    local loaded_cosmetics = {}
                    for _, id in ipairs(player_data.cosmetics)do
                        loaded_cosmetics[id] = true
                        if(not data.players[tostring(user)].cosmetics[id])then
                            -- add cosmetic
                            data.players[tostring(user)].cosmetics[id] = true
                            if(player)then
                                print("Loading client cosmetic: " .. tostring(id))
                                ArenaGameplay.UpdateCosmetics(lobby, data, "load", player, true)
                            end
                        end
                    end

                    for k, v in pairs(data.players[tostring(user)].cosmetics)do
                        if(not loaded_cosmetics[k])then
                            -- remove cosmetic
                            data.players[tostring(user)].cosmetics[k] = nil
                            if(player)then
                                ArenaGameplay.UpdateCosmetics(lobby, data, "unload", player, true)
                            end
                        end
                    end


                    local valid_ids = {}

                    local index = 0
                    local total = 0

                    for _, _ in pairs(player_data.status_list) do
                        total = total + 1
                    end

                    local initial_offset = -((total * 8) / 2) + (total * 0.75)

                    --GamePrint(initial_offset)

                    for id, value in pairs(player_data.status_list) do
                        index = index + 1
                        local offset = initial_offset + (index * 8)

                        local effect = GetStatusElement(id, value)

                        --[[if(effect ~= nil and data.players[tostring(user)].status_effect_comps[id] == nil)then
                            data.players[tostring(user)].status_effect_comps[id] = EntityAddComponent2( player, "SpriteComponent",
                            {
                                image_file = effect.ui_icon,
                                offset_x = offset,
                                offset_y = 35,
                                additive = false,
                            })
                            
                            --GamePrint("Loaded icon of id: "..tostring(effect.id))
                        elseif(data.players[tostring(user)].status_effect_comps[id] ~= nil)then
                            local comp = data.players[tostring(user)].status_effect_comps[id]
                            ComponentSetValue2(comp, "offset_x", offset)
                        end]]

                        if(effect ~= nil and data.players[tostring(user)].status_effect_entities[id] == nil)then
                            if(effect.effect_entity)then
                                data.players[tostring(user)].status_effect_entities[id] = LoadGameEffectEntityTo( player, effect.effect_entity )
                                --GamePrint("Loaded effect of id: "..tostring(effect.id))
                            else
                                data.players[tostring(user)].status_effect_entities[id] = EntityCreateNew("effect")
                                EntityAddComponent2(data.players[tostring(user)].status_effect_entities[id], "InheritTransformComponent")
                                EntityAddComponent2(data.players[tostring(user)].status_effect_entities[id], "GameEffectComponent", {
                                    effect = id,
                                    frames = -1,
                                })
                                EntityAddChild(player, data.players[tostring(user)].status_effect_entities[id])
                            end
                            EntityAddComponent2(data.players[tostring(user)].status_effect_entities[id], "UIIconComponent", {
                                name = effect.ui_name,
                                icon_sprite_file = effect.ui_icon,
                                display_above_head = true,
                                display_in_hud = false,
                                is_perk = false,
                            })
                        end

                        valid_ids[id] = true
                    end

                    for k, v in pairs(data.players[tostring(user)].status_effect_entities)do
                        if(not valid_ids[k] or not EntityGetIsAlive(data.players[tostring(user)].status_effect_entities[k]))then
                            EntityKill(data.players[tostring(user)].status_effect_entities[k])
                            data.players[tostring(user)].status_effect_entities[k] = nil
                        end
                    end

                    ComponentSetValue2(character_data_comp, "mFlyingTimeLeft", player_data.mFlyingTimeLeft)
                end
            end
        end,
        lock_ready_state = function(lobby, message, user, data)
            -- check if user is lobby owner
            if (not steamutils.IsOwner(lobby, user)) then
                return
            end
            
            -- kill any entity with workshop tag to prevent wand edits
            local all_entities = EntityGetWithTag("workshop")
            for k, v in pairs(all_entities) do
                EntityKill(v)
            end
            GameAddFlagRun("lock_ready_state")
            GameAddFlagRun("player_ready")
            GameAddFlagRun("ready_check")
            GameRemoveFlagRun("player_unready")
        end,
        request_spectate_data = function(lobby, message, user, data)
           networking.send.spectate_data(lobby, data, user, true)
        end,
        spectate_data = function(lobby, message, user, data)
            local spectator_simulated = EntityGetWithTag("spectator_simulated")
            if(spectator_simulated ~= nil)then
                for _, spectator in ipairs(spectator_simulated) do
                    EntityKill(spectator)
                end
            end

            if(message.heart)then
                local heart = EntityLoad("data/entities/animals/heart.xml", message.heart[1], message.heart[2])
                EntityAddTag(heart, "spectator_simulated")
            end
        end,
        item_picked_up = function(lobby, message, user, data)
            --GamePrint("pickup received.")
            local entities = EntityGetInRadius(0, 0, 1000000000)
            local item_id = message[1]
            for k, v in ipairs(entities)do
                if(EntityGetFirstComponentIncludingDisabled(v, "ItemComponent") ~= nil)then
                    local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                    if(entity_id ~= nil and entity_id == item_id)then
                        EntityKill(v)
                        return
                    end
                end
            end
        end,
        physics_update = function(lobby, message, user, data)
            local entities = EntityGetInRadiusWithTag(0, 0, 1000000000, "does_physics_update")
            local item_id = message.id
            local x, y, r, vx, vy, vr = message.x, message.y, message.r, message.vx, message.vy, message.vr
            local takes_control = message.takes_control
            for k, v in ipairs(entities)do
                --if(EntityGetFirstComponentIncludingDisabled(v, "ItemComponent") ~= nil)then
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id)then
                    
                    if(takes_control)then
                        for i = #data.controlled_physics_entities, 1, -1 do
                            if(data.controlled_physics_entities[i] == v)then
                                table.remove(data.controlled_physics_entities, i)

                                --GamePrint("No longer in control")

                            end
                        end
                    end

                    local body_ids = PhysicsBodyIDGetFromEntity( v )
                    if(body_ids ~= nil and #body_ids > 0)then
                        local body_id = body_ids[1]

                        PhysicsBodyIDSetTransform(body_id, x, y, r, vx, vy, vr)
                        
                    end
                    return
                end
            end
           -- end
        end,
        fungal_shift = function(lobby, message, user, data)
            dofile_once("data/scripts/lib/utilities.lua")

            

            local from_materials = message[1]
            local to_mat = message[2]

            local iter = tonumber( GlobalsGetValue( "fungal_shift_iteration", "0" ) )
            GlobalsSetValue( "fungal_shift_iteration", tostring(iter+1) )
            if iter > 20 then
                return
            end
            local frame = GameGetFrameNum()

            SetRandomSeed( 89346, 42345+iter )

            local converted_any = false
        
            local rnd = random_create(9123,58925+iter ) -- TODO: store for next change
            local from_material_name = nil
            
            for i,it in ipairs(from_materials) do
                local from_material = CellFactory_GetType( it )
                local to_material = CellFactory_GetType( to_mat )
                
                from_material_name = string.upper( GameTextGetTranslatedOrNot( CellFactory_GetUIName( from_material ) ) )
               
                -- convert
                if from_material ~= to_material then
                    print(CellFactory_GetUIName(from_material) .. " -> " .. CellFactory_GetUIName(to_material))
                    ConvertMaterialEverywhere( from_material, to_material )
                    converted_any = true
        
                    local player_entity = player.Get()
                    if (player_entity) then
                        local x, y = EntityGetTransform(player_entity)
                        -- shoot particles of new material
                        GameCreateParticle( CellFactory_GetName(from_material), x-10, y-10, 20, Random(-100,100), Random(-100,-30), true, true )
                        GameCreateParticle( CellFactory_GetName(from_material), x+10, y-10, 20, Random(-100,100), Random(-100,-30), true, true )
                    end
                end
            end

            local log_messages = 
            {
                "$log_reality_mutation_00",
                "$log_reality_mutation_01",
                "$log_reality_mutation_02",
                "$log_reality_mutation_03",
                "$log_reality_mutation_04",
                "$log_reality_mutation_05",
            }
            

            if converted_any then
                -- remove tripping effect
                EntityRemoveIngestionStatusEffect( entity, "TRIP" );
        
                local x, y = GameGetCameraPos()

                -- audio
                GameTriggerMusicFadeOutAndDequeueAll( 5.0 )
                GameTriggerMusicEvent( "music/oneshot/tripping_balls_01", false, x, y )
        
                -- particle fx
                local eye = EntityLoad( "data/entities/particles/treble_eye.xml", x,y-10 )
                if eye ~= 0 then
                    EntityAddChild( entity, eye )
                end
        
                -- log
                local log_msg = ""
                if from_material_name ~= "" then
                    log_msg = GameTextGet( "$logdesc_reality_mutation", from_material_name )
                    GamePrint( log_msg )
                end
                GamePrintImportant( random_from_array( log_messages ), log_msg, "data/ui_gfx/decorations/3piece_fungal_shift.png" )
                GlobalsSetValue( "fungal_shift_last_frame", tostring(frame) )
        
                -- add ui icon
                local add_icon = true
                local children = EntityGetAllChildren(entity)
                if children ~= nil then
                    for i,it in ipairs(children) do
                        if ( EntityGetName(it) == "fungal_shift_ui_icon" ) then
                            add_icon = false
                            break
                        end
                    end
                end
        
                if add_icon then
                    local icon_entity = EntityCreateNew( "fungal_shift_ui_icon" )
                    EntityAddComponent( icon_entity, "UIIconComponent", 
                    { 
                        name = "$status_reality_mutation",
                        description = "$statusdesc_reality_mutation",
                        icon_sprite_file = "data/ui_gfx/status_indicators/fungal_shift.png"
                    })
                    EntityAddChild( entity, icon_entity )
                end
            end
        end,
        start_map_vote = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            GamePrint("starting map vote")
            gameplay_handler.StartMapVote(lobby, data, message[1])
        end,
        add_vote = function(lobby, message, user, data)

            if data.vote_loop and data.vote_loop.vote_finished then
                return
            end

            GamePlaySound( "data/audio/Desktop/ui.bank", "ui/streaming_integration/new_vote", GameGetCameraPos() )
            local map = message[1]
            if data.map_vote == nil then
                data.map_vote = {}
            end

            if data.map_vote[map] == nil then
                data.map_vote[map] = 0
            end
            
            data.map_vote[map] = data.map_vote[map] + 1

            if(data.voters ~= nil)then
                if(data.voters[tostring(user)])then
                    local vote = data.voters[tostring(user)]
                    if(vote ~= nil)then
                        if(data.map_vote[vote] ~= nil)then
                            data.map_vote[vote] = data.map_vote[vote] - 1
                        end
                    end
                end
                
                data.voters[tostring(user)] = map
            end

        end,
        map_vote_timer_update = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            local frames = message[1]
            if(data.vote_loop ~= nil)then
                data.vote_loop.frames = frames
            end
        end,
        map_vote_finish = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            if(data.vote_loop ~= nil)then
                data.vote_loop.vote_finished = true
                data.vote_loop.winner = message[1]
                data.vote_loop.was_tie = message[2]
            end
        end,
        load_lobby = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            ArenaGameplay.LoadLobby(lobby, data, false)
        end,
        update_round = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            GlobalsSetValue("holyMountainCount", tostring(message[1]))
        end,
        update_world_seed = function(lobby, message, user, data)
            if (not steamutils.IsOwner(lobby, user))then
                return
            end
            SetWorldSeed( message[1] )
        end,
    },
    send = {
        handshake = function(lobby)
            steamutils.send("handshake", { GameGetFrameNum(), (game_funcs.UintToString(game_funcs.GetUnixTimestamp())) },
                steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        request_perk_update = function(lobby)
            arena_log:print("Requesting perk update")
            steamutils.send("request_perk_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
        end,
        ready = function(lobby, is_ready, silent)
            silent = silent or false
            steamutils.send("ready", { is_ready, silent }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        arena_loaded = function(lobby)
            steamutils.send("arena_loaded", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        enter_arena = function(lobby, arena)
            steamutils.send("enter_arena", {arena}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        start_countdown = function(lobby)
            steamutils.send("start_countdown", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        sync_countdown = function(lobby, frames, index)
            steamutils.send("sync_countdown", {frames, index}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        unlock = function(lobby)
            steamutils.send("unlock", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
        end,
        character_position = function(lobby, data, to_spectators)
            local player = player.Get()
            if (player) then
                local x, y = EntityGetTransform(player)
                local characterData = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                local vel_x, vel_y = ComponentGetValue2(characterData, "mVelocity")

                local c = CharacterPos{
                    x = x,
                    y = y,
                    vx = vel_x,
                    vy = vel_y,
                }

                if(to_spectators)then
                    steamutils.send("character_position", c, steamutils.messageTypes.Spectators, lobby, false, true)
                else
                    steamutils.send("character_position", c, steamutils.messageTypes.OtherPlayers, lobby, false, true)
                end

            end
        end,
        wand_update = function(lobby, data, user, force, to_spectators)

            -- LEGACY, USE item_update INSTEAD

            --[[local wandString = player.GetWandString()
            if (wandString ~= nil) then
                if (force or (wandString ~= data.client.previous_wand)) then
                    local wandData = player.GetWandData()
                    if (wandData ~= nil) then
                        --GamePrint("Sending wand data to player")
                        local data = { wandData, wandString, force, GameHasFlagRun( "arena_unlimited_spells" ) }

                        if (user ~= nil) then
                            --steamutils.sendDataToPlayer({type = "wand_update", wandData = wandData}, user)
                            steamutils.sendToPlayer("wand_update", data, user, true)
                        else
                            --steamutils.sendData({type = "wand_update", wandData = wandData}, steamutils.messageTypes.OtherPlayers, lobby)
                            if(to_spectators)then
                                steamutils.send("wand_update", data, steamutils.messageTypes.Spectators, lobby, true, true)
                            else
                                steamutils.send("wand_update", data, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                            end
                        end
                    end
                    data.client.previous_wand = wandString
                end
            else
                if (force or (data.client.previous_wand ~= nil)) then
                    if (user ~= nil) then
                        --steamutils.sendDataToPlayer({type = "wand_update"}, user)
                        steamutils.sendToPlayer("wand_update", {}, user, true)
                    else
                        --steamutils.sendData({type = "wand_update"}, steamutils.messageTypes.OtherPlayers, lobby)

                        if(to_spectators)then
                            steamutils.send("wand_update", {}, steamutils.messageTypes.Spectators, lobby, true, true)
                        else
                            steamutils.send("wand_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                        end
                    end
                    data.client.previous_wand = nil
                end
            end]]
        end,
        item_update = function(lobby, data, user, force, to_spectators)

            local playerEnt = player.Get()
            if (playerEnt == nil) then
                return;
            end

            local item_data = player.GetItemData()
            if(item_data ~= nil)then
                local data = { item_data, force, GameHasFlagRun( "arena_unlimited_spells" ) }

                
                if (user ~= nil) then
                    steamutils.sendToPlayer("item_update", data, user, true)
                else
                    if(to_spectators)then
                        steamutils.send("item_update", data, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("item_update", data, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end
                end
            else
                if (user ~= nil) then
                    steamutils.sendToPlayer("item_update", {}, user, true)
                else
                    if(to_spectators)then
                        steamutils.send("item_update", {}, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("item_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end
                end
            end
        end,
        request_wand_update = function(lobby, user)
            -- LEGACY USE request_item_update INSTEAD

            --[[if(user == nil)then
                steamutils.send("request_wand_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            else
                steamutils.sendToPlayer("request_wand_update", {}, user, true)
            end]]
        end,
        request_item_update = function(lobby, user)
            if(user == nil)then
                steamutils.send("request_item_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            else
                steamutils.sendToPlayer("request_item_update", {}, user, true)
            end
        end,
        input = function(lobby, data, to_spectators)
            local controls = player.GetControlsComponent()
            if (controls ~= nil) then
                local kick = ComponentGetValue2(controls, "mButtonDownKick") -- boolean
                local fire = ComponentGetValue2(controls, "mButtonDownFire")  -- boolean
                local fire2 = ComponentGetValue2(controls, "mButtonDownFire2")  -- boolean
                local action = ComponentGetValue2(controls, "mButtonDownAction") -- boolean
                local throw = ComponentGetValue2(controls, "mButtonDownThrow") -- boolean
                local interact = ComponentGetValue2(controls, "mButtonDownInteract") -- boolean
                local left = ComponentGetValue2(controls, "mButtonDownLeft") -- boolean
                local right = ComponentGetValue2(controls, "mButtonDownRight") -- boolean
                local up = ComponentGetValue2(controls, "mButtonDownUp") -- boolean
                local down = ComponentGetValue2(controls, "mButtonDownDown") -- boolean
                local jump = ComponentGetValue2(controls, "mButtonDownJump") -- boolean
                local fly = ComponentGetValue2(controls, "mButtonDownFly") -- boolean
                local leftClick = ComponentGetValue2(controls, "mButtonDownLeftClick") -- boolean
                local rightClick = ComponentGetValue2(controls, "mButtonDownRightClick") -- boolean
                local aim_x, aim_y = ComponentGetValue2(controls, "mAimingVector") -- float, float
                local aimNormal_x, aimNormal_y = ComponentGetValue2(controls, "mAimingVectorNormalized") -- float, float
                local aimNonZero_x, aimNonZero_y = ComponentGetValue2(controls, "mAimingVectorNonZeroLatest") -- float, float
                local mouse_x, mouse_y = ComponentGetValue2(controls, "mMousePosition") -- float, float
                local mouseRaw_x, mouseRaw_y = ComponentGetValue2(controls, "mMousePositionRaw") -- float, float
                local mouseRawPrev_x, mouseRawPrev_y = ComponentGetValue2(controls, "mMousePositionRawPrev") -- float, float
                local mouseDelta_x, mouseDelta_y = ComponentGetValue2(controls, "mMouseDelta") -- float, float

                local c = Controls{
                    kick = kick,
                    fire = fire,
                    fire2 = fire2,
                    action = action,
                    throw = throw,
                    interact = interact,
                    left = left,
                    right = right,
                    up = up,
                    down = down,
                    jump = jump,
                    fly = fly,
                    leftClick = leftClick,
                    rightClick = rightClick,
                    aim_x = aim_x,
                    aim_y = aim_y,
                    aimNormal_x = aimNormal_x,
                    aimNormal_y = aimNormal_y,
                    aimNonZero_x = aimNonZero_x,
                    aimNonZero_y = aimNonZero_y,
                    mouse_x = mouse_x,
                    mouse_y = mouse_y,
                    mouseRaw_x = mouseRaw_x,
                    mouseRaw_y = mouseRaw_y,
                    mouseRawPrev_x = mouseRawPrev_x,
                    mouseRawPrev_y = mouseRawPrev_y,
                    mouseDelta_x = mouseDelta_x,
                    mouseDelta_y = mouseDelta_y,
                }

                if(to_spectators)then
                    steamutils.send("input", c, steamutils.messageTypes.Spectators, lobby, false, true)
                else
                    steamutils.send("input", c, steamutils.messageTypes.OtherPlayers, lobby, false, true)
                end

                --[[
                local inputs = {
                    kick = kick,
                    fire = fire,
                    fire2 = fire2,
                    action = action,
                    throw = throw,
                    interact = interact,
                    left = left,
                    right = right,
                    up = up,
                    down = down,
                    jump = jump,
                    fly = fly,
                    leftClick = leftClick,
                    rightClick = rightClick,
                    aim_x = round_to_decimal(aim_x, 2),
                    aim_y = round_to_decimal(aim_y, 2),
                    aimNormal_x = round_to_decimal(aimNormal_x, 2),
                    aimNormal_y = round_to_decimal(aimNormal_y, 2),
                    aimNonZero_x = round_to_decimal(aimNonZero_x, 2),
                    aimNonZero_y = round_to_decimal(aimNonZero_y, 2),
                    mouse_x = round_to_decimal(mouse_x, 2),
                    mouse_y = round_to_decimal(mouse_y, 2),
                    mouseRaw_x = round_to_decimal(mouseRaw_x, 2),
                    mouseRaw_y = round_to_decimal(mouseRaw_y, 2),
                    mouseRawPrev_x = round_to_decimal(mouseRawPrev_x, 2),
                    mouseRawPrev_y = round_to_decimal(mouseRawPrev_y, 2),
                    mouseDelta_x = round_to_decimal(mouseDelta_x, 2),
                    mouseDelta_y = round_to_decimal(mouseDelta_y, 2),
                }

                local input_map = {
                    kick = 1,
                    fire = 2,
                    fire2 = 3,
                    action = 4,
                    throw = 5,
                    interact = 6,
                    left = 7,
                    right = 8,
                    up = 9,
                    down = 10,
                    jump = 11,
                    fly = 12,
                    leftClick = 13,
                    rightClick = 14,
                    aim_x = 15,
                    aim_y = 16,
                    aimNormal_x = 17,
                    aimNormal_y = 18,
                    aimNonZero_x = 19,
                    aimNonZero_y = 20,
                    mouse_x = 21,
                    mouse_y = 22,
                    mouseRaw_x = 23,
                    mouseRaw_y = 24,
                    mouseRawPrev_x = 25,
                    mouseRawPrev_y = 26,
                    mouseDelta_x = 27,
                    mouseDelta_y = 28,
                }
                if(data.client.previous_input == nil)then
                    data.client.previous_input = {}
                end

                local changed_inputs = {}
                for k, v in pairs(input_map)do

                    if(data.client.previous_input[k] ~= nil)then
                        if(data.client.previous_input[k] ~= inputs[k])then
                           
                            table.insert( changed_inputs, { v, inputs[k] })
                        end
                    end
                end



                -- send changed inputs to spectators and store current inputs
                if(#changed_inputs > 0)then
                    local to_send = changed_inputs

                    if(to_spectators)then
                        steamutils.send("input", to_send, steamutils.messageTypes.Spectators, lobby, false, true)
                    else
                        steamutils.send("input", to_send, steamutils.messageTypes.OtherPlayers, lobby, false, true)
                    end
                end

                data.client.previous_input = inputs]]
            end
        end,
        player_data_update = function(lobby, data, to_spectators)
            local player = player.Get()
            if(player ~= nil and EntityGetIsAlive(player))then
                local character_data_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                if(character_data_comp ~= nil)then
                    
                    local cosmetics = {}
                    for k, v in pairs(data.cosmetics)do
                        table.insert(cosmetics, k)
                    end
                    
                    local status_list = GetActiveStatusEffects(player, true)

                    local message = {
                        ComponentGetValue2(character_data_comp, "mFlyingTimeLeft"),
                        status_list,
                        cosmetics
                    }

                    --print("mFlyingTimeLeft: " .. tostring(message.mFlyingTimeLeft))

                    if(to_spectators)then
                        steamutils.send("player_data_update", message, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("player_data_update", message, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end
                end
            end
        end,
        animation_update = function(lobby, data, to_spectators)
            local rectAnim = player.GetAnimationData()
            if (rectAnim ~= nil) then
                if (rectAnim ~= data.client.previous_anim) then
                    if(to_spectators)then
                        steamutils.send("animation_update", { rectAnim }, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("animation_update", { rectAnim }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end
                    data.client.previous_anim = rectAnim
                end
            end
        end,
        switch_item = function(lobby, data, user, force, to_spectators)
            local held_item = player.GetActiveHeldItem()
            if (held_item ~= nil and held_item ~= 0) then
                if (force or user ~= nil or held_item ~= data.client.previous_selected_item) then
                    --local wand_id = tonumber(GlobalsGetValue(tostring(held_item) .. "_item")) or -1
                    --if (wand_id ~= -1) then
                    local item_comp = EntityGetFirstComponentIncludingDisabled(held_item, "ItemComponent")
                    local slot_x, slot_y = ComponentGetValue2(item_comp, "inventory_slot")
                    local ability_comp = EntityGetFirstComponentIncludingDisabled(held_item, "AbilityComponent")
                    
                    local is_wand = false
                    if(ability_comp and ComponentGetValue2(ability_comp, "use_gun_script"))then
                        is_wand = true
                    end

                    --GamePrint("Switching to item in slot " .. tostring(slot_x) .. ", " .. tostring(slot_y))

                    if (user == nil) then
                        if(to_spectators)then
                            steamutils.send("switch_item", { is_wand, slot_x, slot_y }, steamutils.messageTypes.Spectators, lobby, true, true)
                        else
                            steamutils.send("switch_item", { is_wand, slot_x, slot_y }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                        end
                        data.client.previous_selected_item = held_item
                    else
                        steamutils.sendToPlayer("switch_item", { is_wand, slot_x, slot_y }, user, true)
                    end
                    --end
                end
            end
        end,
        sync_wand_stats = function(lobby, data, to_spectators)
            local held_item = player.GetActiveHeldItem()
            if (held_item ~= nil) then
                -- if has ability component
                local abilityComp = EntityGetFirstComponentIncludingDisabled(held_item, "AbilityComponent")
                if (abilityComp) then

                    local spell_uses_table = {}

                    local spell_table_changed = false
                    
                    local children = EntityGetAllChildren(held_item) or {}
                    for k, v in ipairs(children)do
                        if(EntityHasTag(v, "card_action"))then
                            local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                            if(item_comp ~= nil)then
                                local inventory_slot = ComponentGetValue2(item_comp, "inventory_slot")
                                local uses_remaining = ComponentGetValue2(item_comp, "uses_remaining")
                                spell_uses_table[tostring(inventory_slot)] = {uses_remaining = uses_remaining}
                                if(data.client.previous_wand_stats.spell_uses_table ~= nil)then
                                    if(data.client.previous_wand_stats.spell_uses_table[tostring(inventory_slot)] ~= nil)then
                                        if(data.client.previous_wand_stats.spell_uses_table[tostring(inventory_slot)].uses_remaining ~= uses_remaining)then
                                            spell_table_changed = true
                                        end
                                    else
                                        spell_table_changed = true
                                    end
                                else
                                    spell_table_changed = true
                                end
                            end
                        end
                    end
                    

                    -- get current mana
                    local mana = round_to_decimal(ComponentGetValue2(abilityComp, "mana"), 2)
                    -- mCastDelayStartFrame
                    local cast_delay_start_frame = ComponentGetValue2(abilityComp, "mCastDelayStartFrame")
                    -- mReloadFramesLeft
                    local reload_frames_left = ComponentGetValue2(abilityComp, "mReloadFramesLeft")
                    -- mReloadNextFrameUsable
                    local reload_next_frame_usable = ComponentGetValue2(abilityComp, "mReloadNextFrameUsable")
                    -- mNextChargeFramemNextChargeFrame
                    local next_charge_frame = ComponentGetValue2(abilityComp, "mNextChargeFrame")

                    if (data.client.previous_wand_stats.mana ~= mana or
                            data.client.previous_wand_stats.mCastDelayStartFrame ~= cast_delay_start_frame or
                            data.client.previous_wand_stats.mReloadFramesLeft ~= reload_frames_left or
                            data.client.previous_wand_stats.mReloadNextFrameUsable ~= reload_next_frame_usable or
                            data.client.previous_wand_stats.mNextChargeFrame ~= next_charge_frame or
                            spell_table_changed) then
                        data.client.previous_wand_stats.mana = mana
                        data.client.previous_wand_stats.mCastDelayStartFrame = cast_delay_start_frame
                        data.client.previous_wand_stats.mReloadFramesLeft = reload_frames_left
                        data.client.previous_wand_stats.mReloadNextFrameUsable = reload_next_frame_usable
                        data.client.previous_wand_stats.mNextChargeFrame = next_charge_frame
                        data.client.previous_wand_stats.spell_uses_table = spell_uses_table
                        
                        local msg_data = {
                            mana,
                            GameGetFrameNum() - cast_delay_start_frame,
                            reload_frames_left,
                            reload_next_frame_usable - GameGetFrameNum(),
                            next_charge_frame - GameGetFrameNum(),
                            spell_uses_table,
                        }

                        if(to_spectators)then
                            steamutils.send("sync_wand_stats", msg_data, steamutils.messageTypes.Spectators, lobby, false, true)
                        else
                            steamutils.send("sync_wand_stats", msg_data, steamutils.messageTypes.OtherPlayers, lobby, false, true)
                        end
                    end
                end
            end
        end,
        health_update = function(lobby, data, force)
            local health, max_health = player.GetHealthInfo()

            if (health ~= nil and max_health ~= nil) then
                if ((data.client.max_hp ~= max_health or data.client.hp ~= health) or force) then
                    local damage_details = deserialize_damage_details(GlobalsGetValue("last_damage_details", ""))

                    if(not GameHasFlagRun("player_died"))then
                        GlobalsSetValue("last_damage_details", "")
                    end

                    --print(json.stringify(damage_details))

                    steamutils.send("health_update", { health, max_health, pack_damage_details(damage_details) }, steamutils.messageTypes.OtherPlayers, lobby,
                        true, true)
                    data.client.max_hp = max_health
                    data.client.hp = health
                end
            end
        end,
        perk_update = function(lobby, data)
            local perk_info = {}
            for i, perk_data in ipairs(perk_list) do
                local perk_id = perk_data.id
                local flag_name = get_perk_picked_flag_name(perk_id)

                local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

                if GameHasFlagRun(flag_name) and (pickup_count > 0) then
                    --print("Has flag: " .. perk_id)
                    table.insert(perk_info, { perk_id, pickup_count })
                end
            end

            --if (#perk_info > 0) then
                local message_data = { perk_info }
                local perk_string = bitser.dumps(message_data)
                if (perk_string ~= data.client.previous_perk_string) then
                    arena_log:print("Sent perk update!!")
                    steamutils.send("perk_update", message_data, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    data.client.previous_perk_string = perk_string
                    data.client.perks = perk_info
                end
            --end
        end,
        fire_wand = function(lobby, rng, special_seed, to_spectators)
            local player = player.Get()
            if (player) then
                local wand = EntityHelper.GetHeldItem(player)

                if (wand ~= nil) then
                    local x, y, r = EntityGetTransform(wand)

                   

                    local data = {
                        x,
                        y,
                        r,
                        rng,
                        special_seed,
                        GlobalsGetValue("player_action_rng", "0")
                    }
                    GlobalsSetValue("player_action_rng", "0")
                    
                    if(to_spectators)then
                        steamutils.send("fire_wand", data, steamutils.messageTypes.Spectators, lobby, false, true)
                    else
                        steamutils.send("fire_wand", data, steamutils.messageTypes.OtherPlayers, lobby, false, true)
                    end
                end
            end
        end,
        death = function(lobby, killer)
            local damage_details = deserialize_damage_details(GlobalsGetValue("last_damage_details", ""))
            GlobalsSetValue("last_damage_details", "")
            steamutils.send("death", { killer, damage_details }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        zone_update = function(lobby, zone_size, shrink_time)
            local c = ZoneUpdate{
                zone_size = zone_size,
                shrink_time = shrink_time
            }

            steamutils.send("zone_update", c, steamutils.messageTypes.OtherPlayers, lobby, false, true)
        end,
        lock_ready_state = function(lobby)
            steamutils.send("lock_ready_state", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
        end,
        request_spectate_data = function(lobby, user)
            steamutils.sendToPlayer("request_spectate_data", {}, user, true)
        end,
        spectate_data = function(lobby, data, user, force)
            local heart_entity = EntityGetWithTag("heart")
            local spectate_data = {
                heart = nil
            }

            if (#heart_entity > 0) then
                local heart_x, heart_y = EntityGetTransform(heart_entity[1])
                spectate_data.heart = { heart_x, heart_y }
            end

            local serialized = bitser.dumps(spectate_data)
            if (serialized ~= data.client.previous_spectate_data or force) then
                data.client.previous_spectate_data = serialized
                
                if(user ~= nil)then
                    steamutils.sendToPlayer("spectate_date", spectate_data, user, true)
                else
                    steamutils.send("spectate_date", spectate_data, steamutils.messageTypes.Spectators, lobby, true)
                end
            end

        end,
        allow_round_end = function(lobby)
            steamutils.send("allow_round_end", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        item_picked_up = function(lobby, item_id, to_spectators)
            if(to_spectators)then
                steamutils.send("item_picked_up", { item_id }, steamutils.messageTypes.Spectators, lobby, true, true)
            else
                steamutils.send("item_picked_up", { item_id }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
            end
        end,
        physics_update = function(lobby, id, x, y, r, vel_x, vel_y, vel_a, takes_control)
            local c = PhysicsUpdate{
                id = id,
                x = x,
                y = y,
                r = r,
                vel_x = vel_x,
                vel_y = vel_y,
                vel_a = vel_a,
                takes_control = takes_control
            }
            steamutils.send("physics_update", c, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        fungal_shift = function(lobby, from, to)
            steamutils.send("fungal_shift", { from, to }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        start_map_vote = function(lobby, maps)
            steamutils.send("start_map_vote", { maps }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        add_vote = function(lobby, map)
            steamutils.send("add_vote", { map }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        map_vote_timer_update = function(lobby, frames)
            steamutils.send("map_vote_timer_update", { frames }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        map_vote_finish = function(lobby, winner, was_tie)
            steamutils.send("map_vote_finish", {winner, was_tie}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        load_lobby = function(lobby)
            steamutils.send("load_lobby", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        update_round = function(lobby, round)
            steamutils.send("update_round", { round }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        update_world_seed = function(lobby, seed)
            steamutils.send("update_world_seed", { seed }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
    },
}

return networking
