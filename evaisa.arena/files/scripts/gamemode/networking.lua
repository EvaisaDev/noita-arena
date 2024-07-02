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




function EntityGetChildrenWithTag( entity_id, tag )
    local valid_children = {};
    local children = EntityGetAllChildren( entity_id ) or {};
    for index, child in pairs( children ) do
        if EntityHasTag( child, tag ) then
            table.insert( valid_children, child );
        end
    end
    return valid_children;
end


local ffi = require("ffi")
-- cdef memcmp
ffi.cdef[[
    int memcmp(const void *s1, const void *s2, size_t n);
]]
local memcmp = ffi.C.memcmp


-- Keyboard struct
ffi.cdef([[
#pragma pack(push, 1)
typedef struct A {
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
} Keyboard;
#pragma pack(pop)
]])

-- Mouse struct
ffi.cdef([[
#pragma pack(push, 1)
typedef struct B {
    float aim_x;
    float aim_y;
    float mouse_x;
    float mouse_y;
    float mouseRaw_x;
    float mouseRaw_y;
} Mouse;
#pragma pack(pop)
]])


-- Zone Update Struct
ffi.cdef([[
#pragma pack(push, 1)
typedef struct C {
    float zone_size;
    float shrink_time;
} ZoneUpdate;
#pragma pack(pop)
]])

-- Physics Update
ffi.cdef([[
#pragma pack(push, 1)
typedef struct D {
    int id;
    float x;
    float y;
    float r;
    float vel_x;
    float vel_y;
    float vel_a;
    bool takes_control:1;
    bool was_kick:1;
} PhysicsUpdate;
#pragma pack(pop)
]])

-- character pos
ffi.cdef([[
#pragma pack(push, 1)
typedef struct E {
    int frames_in_air;
    float x;
    float y;
    float vel_x;
    float vel_y;
    bool is_on_ground:1;
    bool is_on_slippery_ground:1;
} CharacterPos;
#pragma pack(pop)
]])

-- fire_wand
--[[
    x,
    y,
    r,
    rng,
    special_seed,
    player_action_rng
]]
ffi.cdef([[
#pragma pack(push, 1)
typedef struct F {
    float x;
    float y;
    float r;
    int special_seed;
    int player_action_rng;
} FireWand;
#pragma pack(pop)
]])

-- player stats
--[[
    local player_data = {
        mFlyingTimeLeft = message[1],
        fly_time_max = message[2],
        air_needed = message[3],
        air_in_lungs = message[4],
        air_in_lungs_max = message[5],
        hp = message[6],
        max_hp = message[7],
        max_hp_cap = message[8],
        max_hp_old = message[9],
    }
]]
ffi.cdef([[
#pragma pack(push, 1)
typedef struct G {
    float mFlyingTimeLeft;
    float fly_time_max;
    float air_in_lungs;
    float air_in_lungs_max;
    float hp;
    float max_hp;
    float max_hp_cap;
    float max_hp_old;
    int money;
} PlayerStats;
#pragma pack(pop)
]])

-- wand stats
--[[
local msg_data = {
    mana,
    GameGetFrameNum() - cast_delay_start_frame,
    reload_frames_left,
    reload_next_frame_usable - GameGetFrameNum(),
    next_charge_frame - GameGetFrameNum(),
    --spell_uses_table,
}
]]
ffi.cdef([[
#pragma pack(push, 1)
typedef struct H {
    float mana;
    int cast_delay_start_frame;
    int reload_frames_left;
    int reload_next_frame_usable;
    int next_charge_frame;
} WandStats;
#pragma pack(pop)
]])

-- damage details
--[[
    local data = {
        ragdoll_fx,
        damage_types,
        knockback_force,
        impulse[1],
        impulse[2],
        world_pos[1],
        world_pos[2],
    }
]]
ffi.cdef([[
#pragma pack(push, 1)
typedef struct I {
    int ragdoll_fx;
    int damage_types;
    float knockback_force;
    float impulse_x;
    float impulse_y;
    float world_pos_x;
    float world_pos_y;
    float explosion_x;
    float explosion_y;
    float blood_multiplier;
    bool smash_explosion;
} DamageDetails;
#pragma pack(pop)
]])

-- item switch
ffi.cdef([[
#pragma pack(push, 1)
typedef struct J {
    int slot_x;
    int slot_y;
    bool is_wand:1;
} ItemSwitch;
#pragma pack(pop)
]])

-- Entity Update
ffi.cdef([[
#pragma pack(push, 1)
typedef struct K {
    int id;
    float x;
    float y;
    float r;
    float vel_x;
    float vel_y;
    bool takes_control:1;
} EntityUpdate;
#pragma pack(pop)
]])


local Keyboard = ffi.typeof("Keyboard")
local Mouse = ffi.typeof("Mouse")
local ZoneUpdate = ffi.typeof("ZoneUpdate")
local PhysicsUpdate = ffi.typeof("PhysicsUpdate")
local EntityUpdate = ffi.typeof("EntityUpdate")
local CharacterPos = ffi.typeof("CharacterPos")
local FireWand = ffi.typeof("FireWand")
local PlayerStats = ffi.typeof("PlayerStats")
local WandStats = ffi.typeof("WandStats")
local DamageDetails = ffi.typeof("DamageDetails")
local ItemSwitch = ffi.typeof("ItemSwitch")



local function deserialize_damage_details(str)
    local values = {}
    for value in str:gmatch("[^,]+") do
        table.insert(values, tonumber(value))
    end

    local ragdoll_fx = values[1]
    local damage_types = values[2]
    local knockback_force = values[3]
    local blood_multiplier = values[4]
    local impulse_x = values[5]
    local impulse_y = values[6]
    local world_pos_x = values[7]
    local world_pos_y = values[8]
    local smash_explosion = values[9] == 1
    local explosion_x = values[10]
    local explosion_y = values[11]
    local attacker = values[12]
    
    
    --print("ragdoll_fx: " .. tostring(ragdoll_fx) .. ",\ndamage_types: " .. tostring(damage_types) .. ",\nknockback_force: " .. tostring(knockback_force) .. ",\nimpulse_x: " .. tostring(impulse_x) .. ",\nimpulse_y: " .. tostring(impulse_y) .. ",\nworld_pos_x: " .. tostring(world_pos_x) .. ",\nworld_pos_y: " .. tostring(world_pos_y) .. ",\nsmash_explosion: " .. tostring(smash_explosion) .. ",\nexplosion_x: " .. tostring(explosion_x) .. ",\nexplosion_y: " .. tostring(explosion_y))

    return DamageDetails{
        ragdoll_fx = tonumber(ragdoll_fx),
        damage_types = tonumber(damage_types),
        knockback_force = tonumber(knockback_force),
        blood_multiplier = tonumber(blood_multiplier),
        impulse_x = tonumber(impulse_x),
        impulse_y = tonumber(impulse_y),
        world_pos_x = tonumber(world_pos_x),
        world_pos_y = tonumber(world_pos_y),
        smash_explosion = smash_explosion,
        explosion_x = tonumber(explosion_x),
        explosion_y = tonumber(explosion_y),
    }, attacker
end

local round_to_decimal = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

networking = {
    receive = {
        ready = function(lobby, message, user, data)
            if(not data.players[tostring(user)])then
                return
            end

            local username = steamutils.getTranslatedPersonaName(user)

            if(data.players[tostring(user)] == nil)then
                data:DefinePlayer(lobby, user)
            end

            if((data.players[tostring(user)].ready and message[1]) or (not data.players[tostring(user)].ready and not message[1]))then
                return
            end
            

            if(GameHasFlagRun("lock_ready_state"))then
                data.players[tostring(user)].ready = true
                if (steam_utils.IsOwner()) then
                    steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_ready", "true")
                end
                return
            end

            if (message[1]) then
                data.players[tostring(user)].ready = true

                if (not message[2]) then
                    --GamePrint(tostring(username) .. " is ready.")
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_player_ready"), username))
                end

                if (steam_utils.IsOwner()) then
                    arena_log:print(tostring(user) .. "_ready: " .. tostring(message[1]))
                    steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_ready", "true")
                end
            else
                data.players[tostring(user)].ready = false

                if (not message[2]) then
                    --GamePrint(tostring(username) .. " is no longer ready.")
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_player_unready"), username))
                end

                if (steam_utils.IsOwner()) then
                    steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_ready", "false")
                end
            end
        end,
        request_ready_states = function(lobby, message, user, data)
            networking.send.ready(lobby, data.client.ready, true)
        end,
        --[[allow_round_end = function(lobby, message, user, data)
            if(steam_utils.IsOwner( user))then
                data.allow_round_end = true
                print("Allowing round to end.")
            end
        end,]]
        round_end = function(lobby, message, user, data)
            if(steam_utils.IsOwner( user))then
                local winner_string = message[1]
                local win_condition_user = message[2]
                local winner = ArenaGameplay.FindUser(lobby, winner_string)

                if(winner == nil)then
                    GamePrintImportant(GameTextGetTranslatedOrNot("$arena_tie_text"), GameTextGetTranslatedOrNot("$arena_round_end_text"))
                    
                    GameAddFlagRun("round_finished")
                    print("No winner! Loading lobby..")

                    delay.new(300, function()
                        ArenaGameplay.LoadLobby(lobby, data, false)
                    end, function(frames)
                        if (frames % 60 == 0) then
                            GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                        end
                    end)
                else

                    if(not data.spectator_mode and winner == steam_utils.getSteamID())then
                        GameAddFlagRun("arena_winner")
                        local catchup_mechanic = GlobalsGetValue("perk_catchup", "losers")
                        if(catchup_mechanic == "winner")then
                            GameAddFlagRun("first_death")
                            GamePrint(GameTextGetTranslatedOrNot("$arena_compensation_winner"))
                        end
                        if(GameHasFlagRun("upgrades_system"))then
                            local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")
                            if(catchup_mechanic_upgrades == "winner")then
                                GameAddFlagRun("pick_upgrade")
                            end
                        end
                    end
        
                    GameAddFlagRun("round_finished")

                    if(win_condition_user ~= nil)then
                        GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_win_condition_description"))
                    else
                        GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_winner_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_round_end_text"))
                    end
        
                    if(win_condition_user == nil or not GameHasFlagRun("win_condition_end_match"))then
                        print("Win condition not met, loading lobby..")
                        delay.new(300, function()
                            ArenaGameplay.LoadLobby(lobby, data, false)
                        end, function(frames)
                            if (frames % 60 == 0) then
                                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                            end
                        end)
                    else
                        print("Win condition met! ending match..")
                        scoreboard.apply_data(lobby, data)
                        scoreboard.show()
                        delay.new(600, function()
                            scoreboard.open = false
                            StopGame()
                        end, function(frames)
                            if (frames % 60 == 0) then
                                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_ending_game_text"), tostring(math.floor(frames / 60))))
                            end
                        end)
                    end
                    
                end

            end
        end,
        arena_loaded = function(lobby, message, user, data)
            local username = steamutils.getTranslatedPersonaName(user)

            data.players[tostring(user)].loaded = true

            --GamePrint(username .. " has loaded the arena.")
            GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_player_loaded_arena"), username))
            arena_log:print(username .. " has loaded the arena.")

            if (steam_utils.IsOwner()) then
                steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_loaded", "true")
            end
        end,
        enter_arena = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
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
            if (not steam_utils.IsOwner( user))then
                return
            end

            --GamePrint("Starting countdown...")

            arena_log:print("Received all clear for starting countdown.")

            data.players_loaded = true
            gameplay_handler.FightCountdown(lobby, data)
    
        end,
        sync_countdown = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            if(data.state == "arena" and data.countdown ~= nil)then
                data.countdown.frame = message[1]
                data.countdown.image_index = message[2]
            end
        end,
        check_can_unlock = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            
            steamutils.sendToPlayer("can_unlock", {}, user, true)
        end,
        can_unlock = function(lobby, message, user, data)
            data.players[tostring(user)].can_unlock = true
            
            -- if all players can unlock, unlock them
            local all_can_unlock = true
            for k, v in pairs(data.players)do
                if(not v.can_unlock)then
                    all_can_unlock = false
                    break
                end
            end

            if(all_can_unlock)then
                networking.send.unlock(lobby)
            end
        end,
        unlock = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
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

            --[[if(dev_log)then
                dev_log:print("Received character position update.")
            end]]

            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                --[[if (dev_log) then
                    dev_log:print("player is invalid!!")
                end]]
                return
            end

            --[[if(dev_log)then
                dev_log:print("player is valid!!")
                dev_log:print("spectator mode: " .. tostring(data.spectator_mode))
                dev_log:print("player is unlocked: " .. tostring(GameHasFlagRun("player_is_unlocked")))
                dev_log:print("no shooting: " .. tostring(GameHasFlagRun("no_shooting")))
            end]]

            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                

                local x, y = message.x, message.y

                local entity = data.players[tostring(user)].entity
                if (entity ~= nil and EntityGetIsAlive(entity)) then
                    local characterData = EntityGetFirstComponentIncludingDisabled(entity, "CharacterDataComponent")
                    local velocityComp = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")

                    ComponentSetValue2(characterData, "mVelocity", message.vel_x, message.vel_y)
                    ComponentSetValue2(velocityComp, "mVelocity", message.vel_x, message.vel_y)

                    EntityApplyTransform(entity, x, y)


                    ComponentSetValue2(characterData, "is_on_ground", message.is_on_ground or false)
                    ComponentSetValue2(characterData, "is_on_slippery_ground", message.is_on_slippery_ground or false)
                    --data.players[tostring(user)].is_on_ground = message.is_on_ground or false
                    --data.players[tostring(user)].is_on_slippery_ground = message.is_on_slippery_ground or false

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
        item_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end
            print("Received item update")

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                print("Player was missing")
                return
            end

            if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                print("weewoo update items")
                local items_data = message[1]
                local force = message[2]
                local unlimited_spells = message[3]
                local spells = message[4] or {}
                local frame = message[5] or 0

                --print("Received item update")

                if(unlimited_spells)then
                    EntityAddTag(data.players[tostring(user)].entity, "unlimited_spells")
                end

                GameDestroyInventoryItems(data.players[tostring(user)].entity)

                local has_spectator = false
                local spectator_pickupper = nil

                -- if we are in spectator mode
                if (data.spectated_player == user and data.spectator_entity ~= nil and EntityGetIsAlive(data.spectator_entity)) then
                    GameDestroyInventoryItems(data.spectator_entity)

                    --print("Syncing spectator items.")

                    spectator_pickupper = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "ItemPickUpperComponent")

                    has_spectator = true
                end
        

                if (items_data ~= nil) then
                    for k, itemInfo in ipairs(items_data) do
                        local x, y = EntityGetTransform(data.players[tostring(user)].entity)
                        
                        local item = nil
                        local spectator_item = nil
                        if(itemInfo.is_wand)then
                            item = EZWand(itemInfo.data, x, y)


                            if(has_spectator)then
                                spectator_item = EZWand(itemInfo.data, x, y)
                            end
                            
                        else
                            item = EntityCreateNew()
                            np.DeserializeEntity(item, itemInfo.data, x, y)
                            

                            if(has_spectator)then
                                spectator_item = EntityCreateNew()
                                np.DeserializeEntity(spectator_item, itemInfo.data, x, y)
                                
                                local material_inventory_comp = EntityGetFirstComponentIncludingDisabled(spectator_item, "MaterialInventoryComponent")
                                if(material_inventory_comp)then
                                    local last_frame_drank = ComponentGetValue2(material_inventory_comp, "last_frame_drank")
                                    local frame_offset = last_frame_drank - frame
                                    ComponentSetValue2(material_inventory_comp, "last_frame_drank", GameGetFrameNum() + frame_offset)
                                end
                            end
                        end
            
                        if (item == nil) then
                            return
                        end

                        EntityRemoveTag(item, "picked_by_player")

                        local item_entity = nil
                        if(itemInfo.is_wand)then
                            --item:PickUp(data.players[tostring(user)].entity)
                            EntityHelper.PickItem(data.players[tostring(user)].entity, item.entity_id, "QUICK")
                            --print("forcing pickup of wand")
                            item_entity = item.entity_id

                            if(has_spectator)then

                                ComponentSetValue2(spectator_pickupper, "only_pick_this_entity", spectator_item.entity_id)
                                
                                EntityHelper.PickItem(data.spectator_entity, spectator_item.entity_id, "QUICK")
                               -- spectator_item:PickUp(data.spectator_entity)
                                spectator_item_entity = spectator_item.entity_id

                                --print("Adding spectator item to spectator.")
                            end
                        else
                            --print("forcing pickup of item")
                            EntityHelper.PickItem(data.players[tostring(user)].entity, item, "QUICK")
                            item_entity = item

                            if(has_spectator)then

                                ComponentSetValue2(spectator_pickupper, "only_pick_this_entity", spectator_item)

                                EntityHelper.PickItem(data.spectator_entity, spectator_item, "QUICK")
                                spectator_item_entity = spectator_item
                            end
                        end

                        local itemComp = EntityGetFirstComponentIncludingDisabled(item_entity, "ItemComponent")
                        if (itemComp ~= nil) then
                            ComponentSetValue2(itemComp, "inventory_slot", itemInfo.slot_x, itemInfo.slot_y)
                        end

                        if (itemInfo.active) then
                            game_funcs.SetActiveHeldEntity(data.players[tostring(user)].entity, item_entity, false,
                                false)

                            if (has_spectator) then
                                game_funcs.SetActiveHeldEntity(data.spectator_entity, spectator_item_entity, false,
                                    false)
                                data.spectator_selected_item = spectator_item_entity
                            end
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

                if (spells ~= nil and has_spectator) then
                    for k, itemInfo in ipairs(spells) do
                        local x, y = EntityGetTransform(data.players[tostring(user)].entity)
                        
                        local spectator_item = nil
                        if(itemInfo.is_wand)then
                            spectator_item = EZWand(itemInfo.data, x, y)
                        else
                            spectator_item = EntityCreateNew()
                            np.DeserializeEntity(spectator_item, itemInfo.data, x, y)

                        end
            
                        if (spectator_item == nil) then
                            return
                        end

                        if(itemInfo.is_wand)then

                            ComponentSetValue2(spectator_pickupper, "only_pick_this_entity", spectator_item.entity_id)
                            
                            --spectator_item:PickUp(data.spectator_entity)
                            EntityHelper.PickItem(data.players[tostring(user)].entity, spectator_item.entity_id, "QUICK")
                            spectator_item_entity = spectator_item.entity_id

                        else
                            ComponentSetValue2(spectator_pickupper, "only_pick_this_entity", spectator_item)

                            EntityHelper.PickItem(data.spectator_entity, spectator_item, "FULL")
                            spectator_item_entity = spectator_item

                        end


                    end



                end

                if(has_spectator)then
                    local inventory2_comp = EntityGetFirstComponent( data.spectator_entity, "Inventory2Component" )
                    if( inventory2_comp ) then
                        delay.new(0, function()
                            if(EntityGetIsAlive(data.spectator_entity))then
                                local inventory2_comp = EntityGetFirstComponent( data.spectator_entity, "Inventory2Component" )
                                if( inventory2_comp ) then
                                    ComponentSetValue2( inventory2_comp, "mForceRefresh", true )
                                end
                            end
                        end)
                        --ComponentSetValue2( inventory2_comp, "mActualActiveItem", 0 )
                        --print("attempting refresh??")
                    end
                end
                
            end
        end,
        request_item_update = function(lobby, message, user, data)
            if(data.spectator_mode)then
                return
            end
            data.client.previous_wand = nil
            networking.send.item_update(lobby, data, user, true)
            networking.send.switch_item(lobby, data, user, true)
        end,
       
        keyboard = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

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
                        controls_data.kick = false
                    end
                    
                    EntityHelper.BlockFiring(data.players[tostring(user)].entity, false, false)
                    EntityHelper.BlockFiring(data.players[tostring(user)].entity, true, true)


                    if(message.fire)then
                        ComponentSetValue2(controlsComp, "mButtonDownFire", true)
                        if (not controls_data.fire) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFire", GameGetFrameNum()+1)
                        end
                        ComponentSetValue2(controlsComp, "mButtonLastFrameFire", GameGetFrameNum())
                        controls_data.fire = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFire", false)
                        controls_data.fire = false
                    end

                    if(message.fire2)then
                        ComponentSetValue2(controlsComp, "mButtonDownFire2", true)
                        if (not controls_data.fire2) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFire2", GameGetFrameNum()+1)
                        end
                        controls_data.fire2 = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFire2", false)
                        controls_data.fire2 = false
                    end

                    if(message.action)then
                        ComponentSetValue2(controlsComp, "mButtonDownAction", true)
                        if (not controls_data.action) then
                            ComponentSetValue2(controlsComp, "mButtonFrameAction", GameGetFrameNum() + 1)
                        end
                        controls_data.action = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownAction", false)
                        controls_data.action = false
                    end

                    if(message.throw)then
                        ComponentSetValue2(controlsComp, "mButtonDownThrow", true)
                        if (not controls_data.throw) then
                            ComponentSetValue2(controlsComp, "mButtonFrameThrow", GameGetFrameNum() + 1)
                        end
                        controls_data.throw = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownThrow", false)
                        controls_data.throw = false
                    end

                    if(message.interact)then
                        ComponentSetValue2(controlsComp, "mButtonDownInteract", true)
                        if (not controls_data.interact) then
                            ComponentSetValue2(controlsComp, "mButtonFrameInteract", GameGetFrameNum() + 1)
                        end
                        controls_data.interact = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownInteract", false)
                        controls_data.interact = false
                    end

                    if(message.left)then
                        ComponentSetValue2(controlsComp, "mButtonDownLeft", true)
                        if (not controls_data.left) then
                            ComponentSetValue2(controlsComp, "mButtonFrameLeft", GameGetFrameNum() + 1)
                        end
                        controls_data.left = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownLeft", false)
                        controls_data.left = false
                    end

                    if(message.right)then
                        ComponentSetValue2(controlsComp, "mButtonDownRight", true)
                        if (not controls_data.right) then
                            ComponentSetValue2(controlsComp, "mButtonFrameRight", GameGetFrameNum() + 1)
                        end
                        controls_data.right = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownRight", false)
                        controls_data.right = false
                    end

                    if(message.up)then
                        ComponentSetValue2(controlsComp, "mButtonDownUp", true)
                        if (not controls_data.up) then
                            ComponentSetValue2(controlsComp, "mButtonFrameUp", GameGetFrameNum() + 1)
                        end
                        controls_data.up = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownUp", false)
                        controls_data.up = false
                    end

                    if(message.down)then
                        ComponentSetValue2(controlsComp, "mButtonDownDown", true)
                        if (not controls_data.down) then
                            ComponentSetValue2(controlsComp, "mButtonFrameDown", GameGetFrameNum() + 1)
                        end
                        controls_data.down = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownDown", false)
                        controls_data.down = false
                    end

                    if(message.jump)then
                        ComponentSetValue2(controlsComp, "mButtonDownJump", true)
                        if (not controls_data.jump) then
                            ComponentSetValue2(controlsComp, "mButtonFrameJump", GameGetFrameNum() + 1)
                        end
                        controls_data.jump = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownJump", false)
                        controls_data.jump = false
                    end

                    if(message.fly)then
                        ComponentSetValue2(controlsComp, "mButtonDownFly", true)
                        if (not controls_data.fly) then
                            ComponentSetValue2(controlsComp, "mButtonFrameFly", GameGetFrameNum() + 1)
                        end
                        controls_data.fly = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownFly", false)
                        controls_data.fly = false
                    end

                    if(message.leftClick)then
                        ComponentSetValue2(controlsComp, "mButtonDownLeftClick", true)
                        if (not controls_data.leftClick) then
                            ComponentSetValue2(controlsComp, "mButtonFrameLeftClick", GameGetFrameNum() + 1)
                        end
                        controls_data.leftClick = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownLeftClick", false)
                        controls_data.leftClick = false
                    end

                    if(message.rightClick)then
                        ComponentSetValue2(controlsComp, "mButtonDownRightClick", true)
                        if (not controls_data.rightClick) then
                            ComponentSetValue2(controlsComp, "mButtonFrameRightClick", GameGetFrameNum() + 1)
                        end
                        controls_data.rightClick = true
                    else
                        ComponentSetValue2(controlsComp, "mButtonDownRightClick", false)
                        controls_data.rightClick = false
                    end

                end
            end
        end,
        mouse = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            -- check which inputs have changed
            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                if (data.players[tostring(user)] ~= nil and data.players[tostring(user)].entity ~= nil and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                    local controlsComp = EntityGetFirstComponentIncludingDisabled(data.players[tostring(user)].entity, "ControlsComponent")

                    ComponentSetValue2(controlsComp, "mAimingVector", message.aim_x, message.aim_y)

                    local vx = message.aim_x
                    local vy = message.aim_y
                    local CONTROLS_AIMING_VECTOR_FULL_LENGTH_PIXELS = tonumber(MagicNumbersGetValue("CONTROLS_AIMING_VECTOR_FULL_LENGTH_PIXELS"))

                    -- get length of aiming vector
                    local aiming_vec_distance = math.sqrt(vx * vx + vy * vy)
                    if aiming_vec_distance > CONTROLS_AIMING_VECTOR_FULL_LENGTH_PIXELS then
                        vx = vx / aiming_vec_distance
                        vy = vy / aiming_vec_distance
                    else
                        vx = vx / CONTROLS_AIMING_VECTOR_FULL_LENGTH_PIXELS
                        vy = vy / CONTROLS_AIMING_VECTOR_FULL_LENGTH_PIXELS
                    end

                    ComponentSetValue2(controlsComp, "mAimingVectorNormalized", vx, vy)
     
                    ComponentSetValue2(controlsComp, "mMousePosition", message.mouse_x, message.mouse_y)

                    local mouse_raw_x_prev, mouse_raw_y_prev = ComponentGetValue2(controlsComp, "mMousePositionRawPrev")

                    local dx, dy = message.mouseRaw_x - mouse_raw_x_prev, message.mouseRaw_y - mouse_raw_y_prev

                    ComponentSetValue2(controlsComp, "mMousePositionRaw", message.mouseRaw_x, message.mouseRaw_y)
                    ComponentSetValue2(controlsComp, "mMousePositionRawPrev", message.mouseRaw_x, message.mouseRaw_y)
                    ComponentSetValue2(controlsComp, "mMouseDelta", dx, dy)

                    local children = EntityGetAllChildren(data.players[tostring(user)].entity) or {}
                    for i, child in ipairs(children) do
                        if (EntityGetName(child) == "cursor") then
                            --EntitySetTransform(child, message.mouse_x, message.mouse_y)
                            EntityApplyTransform(child, message.mouse_x, message.mouse_y)
                        end
                    end
                end
            end
        end,
        animation_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

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
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            --GlobalsSetValue(tostring(wand.entity_id).."_wand", wandInfo.id)
            local is_wand, slot_x, slot_y = message.is_wand, message.slot_x, message.slot_y
            -- GamePrint("Switching item to slot: " .. tostring(slot_x) .. ", " .. tostring(slot_y))
            if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then
                local items = GameGetAllInventoryItems(data.players[tostring(user)].entity) or {}
                local target = nil
                local not_target = nil
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
                        --local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                        target = item
                        --if (mActiveItem ~= item) then
                            
                        --end
                    else
                        not_target = item
                    end

                    if(target and not_target)then
                        break
                    end
                end

                if(not_target)then
                    np.SetActiveHeldEntity(data.players[tostring(user)].entity, not_target, false, false)
                end
                
                if(target)then
                    np.SetActiveHeldEntity(data.players[tostring(user)].entity, target, false, false)
                end

                local has_spectator = false


                -- if we are in spectator mode
                if (data.spectated_player == user and data.spectator_entity ~= nil and EntityGetIsAlive(data.spectator_entity)) then
                    has_spectator = true
                end


                if(has_spectator)then
                    local spectator_items = GameGetAllInventoryItems(data.spectator_entity) or {}
                    for i, item in ipairs(spectator_items) do
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
                            local inventory2Comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "Inventory2Component")
                            local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")
    
                            if (mActiveItem ~= item) then
                                game_funcs.SetActiveHeldEntity(data.spectator_entity, item, false, false)
                                data.spectator_selected_item = item
                                --print("Switching spectator item to slot: " .. tostring(slot_x) .. ", " .. tostring(slot_y))
                            end
                            break
                        end
                    end
                end
            end
          
        end,
        sync_wand_stats = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end
            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting")))) then
                if (data.players[tostring(user)].entity and EntityGetIsAlive(data.players[tostring(user)].entity)) then

                    --print("Syncing wand stats!!")
                    local player = data.players[tostring(user)].entity

                    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")

                    -- if no inventory2Comp, return
                    if (inventory2Comp == nil) then
                        return
                    end
                    
                    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                    if (mActiveItem ~= nil) then
                        
                        local mana = message.mana
                        local mCastDelayStartFrame = GameGetFrameNum() - message.cast_delay_start_frame
                        local mReloadFramesLeft = message.reload_frames_left
                        local mReloadNextFrameUsable = message.reload_next_frame_usable + GameGetFrameNum()
                        local mNextChargeFrame = message.next_charge_frame + GameGetFrameNum()

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
            local attacker = message[1]
            local health = message[2]
            local maxHealth = message[3]
            local damage_details = message[4]
            local damage = message[5]
            local invincibility_frames = message[6]

            if (health ~= nil and maxHealth ~= nil) then
                local client_entity = data.players[tostring(user)].entity
                if (client_entity ~= nil) then
                    if(not EntityGetIsAlive(client_entity))then
                        return
                    end

                    -- find attacker entity
                    local attacker_entity = nil
                    if (attacker ~= nil and data.players[tostring(attacker)] ~= nil) then
                        local ent = data.players[tostring(attacker)].entity
                        if(ent and EntityGetIsAlive(ent))then
                            attacker_entity = ent
                        end
                    end

                    --print("Received health update!!")

                    local last_health = maxHealth
                    if (data.players[tostring(user)].health) then
                        last_health = data.players[tostring(user)].health
                    end

                   -- print("last health: " .. tostring(last_health) .. ", new health: " .. tostring(health) .. ", max health: " .. tostring(maxHealth))

                    if (health < last_health or damage) then
                        if(damage == nil)then
                            damage = last_health - health
                        end

                        if(invincibility_frames)then
                            local effect = GetGameEffectLoadTo(client_entity, "PROTECTION_ALL", true)
    
                            ComponentSetValue2( effect, "frames", invincibility_frames )
                        end

                        --[[
                            int ragdoll_fx;
                            int damage_types;
                            float knockback_force;
                            float impulse_x;
                            float impulse_y;
                            float world_pos_x;
                            float world_pos_y;
                        ]]


                        --[[local damage_entity = EntityGetWithName("dummy_damage")
                        if(damage_entity == nil or damage_entity == 0 or not EntityGetIsAlive(damage_entity))then
                            damage_entity = EntityCreateNew("dummy_damage")
                        end]]
                        if(damage_details ~= nil and damage_details.ragdoll_fx ~= nil)then
                            --print(json.stringify(damage_details))

                            --print("damage types: " .. tostring(damage_details.damage_types))

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

                            local damage_model_comp = EntityGetFirstComponentIncludingDisabled(client_entity, "DamageModelComponent")

                            if(damage_model_comp == nil)then
                                return
                            end

                            local old_blood_multiplier = ComponentGetValue2(damage_model_comp, "blood_multiplier")
                            ComponentSetValue2(damage_model_comp, "blood_multiplier", blood_multiplier)

                            

                            for i, damage_type in ipairs(damage_types) do
                                --print("inflicting damage: " .. tostring(damage_per_type) .. " of type: " .. tostring(damage_type))
                                EntityInflictDamage(client_entity, 
                                damage_per_type, 
                                damage_type, 
                                "damage_fake",
                                ragdoll_fx, 
                                damage_details.impulse_x, 
                                damage_details.impulse_y, 
                                attacker_entity, 
                                damage_details.world_pos_x, 
                                damage_details.world_pos_y, 
                                damage_details.knockback_force)
                            end
                            if(old_blood_multiplier ~= nil)then
                                ComponentSetValue2(damage_model_comp, "blood_multiplier", old_blood_multiplier)
                            end
                        else
                            EntityInflictDamage(client_entity, 
                            damage, 
                            "DAMAGE_DROWNING", 
                            "damage_fake",
                            "NONE", 
                            0, 
                            0, 
                            attacker_entity)

                            --print("inflicting damage: " .. tostring(damage))

                        end

                    end

                    local DamageModelComp = EntityGetFirstComponentIncludingDisabled(client_entity,
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


            local perk_data = {}
            local last_player_perk_data = data.players[tostring(user)].perks or {}

            for i, perk in ipairs(message) do
                local perk_id = perks_sorted[perk[1]]
                local perk_stack = perk[2]

                table.insert(perk_data, {perk_id, perk_stack})
            end

            -- find new perks or perks that gained stacks, only add stacks that it gained
            local gained_perks = {}
            for i, perk in ipairs(perk_data) do
                local perk_id = perk[1]
                local perk_stack = perk[2]

                local found = false
                for j, last_perk in ipairs(last_player_perk_data) do
                    local last_perk_id = last_perk[1]
                    local last_perk_stack = last_perk[2]

                    if (perk_id == last_perk_id) then
                        if (perk_stack > last_perk_stack) then
                            table.insert(gained_perks, {perk_id, perk_stack - last_perk_stack})
                        end
                        found = true
                        break
                    end
                end

                if (not found) then
                    table.insert(gained_perks, {perk_id, perk_stack})
                end
            end

            local client = data.players[tostring(user)].entity

            if (client ~= nil and EntityGetIsAlive(client)) then
               --- print("Giving perks to player: " .. tostring(user))
                for k, v in ipairs(gained_perks) do
                    local perk = v[1]
                    local count = v[2]

                    --print("Giving perk: " .. tostring(perk) .. " with count: " .. tostring(count))
    
                    for i = 1, count do
                        EntityHelper.GivePerk(client, perk, i, true)
                    end
                end
            end

            
            

            data.players[tostring(user)].perks = perk_data

        end,
        fire_wand = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                return
            end

            local rng = message[1]
            local message = message[2]

            local client_entity = data.players[tostring(user)].entity

            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))) and client_entity ~= nil and EntityGetIsAlive(client_entity)) then
                data.players[tostring(user)].can_fire = true

                --print("Received fire wand message!")

                GlobalsSetValue("shooter_rng_" .. tostring(user), tostring(message.special_seed))
                
                GlobalsSetValue("action_rng_"..tostring(user), tostring(message.player_action_rng or 0))


                data.players[tostring(user)].projectile_rng_stack = rng

                local controlsComp = EntityGetFirstComponentIncludingDisabled(client_entity,
                    "ControlsComponent")

                if (controlsComp ~= nil) then
                    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(client_entity,
                        "Inventory2Component")

                    if (inventory2Comp == nil) then
                        return
                    end

                    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")

                    print("Active item id: " .. tostring(mActiveItem))
                    print("Client entity id: " .. tostring(client_entity))
                    print("Item root entity id: " .. tostring(EntityGetRootEntity(mActiveItem)))
                    print("Item is alive: " .. tostring(EntityGetIsAlive(mActiveItem)))
                    print("Client is alive: " .. tostring(EntityGetIsAlive(client_entity)))

                    if (mActiveItem ~= nil and client_entity == EntityGetRootEntity(mActiveItem)) then
                        local aimNormal_x, aimNormal_y = ComponentGetValue2(controlsComp, "mAimingVectorNormalized")
                        local aim_x, aim_y = ComponentGetValue2(controlsComp, "mAimingVector")
                        local firing = ComponentGetValue2(controlsComp, "mButtonDownFire")

                        ComponentSetValue2(controlsComp, "mButtonDownFire", false)

                        local wand_x, wand_y, wand_r = message.x, message.y, message.r

                        --print("Firing wand at " .. tostring(wand_x) .. ", " .. tostring(wand_y))	

                        --EntitySetTransform(mActiveItem, wand_x, wand_y, wand_r)
                        --EntityApplyTransform(mActiveItem, wand_x, wand_y, wand_r)

                        local x = wand_x + (aimNormal_x * 2)
                        local y = wand_y + (aimNormal_y * 2)
                        y = y - 1

                        local target_x = x + aim_x
                        local target_y = y + aim_y

                        EntityHelper.BlockFiring(client_entity, false, true)

                        print("Using item!")

                        -- Add player_unit tag to fix physics projectile lob strength
                        EntityAddTag(client_entity, "player_unit")
                        np.UseItem(client_entity, mActiveItem, true, true, true, x, y, target_x, target_y)
                        EntityRemoveTag(client_entity, "player_unit")

                        EntityHelper.BlockFiring(client_entity, true, true)

                        ComponentSetValue2(controlsComp, "mButtonDownFire", firing)
                    end
                end 
            end
        end,
        death = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (data.state == "arena") then
                local username = steamutils.getTranslatedPersonaName(user)

                arena_log:print("Received death for user: " .. tostring(username))
                print("Player " .. tostring(username) .. " died.")

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

                local attacker_entity = nil
                if (killer ~= nil and data.players[tostring(killer)] ~= nil) then
                    local ent = data.players[tostring(killer)].entity
                    if(ent and EntityGetIsAlive(ent))then
                        attacker_entity = ent
                    end
                end

                data.players[tostring(user)]:Death(damage_details, attacker_entity)

                data.players[tostring(user)].alive = false
                data.deaths = data.deaths + 1
       


                if (killer == nil) then
                    --GamePrint(tostring(username) .. " died.")
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_other_player_died"), username))
                else
                    local killer_id = gameplay_handler.FindUser(lobby, killer)
                    if (killer_id ~= nil) then
                        --[[GamePrint(tostring(username) ..
                            " was killed by " .. steamutils.getTranslatedPersonaName(killer_id))]]
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_kill"), username, steamutils.getTranslatedPersonaName(killer_id)))

                        -- if killer is us
                        if (killer_id == steam_utils.getSteamID()) then
                            -- grant coin
                            local currency = ModSettingGet("arena_cosmetics_currency") or 0
                            currency = currency + 10
                            ModSettingSet("arena_cosmetics_currency", currency)

                            local player_entity = player.Get()
                            if(player_entity)then
                                cosmetics_handler.OnKill(lobby, data, player_entity)
                            end
                        end

                        if(steam_utils.IsOwner())then
                            local user = killer_id
                            local kill_key = tostring(user) .. "_kills"
            
                            local current_kills = tonumber(tonumber(steamutils.GetLobbyData(kill_key)) or "0")
                
                            print("incrementing kill count for "..tostring(user).." to "..tostring(current_kills + 1))
                            steam_utils.TrySetLobbyData(lobby, kill_key, tostring(current_kills + 1))
                
                            if(user ~= steam_utils.getSteamID())then
                                data.players[tostring(user)].kills = current_kills + 1
                            else
                                data.client.kills = current_kills + 1
                            end
            
                            gameplay_handler.WinnerCheck(lobby, data)
                        end
                    else
                        --GamePrint(tostring(username) .. " died.")
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_other_player_died"), username))
                    end
                end

                if(steam_utils.IsOwner())then
                    local death_key = tostring(user) .. "_deaths"

                    local current_deaths = tonumber(tonumber(steamutils.GetLobbyData(death_key)) or "0")
     
                    print("incrementing death count for "..tostring(user).." to "..tostring(current_deaths + 1))
                    steam_utils.TrySetLobbyData(lobby, death_key, tostring(current_deaths + 1))
        
                    if(user ~= steam_utils.getSteamID())then
                        data.players[tostring(user)].deaths = current_deaths + 1
                    else
                        data.client.deaths = current_deaths + 1
                    end

                    gameplay_handler.WinnerCheck(lobby, data)
                end
                
                -- kill the player
                --[[local client_entity = data.players[tostring(user)].entity
                if (client_entity ~= nil and EntityGetIsAlive(client_entity)) then
                    -- CLIENT ANNIHILATION WAWAWAHAHAHAHAH
                    EntityKill(client_entity)
                end]]


            end
        end,
        zone_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            if (not steam_utils.IsOwner( user))then
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
            networking.send.perk_update(lobby, data, user)
        end,
        player_data_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                print("not in arena")
                return
            end

            --[[
                template:
                local message = {
                    mFlyingTimeLeft = ComponentGetValue2(character_data_comp, "mFlyingTimeLeft"),
                }

            ]]
            if (not gameplay_handler.CheckPlayer(lobby, user, data)) then
                print("not a player")
                return
            end
            local client_entity = data.players[tostring(user)].entity
            local client_data = data.players[tostring(user)]

            if (data.spectator_mode or (GameHasFlagRun("player_is_unlocked")) and client_entity ~= nil and EntityGetIsAlive(client_entity)) then
                
                local character_data_comp = EntityGetFirstComponentIncludingDisabled(client_entity, "CharacterDataComponent")
                if (character_data_comp ~= nil) then
                    local player_data = {
                        status_list = message[1],
                        cosmetics = message[2],
                    }

                    local cosmetics_string = table.concat(player_data.cosmetics, ",")

                    --print("Received cosmetics: " .. cosmetics_string)
                    --print("Last cosmetics: " .. tostring(client_data.last_cosmetics))
                    
                    if(client_data.last_cosmetics ~= cosmetics_string)then
                        print("Applying cosmetics!!")
                        cosmetics_handler.ApplyCosmeticsList(lobby, data, client_entity, player_data.cosmetics, true, user)
                    end

                    client_data.last_cosmetics = cosmetics_string

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
                            data.players[tostring(user)].status_effect_comps[id] = EntityAddComponent2( client_entity, "SpriteComponent",
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
                            local effect_entity = nil
                            if(effect.effect_entity ~= nil)then
                                print("Loading effect of id: "..tostring(effect.id))
                                data.players[tostring(user)].status_effect_entities[id] = LoadGameEffectEntityTo( client_entity, effect.effect_entity )
                                print("New entity: " .. tostring(data.players[tostring(user)].status_effect_entities[id]))
                                effect_entity = data.players[tostring(user)].status_effect_entities[id]
                                local game_effect_comp = EntityGetFirstComponentIncludingDisabled(effect_entity, "GameEffectComponent")
                                if(game_effect_comp ~= nil)then
                                    ComponentSetValue2(game_effect_comp, "frames", -1)
                                    print("Loaded effect of id: "..tostring(effect.id))
                                end
                            else
                                data.players[tostring(user)].status_effect_entities[id] = EntityCreateNew("effect")
                                effect_entity = data.players[tostring(user)].status_effect_entities[id]
                                EntityAddComponent2(effect_entity, "InheritTransformComponent")
                                EntityAddComponent2(effect_entity, "GameEffectComponent", {
                                    effect = id,
                                    frames = -1,
                                })
                                EntityAddChild(client_entity, effect_entity)
                            end

                            if(effect_entity ~= 0 and effect_entity ~= nil)then

                                EntityAddComponent2(effect_entity, "UIIconComponent", {
                                    name = effect.ui_name,
                                    icon_sprite_file = effect.ui_icon,
                                    description = effect.ui_description,
                                    display_above_head = true,
                                    display_in_hud = false,
                                    is_perk = false,
                                })
                            end
                        end

                        valid_ids[id] = true
                    end

                    for k, v in pairs(data.players[tostring(user)].status_effect_entities)do
                        if(not valid_ids[k] or not EntityGetIsAlive(data.players[tostring(user)].status_effect_entities[k]))then
                            EntityKill(data.players[tostring(user)].status_effect_entities[k])
                            data.players[tostring(user)].status_effect_entities[k] = nil
                        end
                    end
                end
            end
        end,
        player_stats_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

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
                local damage_model_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
                if (character_data_comp ~= nil and damage_model_comp ~= nil) then
                    --[[
                        ComponentGetValue2(character_data_comp, "mFlyingTimeLeft"),
                        ComponentGetValue2(character_data_comp, "fly_time_max"),
                        ComponentGetValue2(damage_model_comp, "air_needed"),
                        ComponentGetValue2(damage_model_comp, "air_in_lungs"),
                        ComponentGetValue2(damage_model_comp, "air_in_lungs_max"),
                        ComponentGetValue2(damage_model_comp, "hp"),
                        ComponentGetValue2(damage_model_comp, "max_hp"),
                        ComponentGetValue2(damage_model_comp, "max_hp_cap"),
                        ComponentGetValue2(damage_model_comp, "max_hp_old"),
                    ]]
                    local player_data = message

                    ComponentSetValue2(character_data_comp, "mFlyingTimeLeft", player_data.mFlyingTimeLeft)
                    ComponentSetValue2(character_data_comp, "fly_time_max", player_data.fly_time_max)
                    ComponentSetValue2(damage_model_comp, "air_in_lungs", player_data.air_in_lungs)
                    ComponentSetValue2(damage_model_comp, "air_in_lungs_max", player_data.air_in_lungs_max)

                    local has_spectator = false

                    -- if we are in spectator mode
                    if (data.spectated_player == user and data.spectator_entity ~= nil and EntityGetIsAlive(data.spectator_entity)) then
                        has_spectator = true
                    end


                    if(has_spectator)then
                        local spectator_character_data_comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "CharacterDataComponent")
                        local spectator_damage_model_comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "DamageModelComponent")
                        local spectator_wallet_comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "WalletComponent")

                        if(spectator_character_data_comp ~= nil and spectator_damage_model_comp ~= nil)then
                            ComponentSetValue2(spectator_character_data_comp, "mFlyingTimeLeft", player_data.mFlyingTimeLeft)
                            ComponentSetValue2(spectator_character_data_comp, "fly_time_max", player_data.fly_time_max)
                            ComponentSetValue2(spectator_damage_model_comp, "air_in_lungs", player_data.air_in_lungs)
                            ComponentSetValue2(spectator_damage_model_comp, "air_in_lungs_max", player_data.air_in_lungs_max)
                            ComponentSetValue2(spectator_damage_model_comp, "hp", player_data.hp)
                            ComponentSetValue2(spectator_damage_model_comp, "max_hp", player_data.max_hp)
                            ComponentSetValue2(spectator_damage_model_comp, "max_hp_cap", player_data.max_hp_cap)
                            ComponentSetValue2(spectator_damage_model_comp, "max_hp_old", player_data.max_hp_old)
                            ComponentSetValue2(spectator_wallet_comp, "money", player_data.money)
                        end
                    end


                end
            end
        end,
        lock_ready_state = function(lobby, message, user, data)
            -- check if user is lobby owner
            if (not steam_utils.IsOwner( user)) then
                return
            end
            
            -- kill any entity with workshop tag to prevent wand edits
            --[[local all_entities = EntityGetWithTag("workshop")
            for k, v in pairs(all_entities) do
                EntityKill(v)
            end]]

            -- no more wand editting
            local player_entity = player.Get()

            if(player_entity)then
                local effect = EntityGetNamedChild(player_entity, "wand_edit")
                if(effect ~= nil and effect ~= 0)then
                    EntityKill(effect)
                end
            end
            

            GameAddFlagRun("lock_ready_state")
            GameAddFlagRun("player_ready")
            GameAddFlagRun("ready_check")
            GameRemoveFlagRun("player_unready")
        end,
        --[[request_spectate_data = function(lobby, message, user, data)
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
        end,]]
        item_picked_up = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            local item_id = message

            print("Client picked up item: " .. tostring(item_id))

            data.picked_up_items = data.picked_up_items or {}

            table.insert(data.picked_up_items, item_id)

            -- remove from network entity cache
            for k = #data.network_entity_cache, 1, -1 do
                local v = data.network_entity_cache[k]
                if(v[1] == item_id)then
                    table.remove(data.network_entity_cache, k)
                    break
                end
            end
        end,
        physics_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end
            data.network_entity_cache = data.network_entity_cache or {}

            local item_id = math.floor(message.id)
            local x, y, r, vx, vy, vr = message.x, message.y, message.r, message.vel_x, message.vel_y, message.vel_a

            
            local takes_control = message.takes_control
            local was_kick = message.was_kick

            local entities_cleanup = EntityGetInRadiusWithTag(0, 0, 1000, "does_physics_update")
            
            local has_found = false
            for k, v in ipairs(entities_cleanup)do
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id and EntityGetRootEntity(v) == v)then
                    if(has_found)then
                        EntityKill(v)
                    end

                    has_found = true
                end
            end

            if(not has_found)then
                return
            end
            
            local kick_handlers = {
                ["beamstone"] = function(entity_id)
                    dofile("data/scripts/items/beamstone_kick.lua")
                    trigger(entity_id)
                    print("beamstone triggered!")
                end
            }


            -- check cache
            for k = #data.network_entity_cache, 1, -1 do
                local v = data.network_entity_cache[k]
                if not EntityGetIsAlive(v[2]) then
                    table.remove(data.network_entity_cache, k)
                else
                    if(v[1] == item_id)then
                        local entity_id = v[2]

                        if(was_kick)then
                            for str, func in pairs(kick_handlers)do
                                local name = EntityGetName(entity_id)
                                -- check if name contains string
                                if(string.find(name, str))then
                                    func(entity_id)
                                end
                            end
                        end

                        if(takes_control)then
                            for i = #data.controlled_entities, 1, -1 do
                                if(data.controlled_entities[i] == entity_id)then
                                    table.remove(data.controlled_entities, i)
    
                                    --GamePrint("No longer in control")
    
                                end
                            end
                        end
    
                        local body_ids = PhysicsBodyIDGetFromEntity( entity_id )
                        if(body_ids ~= nil and #body_ids > 0)then
                            local body_id = body_ids[1]

                            PhysicsBodyIDSetTransform(body_id, x, y, r, vx, vy, vr)
                            
                        end
                        return
                    end
                end
            end
            
            local entities = EntityGetInRadiusWithTag(0, 0, 1000000000, "does_physics_update")


            for k, v in ipairs(entities)do
                --if(EntityGetFirstComponentIncludingDisabled(v, "ItemComponent") ~= nil)then
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id)then
                    
                    if(was_kick)then
                        for str, func in pairs(kick_handlers)do
                            local name = EntityGetName(entity_id)
                            -- check if name contains string
                            if(name ~= nil and name ~= "")then
                                if(string.find(name, str))then
                                    func(entity_id)
                                end
                            end
                        end
                    end

                    if(takes_control)then
                        for i = #data.controlled_entities, 1, -1 do
                            if(data.controlled_entities[i] == v)then
                                table.remove(data.controlled_entities, i)
                            end
                        end
                    end

                    table.insert(data.network_entity_cache, {item_id, v})

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
        entity_update = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end
            data.network_entity_cache = data.network_entity_cache or {}

            local item_id = math.floor(message.id)
            local x, y, r, vx, vy = message.x, message.y, message.r, message.vel_x, message.vel_y

            
            local takes_control = message.takes_control

            local entities_cleanup = EntityGetInRadiusWithTag(0, 0, 1000, "does_physics_update")
            
            local has_found = false
            for k, v in ipairs(entities_cleanup)do
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id and EntityGetRootEntity(v) == v)then
                    if(has_found)then
                        EntityKill(v)
                    end

                    has_found = true
                end
            end

            if(not has_found)then
                return
            end


            -- check cache
            for k = #data.network_entity_cache, 1, -1 do
                local v = data.network_entity_cache[k]
                if not EntityGetIsAlive(v[2]) then
                    table.remove(data.network_entity_cache, k)
                else
                    if(v[1] == item_id)then
                        local entity_id = v[2]

                        if(takes_control)then
                            for i = #data.controlled_entities, 1, -1 do
                                if(data.controlled_entities[i] == entity_id)then
                                    table.remove(data.controlled_entities, i)
    
                                    --GamePrint("No longer in control")
    
                                end
                            end
                        end
    
                        local velocity_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "VelocityComponent")
                        if(velocity_comp ~= nil)then
                            ComponentSetValue2(velocity_comp, "mVelocity", vx, vy)
                        end

                        EntityApplyTransform(entity_id, x, y, r)
                
                        return
                    end
                end
            end
            
            local entities = EntityGetInRadiusWithTag(0, 0, 1000000000, "does_physics_update")


            for k, v in ipairs(entities)do
                --if(EntityGetFirstComponentIncludingDisabled(v, "ItemComponent") ~= nil)then
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id)then

                    if(takes_control)then
                        for i = #data.controlled_entities, 1, -1 do
                            if(data.controlled_entities[i] == v)then
                                table.remove(data.controlled_entities, i)
                            end
                        end
                    end

                    table.insert(data.network_entity_cache, {item_id, v})

                    local velocity_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "VelocityComponent")
                    if(velocity_comp ~= nil)then
                        ComponentSetValue2(velocity_comp, "mVelocity", vx, vy)
                    end

                    EntityApplyTransform(entity_id, x, y, r)
                   
                    return
                end
            end
        end,
        sync_entity = function(lobby, message, user, data)
            if(data.state ~= "arena" and not data.spectator_mode)then
                return
            end

            -- if spectator, check if we are spectating the user
            if(data.spectator_mode and data.state ~= "arena" and data.spectated_player ~= user)then
                return
            end

            local item_id = message[1]
            local entity_data = message[2]

            
            local entities_cleanup = EntityGetInRadiusWithTag(0, 0, 1000, "does_physics_update")
            
            local has_found = false
            for k, v in ipairs(entities_cleanup)do
                local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                if(entity_id ~= nil and entity_id == item_id and EntityGetRootEntity(v) == v)then
                    if(has_found)then
                        print("Killing entity: " .. tostring(v))
                        EntityKill(v)
                    end

                    has_found = true
                end
            end

            if(has_found)then
                print("Entity already loaded!")
                return
            end

            -- spawn entity!
            local new_entity = EntityCreateNew()
            np.DeserializeEntity(new_entity, entity_data)
            EntityRemoveTag(new_entity, "picked_by_player")

            print("Synced entity: " .. tostring(new_entity))
         
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
        
            local player_entity = player_helper.Get()

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
                EntityRemoveIngestionStatusEffect( player_entity, "TRIP" );
        
                local x, y = GameGetCameraPos()

                -- audio
                GameTriggerMusicFadeOutAndDequeueAll( 5.0 )
                GameTriggerMusicEvent( "music/oneshot/tripping_balls_01", false, x, y )
        
                -- particle fx
                local eye = EntityLoad( "data/entities/particles/treble_eye.xml", x,y-10 )
                if eye ~= 0 then
                    EntityAddChild( player_entity, eye )
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
                local children = EntityGetAllChildren(player_entity)
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
                    EntityAddChild( player_entity, icon_entity )
                end
            end
        end,
        start_map_vote = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            --GamePrint("starting map vote")
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
            if (not steam_utils.IsOwner( user))then
                return
            end
            local frames = message
            if(data.vote_loop ~= nil)then
                data.vote_loop.frames = frames
            end
        end,
        map_vote_finish = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            if(data.vote_loop ~= nil)then
                data.vote_loop.vote_finished = true
                data.vote_loop.winner = message[1]
                data.vote_loop.was_tie = message[2]
            end
        end,
        load_lobby = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            ArenaGameplay.LoadLobby(lobby, data, false)
        end,
        update_round = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            GlobalsSetValue("holyMountainCount", tostring(message))
        end,
        update_world_seed = function(lobby, message, user, data)
            if (not steam_utils.IsOwner( user))then
                return
            end
            SetWorldSeed( message )
        end,
        send_skin = function(lobby, message, user, data)
            if data.players[tostring(user)] then
                data.players[tostring(user)].skin_data = message

                if(skin_system and lobby)then
                    skin_system.update_client_skin(lobby, data.players[tostring(user)].entity, user, data)
                end

                if(data.players[tostring(user)].entity)then
                    if(skin_system and lobby)then
                        skin_system.apply_skin_to_entity(lobby, data.players[tostring(user)].entity, user, data)
                    end
                end
            end
        end,
        request_skins = function(lobby, message, user, data)
            if(skin_system.active_skin_data)then
                networking.send.send_skin(lobby, skin_system.active_skin_data, user)
            end
        end,
        request_sync_hm = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end

            --print("received HM sync request.")
            networking.send.sync_hm(lobby, data, user, message[1] or nil)
        end,
        picked_heart = function (lobby, message, user, data)
            if(message)then
                steamutils.AddLobbyFlag(lobby, tostring(user).."picked_heart")
            else
                steamutils.RemoveLobbyFlag(lobby, tostring(user).."picked_heart")
            end
        end,
        sync_hm = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end

            if(GameHasFlagRun("lock_ready_state") or not data.spectator_mode)then
                return
            end

            -- if user is not spectated player, return
            if(user ~= data.spectated_player)then
                return
            end

            data.last_hm_sync = data.last_hm_sync or 0

            if(data.last_hm_sync and GameGetFrameNum() - data.last_hm_sync < 15)then
                return
            end

            data.last_hm_sync = GameGetFrameNum()

            -- destroy all applicable entities
            SpectatorMode.ClearHM()


            local entities = message[2]

            data.last_synced_entity_count = #entities
            
            --networking.send.request_second_row(lobby, user)

            --delay.new(2, function()

            local second_row_entities = EntityGetWithTag("hm_platform")
            for k, v in ipairs(second_row_entities)do
                EntityKill(v)
            end

            local second_row_spots = message[1]
            
            for k, v in ipairs(second_row_spots)do
                local x, y = unpack(v)
                --print("Spawning second row at: " .. tostring(x) .. ", " .. tostring(y))
                --LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x, y, "", true )
                EntityLoad("mods/evaisa.arena/files/entities/misc/hm_shop_platform.xml", x, y)
            end


            for k, v in ipairs(entities)do
                local ent = EntityCreateNew()
                local x, y, entity_data, uid = unpack(v)
                np.DeserializeEntity(ent, entity_data, x, y)
                EntityRemoveTag(ent, "picked_by_player")
                local name = EntityGetFilename(ent)
            end



            --end)
            
        end,
        pick_hm_entity = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end
            local uid = message

            print("Picking HM entity: " .. tostring(uid))

            local entity = EntityGetWithName(uid)
            if(entity ~= nil and entity ~= 0 and data.players[tostring(user)])then
                local p = data.players[tostring(user)].entity
                local was_perk = false
                if(p ~= nil)then
                    --[[
                    local itemCostComp = EntityGetFirstComponentIncludingDisabled(entity, "ItemCostComponent")
                    if(itemCostComp)then
                        EntityRemoveComponent(entity, itemCostComp)
                    end

                    local itemPickUpperComponent = EntityGetFirstComponentIncludingDisabled(p, "ItemPickUpperComponent")
                    if(itemPickUpperComponent)then
                        ComponentSetValue2(itemPickUpperComponent, "only_pick_this_entity", entity)
                    end
                    ]]
                    if(EntityGetIsAlive(entity))then
                        local was_refresh = false

                        local entity_x, entity_y = EntityGetTransform(entity)
                        if(EntityHasTag(entity, "perk"))then

                            was_perk = true
                            EntityLoad( "data/entities/particles/image_emitters/perk_effect.xml", entity_x, entity_y - 8 )

                        elseif(EntityGetFilename(entity) == "mods/evaisa.arena/files/entities/misc/spell_refresh.xml")then
                            was_refresh = true
                            data.last_refreshed = data.last_refreshed or 0
                            if(GameGetFrameNum() - data.last_refreshed > 60)then
                                data.last_refreshed = GameGetFrameNum()
                                EntityLoad("data/entities/particles/image_emitters/spell_refresh_effect.xml", entity_x, entity_y-12)
                            end
                        elseif(EntityHasTag(entity, "heart"))then
                            EntityLoad("data/entities/particles/image_emitters/heart_fullhp_effect.xml", entity_x, entity_y-12)
                            EntityLoad("data/entities/particles/heart_out.xml", entity_x, entity_y-8)
                        else
                            EntityLoad("data/entities/particles/image_emitters/shop_effect.xml", entity_x, entity_y - 8)
                        end

                        if(not was_refresh)then
                            local comps = EntityGetAllComponents(entity)
        
                            for k2, v2 in ipairs(comps)do
                                EntitySetComponentIsEnabled(entity, v2, false)
                            end

                            local material_storage = EntityGetFirstComponentIncludingDisabled(entity, "MaterialInventoryComponent")
                            if(material_storage ~= nil)then
                                EntityRemoveComponent(entity, material_storage)
                            end

                            EntityKill(entity)
                        end

                        if(not was_refresh)then
                            networking.send.request_item_update(lobby, user)
                            networking.send.request_sync_hm(lobby, user)
                        end
                        --networking.send.request_spectate_data(lobby, user)
                    end
                end

                if(was_perk)then
                    
                    --[[for k, v in ipairs(EntityGetWithTag("client") or {})do
                        data.client_spawn_x, data.client_spawn_y = EntityGetTransform(v)
                        EntityKill(v)
                    end
    
                    SpectatorMode.ClearHM()]]

                    print("requesting perk update")

                    networking.send.request_perk_update(lobby, user)
                end
            end
        end,
        request_second_row = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end
            --print(GlobalsGetValue("temple_second_row_spots", "{}"))
            local second_row_spots = smallfolk.loads(GlobalsGetValue("temple_second_row_spots", "{}"))

            steamutils.sendToPlayer("second_row_spots", second_row_spots, user, true, true)
        end,
        second_row_spots = function(lobby, message, user, data)

            if(user ~= data.spectated_player or data.state ~= "lobby")then
                return
            end

            -- kill all old second row entities
            local second_row_entities = EntityGetWithTag("hm_platform")
            for k, v in ipairs(second_row_entities)do
                EntityKill(v)
            end

            local second_row_spots = message
            
            for k, v in ipairs(second_row_spots)do
                local x, y = unpack(v)
                --print("Spawning second row at: " .. tostring(x) .. ", " .. tostring(y))
                --LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x, y, "", true )
                EntityLoad("mods/evaisa.arena/files/entities/misc/hm_shop_platform.xml", x, y)
            end
        end,
        hm_timer_update = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                if(data.hm_timer ~= nil)then
                    data.hm_timer.clear()
                    data.hm_timer = nil
                end
                return
            end
            if(not steam_utils.IsOwner( user))then
                return
            end

            local frames = message

            if(data.hm_timer == nil)then
                local hm_timer_time = tonumber(GlobalsGetValue("hm_timer_time", "60"))
                
                local timer_frames = tonumber(hm_timer_time) * 60
                data.hm_timer = delay.new(timer_frames, function()
                    if(steam_utils.IsOwner())then
                        ArenaGameplay.ForceReady(lobby, data)
                    end
                    if(data.hm_timer_gui)then
                        GuiDestroy(data.hm_timer_gui)
                        data.hm_timer_gui = nil
                    end
                end, function(frame)
                    --print("HM Tick: "..tostring(frame))
                    local seconds_left = math.floor((frame) / 60)
                    
                    -- format as seconds more minutes
                    local time_string = "0s"
                    if(seconds_left >= 60)then
                        local minutes = math.floor(seconds_left / 60)
                        local seconds = seconds_left % 60
                        time_string = tostring(minutes).."m "..tostring(seconds).."s"
                    else
                        time_string = tostring(seconds_left).."s"
                    end

                    local message = string.format(GameTextGetTranslatedOrNot("$arena_hm_timer_string"), time_string)
  
                    networking.send.hm_timer_update(lobby, frame)

                    data.hm_timer_gui = data.hm_timer_gui or GuiCreate()
                    GuiStartFrame(data.hm_timer_gui)

                    local screen_w, screen_h = GuiGetScreenDimensions(data.hm_timer_gui)

                    -- draw text at bottom center of screen
                    local text_width, text_height = GuiGetTextDimensions(data.hm_timer_gui, message)

                    GuiZSetForNextWidget(data.hm_timer_gui, -11)
                    GuiText(data.hm_timer_gui, (screen_w / 2) - (text_width / 2), screen_h - text_height - 10, message)
                end)
            else
                data.hm_timer.frames = frames
            end
        end,
        hm_timer_clear = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end
            if(not steam_utils.IsOwner( user))then
                return
            end
            if(data.hm_timer)then
                data.hm_timer.clear()
                data.hm_timer = nil
            end
        end,
        update_state = function(lobby, message, user, data)
            local state = message

            if(data.players[tostring(user)])then
                data.players[tostring(user)].state = state

                if(state == "arena" and data.state == "arena")then
                    gameplay_handler.LoadClientPlayers(lobby, data)
                end
            end
        end,
        set_map = function(lobby, message, user, data)
            steam_utils.TrySetLobbyData(lobby, "current_map", message)
            print("Setting current map to "..tostring(message))
        end,
        request_character_position = function(lobby, message, user, data)
            networking.send.character_position(lobby, data, false, user)
        end,
        request_dummy_target = function(lobby, message, user, data)
            networking.send.dummy_target(lobby, data.target_dummy_player, user)
        end,
        dummy_target = function(lobby, message, user, data)
            if(not data.spectator_mode or user ~= data.spectated_player or data.state ~= "lobby")then
                return
            end

            local player = ArenaGameplay.FindUser(lobby, message)

            if(player)then
                data.target_dummy_player = player
                GameAddFlagRun("refresh_dummy")
            end
        end,
        request_card_list = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end
            if(data.spectator_mode)then
                return
            end
            networking.send.card_list(lobby, data, user)
        end,
        card_list = function(lobby, message, user, data)
            if(not data.spectator_mode or user ~= data.spectated_player or data.state ~= "lobby")then
                return
            end

            print("Received card list.")

            if( data.upgrade_system == nil )then
                data.upgrade_system = upgrade_system.create(message, function(upgrade)
                    data.upgrade_system = nil
                end)
                print("Created upgrade system.")
            else
                data.upgrade_system:clean()
                data.upgrade_system = upgrade_system.create(message, function(upgrade)
                    data.upgrade_system = nil
                end)
                print("Updated upgrade system.")
            end

            networking.send.request_card_list_state(lobby, user)
        end,
        request_card_list_state = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end
            if(data.spectator_mode)then
                return
            end

            networking.send.card_list_state(lobby, data, user)
        end,
        card_list_state = function(lobby, message, user, data)
            if(not data.spectator_mode or user ~= data.spectated_player or data.state ~= "lobby")then
                return
            end

            if(message[1] == nil)then
                print("Received nil message (card list state), destroying")
                local card = data.upgrade_system.upgrades[data.upgrade_system.selected_index]
                
                GamePrintImportant(GameTextGetTranslatedOrNot(card.ui_name), GameTextGetTranslatedOrNot(card.ui_description))

                data.upgrade_system:clean()
                data.upgrade_system = nil

                local card_entity = EntityGetWithTag("card_pick")
                for k, v in ipairs(card_entity) do
                    EntityKill(v)
                    --print("killed card entity")
                end

                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
            end

            local open = message[1]
            local selected = message[2]
            
            if(open)then
                print("Opening card menu.")
                GameAddFlagRun("card_menu_open")
            else
                print("Closing card menu.")
                GameRemoveFlagRun("card_menu_open")
            end

            if(data.upgrade_system)then
                data.upgrade_system.selected_index = selected
                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_select", 0, 0)
                print("Setting selected index to "..tostring(selected))
            end
        end,
        swap_positions = function(lobby, message, user, data)
            if(data.state ~= "arena")then
                return
            end
            if(data.spectator_mode)then
                return
            end

            local target = data.players[tostring(user)]
            if(target == nil)then
                return
            end

            local target_entity = target.entity
            if(target_entity == nil or not EntityGetIsAlive(target_entity))then
                return
            end

            local target_x, target_y = message[1], message[2]
            local player_entity = player_helper.Get()
            if(player_entity == nil or not EntityGetIsAlive(player_entity))then
                return
            end

            local x, y = EntityGetTransform(player_entity)

            EntityLoad("data/entities/particles/teleportation_source.xml", x, y)
            EntityLoad("data/entities/particles/teleportation_target.xml", target_x, target_y)

            EntityApplyTransform(player_entity, target_x, target_y)
        end,
        spawn_trailer_effects = function(lobby, message, user, data)
            if(data.state ~= "arena")then
                return
            end

            local particle_positions = {
                original = {x = 0, y = -80},
                spoop = {x = -107, y = 81},
                tryon = {x = -4, y = -57},
                bureon = {x = 0, y = -8},
                stadium = {x = 247, y = -83},
                coalpit = {x = -33, y = -39},
                mimicstemple = {x = 6.681, y = -178},
                foundry = {x = 172.231, y = -197.123},
            }

            --EntityLoad("mods/evaisa.arena/files/entities/particles/trailer/arena_logo.xml", 0, -100)
            local current_map = steamutils.GetLobbyData("current_map")

            if (particle_positions[current_map] ~= nil) then
                local x = particle_positions[current_map].x
                local y = particle_positions[current_map].y
                EntityLoad("mods/evaisa.arena/files/entities/particles/trailer/arena_logo.xml", x, y)
            else
                local x = particle_positions.original.x
                local y = particle_positions.original.y
                EntityLoad("mods/evaisa.arena/files/entities/particles/trailer/arena_logo.xml", x, y)
            end
        end,
        is_spectating = function(lobby, message, user, data)
            if(data.spectator_mode)then
                return
            end

            print("Setting spectator mode for player ["..tostring(user).."] to "..tostring(message))

            data.spectators = data.spectators or {}

            if(message)then
                if(not data.spectators[tostring(user)])then
                    -- send updates
                    

                    local second_row_spots = smallfolk.loads(GlobalsGetValue("temple_second_row_spots", "{}"))
                    steamutils.sendToPlayer("second_row_spots", second_row_spots, user, true, true)

                    networking.send.sync_hm(lobby, data, user)
                    networking.send.item_update(lobby, data, user, true)
                    networking.send.send_skin(lobby, skin_system.active_skin_data, user)
                    networking.send.perk_update(lobby, data, user)
                    networking.send.character_position(lobby, data, true, user)
                    networking.send.dummy_target(lobby, data.target_dummy_player, user)
                    networking.send.card_list(lobby, data, user)


                    world_sync.add_chunks(-512, -512, 1280, 1280)
                end
                data.spectators[tostring(user)] = true
            else
                data.spectators[tostring(user)] = nil
            end
        end,
        sync_world = function(lobby, message, user, data)
            if(data.state ~= "lobby")then
                return
            end

            if(not data.spectator_mode)then
                return
            end

            if(data.spectated_player ~= user)then
                networking.send.is_spectating(user, false)
                return
            end

            --[[message = message or {}

            for i = 0, #message do 
                local v = message[i]
                if(v)then
                    world_sync.apply(v)
                end
            end]]
            world_sync.apply(message)
        end,
        did_spectate = function(lobby, message, user, data)
            if(not data.spectator_mode)then
                return
            end

            if(data.spectated_player ~= user)then
                networking.send.is_spectating(user, false)
            else
                networking.send.is_spectating(user, true)
            end

            
        end,
    },
    send = {
        handshake = function(lobby)
            steamutils.send("handshake", { GameGetFrameNum(), (game_funcs.UintToString(game_funcs.GetUnixTimestamp())) },
                steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        request_perk_update = function(lobby, user)
            if(user == nil)then
                steamutils.send("request_perk_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            else
                steamutils.sendToPlayer("request_perk_update", {}, user, true)
            end
        end,
        ready = function(lobby, is_ready, silent)
            silent = silent or false
            steamutils.send("ready", { is_ready, silent }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        request_ready_states = function(lobby)
            steamutils.send("request_ready_states", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
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
        check_can_unlock = function(lobby)
            steamutils.send("check_can_unlock", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
        end,
        request_character_position = function(lobby, user)
            if(user == nil)then
                steamutils.send("request_character_position", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            else
                steamutils.sendToPlayer("request_character_position", {}, user, true)
            end
        end,
        character_position = function(lobby, data, to_spectators, user)
            local t = GameGetRealWorldTimeSinceStarted()
            local min_framerate = 30 -- Minimum acceptable framerate
            local frame_delay = 60 / min_framerate -- Calculate frame delay based on minimum framerate
            local last_update_frame = 0 -- Track the last frame when an update was sent
        
            local current_frame = GameGetFrameNum()
            local player = player_helper.Get()
        
            if player then
                local x, y = EntityGetTransform(player)
                local characterData = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                local characterPlatformingComp = EntityGetFirstComponentIncludingDisabled(player, "CharacterPlatformingComponent")
                local vel_x, vel_y = ComponentGetValue2(characterData, "mVelocity")
        
                local c = CharacterPos{
                    frames_in_air = ComponentGetValue2(characterPlatformingComp, "mFramesInAirCounter"),
                    x = x,
                    y = y,
                    vx = vel_x,
                    vy = vel_y,
                    is_on_ground = ComponentGetValue2(characterData, "is_on_ground"),
                    is_on_slippery_ground = ComponentGetValue2(characterData, "is_on_slippery_ground"),
                }

                if(data.client.last_character_pos == nil)then
                    data.client.last_character_pos = c
                end

                -- use ffi.C.memcmp() to check if the character state has changed
                local memcmp_result = memcmp(ffi.new("CharacterPos", data.client.last_character_pos), ffi.new("CharacterPos", c), ffi.sizeof("CharacterPos"))

                -- if same, return
                if(memcmp_result == 0 and user ~= nil)then
                    return
                end
        
                -- Check if it's time to send an update based on frame delay
                if current_frame - last_update_frame >= frame_delay then
                    -- Update last_update_frame to current frame
                    last_update_frame = current_frame
        
                    if(user ~= nil)then
                        steamutils.sendToPlayer("character_position", c, user, true, 4)
                    elseif to_spectators then
                        steamutils.send("character_position", c, steamutils.messageTypes.Spectators, lobby, true, true, 4)
                    else
                        steamutils.send("character_position", c, steamutils.messageTypes.OtherPlayers, lobby, false, true, 4)
                    end
                end

                data.client.last_character_pos = c
            end
        end,
        item_update = function(lobby, data, user, force, to_spectators)

            local playerEnt = player_helper.Get()
            if (playerEnt == nil) then
                return;
            end

            local all_data = player_helper.GetItemData()

            local item_data, spell_data = all_data[1], all_data[2]


            local message = { item_data or {}, force, GameHasFlagRun( "arena_unlimited_spells" ), spell_data or {}, GameGetFrameNum() }

            if (user ~= nil) then
                steamutils.sendToPlayer("item_update", message, user, true)
            else
                if(to_spectators)then
                    steamutils.send("item_update", message, steamutils.messageTypes.Spectators, lobby, true, true)
                else
                    steamutils.send("item_update", message, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                end
            end
        end,
        request_item_update = function(lobby, user)
            if(user == nil)then
                steamutils.send("request_item_update", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            else
                steamutils.sendToPlayer("request_item_update", {}, user, true)
            end
        end,
        keyboard = function(lobby, data, to_spectators)
            local player = player_helper.Get()
            if (player == nil) then
                return
            end
            local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")

            
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

                local c = Keyboard{
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
                }

                -- memcmp previous keyboard state to current state
                if(data.client.previous_keyboard == nil)then
                    data.client.previous_keyboard = c
                end

                -- use ffi.C.memcmp() to check if the keyboard state has changed
      
                local memcmp_result = memcmp(ffi.new("Keyboard", data.client.previous_keyboard), ffi.new("Keyboard", c), ffi.sizeof("Keyboard"))
                
                -- if same, return
                if(memcmp_result == 0)then
                    return
                end
                
                if(to_spectators)then
                    steamutils.send("keyboard", c, steamutils.messageTypes.Spectators, lobby, true, true, 6)
                else
                    steamutils.send("keyboard", c, steamutils.messageTypes.OtherPlayers, lobby, true, true, 6)
                end

                data.client.previous_keyboard = c
            end
        end,
        mouse = function(lobby, data, to_spectators)
            local player = player_helper.Get()
            if (player == nil) then
                return
            end
            local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")

            
            if (controls ~= nil) then
                local aim_x, aim_y = ComponentGetValue2(controls, "mAimingVector") -- float, float
                local aimNormal_x, aimNormal_y = ComponentGetValue2(controls, "mAimingVectorNormalized") -- float, float
                local aimNonZero_x, aimNonZero_y = ComponentGetValue2(controls, "mAimingVectorNonZeroLatest") -- float, float
                local mouse_x, mouse_y = ComponentGetValue2(controls, "mMousePosition") -- float, float
                local mouseRaw_x, mouseRaw_y = ComponentGetValue2(controls, "mMousePositionRaw") -- float, float
                local mouseRawPrev_x, mouseRawPrev_y = ComponentGetValue2(controls, "mMousePositionRawPrev") -- float, float
                local mouseDelta_x, mouseDelta_y = ComponentGetValue2(controls, "mMouseDelta") -- float, float

                local c = Mouse{
                    aim_x = aim_x,
                    aim_y = aim_y,
                    mouse_x = mouse_x,
                    mouse_y = mouse_y,
                    mouseRaw_x = mouseRaw_x,
                    mouseRaw_y = mouseRaw_y,
                }

                if(data.client.previous_mouse == nil)then
                    data.client.previous_mouse = c
                end
      
                local memcmp_result = memcmp(ffi.new("Mouse", data.client.previous_mouse), ffi.new("Mouse", c), ffi.sizeof("Mouse"))
                
                -- if same, return
                if(memcmp_result == 0)then
                    return
                end
                
                if(to_spectators)then
                    steamutils.send("mouse", c, steamutils.messageTypes.Spectators, lobby, true, true, 7)
                else
                    steamutils.send("mouse", c, steamutils.messageTypes.OtherPlayers, lobby, true, true, 7)
                end

                data.client.previous_mouse = c
            end
        end,
        player_stats_update = function(lobby, data, to_spectators)

            local player = player_helper.Get()
            if(player ~= nil and EntityGetIsAlive(player))then
                local character_data_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                local damage_model_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
                local wallet_comp = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
                if(character_data_comp ~= nil and damage_model_comp ~= nil)then
                    local message = PlayerStats{
                        mFlyingTimeLeft = ComponentGetValue2(character_data_comp, "mFlyingTimeLeft"),
                        fly_time_max = ComponentGetValue2(character_data_comp, "fly_time_max"),
                        air_in_lungs = ComponentGetValue2(damage_model_comp, "air_in_lungs"),
                        air_in_lungs_max = ComponentGetValue2(damage_model_comp, "air_in_lungs_max"),
                        hp = ComponentGetValue2(damage_model_comp, "hp"),
                        max_hp = ComponentGetValue2(damage_model_comp, "max_hp"),
                        max_hp_cap = ComponentGetValue2(damage_model_comp, "max_hp_cap"),
                        max_hp_old = ComponentGetValue2(damage_model_comp, "max_hp_old"),
                        money = ComponentGetValue2(wallet_comp, "money"),
                    }

                    -- memcmp
                    if(data.client.last_player_stats == nil)then
                        data.client.last_player_stats = message
                    end

                    local memcmp_result = memcmp(ffi.new("PlayerStats", data.client.last_player_stats), ffi.new("PlayerStats", message), ffi.sizeof("PlayerStats"))
                    
                    -- if same, return
                    if(memcmp_result == 0)then
                        return
                    end

                    if(to_spectators)then
                        steamutils.send("player_stats_update", message, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("player_stats_update", message, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end

                    data.client.last_player_stats = message
                end
            end
        end,
        player_data_update = function(lobby, data, to_spectators)
            local player = player_helper.Get()
            if(player ~= nil and EntityGetIsAlive(player))then
                local character_data_comp = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
                if(character_data_comp ~= nil)then
                    
                    local cosmetics = {}
                    for k, v in pairs(data.cosmetics)do
                        table.insert(cosmetics, k)
                    end
                    
                    local status_list = GetActiveStatusEffects(player, true)

                    local message = {
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
            local rectAnim = player_helper.GetAnimationData()
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
            local held_item = player_helper.GetActiveHeldItem()
            if (held_item ~= nil and held_item ~= 0) then
     
                local item_comp = EntityGetFirstComponentIncludingDisabled(held_item, "ItemComponent")

                -- the hell??
                if(item_comp == nil)then
                    return
                end

                local slot_x, slot_y = ComponentGetValue2(item_comp, "inventory_slot")
                local ability_comp = EntityGetFirstComponentIncludingDisabled(held_item, "AbilityComponent")
                
                local is_wand = false
                if(ability_comp and ComponentGetValue2(ability_comp, "use_gun_script"))then
                    is_wand = true
                end

                local item = ItemSwitch{
                    is_wand = is_wand,
                    slot_x = slot_x,
                    slot_y = slot_y,
                }

                if (user == nil) then
                    if(to_spectators)then
                        steamutils.send("switch_item", item, steamutils.messageTypes.Spectators, lobby, true, true)
                    else
                        steamutils.send("switch_item", item, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                    end
                    --data.client.previous_selected_item = held_item
                else
                    steamutils.sendToPlayer("switch_item", item, user, true)
                end
    
            end
        end,
        sync_wand_stats = function(lobby, data, to_spectators)
            local held_item = player_helper.GetActiveHeldItem()
            if (held_item ~= nil) then
                -- if has ability component
                local abilityComp = EntityGetFirstComponentIncludingDisabled(held_item, "AbilityComponent")
                if (abilityComp) then

                    --[[
                    local spell_uses_table = {}

                    local spell_table_changed = false
                    
                    local children = EntityGetAllChildren(held_item) or {}
                    for k, v in ipairs(children)do
                        if(EntityHasTag(v, "card_action"))then
                            local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                            if(item_comp ~= nil)then
                                local inventory_slot = ComponentGetValue2(item_comp, "inventory_slot")
                                local uses_remaining = ComponentGetValue2(item_comp, "uses_remaining")
                                spell_uses_table[tostring(inventory_slot)] = uses_remaining
                                if(data.client.previous_wand_stats.spell_uses_table ~= nil)then
                                    if(data.client.previous_wand_stats.spell_uses_table[tostring(inventory_slot)] ~= nil)then
                                        if(data.client.previous_wand_stats.spell_uses_table[tostring(inventory_slot)] ~= uses_remaining)then
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
                    ]]
                    

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
                            data.client.previous_wand_stats.mNextChargeFrame ~= next_charge_frame--[[ or
                            spell_table_changed]]) then
                        data.client.previous_wand_stats.mana = mana
                        data.client.previous_wand_stats.mCastDelayStartFrame = cast_delay_start_frame
                        data.client.previous_wand_stats.mReloadFramesLeft = reload_frames_left
                        data.client.previous_wand_stats.mReloadNextFrameUsable = reload_next_frame_usable
                        data.client.previous_wand_stats.mNextChargeFrame = next_charge_frame
                        --data.client.previous_wand_stats.spell_uses_table = spell_uses_table
                        
                        --[[local msg_data = {
                            mana,
                            GameGetFrameNum() - cast_delay_start_frame,
                            reload_frames_left,
                            reload_next_frame_usable - GameGetFrameNum(),
                            next_charge_frame - GameGetFrameNum(),
                            --spell_uses_table,
                        }]]
                        

                        local msg_data = WandStats{
                            mana = mana,
                            cast_delay_start_frame = GameGetFrameNum() - cast_delay_start_frame,
                            reload_frames_left = reload_frames_left,
                            reload_next_frame_usable = reload_next_frame_usable - GameGetFrameNum(),
                            next_charge_frame = next_charge_frame - GameGetFrameNum(),
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
            local health, max_health = player_helper.GetHealthInfo()

            if (health ~= nil and max_health ~= nil) then
                if ((data.client.max_hp ~= max_health or data.client.hp ~= health) or force) then
                   -- print(GlobalsGetValue("last_damage_details", ""))
                    local damage_details, attacker = deserialize_damage_details(GlobalsGetValue("last_damage_details", ""))

                    if(not GameHasFlagRun("player_died"))then
                        GlobalsSetValue("last_damage_details", "")
                    end

                    local damage = nil
                    local invincibility_frames = nil
                    --print(json.stringify(damage_details))
                    data.client.max_hp = max_health
                    data.client.hp = health

                    if(force and GameHasFlagRun("prepared_damage"))then
                        damage = 0.04
                        invincibility_frames = tonumber(GlobalsGetValue("invincibility_frames", "5"))
                    end

                    steamutils.send("health_update", {attacker, health, max_health, damage_details, damage, invincibility_frames }, steamutils.messageTypes.OtherPlayers, lobby,
                        true, true)
                end
            end
        end,
        perk_update = function(lobby, data, user)

            local player_perks = player_helper.GetPerks()
            

            local perk_info = {}
            local perk_info_self = {}
            --[[for i, perk_data in ipairs(perk_list) do
                local perk_id = perk_data.id
                local flag_name = get_perk_picked_flag_name(perk_id)

                local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

                if GameHasFlagRun(flag_name) and (pickup_count > 0) then
                    --print("Has flag: " .. perk_id)
                    table.insert(perk_info, { perk_enum[perk_id], pickup_count })
                    table.insert(perk_info_self, { perk_id, pickup_count })
                end
            end]]

            for i, perk_data in ipairs(player_perks) do
                table.insert(perk_info, { perk_enum[perk_data.id], perk_data.count })
                table.insert(perk_info_self, { perk_data.id, perk_data.count })
            end

            local perk_string = bitser.dumps(perk_info)
            if (user ~= nil or perk_string ~= data.client.previous_perk_string) then
                if(user)then
                    steamutils.sendToPlayer("perk_update", perk_info, user, true, true)
                else
                    steamutils.send("perk_update", perk_info, steamutils.messageTypes.OtherPlayers, lobby, true, true)
                end

                data.client.previous_perk_string = perk_string
                data.client.perks = perk_info_self
            end
        end,
        fire_wand = function(lobby, rng, special_seed, to_spectators)
            local player = player_helper.Get()
            if (player) then
                local wand = EntityHelper.GetHeldItem(player)

                if (wand ~= nil) then
                    local x, y, r = EntityGetTransform(wand)

                   

                    --[[local data = {
                        x,
                        y,
                        r,
                        rng,
                        special_seed,
                        GlobalsGetValue("player_action_rng", "0")
                    }]]


                    local c = FireWand{
                        x = x,
                        y = y,
                        r = r,
                        special_seed = tonumber(special_seed),
                        action_rng = tonumber(GlobalsGetValue("player_action_rng", "0"))
                    }

                    GlobalsSetValue("player_action_rng", "0")
                    
                    if(to_spectators)then
                        steamutils.send("fire_wand", {rng, c}, steamutils.messageTypes.Spectators, lobby, false, true)
                    else
                        steamutils.send("fire_wand", {rng, c}, steamutils.messageTypes.OtherPlayers, lobby, false, true)
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
        --[[request_spectate_data = function(lobby, user)
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

        end,]]
        --[[allow_round_end = function(lobby)
            steamutils.send("allow_round_end", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,]]
        round_end = function(lobby, winner, win_condition)
            steamutils.send("round_end", { tostring(winner), win_condition }, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        item_picked_up = function(lobby, item_id, to_spectators)
            if(to_spectators)then
                steamutils.send("item_picked_up", item_id, steamutils.messageTypes.Spectators, lobby, true, true)
            else
                steamutils.send("item_picked_up", item_id, steamutils.messageTypes.OtherPlayers, lobby, true, true)
            end
        end,
        physics_update = function(lobby, id, x, y, r, vel_x, vel_y, vel_a, takes_control, was_kick)
            local c = PhysicsUpdate{
                id = id,
                x = x,
                y = y,
                r = r,
                vel_x = vel_x,
                vel_y = vel_y,
                vel_a = vel_a,
                takes_control = takes_control,
                was_kick = was_kick
            }
            steamutils.send("physics_update", c, steamutils.messageTypes.OtherPlayers, lobby, true, true, 2)
        end,
        entity_update = function(lobby, id, x, y, r, vel_x, vel_y, takes_control)
            local c = EntityUpdate{
                id = id,
                x = x,
                y = y,
                r = r,
                vel_x = vel_x,
                vel_y = vel_y,
                takes_control = takes_control,
            }
            steamutils.send("entity_update", c, steamutils.messageTypes.OtherPlayers, lobby, true, true, 3)
        end,
        sync_entity = function(lobby, arena_entity_id, entity_data, to_spectators)
            if(to_spectators)then
                steamutils.send("sync_entity", {arena_entity_id, entity_data}, steamutils.messageTypes.Spectators, lobby, true, true)
            else
                steamutils.send("sync_entity", {arena_entity_id, entity_data}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
            end
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
            steamutils.send("map_vote_timer_update", frames, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        map_vote_finish = function(lobby, winner, was_tie)
            steamutils.send("map_vote_finish", {winner, was_tie}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        load_lobby = function(lobby)
            steamutils.send("load_lobby", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        update_round = function(lobby, round)
            steamutils.send("update_round", round, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        update_world_seed = function(lobby, seed)
            steamutils.send("update_world_seed", seed, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        send_skin = function(lobby, skin_data, user) 
            if (user ~= nil) then
                steamutils.sendToPlayer("send_skin", skin_data, user, true)
            else
                steamutils.send("send_skin", skin_data, steamutils.messageTypes.OtherPlayers, lobby, true, true)
            end
        end,
        request_skins = function(lobby)
            steamutils.send("request_skins", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        request_skin = function(lobby, user)
            steamutils.sendToPlayer("request_skins", {}, user, true)
        end,
        request_sync_hm = function(lobby, user, count)
            steamutils.sendToPlayer("request_sync_hm", {count}, user, true)
        end,
        sync_hm = function(lobby, data, user, count)

            --print("sending HM")

            if(data.state ~= "lobby")then
                return
            end

            
            

            delay.new(function()
                local valid = #(EntityGetWithTag("workshop") or {}) > 0
                --print("Valid: "..tostring(valid))
                return valid
            end, function()
                -- send all entities
                local illegal_sync_tags = {
                    "spectator_no_clear",
                    "workshop_spell_visualizer",
                    "workshop_aabb",
                    "world_state",
                    "coop_respawn",
                    "player_projectile",
                    "projectile",
                }

                local illegal_file_matches = {
                    "verlet_chains",
                    "particles",
                }

                local to_sync = {}
                local filtered = {}

                local entities = EntityGetInRadius(0, 0, 1000000)
                for k, v in ipairs(entities)do
                    if(EntityGetRootEntity(v) ~= v)then
                        goto continue
                    end
                    for _, tag in ipairs(illegal_sync_tags)do
                        if(EntityHasTag(v, tag))then
                            goto continue
                        end
                    end
                    
                    local file = EntityGetFilename(v)
                    for _, match in ipairs(illegal_file_matches)do
                        if(file:match(match) )then
                            goto continue
                        end
                    end

                    table.insert(filtered, v)

                    ::continue::
                end

                --print("count: "..tostring(count).." #filtered: "..tostring(#filtered))
                if(count ~= nil and math.abs(#filtered - count) < 5)then
                    return
                end

                for k, v in ipairs(filtered)do
                    if(not EntityHasTag(v, "synced_once"))then
                        EntitySetName(v, EntityGetName(v).."_"..tostring((GameGetFrameNum() % 100000) + v))
                        EntityAddComponent2(v, "LuaComponent", {
                            _tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
                            script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/hm_pickup.lua",
                        })
                    end

                    EntityAddTag(v, "synced_once")


                

                    local x, y = EntityGetTransform(v)
                    table.insert(to_sync, {
                        x,
                        y,
                        np.SerializeEntity(v)
                    }) 
                end


                --print("Sending "..tostring(#to_sync).." entities")

                
                if(user)then
                    steamutils.sendToPlayer("sync_hm", {smallfolk.loads(GlobalsGetValue("temple_second_row_spots", "{}")), to_sync}, user, true, true)
                else
                    steamutils.send("sync_hm", { smallfolk.loads(GlobalsGetValue("temple_second_row_spots", "{}")), to_sync}, steamutils.messageTypes.Spectators, lobby, true, true)
                end
            end)
          
        end,
        pick_hm_entity = function(lobby, uid)
            steamutils.send("pick_hm_entity", uid, steamutils.messageTypes.Spectators, lobby, true, true)
        end,
        request_second_row = function(lobby, player)
            steamutils.sendToPlayer("request_second_row", {}, player, true)
        end,
        picked_heart = function(lobby, picked)
            steamutils.send("picked_heart", picked, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        hm_timer_update = function(lobby, frames)
            steamutils.send("hm_timer_update", frames, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        hm_timer_clear = function(lobby)
            steamutils.send("hm_timer_clear", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        update_state = function(lobby, state)
            steam.matchmaking.setLobbyMemberData(lobby, "state", state)
            steamutils.send("update_state", state, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        set_map = function(lobby, map)
            steamutils.send("set_map", map, steamutils.messageTypes.Host, lobby, true, true)
        end,
        request_dummy_target = function(lobby, user)
            steamutils.sendToPlayer("request_dummy_target", {}, user, true)
        end,
        dummy_target = function(lobby, target, user)
            if(user)then
                steamutils.sendToPlayer("dummy_target", tostring(target), user, true)
            else
                steamutils.send("dummy_target", tostring(target), steamutils.messageTypes.Spectators, lobby, true, true)
            end
        end,
        request_card_list = function(lobby, user)
            print("card list request wawa")
            if(user)then
                print("requesting card list")
                steamutils.sendToPlayer("request_card_list", {}, user, true)
            else
                steamutils.send("request_card_list", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            end
        end,
        card_list = function(lobby, data, user)
            local upgrades_system = data.upgrade_system
            if(upgrades_system == nil)then
                return
            end
            local cards = {}
            for k, v in pairs(upgrades_system.upgrades)do
                table.insert(cards, v.id)
            end
            if(user)then
                steamutils.sendToPlayer("card_list", cards, user, true)
            else
                steamutils.send("card_list", cards, steamutils.messageTypes.Spectators, lobby, true, true)
            end
        end,
        request_card_list_state = function(lobby, user)
            if(user)then
                steamutils.sendToPlayer("request_card_list_state", {}, user, true)
            else
                steamutils.send("request_card_list_state", {}, steamutils.messageTypes.OtherPlayers, lobby, true)
            end
        end,
        card_list_state = function(lobby, data, user)
            local upgrades_system = data.upgrade_system
            if(upgrades_system == nil or GameHasFlagRun("card_picked"))then
                if(user)then
                    steamutils.sendToPlayer("card_list_state", {}, user, true)
                else
                    steamutils.send("card_list_state", {}, steamutils.messageTypes.Spectators, lobby, true, true)
                end
                return
            end

            if(user)then
                steamutils.sendToPlayer("card_list_state", {GameHasFlagRun("card_menu_open"), upgrades_system.selected_index}, user, true)
            else
                steamutils.send("card_list_state", {GameHasFlagRun("card_menu_open"), upgrades_system.selected_index}, steamutils.messageTypes.Spectators, lobby, true, true)
            end
        end,
        swap_positions = function(user, x, y)
            steamutils.sendToPlayer("swap_positions", {x, y}, user, true)
        end,
        spawn_trailer_effects = function(lobby)
            steamutils.send("spawn_trailer_effects", {}, steamutils.messageTypes.OtherPlayers, lobby, true, true)
        end,
        is_spectating = function(user, value)
            steamutils.sendToPlayer("is_spectating", value, user, true)
        end,
        sync_world = function(user, msg)
            steamutils.sendToPlayer("sync_world", msg, user, false, 1, true)
        end,
        did_spectate = function(lobby)
            steamutils.send("did_spectate", {}, steamutils.messageTypes.Spectators, lobby, true, true)
        end,
    },
}

return networking
