local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
local counter = dofile_once("mods/evaisa.arena/files/scripts/utilities/ready_counter.lua")
local countdown = dofile_once("mods/evaisa.arena/files/scripts/utilities/countdown.lua")
local json = dofile("mods/evaisa.arena/lib/json.lua")
local EZWand = dofile("mods/evaisa.arena/files/scripts/utilities/EZWand.lua")

ArenaLoadCountdown = ArenaLoadCountdown or nil

ArenaGameplay = {
    GetNumRounds = function()
        local holyMountainCount = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
        return holyMountainCount
    end,
    GetPlayerIndex = function(lobby)
        local members = steamutils.getLobbyMembers(lobby)
        for i, member in ipairs(members) do
            if(member.id == steam.user.getSteamID())then
                return i
            end
        end
        return 1
    end,
    AddRound = function()
        local holyMountainCount = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
        holyMountainCount = holyMountainCount + 1
        GlobalsSetValue("holyMountainCount", tostring(holyMountainCount))
    end,
    RemoveRound = function()
        local holyMountainCount = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
        holyMountainCount = holyMountainCount - 1
        GlobalsSetValue("holyMountainCount", tostring(holyMountainCount))
    end,
    GetSpawnPoints = function()
        local spawns = {}
        local spawn_points = EntityGetWithTag("spawn_point") or {}
        if (spawn_points ~= nil and #spawn_points > 0) then
            -- sort points by x and y
            table.sort(spawn_points, function(a, b)
                local ax, ay = EntityGetTransform(a)
                local bx, by = EntityGetTransform(b)
                if (ax == bx) then
                    return ay < by
                end
                return ax < bx
            end)
            spawns = spawn_points
        end
        return spawns
    end,
    GetRoundTier = function()
        local rounds = ArenaGameplay.GetNumRounds()
        -- how many rounds it takes for the shop level to increment
        local shop_scaling = tonumber(GlobalsGetValue("shop_scaling", "2"))
        -- how much the shop level increments by
        local shop_increment = tonumber(GlobalsGetValue("shop_jump", "1"))
        -- the maximum shop level
        local shop_max = tonumber(GlobalsGetValue("max_shop_level", "5"))
        -- shop start level
        local shop_start_level = tonumber(GlobalsGetValue("shop_start_level", "0"))

        -- calculating how many times the shop level has been incremented
        local num_increments = math.floor((rounds - 1) / shop_scaling)
        -- calculating the current shop level including the start level and clamping it to the max level
        local round_scaled = math.min(shop_start_level + num_increments * shop_increment, shop_max)
        round_scaled = math.floor(round_scaled + 0.5)
        if(round_scaled < 0)then
            round_scaled = 0
        end

        return round_scaled
    end,
    CheckWinCondition = function(lobby, data)
        local conditions = {
            ["first_to"] = function(value)
                local members = steamutils.getLobbyMembers(lobby)
                for k, member in pairs(members) do
                    local wins = ArenaGameplay.GetWins(lobby, member.id, data)
                    if(wins >= value)then
                        return member.id
                    end
                end
            end,
            ["best_of"] = function(value)
                local current_round = ArenaGameplay.GetNumRounds() + 1
                if(current_round >= value)then
                    local members = steamutils.getLobbyMembers(lobby)
                    local best_player = nil
                    local best_wins = 0
                    for k, member in pairs(members) do
                        local wins = ArenaGameplay.GetWins(lobby, member.id, data)
                        if(wins > best_wins)then
                            best_player = member.id
                            best_wins = wins
                        end
                    end
                    return best_player
                end
            end,
            ["winstreak"] = function(value)
                local members = steamutils.getLobbyMembers(lobby)
                for k, member in pairs(members) do
                    local winstreak = ArenaGameplay.GetWinstreak(lobby, member.id, data)
                    print("Checking winstreak: " .. winstreak .. " - " .. value)
                    if(winstreak >= value)then
                        return member.id
                    end
                end
            end,
        }
        local type = GlobalsGetValue("win_condition", "unlimited")
        local value = tonumber(GlobalsGetValue("win_condition_value", "5"))

        print("Checking win condition: " .. type .. " - " .. value)

        if (conditions[type] ~= nil) then
            return conditions[type](value)
        end
    end,
    SendGameData = function(lobby, data)
        steam.matchmaking.setLobbyData(lobby, "holyMountainCount", tostring(ArenaGameplay.GetNumRounds()))
        local ready_players = {}
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].ready) then
                    table.insert(ready_players, tostring(member.id))
                end
            end
        end
        steam.matchmaking.setLobbyData(lobby, "ready_players", bitser.dumps(ready_players))
    end,
    GetGameData = function(lobby, data)
        local mountainCount = tonumber(steam.matchmaking.getLobbyData(lobby, "holyMountainCount"))
        if (mountainCount ~= nil) then
            GlobalsSetValue("holyMountainCount", tostring(mountainCount))
            arena_log:print("Holymountain count: " .. mountainCount)
        end
        local goldCount = tonumber(steam.matchmaking.getLobbyData(lobby, "total_gold"))
        if (goldCount ~= nil) then
            data.client.first_spawn_gold = goldCount
            arena_log:print("Gold count: " .. goldCount)
        end
        local playerData = steamutils.GetLocalLobbyData(lobby, "player_data") --steam.matchmaking.getLobbyMemberData(lobby, steam.user.getSteamID(), "player_data")
        --local rerollCount = tonumber(steamutils.GetLocalLobbyData(lobby, "reroll_count") or 0)

        --[[
             local match_data = {
                reroll_count = GlobalsGetValue("TEMPLE_PERK_REROLL_COUNT", "0"),
                picked_health = GameHasFlagRun("picked_health"),
                picked_perk = GameHasFlagRun("picked_perk"),
            }

            local serialized = bitser.dumps(match_data)

            if(data.client.match_data ~= serialized)then
                steamutils.SetLocalLobbyData(lobby, "match_data", serialized)

                data.client.match_data = serialized
            end
        ]]

        if(steamutils.GetLocalLobbyData(lobby, "match_data") ~= nil)then
            local match_data = bitser.loads(steamutils.GetLocalLobbyData(lobby, "match_data"))

            if(match_data ~= nil)then
                data.client.reroll_count = tonumber(match_data.reroll_count)
                GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", tostring(data.client.reroll_count))
                print("Reroll count overwritten: "..tostring(data.client.reroll_count))
                GameAddFlagRun("picked_health")
                GameAddFlagRun("picked_perk")
            end
        end

        --[[
        if(steamutils.GetLocalLobbyData(lobby, "reroll_count") == nil)then
            data.rejoined = true
        end

        data.client.reroll_count = rerollCount

        GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", tostring(rerollCount))
        ]]

        if (playerData ~= nil and playerData ~= "") then
            data.client.serialized_player = playerData

            data.client.player_loaded_from_data = true
            --data.client.serialized_player = bitser.dumps(playerData)
            arena_log:print("Player data: " .. data.client.serialized_player)
        end
        
        local ready_players_string = steam.matchmaking.getLobbyData(lobby, "ready_players")
        local ready_players = (ready_players_string ~= nil and ready_players_string ~= "null") and
            bitser.loads(ready_players_string) or nil

        local members = steamutils.getLobbyMembers(lobby)

        for k, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID()) then
                local user = member.id
                local wins = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_wins")) or 0
                local winstreak = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_winstreak")) or 0
                data.players[tostring(user)].wins = wins
                data.players[tostring(user)].winstreak = winstreak
            end
        end
        --print(tostring(ready_players_string))


        if (ready_players ~= nil) then
            for k, member in pairs(members) do
                if (member.id ~= steam.user.getSteamID()) then
                    if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].ready) then
                        data.players[tostring(member.id)].ready = false
                    end
                end
            end
            for k, member in pairs(ready_players) do
                if (data.players[member] ~= nil) then
                    data.players[member].ready = true
                end
            end
        end
    end,
    GracefulReset = function(lobby, data)
        if (data.spectator_gui) then
            GuiDestroy(data.spectator_gui)
            data.spectator_gui = nil
            if(data.spectator_text_gui)then
                GuiDestroy(data.spectator_text_gui)
                data.spectator_text_gui = nil
            end

            if (data.spectator_gui_entity and EntityGetIsAlive(data.spectator_gui_entity)) then
                EntityKill(data.spectator_gui_entity)
            end
        end
        if(data.upgrade_system)then
            data.upgrade_system:clean()
            data.upgrade_system = nil
        end
        if (data.countdown) then
            data.countdown:cleanup()
            data.countdown = nil
        end
        if (data.ready_counter) then
            data.ready_counter:cleanup()
            data.ready_counter = nil
        end
    end,
    ResetEverything = function(lobby)
        local player = player.Get()

        dofile_once("data/scripts/perks/perk_list.lua")
        for i, perk_data in ipairs(perk_list) do
            local perk_id = perk_data.id
            local flag_name = get_perk_picked_flag_name(perk_id)

            local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

            if (pickup_count > 0) then
                if (perk_data.func_remove ~= nil) then
                    perk_data.func_remove(player)
                end
            end
            GameRemoveFlagRun(flag_name)
            GlobalsSetValue(flag_name .. "_PICKUP_COUNT", "0")
        end

        if (player ~= nil) then
            EntityKill(player)
        end

        GameRemoveFlagRun( "arena_unlimited_spells" )
        GlobalsSetValue("TEMPLE_SHOP_ITEM_COUNT", "5")
        GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", "0")
        GlobalsSetValue("EXTRA_MONEY_COUNT", "0")
        GlobalsSetValue("RESPAWN_COUNT", "0")
        GlobalsSetValue("holyMountainCount", "0")
        GlobalsSetValue("HEARTS_MORE_EXTRA_HP_MULTIPLIER", "1")
        GlobalsSetValue("PERK_SHIELD_COUNT", "0")
        GlobalsSetValue("PERK_ATTRACT_ITEMS_RANGE", "0")
        GlobalsSetValue("PERK_NO_MORE_SHUFFLE_WANDS", "0")
        --[[GlobalsSetValue("TEMPLE_PERK_COUNT", "3")
        GlobalsSetValue("TEMPLE_PERK_DESTROY_CHANCE", "100")
        GlobalsSetValue("TEMPLE_SHOP_ITEM_COUNT", "5")]]
        GlobalsSetValue("TEMPLE_PEACE_WITH_GODS", "0")
        GlobalsSetValue("TEMPLE_SPAWN_GUARDIAN", "0")
        GameRemoveFlagRun("ATTACK_FOOT_CLIMBER")
        GameRemoveFlagRun("player_status_cordyceps")
        GameRemoveFlagRun("player_status_mold")
        GameRemoveFlagRun("player_status_fungal_disease")
        GameRemoveFlagRun("player_status_angry_ghost")
        GameRemoveFlagRun("player_status_hungry_ghost")
        GameRemoveFlagRun("player_status_death_ghost")
        GameRemoveFlagRun("player_status_lukki_minion")
        GameRemoveFlagRun("exploding_gold")
        GameRemoveFlagRun("first_death")
        GameRemoveFlagRun("skip_perks")
        GameRemoveFlagRun("pick_upgrade")
        GameRemoveFlagRun("arena_winner")
        GameRemoveFlagRun("arena_loser")
        GameRemoveFlagRun("arena_first_death")
        GlobalsSetValue("smash_knockback", "1" )
        GlobalsSetValue("smash_knockback_dummy", "1")

        if (steamutils.IsOwner(lobby)) then
            steam.matchmaking.deleteLobbyData(lobby, "holyMountainCount")
            steam.matchmaking.deleteLobbyData(lobby, "total_gold")
            steam.matchmaking.deleteLobbyData(lobby, "ready_players")

            -- loop through all players and remove their data
            local members = steamutils.getLobbyMembers(lobby)
            for k, member in pairs(members) do
                local winner_key = tostring(member.id) .. "_wins"
                steam.matchmaking.deleteLobbyData(lobby, winner_key)
                local winstreak_key = tostring(member.id) .. "_winstreak"
                steam.matchmaking.deleteLobbyData(lobby, winstreak_key)
            end

            local winner_keys = steam.matchmaking.getLobbyData(lobby, "winner_keys")
            if (winner_keys == nil) then
                winner_keys = {}
            else
                winner_keys = bitser.loads(winner_keys)
            end

            for k, key in pairs(winner_keys) do
                steam.matchmaking.deleteLobbyData(lobby, key)
                steam.matchmaking.deleteLobbyData(lobby, key .. "treak")
            end

            steam.matchmaking.deleteLobbyData(lobby, "winner_keys")

        end

        GameRemoveFlagRun("saving_grace")
        GameRemoveFlagRun("player_ready")
    end,
    ReadyAmount = function(data, lobby)
        local amount = data.client.ready and 1 or 0
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].ready) then
                    amount = amount + 1
                end
            end
        end
        return amount
    end,
    CheckFiringBlock = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].entity ~= nil) then
                    local player_entity = data.players[tostring(member.id)].entity
                    if (EntityGetIsAlive(player_entity)) then
                        --[[if(not data.players[tostring(member.id)].can_fire)then
                            entity.BlockFiring(player_entity, true)
                            data.players[tostring(member.id)].can_fire = false
                        else
                            entity.BlockFiring(player_entity, false)
                        end]]
                        EntityHelper.BlockFiring(player_entity, true)
                    end
                end
            end
        end
    end,
    FindUser = function(lobby, user_string, debug)
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (tostring(member.id) == user_string) then
                if (debug) then
                    arena_log:print("found member: " .. tostring(member.id))
                end
                return member.id
            end
        end
        return nil
    end,
    TotalPlayers = function(lobby)
        local amount = 0
        for k, v in pairs(steamutils.getLobbyMembers(lobby)) do
            amount = amount + 1
        end
        return amount
    end,
    ReadyCounter = function(lobby, data)
        data.ready_counter = counter.create(GameTextGetTranslatedOrNot("$arena_players_ready"), function()
            local playersReady = ArenaGameplay.ReadyAmount(data, lobby)
            local totalPlayers = ArenaGameplay.TotalPlayers(lobby)

            return playersReady, totalPlayers
        end)
    end,
    LoadPlayer = function(lobby, data)
        local current_player = EntityLoad("data/entities/player.xml", 0, 0)

        local aiming_reticle = EntityGetComponentIncludingDisabled(current_player, "SpriteComponent", "aiming_reticle") or {}

        for k, v in ipairs(aiming_reticle)do
            if(GameGetIsGamepadConnected())then
                ComponentSetValue2(v, "visible", true)
            else
                ComponentSetValue2(v, "visible", false)
            end
        end

        game_funcs.SetPlayerEntity(current_player)
        np.RegisterPlayerEntityId(current_player)

        -- Mark inventory as initialised, else the game will change the item
        -- after we've set it in the deserialization.
        local inventory = EntityGetFirstComponentIncludingDisabled(current_player, "Inventory2Component")
        ComponentSetValue2(inventory, "mInitialized", true)

        player.Deserialize(data.client.serialized_player, (not data.client.player_loaded_from_data))

        GameRemoveFlagRun("player_unloaded")
    end,
    AllowFiring = function(data)
        GameRemoveFlagRun("no_shooting")
        data.client.spread_index = 0
    end,
    PreventFiring = function()
        GameAddFlagRun("no_shooting")
    end,
    CancelFire = function(lobby, data)
        local player_entity = player.Get()
        if (player_entity ~= nil) then
            local items = GameGetAllInventoryItems(player_entity) or {}
            for k, item in ipairs(items) do
                local abilityComponent = EntityGetFirstComponentIncludingDisabled(item, "AbilityComponent")
                if (abilityComponent ~= nil) then
                    -- set mNextFrameUsable to false
                    ComponentSetValue2(abilityComponent, "mNextFrameUsable", GameGetFrameNum() + 10)
                    -- set mReloadFramesLeft
                    ComponentSetValue2(abilityComponent, "mReloadFramesLeft", 10)
                    -- set mReloadNextFrameUsable to false
                    ComponentSetValue2(abilityComponent, "mReloadNextFrameUsable", GameGetFrameNum() + 10)
                end
            end
        end

        for k, v in pairs(data.players) do
            if (v.entity ~= nil) then
                local item = v.held_item
                if (item ~= nil) then
                    local abilityComponent = EntityGetFirstComponentIncludingDisabled(item, "AbilityComponent")
                    if (abilityComponent ~= nil) then
                        -- set mNextFrameUsable to false
                        ComponentSetValue2(abilityComponent, "mNextFrameUsable", GameGetFrameNum() + 10)
                        -- set mReloadFramesLeft
                        ComponentSetValue2(abilityComponent, "mReloadFramesLeft", 10)
                        -- set mReloadNextFrameUsable to false
                        ComponentSetValue2(abilityComponent, "mReloadNextFrameUsable", GameGetFrameNum() + 10)
                    end
                end
            end
        end
    end,
    IsInBounds = function(x, y, max_distance)
        local players = EntityGetWithTag("player_unit") or {}
        for k, v in pairs(players) do
            local x2, y2 = EntityGetTransform(v)
            local distance = math.sqrt((x2 - x) ^ 2 + (y2 - y) ^ 2)
            if (distance > max_distance) then
                return false
            end
        end
        return true
    end,
    DamageZoneCheck = function(x, y, max_distance, distance_cap)
        local players = EntityGetWithTag("player_unit") or {}
        for k, v in pairs(players) do
            local x2, y2 = EntityGetTransform(v)
            local distance = math.sqrt((x2 - x) ^ 2 + (y2 - y) ^ 2)
            if (distance > max_distance) then
                local healthComp = EntityGetFirstComponentIncludingDisabled(v, "DamageModelComponent")
                if (healthComp ~= nil) then
                    local health = tonumber(ComponentGetValue(healthComp, "hp"))
                    local max_health = tonumber(ComponentGetValue(healthComp, "max_hp"))
                    local base_health = 4
                    local damage_percentage = (distance - max_distance) / distance_cap
                    local damage = max_health * damage_percentage
                    EntityInflictDamage(v, damage, "DAMAGE_FALL", "Out of bounds", "BLOOD_EXPLOSION", 0, 0, GameGetWorldStateEntity())
                end
            end
        end
    end,
    DamageFloorCheck = function(depth, max_depth)
        -- if player goes under depth, do proportional damage based on depth
        local players = EntityGetWithTag("player_unit") or {}
        for k, v in pairs(players) do
            local x, y = EntityGetTransform(v)
            if(y >= depth)then
                local healthComp = EntityGetFirstComponentIncludingDisabled(v, "DamageModelComponent")
                if (healthComp ~= nil) then
                    local health = tonumber(ComponentGetValue(healthComp, "hp"))
                    local max_health = tonumber(ComponentGetValue(healthComp, "max_hp"))
                    local base_health = 4
                    local damage_percentage = (y - depth) / max_depth
                    local damage = max_health * damage_percentage
                    EntityInflictDamage(v, damage, "DAMAGE_FALL", "Out of bounds", "BLOOD_EXPLOSION", 0, 0, GameGetWorldStateEntity())
                end
            end
        end
    end,
    ResetDamageZone = function(lobby, data)
        GuiDestroy(data.zone_gui)
        data.zone_gui = nil
        data.zone_size = nil
        data.last_step_frame = nil
        data.ready_for_zone = false
        data.zone_spawned = false
    end,
    DamageZoneHandler = function(lobby, data, can_shrink)
        if (data.current_arena) then
            local default_size = data.current_arena.zone_size
            local zone_floor = data.current_arena.zone_floor

            --{{"disabled", "Disabled"}, {"static", "Static"}, {"shrinking_Linear", "Linear Shrinking"}, {"shrinking_step", "Stepped Shrinking"}},
            local zone_type = GlobalsGetValue("zone_shrink", "static")
            local zone_speed = tonumber(GlobalsGetValue("zone_speed", "30")) -- pixels per step or pixels per minute (frames * 60 * 60)
            local zone_step_interval = tonumber(GlobalsGetValue("zone_step_interval", "30")) *
                60                                                           -- seconds between steps

            local step_time = zone_step_interval / 2

            if(data.zone_size == nil)then
                data.zone_size = default_size or 600
            end

            if (zone_type ~= "disabled") then
                if (data.ready_for_zone and not data.zone_spawned) then
                    EntityLoad("mods/evaisa.arena/files/entities/area_indicator.xml", 0, 0)
                    data.zone_size = default_size
                    data.ready_for_zone = false
                    data.zone_spawned = true

                    GlobalsSetValue("arena_area_size", tostring(data.zone_size))
                    GlobalsSetValue("arena_area_size_cap", tostring(data.zone_size + 200))
                end


                if (data.zone_size ~= nil and can_shrink and steamutils.IsOwner(lobby)) then
                    local zone_shrink_time = 0;

                    local last_zone_size = data.zone_size

                    if (data.last_step_frame == nil) then
                        data.last_step_frame = GameGetFrameNum()
                    end

                    if (zone_type == "shrinking_Linear") then
                        if (data.zone_gui == nil) then
                            data.zone_gui = GuiCreate()
                        end

                        GuiStartFrame(data.zone_gui)

                        if (data.using_controller) then
                            GuiOptionsAdd(data.zone_gui, GUI_OPTION.NonInteractive)
                        end

                        local step_size = zone_speed / 60 / 60

                        --GamePrint("step_size: " .. step_size)

                        data.zone_size = data.zone_size - step_size

                        if (data.zone_size < 0) then
                            data.zone_size = 0
                        end

                        GlobalsSetValue("arena_area_size", tostring(data.zone_size))
                        GlobalsSetValue("arena_area_size_cap", tostring(data.zone_size + 200))

                        if (not IsPaused()) then
                            local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                            local text = GameTextGetTranslatedOrNot("$arena_zone_shrinking").." (" .. math.ceil(data.zone_size) .. "/" .. default_size .. ")"

                            local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)

                            GuiBeginAutoBox(data.zone_gui)
                            -- draw at bottom center of screen
                            GuiZSetForNextWidget(data.zone_gui, -200)
                            GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 12, text)
                            GuiZSetForNextWidget(data.zone_gui, -150)
                            GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                        end
                    elseif (zone_type == "shrinking_step") then
                        if (data.zone_gui == nil) then
                            data.zone_gui = GuiCreate()
                        end

                        GuiStartFrame(data.zone_gui)

                        if (data.using_controller) then
                            GuiOptionsAdd(data.zone_gui, GUI_OPTION.NonInteractive)
                        end

                        -- every step should take step_time seconds to complete
                        if (GameGetFrameNum() - data.last_step_frame > zone_step_interval) then
                            local step_size = zone_speed / step_time
                            data.zone_size = data.zone_size - step_size

                            if (data.zone_size < 0) then
                                data.zone_size = 0
                            end

                            if (GameGetFrameNum() - data.last_step_frame > zone_step_interval + step_time) then
                                data.last_step_frame = GameGetFrameNum()
                            end

                            GlobalsSetValue("arena_area_size", tostring(data.zone_size))
                            GlobalsSetValue("arena_area_size_cap", tostring(data.zone_size + 200))

                            if (not IsPaused()) then
                                local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                                local text = GameTextGetTranslatedOrNot("$arena_zone_shrinking").." (" ..
                                    math.ceil(data.zone_size) .. "/" .. default_size .. ")"

                                local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)


                                GuiBeginAutoBox(data.zone_gui)
                                -- draw at bottom center of screen
                                GuiZSetForNextWidget(data.zone_gui, -200)
                                GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 14, text)
                                GuiZSetForNextWidget(data.zone_gui, -150)
                                GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                            end
                        else
                            if (not IsPaused()) then
                                local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                                local text = "Zone will shrink in " ..
                                    math.ceil((zone_step_interval - (GameGetFrameNum() - data.last_step_frame)) / 60) ..
                                    " seconds"

                                zone_shrink_time = math.ceil((zone_step_interval - (GameGetFrameNum() - data.last_step_frame)) /
                                    60)

                                local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)

                                GuiBeginAutoBox(data.zone_gui)
                                -- draw at bottom center of screen
                                GuiZSetForNextWidget(data.zone_gui, -200)
                                GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 14, text)
                                GuiZSetForNextWidget(data.zone_gui, -150)
                                GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                            end
                        end
                    end


                    --message_handler.send.ZoneUpdate(lobby, data.zone_size, zone_shrink_time)
                    networking.send.zone_update(lobby, data.zone_size, zone_shrink_time)

                    -- GamePrint("Zone size: " .. data.zone_size .. " (" .. last_zone_size .. " -> " .. data.zone_size .. ")")
                end

                if ((not steamutils.IsOwner(lobby)) and (not IsPaused()) and data.zone_size ~= nil) then
                    if (data.zone_gui == nil) then
                        data.zone_gui = GuiCreate()
                    end

                    GuiStartFrame(data.zone_gui)

                    if (data.using_controller) then
                        GuiOptionsAdd(data.zone_gui, GUI_OPTION.NonInteractive)
                    end
                    -- GamePrint("???")

                    if (zone_type == "shrinking_Linear") then
                        --GamePrint(tostring(data.zone_size))

                        local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                        local text = GameTextGetTranslatedOrNot("$arena_zone_shrinking").." (" ..
                            tostring(math.ceil(data.zone_size)) .. "/" .. default_size .. ")"

                        -- GamePrint(text)

                        local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)

                        GuiBeginAutoBox(data.zone_gui)
                        -- draw at bottom center of screen
                        GuiZSetForNextWidget(data.zone_gui, -200)
                        GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 12, text)
                        GuiZSetForNextWidget(data.zone_gui, -150)
                        GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                    elseif (zone_type == "shrinking_step") then
                        if (data.shrink_time == 0) then
                            local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                            local text = GameTextGetTranslatedOrNot("$arena_zone_shrinking").." (" ..
                                tostring(math.ceil(data.zone_size)) .. "/" .. default_size .. ")"

                            --GamePrint(text)

                            local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)

                            GuiBeginAutoBox(data.zone_gui)
                            -- draw at bottom center of screen
                            GuiZSetForNextWidget(data.zone_gui, -200)
                            GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 14, text)
                            GuiZSetForNextWidget(data.zone_gui, -150)
                            GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                        else
                            local screen_width, screen_height = GuiGetScreenDimensions(data.zone_gui)

                            local text = string.format("$arena_zone_shrink_countdown", tostring(data.shrink_time))--"Zone will shrink in " .. tostring(data.shrink_time) .. " seconds"

                            --GamePrint(text)

                            local text_width, text_height = GuiGetTextDimensions(data.zone_gui, text)

                            GuiBeginAutoBox(data.zone_gui)
                            -- draw at bottom center of screen
                            GuiZSetForNextWidget(data.zone_gui, -200)
                            GuiText(data.zone_gui, (screen_width / 2) - (text_width / 2), screen_height - 14, text)
                            GuiZSetForNextWidget(data.zone_gui, -150)
                            GuiEndAutoBoxNinePiece(data.zone_gui, 2)
                        end
                    end
                end

                if (GameGetFrameNum() % 60 == 0) then
                    ArenaGameplay.DamageZoneCheck(0, 0, data.zone_size, data.zone_size + 200)

                end
            else
                if (GameGetFrameNum() % 60 == 0) then
                    ArenaGameplay.DamageFloorCheck(zone_floor, zone_floor + 200)
                end
            end
        end
    end,
    GetWins = function(lobby, user, data)
        if(data.players[tostring(user)] ~= nil and data.players[tostring(user)].wins ~= nil)then
            return data.players[tostring(user)].wins or 0
        end
        local wins = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_wins")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].wins = wins
            print("Updated wins for " .. tostring(user) .. " to " .. tostring(wins))
        end
        return wins
    end,
    GetWinstreak = function(lobby, user, data)
        if(data.players[tostring(user)] ~= nil and data.players[tostring(user)].winstreak ~= nil)then
            return data.players[tostring(user)].winstreak or 0
        end
        local winstreak = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_winstreak")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].winstreak = winstreak
            print("Updated winstreak for " .. tostring(user) .. " to " .. tostring(winstreak))
        end
        return winstreak
    end,
    WinnerCheck = function(lobby, data)
        
        --[[if(true)then
            return
        end]]
        

        if(GameHasFlagRun("round_finished"))then
            return
        end

        -- print("WinnerCheck (gameplay)")

        local alive = data.client.alive and 1 or 0
        local winner = steam.user.getSteamID()
        for k, v in pairs(data.players) do
            if (v.alive) then
                alive = alive + 1
                winner = v.id
            end
        end

        -- print("Alive count: "..tostring(alive))

        if (alive == 1) then
            -- if we are owner, add win to tally
            if (steamutils.IsOwner(lobby)) then
                local winner_key = tostring(winner) .. "_wins"
                local winstreak_key = tostring(winner) .. "_winstreak"

                local winner_keys = steam.matchmaking.getLobbyData(lobby, "winner_keys")
                
                if (winner_keys == nil) then
                    winner_keys = {}
                else
                    winner_keys = bitser.loads(winner_keys)
                end


                for k, v in pairs(winner_keys) do
                    if (tostring(v) ~= tostring(winner_key)) then
                        print(v .. "treak")
                        steam.matchmaking.setLobbyData(lobby, v .. "treak", "0")
                    end
                end


                if (not table.contains(winner_keys, winner_key)) then
                    table.insert(winner_keys, winner_key)
                    steam.matchmaking.setLobbyData(lobby, "winner_keys", bitser.dumps(winner_keys))
                end


                for k, v in pairs(data.players) do
                    local id = v.id
                    if (tostring(id) ~= tostring(winner)) then
                        steam.matchmaking.setLobbyData(lobby, tostring(id) .. "_winstreak", "0")
                    end
                end

                local current_wins = tonumber(tonumber(steam.matchmaking.getLobbyData(lobby, winner_key)) or "0")
                local current_winstreak = tonumber(tonumber(steam.matchmaking.getLobbyData(lobby, winstreak_key)) or "0")

                print("incrementing win count for "..tostring(winner).." to "..tostring(current_wins + 1))
                steam.matchmaking.setLobbyData(lobby, winner_key, tostring(current_wins + 1))
                steam.matchmaking.setLobbyData(lobby, winstreak_key, tostring(current_winstreak + 1))

                wait.new(function() 
                    return steam.matchmaking.getLobbyData(lobby, winner_key) == tostring(current_wins + 1)
                end, function()
                    networking.send.allow_round_end(lobby)
                    data.allow_round_end = true
                end)


            end

            

            -- check if winner is us!!!
            if(winner == steam.user.getSteamID())then
                GameAddFlagRun("arena_winner")
                local catchup_mechanic = GlobalsGetValue("perk_catchup", "losers")
                if(catchup_mechanic == "winner")then
                    GameAddFlagRun("first_death")
                    GamePrint(GameTextGetTranslatedOrNot("$arena_compensation_winner"))
                end
                if(GlobalsGetValue("upgrades_system", "false") == "true")then
                    local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")
                    if(catchup_mechanic_upgrades == "winner")then
                        GameAddFlagRun("pick_upgrade")
                    end
                end
            end

            -- data.allow_round_end = false

            local updated_was_wins = false
            wait.new(function()  
                if(lobby_data_updated_this_frame[tostring(winner) .. "_wins"])then
                    updated_was_wins = lobby_data_updated_this_frame[tostring(winner) .. "_wins"]
                end
                return lobby_data_updated_this_frame[tostring(winner) .. "_wins"] or lobby_data_updated_this_frame[tostring(winner) .. "_winstreak"]
            end, function() 

                wait.new(function()  
                    print("winstreak updated: "..tostring(lobby_data_updated_this_frame[tostring(winner) .. "_winstreak"]))
                    print("wins updated: "..tostring(lobby_data_updated_this_frame[tostring(winner) .. "_wins"]))
                    print("updated_was_wins: "..tostring(updated_was_wins))

                    return updated_was_wins and lobby_data_updated_this_frame[tostring(winner) .. "_winstreak"] or lobby_data_updated_this_frame[tostring(winner) .. "_wins"]
                end, function() 
                    print("user wins: "..tostring(ArenaGameplay.GetWins(lobby, winner, data)))
                    print("user winstreak: "..tostring(ArenaGameplay.GetWinstreak(lobby, winner, data)))
                    GameAddFlagRun("round_finished")
                    local win_condition_user = ArenaGameplay.CheckWinCondition(lobby, data)

                    if(win_condition_user ~= nil)then
                        GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_win_condition_description"))
                    else
                        GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_winner_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_round_end_text"))
                    end

                    if(win_condition_user == nil or not GameHasFlagRun("win_condition_end_match"))then
                        delay.new(5 * 60, function()
                            ArenaGameplay.LoadLobby(lobby, data, false)
                        end, function(frames)
                            if (frames % 60 == 0) then
                                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                            end
                        end)
                    else
                        delay.new(10 * 60, function()
                            StopGame()
                        end, function(frames)
                            if (frames % 60 == 0) then
                                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_ending_game_text"), tostring(math.floor(frames / 60))))
                            end
                        end)
                    end
                end)
            end)
        elseif (alive == 0) then

            local win_condition_user = ArenaGameplay.CheckWinCondition(lobby, data)

            GameAddFlagRun("round_finished")

            if(win_condition_user == nil or not GameHasFlagRun("win_condition_end_match"))then
                GamePrintImportant(GameTextGetTranslatedOrNot("$arena_tie_text"), GameTextGetTranslatedOrNot("$arena_round_end_text"))
                delay.new(5 * 60, function()
                    ArenaGameplay.LoadLobby(lobby, data, false)
                end, function(frames)
                    if (frames % 60 == 0) then
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                    end
                end)
            else
                delay.new(10 * 60, function()
                    StopGame()
                end, function(frames)
                    if (frames % 60 == 0) then
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_ending_game_text"), tostring(math.floor(frames / 60))))
                    end
                end)
            end

        end
    end,
    KillCheck = function(lobby, data)
        if (GameHasFlagRun("player_died")) then
            local killer = GlobalsGetValue("killer", "");

            if(killer == "")then
                killer = nil
            end

            local username = steamutils.getTranslatedPersonaName(steam.user.getSteamID())

            if (killer == nil) then
                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_other_player_died"), tostring(username)))
            else
                local killer_id = ArenaGameplay.FindUser(lobby, killer)
                if (killer_id ~= nil) then
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_kill"), tostring(username), steamutils.getTranslatedPersonaName(killer_id))--[[tostring(username) .. " was killed by " .. steamutils.getTranslatedPersonaName(killer_id)]])
                else
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_other_player_died"), tostring(username)))
                end
            end

            if(data.deaths == 0)then
                GameAddFlagRun("arena_first_death")
            end

            GameAddFlagRun("arena_loser")

            local catchup_mechanic = GlobalsGetValue("perk_catchup", "losers")
            if(catchup_mechanic == "losers" or (data.deaths == 0 and catchup_mechanic == "first_death"))then
                if(catchup_mechanic == "losers" and not GameHasFlagRun("arena_winner"))then
                    GameAddFlagRun("first_death")
                elseif(catchup_mechanic == "first_death")then
                    GameAddFlagRun("first_death")
                end
                
                GamePrint(GameTextGetTranslatedOrNot("$arena_compensation"))
            end
            if(GlobalsGetValue("upgrades_system", "false") == "true")then
                local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")
                if(catchup_mechanic_upgrades == "losers" or (data.deaths == 0 and catchup_mechanic_upgrades == "first_death"))then
                    GameAddFlagRun("pick_upgrade")
                end
            end

            data.deaths = data.deaths + 1
            data.client.alive = false

            --message_handler.send.Death(lobby, killer)
            networking.send.death(lobby, killer)

            GameRemoveFlagRun("player_died")

            GamePrintImportant(GameTextGetTranslatedOrNot("$arena_player_died"))

            GameSetCameraFree(true)

            data.arena_spectator = true

            player.Lock()
            player.Immortal(true)
            --player.Move(-3000, -3000)

            ArenaGameplay.WinnerCheck(lobby, data)
        end
    end,
    ClearWorld = function()
        local all_entities = EntityGetInRadius(0, 0, math.huge)
        for k, v in pairs(all_entities) do
            if (v ~= GameGetWorldStateEntity() and not EntityHasTag(v, "free_camera_light") --[[ and v ~= GameGetPlayerStatsEntity()]]) then
                if (EntityHasTag(v, "player_unit")) then
                    EntityRemoveTag(v, "player_unit")
                end
                EntityKill(v)
            end
        end
    end,
    SavePlayerData = function(lobby, data, force)
        if ((not GameHasFlagRun("player_unloaded")) and player.Get()) then
            --[[local profile = profiler.new()
            profile:start()]]
            local serialized_player_data, compare_string = player.Serialize()


            if (force or compare_string ~= data.client.player_data_old) then
                steamutils.SetLocalLobbyData(lobby, "player_data", serialized_player_data)

                --print("Backing up Player Data: \n"..serialized_player_data)

                data.client.serialized_player = serialized_player_data
                data.client.player_data_old = compare_string
            end

            --[[profile:stop()

            print("Profiler result: "..tostring(profile:time()) .. "ms")]]

            local match_data = {
                reroll_count = GlobalsGetValue("TEMPLE_PERK_REROLL_COUNT", "0"),
                picked_health = GameHasFlagRun("picked_health"),
                picked_perk = GameHasFlagRun("picked_perk"),
            }

            local serialized = bitser.dumps(match_data)

            if(data.client.match_data ~= serialized)then
                steamutils.SetLocalLobbyData(lobby, "match_data", serialized)

                data.client.match_data = serialized
            end
        end
    end,
    LoadLobby = function(lobby, data, show_message, first_entry)
        if(not steamutils.IsSpectator(lobby))then
            local catchup_mechanic = GlobalsGetValue("perk_catchup", "losers")
            if(catchup_mechanic == "everyone")then
                GameAddFlagRun("first_death")
            end
            if(GlobalsGetValue("upgrades_system", "false") == "true")then
                local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")
                if(catchup_mechanic_upgrades == "everyone")then
                    GameAddFlagRun("pick_upgrade")
                end
            end
        else
            print("Loading lobby as spectator")
        end

        ArenaGameplay.GracefulReset(lobby, data)

        data.selected_player = nil
        data.selected_player_name = nil
        data.client.previous_spectate_data = nil
        data.allow_round_end = false
        data.controlled_physics_entities = {}
        GameRemoveFlagRun("lock_ready_state")
        GameRemoveFlagRun("can_save_player")
        GameRemoveFlagRun("countdown_completed")
        GameRemoveFlagRun("round_finished")
        GlobalsSetValue("smash_knockback", "1" )
        GlobalsSetValue("smash_knockback_dummy", "1")
        show_message = show_message or false
        first_entry = first_entry or false

        np.ComponentUpdatesSetEnabled("CellEaterSystem", false)
        np.ComponentUpdatesSetEnabled("LooseGroundSystem", false)
        np.ComponentUpdatesSetEnabled("BlackHoleSystem", false)
        np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", false)

        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID()) then
                local user = member.id
                local wins = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_wins")) or 0
                local winstreak = tonumber(steam.matchmaking.getLobbyData(lobby, tostring(user) .. "_winstreak")) or 0
                if(data.players[tostring(user)])then
                    data.players[tostring(user)].wins = wins
                    data.players[tostring(user)].winstreak = winstreak
                end
            end
        end

        if(not steamutils.IsSpectator(lobby))then
            if (not first_entry) then
                ArenaGameplay.SavePlayerData(lobby, data, true)
                ArenaGameplay.ClearWorld()
            end

            if (data.client.serialized_player) then
                first_entry = false
            end

            player.Immortal(true)

            RunWhenPlayerExists(function()
                if (first_entry and player.Get()) then
                    GameDestroyInventoryItems(player.Get())
                end
            end)
        else
            ArenaGameplay.ClearWorld()
        end

        -- clean other player's data
        ArenaGameplay.CleanMembers(lobby, data)

        -- manage flags
        GameRemoveFlagRun("player_ready")
        GameRemoveFlagRun("ready_check")
        GameRemoveFlagRun("player_unloaded")

        -- destroy active tweens
        data.tweens = {}

        -- clean local data
        if(not steamutils.IsSpectator(lobby))then
            ArenaGameplay.SetReady(lobby, data, false, true)
        end

        data.client.alive = true
        data.client.previous_wand = nil
        data.client.previous_anim = nil
        data.projectile_seeds = {}

        ArenaGameplay.ResetDamageZone(lobby, data)
        --data.client.projectile_homing = {}

        -- set state
        data.state = "lobby"

        if(not steamutils.IsSpectator(lobby))then
            player.Immortal(true)

            RunWhenPlayerExists(function()
                -- clean and unlock player entity
                player.Clean(first_entry)
                player.Unlock(data)

                GameRemoveFlagRun("player_is_unlocked")

                -- move player to correct position
                player.Move(0, 0)
            end)



            if (data.client.player_loaded_from_data) then
                if(GameHasFlagRun("picked_perk"))then
                    GameAddFlagRun("skip_perks")
                end
                if(GameHasFlagRun("picked_health"))then
                    GameAddFlagRun("skip_health")
                end
                ArenaGameplay.RemoveRound()
            else
                if(GlobalsGetValue("upgrades_system", "false") == "true" and GameHasFlagRun("pick_upgrade"))then
                    data.upgrade_system = upgrade_system.create(3, function(upgrade)
                        data.upgrade_system = nil
                    end)
                end
                GameRemoveFlagRun("picked_health")
                GameRemoveFlagRun("picked_perk")
            end
        end
        -- get rounds
        local rounds = ArenaGameplay.GetNumRounds()

        -- Give gold
        local rounds_limited = ArenaGameplay.GetRoundTier() --math.max(0, math.min(math.ceil(rounds / 2), 7))

        local extra_gold_count = tonumber( GlobalsGetValue( "EXTRA_MONEY_COUNT", "0" ) )

        extra_gold_count = extra_gold_count + 1

        local extra_gold = 400 + (extra_gold_count * (70 * (rounds_limited * rounds_limited)))

        --print("First spawn gold = "..tostring(data.client.first_spawn_gold))

        if(not steamutils.IsSpectator(lobby))then
            arena_log:print("First entry = " .. tostring(first_entry))

            if (first_entry and data.client.first_spawn_gold > 0) then
                extra_gold = data.client.first_spawn_gold
            end
        end

        --GamePrint("You were granted " ..tostring(extra_gold) .. " gold for this round. (Rounds: " .. tostring(rounds) .. ")")
        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_round_gold"), tostring(extra_gold), tostring(rounds)))

        if(not steamutils.IsSpectator(lobby))then
            arena_log:print("Loaded from data: " .. tostring(data.client.player_loaded_from_data))

            RunWhenPlayerExists(function()
                if (not data.client.player_loaded_from_data) then
                    arena_log:print("Giving gold: " .. tostring(extra_gold))
                    player.GiveGold(extra_gold)
                end
            end)


            RunWhenPlayerExists(function()
                -- if we are the owner of the lobby
                if (steamutils.IsOwner(lobby)) then
                    -- get the gold count from the lobby
                    local gold = tonumber(steam.matchmaking.getLobbyData(lobby, "total_gold")) or 0
                    -- add the new gold
                    gold = gold + extra_gold
                    -- set the new gold count
                    steam.matchmaking.setLobbyData(lobby, "total_gold", tostring(gold))
                end
            end)
        else
            if (steamutils.IsOwner(lobby)) then
                -- get the gold count from the lobby
                local gold = tonumber(steam.matchmaking.getLobbyData(lobby, "total_gold")) or 0
                -- add the new gold
                gold = gold + extra_gold
                -- set the new gold count
                steam.matchmaking.setLobbyData(lobby, "total_gold", tostring(gold))
            end
        end

        -- increment holy mountain count

        ArenaGameplay.AddRound()

        if(not steamutils.IsSpectator(lobby))then
            RunWhenPlayerExists(function()
                if(not first_entry)then
                    local was_winner = GameHasFlagRun("arena_winner")
                    local was_loser = GameHasFlagRun("arena_loser")
                    local was_first_death = GameHasFlagRun("arena_first_death")

                    local wand_removal = GlobalsGetValue("wand_removal", "disabled")
                    local who_remove = GlobalsGetValue("wand_removal_who", "everyone")

                    local wand_removal_types = {
                        random = function()
                            local wands = EZWand.GetAllWands()
                            if (wands == nil or #wands == 0) then
                                return nil
                            end

                            local player_entity = player.Get()

                            local wand = data.random.range(1, #wands)
                            GameKillInventoryItem(player_entity, wands[wand].entity_id)
                        end,
                        all = function()
                            local wands = EZWand.GetAllWands()
                            if (wands == nil or #wands == 0) then
                                return nil
                            end
                            local player_entity = player.Get()

                            for _, wand in ipairs(wands) do
                                GameKillInventoryItem(player_entity, wand.entity_id)
                            end
                        end,
                    }

                    if(wand_removal ~= "disabled")then
                        if(who_remove == "everyone" or 
                        (who_remove == "winner" and was_winner) or 
                        (who_remove == "losers" and was_loser) or
                        (who_remove == "first_death" and was_first_death))then
                            wand_removal_types[wand_removal]()
                        end
                    end
                end
                
                -- give starting gear if first entry
                if (first_entry) then
                    player.GiveStartingGear()
                    if (((rounds - 1) > 0)) then
                        player.GiveMaxHealth(0.4 * (rounds - 1))
                    end
                end

                GameAddFlagRun("can_save_player")

                networking.send.request_perk_update(lobby)
            end)

        else
            data.spectator_entity = EntityLoad("mods/evaisa.arena/files/entities/spectator_entity.xml", 0, 0)
            np.RegisterPlayerEntityId(data.spectator_entity)
        end
        --message_handler.send.Unready(lobby, true)
        if(not steamutils.IsSpectator(lobby))then
            -- load map
            if(GameHasFlagRun("item_shop"))then
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby.lua",
                "mods/evaisa.arena/files/biome/holymountain_itemshop_scenes.xml")
            else
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby.lua",
                "mods/evaisa.arena/files/biome/holymountain_scenes.xml")
                
            end


            -- show message
            
            if (show_message) then
                GamePrintImportant("$arena_holymountain_enter", "$arena_holymountain_enter_sub")
            end
        else
            -- load map
            if(GameHasFlagRun("item_shop"))then
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby_spectator.lua",
                "mods/evaisa.arena/files/biome/holymountain_itemshop_scenes.xml")
            else
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby_spectator.lua",
                "mods/evaisa.arena/files/biome/holymountain_scenes.xml")
                
            end

            GameSetCameraFree(true)
        end


        -- clean other player's data again because it might have failed for some cursed reason
        ArenaGameplay.CleanMembers(lobby, data)

        -- set ready counter
        ArenaGameplay.ReadyCounter(lobby, data)


        -- print member data
        --print(json.stringify(data))
    end,
    LoadArena = function(lobby, data, show_message, map)
        if(not steamutils.IsSpectator(lobby))then
            ArenaGameplay.SavePlayerData(lobby, data, true)

            GameRemoveFlagRun("can_save_player")
        end

        show_message = show_message or false

        np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
        np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
        np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
        np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)

        ArenaGameplay.ClearWorld()

        playermenu:Close()

        --[[
        local current_player = player.Get()

        if(current_player == nil)then
            ArenaGameplay.LoadPlayer(lobby, data)
        end
        ]]
        -- manage flags
        GameRemoveFlagRun("ready_check")
        GameRemoveFlagRun("first_death")
        GameRemoveFlagRun("skip_perks")
        GameRemoveFlagRun("in_hm")
        GameRemoveFlagRun("arena_winner")
        GameRemoveFlagRun("arena_loser")
        GameRemoveFlagRun("arena_first_death")
        
        data.state = "arena"
        data.preparing = true
        data.players_loaded = false
        data.deaths = 0
        data.lobby_loaded = false
        data.controlled_physics_entities = {}
        data.client.player_loaded_from_data = false

        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID() and data.players[tostring(member.id)] ~= nil) then
                data.players[tostring(member.id)].alive = true
            end
        end

        --message_handler.send.SendPerks(lobby)
        if(not steamutils.IsSpectator(lobby))then
            networking.send.perk_update(lobby, data)
        end

        ArenaGameplay.PreventFiring()
        local arena = nil
        -- available arenas
        local available_map_list = {}
        for k, v in ipairs(arena_list)do
            if(not GameHasFlagRun("map_blacklist_"..v.id))then
                table.insert(available_map_list, v)
            end
        end

        if(#available_map_list == 0)then
            table.insert(available_map_list, arena_list[1])
        end

        -- load map
        if(map)then
            for k, v in ipairs(available_map_list)do
                if(v.id == map)then
                    arena = v
                    break
                end
            end
        else
            local map_picker = GlobalsGetValue("map_picker", "random")
            for i = 1, 30 do
                local seed = data.random.range(1, 2)
                --print("test: "..seed)
            end
            if(map_picker == "random")then
                SetRandomSeed(seed, seed)
                arena = available_map_list[Random(1, #available_map_list)]
            elseif(map_picker == "ordered")then
                local last_arena = data.current_arena and data.current_arena.id or nil
                if(arena == nil)then
                    arena = available_map_list[1]
                else
                    -- get the next arena, loop around if past last
                    -- if current arena is nil, set to first arena
                    local next_arena = nil
                    for k, v in ipairs(available_map_list)do
                        if(v.id == last_arena)then
                            next_arena = available_map_list[k + 1]
                            break
                        end
                    end
                    if(next_arena == nil)then
                        next_arena = available_map_list[1]
                    end
                    arena = next_arena
                end
            end
        end
        data.current_arena = arena

        if(arena == nil)then
            print("[CRITICAL ERROR] Game failed to load arena, maplist missmatch?")
            GamePrint("[CRITICAL ERROR] Game failed to load arena, maplist missmatch?")
            popup.create("bad_map_load", GameTextGetTranslatedOrNot("$arena_map_critical_error"), GameTextGetTranslatedOrNot("$arena_map_map_load_failed"), {
                {
                    text = GameTextGetTranslatedOrNot("$mp_close_popup"),
                    callback = function()
                    end
                }
            }, -6000)

            disconnect({
                lobbyID = lobby,
                message = GameTextGetTranslatedOrNot("$arena_map_map_load_failed")
            })
            return
        end

        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_map_loaded"), tostring(arena.name)))

        BiomeMapLoad_KeepPlayer(arena.biome_map, arena.pixel_scenes)

        if(not steamutils.IsSpectator(lobby))then
            RunWhenPlayerExists(function()
                player.Lock()

                -- move player to correct position
                data.spawn_point = arena.spawn_points[data.random.range(1, #arena.spawn_points)]

                ArenaGameplay.LoadClientPlayers(lobby, data)

                --GamePrint("Loading arena")

                GameAddFlagRun("can_save_player")
            end)
        end
    end,
    ReadyCheck = function(lobby, data)
        --print("Players ready: "..tostring(ArenaGameplay.ReadyAmount(data, lobby)))
        return ArenaGameplay.TotalPlayers(lobby) > 0 and (ArenaGameplay.ReadyAmount(data, lobby) >= ArenaGameplay.TotalPlayers(lobby))
    end,
    SetReady = function(lobby, data, ready, silent)
        if (ready == nil) then
            return
        end

        --print("SetReady called: "..tostring(ready))

        if (ready) then
            GamePrint(GameTextGetTranslatedOrNot("$arena_self_ready"))
        else
            GamePrint(GameTextGetTranslatedOrNot("$arena_self_unready"))
            GameRemoveFlagRun("ready_check")
        end

        networking.send.ready(lobby, ready, silent or false)
        data.client.ready = ready
        if (steamutils.IsOwner(lobby)) then
            steam.matchmaking.setLobbyData(lobby, tostring(steam.user.getSteamID()) .. "_ready", tostring(ready))
        end
    end,
    CleanMembers = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID() and data.players[tostring(member.id)] ~= nil) then
                data.players[tostring(member.id)]:Clean(lobby)
            end
        end
    end,
    UpdateTweens = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)

        local validMembers = {}

        for _, member in pairs(members) do
            local memberid = tostring(member.id)

            validMembers[memberid] = true
        end

        -- iterate active tweens backwards and update
        for i = #data.tweens, 1, -1 do
            local tween = data.tweens[i]
            if (tween) then
                if (validMembers[tween.id] == nil) then
                    table.remove(data.tweens, i)
                else
                    if (tween:update()) then
                        table.remove(data.tweens, i)
                    end
                end
            end
        end
    end,
    RunReadyCheck = function(lobby, data)
        if (steamutils.IsOwner(lobby)) then
            --print("we are owner!")
            -- check if all players are ready
            if (ArenaGameplay.ReadyCheck(lobby, data)) then
                if(ArenaLoadCountdown == nil)then
                    print("all players ready!")
                    GameAddFlagRun("lock_ready_state")
                    networking.send.lock_ready_state(lobby)
                    ArenaLoadCountdown = GameGetFrameNum() + 62
                end
            else
                ArenaLoadCountdown = nil 
            end

            if (ArenaLoadCountdown ~= nil and GameGetFrameNum() >= ArenaLoadCountdown) then
                ArenaLoadCountdown = nil

                if(data.ready_counter)then
                    data.ready_counter:cleanup()
                    data.ready_counter = nil
                end

                -- still ready? start game.
                if (ArenaGameplay.ReadyCheck(lobby, data)) then

                    local map_picker = GlobalsGetValue("map_picker", "random")

                    if(map_picker == "vote")then
                        -- pick 3 random map ids from arena_list
                        -- no duplicate maps
                        -- it should be {id, id2, id3}

                        -- available arenas
                        local available_map_list = {}
                        for k, v in ipairs(arena_list)do
                            if(not GameHasFlagRun("map_blacklist_"..v.id))then
                                table.insert(available_map_list, v)
                            end
                        end

                        if(#available_map_list == 0)then
                            table.insert(available_map_list, arena_list[1])
                        end

                        local map_ids = {}
                        local picked_maps = {}
                        -- if we have less than 3 maps, just pick all of them
                        if(#available_map_list <= 3)then
                            for k, v in ipairs(available_map_list)do
                                table.insert(map_ids, v.id)
                            end
                        else
                            for i = 1, 3 do
                                local map_id = nil
                                while(map_id == nil or picked_maps[map_id] ~= nil)do
                                    local index = data.random.range(1, #available_map_list)
                                    print(tostring(index))
                                    map_id = available_map_list[index].id
                                end
                                table.insert(map_ids, map_id)
                                picked_maps[map_id] = true
                            end
                        end

                        networking.send.start_map_vote(lobby, map_ids)
                        gameplay_handler.StartMapVote(lobby, data, map_ids)
                    else
                        ArenaGameplay.LoadArena(lobby, data, true)
                        networking.send.enter_arena(lobby, data.current_arena.id)
                    end
                end
            end
        end
    end,
    StartMapVote = function(lobby, data, maps)
        data.state = "map_vote"
        data.map_vote = {}
        data.voters = {}
        for k, v in ipairs(maps)do
            data.map_vote[v] = 0
        end

        local vote_length = tonumber(GlobalsGetValue("map_vote_timer", tostring(90))) * 60
        local vote_gui = GuiCreate()
        local last_hovered = nil
        local finish_time = (3 * 60)
        local finish_frame_count = 0

        data.vote_loop = delay.new(vote_length + finish_time, function()
            -- finish
            if(steamutils.IsOwner(lobby))then
                -- find highest vote, if there is a tie, pick random
                
                ArenaGameplay.LoadArena(lobby, data, true, data.vote_loop.winner)
                networking.send.enter_arena(lobby, data.vote_loop.winner)
            end
            GuiDestroy(vote_gui)
        end, function(frames)
            --print("Current game frame: "..tostring(GameGetFrameNum()))
            if(steamutils.IsOwner(lobby))then
                --print("Sending map vote timer update")
                networking.send.map_vote_timer_update(lobby, frames)
            end

            -- tick
            local frames_left = frames - finish_time

            if(frames_left < 0)then
                frames_left = 0
            end
            --GamePrint("Voting ends in "..tostring(math.floor(frames / 60)).." seconds")

            if(steamutils.IsOwner(lobby))then
                if(frames_left <= 0 )then
                    if(not data.vote_loop.vote_finished)then
                        local highest_vote = 0
                        local highest_vote_id = nil
                        local was_tie = false
                        for k, v in pairs(data.map_vote)do
                            if(v > highest_vote)then
                                highest_vote = v
                                highest_vote_id = k
                                was_tie = false
                            elseif(v == highest_vote)then
                                if(data.random.range(1, 2) == 1)then
                                    highest_vote = v
                                    highest_vote_id = k
                                end
                                was_tie = true
                            end
                        end
        
                        if(highest_vote_id == nil)then
                            highest_vote_id = maps[data.random.range(1, #maps)]
                        end
                        
                        data.vote_loop.winner = highest_vote_id
                        data.vote_loop.was_tie = was_tie
                        networking.send.map_vote_finish(lobby, highest_vote_id, was_tie)
                    end
                    data.vote_loop.vote_finished = true
                end
            end




            local curr_id = 2152135
            local function new_id()
                curr_id = curr_id + 1
                return curr_id
            end

            local function get_map(id)
                for k, v in ipairs(arena_list)do
                    if(v.id == id)then
                        return v
                    end
                end
                return nil
            end

            local add_vote = function(map)
            
                networking.send.add_vote(lobby, map.id)
                if data.map_vote == nil then
                    data.map_vote = {}
                end
    
                if data.map_vote[map.id] == nil then
                    data.map_vote[map.id] = 0
                end
                
                data.map_vote[map.id] = data.map_vote[map.id] + 1
    
                if(data.voters ~= nil)then
                    if(data.voters["self"])then
                        local vote = data.voters["self"]
                        if(vote ~= nil)then
                            if(data.map_vote[vote] ~= nil)then
                                data.map_vote[vote] = data.map_vote[vote] - 1
                                --GamePrint("Removed vote from "..tostring(vote))
                            end
                        end
                    end
                    
                    data.voters["self"] = map.id
                end
   
            end

            -- draw vote ui
            if (not IsPaused()) then
                GuiStartFrame(vote_gui)
                GuiOptionsAdd(vote_gui, 6)
                local screen_w, screen_h = GuiGetScreenDimensions(vote_gui)

                local total_card_width = 0
                local distance_between_cards = 10
                
                local all_vote_maps = {}

                local max_height = 0

                for i = 1, #maps do
                    local v = maps[i]
                    local map = get_map(v)
                    
                    table.insert(all_vote_maps, map)

                    local frame_width, frame_height = GuiGetImageDimensions(vote_gui, map.frame, 1)

                    total_card_width = total_card_width + frame_width
                    if i < #maps then
                        total_card_width = total_card_width + distance_between_cards
                    end
                    if(frame_height > max_height)then
                        max_height = frame_height
                    end
                end

                local highest_vote = 0
                for k, v in pairs(data.map_vote)do
                    if(v > highest_vote)then
                        highest_vote = v
                    end
                end

                local function get_next_highest_vote_index(current_index)
                    local found = false
                    while not found do
                        current_index = current_index + 1
                        if(current_index > #all_vote_maps)then
                            current_index = 1
                        end
                        if(data.map_vote[all_vote_maps[current_index].id] == highest_vote)then
                            found = true
                            return current_index
                        end
                    end
                end

                local time_between_cycle = 8
                --GamePrint(tostring(time_between_cycle))
                if(frames_left <= 0)then
                    finish_frame_count = finish_frame_count + 1
                    local total_map_cycle_time = time_between_cycle * #all_vote_maps
                    if(data.vote_loop.vote_finished and data.vote_loop.winner)then
                        if(data.vote_loop.was_tie)then
                            if(last_hovered == nil)then
                                last_hovered = get_next_highest_vote_index(0)
                            else
                                if(frames >= total_map_cycle_time * 3)then
                                    if(GameGetFrameNum() % time_between_cycle == 0)then
                                        last_hovered = get_next_highest_vote_index(last_hovered)
                                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/streaming_integration/new_vote", GameGetCameraPos() )
                                    end
                                else
                                    if(GameGetFrameNum() % time_between_cycle == 0 and all_vote_maps[last_hovered].id ~= data.vote_loop.winner)then
                                        last_hovered = get_next_highest_vote_index(last_hovered)
                                        GamePlaySound( "data/audio/Desktop/ui.bank", "ui/streaming_integration/new_vote", GameGetCameraPos() )
                                    end
                                end
                            end
                        end
                    end
                end
    

                local map_header = GameTextGetTranslatedOrNot("$arena_map_vote_header")
                local map_header_width, map_header_height = GuiGetTextDimensions(vote_gui, map_header, 1)
                GuiZSetForNextWidget(vote_gui, -11)
                GuiText(vote_gui, (screen_w / 2) - (map_header_width / 2), (screen_h / 2) - (max_height / 2) - 30, map_header)

                local timer_text = string.format(GameTextGetTranslatedOrNot("$arena_map_vote_timer"), tostring(math.floor(frames_left / 60)))
                local timer_text_width, timer_text_height = GuiGetTextDimensions(vote_gui, timer_text, 1)
                GuiZSetForNextWidget(vote_gui, -11)
                GuiColorSetForNextWidget(vote_gui, 0.6, 0.6, 0.6, 1)
                
                GuiText(vote_gui, (screen_w / 2) - (timer_text_width / 2), (screen_h / 2) + (max_height / 2) + 7 + (last_hovered ~= nil and (timer_text_height + 1) or 0), timer_text)

                local x = (screen_w / 2) - (total_card_width / 2)
                
                for i = 1, #all_vote_maps do
                    local was_hovered = last_hovered ~= nil and last_hovered == i

                    local v = all_vote_maps[i]
                    local size = 1
                    if(was_hovered)then
                        size = 1.1
                    end
                    
                    local frame_width, frame_height = GuiGetImageDimensions(vote_gui, v.frame, 1)
                    local thumbnail_width, thumbnail_height = GuiGetImageDimensions(vote_gui, v.thumbnail, 1)

                    local card_y = (screen_h / 2) - (frame_height / 2)
                    local card_x = x + ((i - 1) * (frame_width + distance_between_cards))

                    local old_card_y = card_y
                    local old_card_x = card_x

                    if(was_hovered)then
                        card_x = card_x - ((frame_width * 0.1) / 2)
                        card_y = card_y - ((frame_height * 0.1) / 2)
                    end

                    

                    local voters = data.map_vote[v.id] or 0
                    local vote_text = string.format(GameTextGetTranslatedOrNot("$arena_map_vote_votes"), tostring(voters))

                    local vote_text_width, vote_text_height = GuiGetTextDimensions(vote_gui, vote_text)
                    
                    GuiZSetForNextWidget(vote_gui, -11)
                    GuiText(vote_gui, ((card_x + (frame_width * size)) - 6) - vote_text_width, ((card_y + (frame_height * size)) - 4) - vote_text_height, vote_text)
                    GuiZSetForNextWidget(vote_gui, -11)
                    GuiText(vote_gui, card_x + 8, card_y + 6, v.name)
                    GuiZSetForNextWidget(vote_gui, -10)
                    GuiImage(vote_gui, new_id(), card_x, card_y, v.frame, 1, size, size)
                    GuiZSetForNextWidget(vote_gui, -9)
                    GuiImage(vote_gui, new_id(), (card_x + (frame_width / 2)) - (thumbnail_width / 2), (card_y + (frame_height / 2)) - (thumbnail_height / 2), v.thumbnail, 1, size, size)
                    local clicked, _, hovered = GuiGetPreviousWidgetInfo(vote_gui)
                    if(frames_left > 0)then
                        if(hovered)then
                            last_hovered = i
                            local text_width = GuiGetTextDimensions(vote_gui, v.description)
                            GuiText(vote_gui, (screen_w / 2) - (text_width / 2), old_card_y + max_height + 7, v.description)
                        else
                            if(last_hovered == i)then
                                last_hovered = nil
                            end
                        end
                        if(clicked)then
                            add_vote(v)
                            GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                        end
                    else
                        if(data.vote_loop.vote_finished and data.vote_loop.winner)then
                            if(not data.vote_loop.was_tie)then
                                if(v.id == data.vote_loop.winner)then
                                    last_hovered = i
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
    LobbyUpdate = function(lobby, data)
        -- update ready counter
        if (data.ready_counter ~= nil) then
            if (not IsPaused()) then
                data.ready_counter:appy_offset(9, 28)
            else
                data.ready_counter:appy_offset(9, 9)
            end


            data.ready_counter:update()
        end

        --if (GameGetFrameNum() % 2 == 0) then
            networking.send.character_position(lobby, data, true)
        --end
       -- networking.send.wand_update(lobby, data, nil, nil, true)
        networking.send.input_update(lobby, true)
        networking.send.animation_update(lobby, data, true)
        if(GameGetFrameNum() % 15 == 0)then
            networking.send.player_data_update(lobby, data, true)
        end
        networking.send.spectate_data(lobby, data, nil, false)

        GameAddFlagRun("Immortal")

        ArenaGameplay.RunReadyCheck(lobby, data)

        if (GameHasFlagRun("player_ready")) then
            GameRemoveFlagRun("player_ready")

            ArenaGameplay.SetReady(lobby, data, true)
        end

        if (GameHasFlagRun("player_unready")) then
            GameRemoveFlagRun("player_unready")

            ArenaGameplay.SetReady(lobby, data, false)
        end

        if (GameGetFrameNum() % 5 == 0) then
            -- message_handler.send.UpdateHp(lobby, data)
            networking.send.health_update(lobby, data)
            --message_handler.send.SendPerks(lobby)
            networking.send.perk_update(lobby, data)
        end

        if(GameGetFrameNum() % 60 == 0)then
            networking.send.request_perk_update(lobby)
        end
    end,
    UpdateHealthbars = function(data)
        for k, v in pairs(data.players) do
            if (v.hp_bar) then
                if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                    local x, y = EntityGetTransform(v.entity)
                    y = y + 10
                    v.hp_bar:update(x, y)
                end
            end
        end
    end,
    CheckAllPlayersLoaded = function(lobby, data)
        local ready = not data.preparing
        for k, v in pairs(data.players) do
            if not v.loaded then
                ready = false
                break
            end
        end
        return ready
    end,
    FightCountdown = function(lobby, data)
        player.Unlock(data)
        data.countdown = countdown.create({
            "mods/evaisa.arena/files/sprites/ui/countdown/ready.png",
            "mods/evaisa.arena/files/sprites/ui/countdown/3.png",
            "mods/evaisa.arena/files/sprites/ui/countdown/2.png",
            "mods/evaisa.arena/files/sprites/ui/countdown/1.png",
            "mods/evaisa.arena/files/sprites/ui/countdown/fight.png",
        }, 60, function()
            print("Countdown completed")
            data.countdown:cleanup()
            data.countdown = nil
            --message_handler.send.Unlock(lobby)
            networking.send.unlock(lobby)
            GameAddFlagRun("countdown_completed")
            if(not steamutils.IsSpectator(lobby))then
                player.Immortal(false)
            end
            ArenaGameplay.AllowFiring(data)

            arena_log:print("Completed countdown.")

            --message_handler.send.RequestWandUpdate(lobby, data)
            networking.send.request_item_update(lobby)
        end)
    end,
    SpawnClientPlayer = function(lobby, user, data, x, y)
        local client = EntityLoad("mods/evaisa.arena/files/entities/client.xml", x or -1000, y or -1000)
        EntitySetName(client, tostring(user))
        local usernameSprite = EntityGetFirstComponentIncludingDisabled(client, "SpriteComponent", "username")
        local name = steamutils.getTranslatedPersonaName(user)
        ComponentSetValue2(usernameSprite, "text", name)
        ComponentSetValue2(usernameSprite, "offset_x", string.len(name) * (1.8))
        data.players[tostring(user)].entity = client
        data.players[tostring(user)].alive = true

        arena_log:print("Spawned client player for " .. name)

        if (data.players[tostring(user)].perks) then
            for k, v in ipairs(data.players[tostring(user)].perks) do
                local perk = v[1]
                local count = v[2]

                for i = 1, count do
                    EntityHelper.GivePerk(client, perk, i, true)
                end
            end
        end

        return client
    end,
    CheckPlayer = function(lobby, user, data)
        if (not data.players[tostring(user)].entity and data.players[tostring(user)].alive) then
            --ArenaGameplay.SpawnClientPlayer(lobby, user, data)
            return false
        end
        return true
    end,
    LoadClientPlayers = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do
            if (member.id ~= steam.user.getSteamID() and data.players[tostring(member.id)].entity) then
                data.players[tostring(member.id)]:Clean(lobby)
            end

            --[[if(member.id ~= steam.user.getSteamID())then
                print(json.stringify(data.players[tostring(member.id)]))
            end]]
            if (member.id ~= steam.user.getSteamID() and data.players[tostring(member.id)].entity == nil) then
                --GamePrint("Loading player " .. tostring(member.id))
                ArenaGameplay.SpawnClientPlayer(lobby, member.id, data)
            end
        end
    end,
    ClosestPlayer = function(x, y)
        closest = EntityGetClosestWithTag(x, y, "client")
        if (closest ~= nil) then
            return EntityGetName(closest)
        end

        return nil
    end,
    ArenaUpdate = function(lobby, data)
        if (data.preparing) then
            local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")
            local world_seed = tonumber(steam.matchmaking.getLobbyData(lobby, "seed") or 1)
            local spawn_seed = world_seed + (ArenaGameplay.GetNumRounds() * 62362)
            local spawn_rng = rng.new(spawn_seed)
            local spawn_points = ArenaGameplay.GetSpawnPoints()
            -- shuffle spawn points using spawn_rng.range(a, b)
            for i = #spawn_points, 2, -1 do
                local j = spawn_rng.range(1, i)
                spawn_points[i], spawn_points[j] = spawn_points[j], spawn_points[i]
            end


            print("Spawn RNG: "..tostring(spawn_seed))


            if (spawn_points ~= nil and #spawn_points > 0 and data.current_arena ~= nil) then
                data.ready_for_zone = true

                local spawn_index = math.floor(ArenaGameplay.GetPlayerIndex(lobby) % #spawn_points)

                if(spawn_index < 1)then
                    spawn_index = 1
                end

                local spawn_point = spawn_points[spawn_index]
                local x, y = EntityGetTransform(spawn_point)

                local spawn_loaded = DoesWorldExistAt(x - 100, y - 100, x + 100, y + 100)

                player.Move(x, y)

                arena_log:print("Arena loaded? " .. tostring(spawn_loaded))

                local in_bounds = ArenaGameplay.IsInBounds(0, 0, data.current_arena.zone_size)

                if (not in_bounds) then
                    arena_log:print("Game tried to spawn player out of bounds, retrying...")
                    GamePrint("Game attempted to spawn you out of bounds, retrying...")
                end

                if (spawn_loaded and in_bounds) then
                    data.preparing = false


                    --GamePrint("Spawned!!")

                    if (not steamutils.IsOwner(lobby)) then
                        networking.send.arena_loaded(lobby)
                        --message_handler.send.Loaded(lobby)
                    end

                    --message_handler.send.Health(lobby)
                    networking.send.health_update(lobby, data, true)
                end
            else
                player.Move(data.spawn_point.x, data.spawn_point.y)
            end
        end
        local player_entities = {}
        for k, v in pairs(data.players) do
            if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                table.insert(player_entities, v.entity)
            end
        end
        if (not IsPaused() and GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))) then
            game_funcs.RenderOffScreenMarkers(player_entities)
            game_funcs.RenderAboveHeadMarkers(player_entities, 0, 27)
            ArenaGameplay.UpdateHealthbars(data)
        end

        if (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))) then
            ArenaGameplay.DamageZoneHandler(lobby, data, true)
        else
            ArenaGameplay.DamageZoneHandler(lobby, data, false)
        end

        local player_entity = player.Get()

        if (steamutils.IsOwner(lobby)) then
            if (player_entity ~= nil and (not data.players_loaded and ArenaGameplay.CheckAllPlayersLoaded(lobby, data))) then
                data.players_loaded = true
                arena_log:print("All players loaded")
                --message_handler.send.StartCountdown(lobby)
                networking.send.start_countdown(lobby)
                ArenaGameplay.FightCountdown(lobby, data)
            end
        end
        if (data.countdown ~= nil) then
            data.countdown:update()
        end

        if (GameGetFrameNum() % 2 == 0) then
            networking.send.character_position(lobby, data)
        end

        if (GameHasFlagRun("took_damage")) then
            GameRemoveFlagRun("took_damage")
            --message_handler.send.Health(lobby)
            networking.send.health_update(lobby, data, true)
        end
        if (data.players_loaded) then
            --message_handler.send.WandUpdate(lobby, data)
            --networking.send.item_update(lobby, data)

            --[[if(GameGetFrameNum() % 60 == 0)then
                networking.send.wand_update(lobby, data, nil, true)
                networking.send.switch_item(lobby, data, nil, true)
            end]]
            if (GameGetFrameNum() % 2 == 0 and GameHasFlagRun("countdown_completed")) then
                networking.send.unlock(lobby)
            end


            --message_handler.send.SwitchItem(lobby, data)
            --message_handler.send.Kick(lobby, data)
            --message_handler.send.AnimationUpdate(lobby, data)
            networking.send.animation_update(lobby, data)
            if(GameGetFrameNum() % 15 == 0)then
                networking.send.player_data_update(lobby, data)
            end
            --message_handler.send.AimUpdate(lobby)
            --message_handler.send.SyncControls(lobby, data)
            networking.send.input_update(lobby)

            ArenaGameplay.CheckFiringBlock(lobby, data)
        end
    end,
    ValidatePlayers = function(lobby, data)
        for k, v in pairs(data.players) do
            local playerid = ArenaGameplay.FindUser(lobby, k)

            if (playerid == nil) then
                v:Clean(lobby)
                data.players[k] = nil
                --local name = steamutils.getTranslatedPersonaName(playerid)
                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_player_left") ,tostring(lobby_member_names[k])))

                -- if we are the last player, unready
                if(not data.spectator_mode)then
                    if (steam.matchmaking.getNumLobbyMembers(lobby) == 1) then
                        GameRemoveFlagRun("lock_ready_state")
                        GameAddFlagRun("player_unready")
                        GameRemoveFlagRun("ready_check")
                        --ArenaGameplay.SetReady(lobby, data, false, true)
                    end
                end

                --[[if (steamutils.IsOwner(lobby)) then
                    local winner_key = tostring(k) .. "_wins"
                    steam.matchmaking.deleteLobbyData(lobby, winner_key)
                end
                ]]
                lobby_member_names[k] = nil
                if (data.state == "arena") then
                    if(not data.spectator_mode)then
                        ArenaGameplay.WinnerCheck(lobby, data) 
                    else
                        spectator_handler.WinnerCheck(lobby, data)
                    end
                end
            end
        end
    end,
    GetAlivePlayers = function(lobby, data)
        local alive_players = {}
        for k, v in pairs(data.players) do
            if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                table.insert(alive_players, v)
            end
        end
        return alive_players
    end,
    Update = function(lobby, data)
        SpectatorMode.SpectateUpdate(lobby, data)

        if(data.upgrade_system ~= nil and not IsPaused())then
            data.upgrade_system:draw()
        end
        

        local spells = EntityGetWithTag("card_action")
        for k, card in ipairs(spells)do
            if(not EntityHasTag(card, "patched_unlimited"))then
                local root = EntityGetRootEntity(card)
                if((GameHasFlagRun( "arena_unlimited_spells" ) and not EntityHasTag(root, "client")) or EntityHasTag(root, "unlimited_spells"))then
                    local ability_comp = EntityGetFirstComponentIncludingDisabled(card, "AbilityComponent")
                    if(ability_comp ~= nil)then
                        ComponentObjectSetValue2(ability_comp, "gunaction_config", "action_max_uses", -1)
                    end
                    local item_comp = EntityGetFirstComponentIncludingDisabled(card, "ItemComponent")
                    if(item_comp ~= nil)then
                        ComponentSetValue2(item_comp, "uses_remaining", -2)
                    end
                end
                local inventory2_comp = EntityGetFirstComponentIncludingDisabled( root, "Inventory2Component" )
                if( inventory2_comp ) then
                    ComponentSetValue( inventory2_comp, "mActualActiveItem", "0" )
                end
                EntityAddTag(card, "patched_unlimited")
            end
        end
 
        --if(GameGetFrameNum() % 60 == 0)then
        --message_handler.send.Handshake(lobby)
        --end

        --[[local chunk_loaders = EntityGetWithTag("chunk_loader") or {}
        for k, v in pairs(chunk_loaders)do
            local chunk_loader_x, chunk_loader_y = EntityGetTransform(v)
            game_funcs.LoadRegion(chunk_loader_x, chunk_loader_y, 1000, 1000)
        end]]
        for k, v in pairs(data.players) do
            if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                local controls = EntityGetFirstComponentIncludingDisabled(v.entity, "ControlsComponent")
                if (controls) then
                    ComponentSetValue2(controls, "mButtonDownKick", false)
                    ComponentSetValue2(controls, "mButtonDownFire", false)
                    ComponentSetValue2(controls, "mButtonDownFire2", false)
                    ComponentSetValue2(controls, "mButtonDownLeftClick", false)
                    ComponentSetValue2(controls, "mButtonDownRightClick", false)
                end
            end
        end

        if (data.state == "lobby") then
            networking.send.sync_wand_stats(lobby, data, true)
            ArenaGameplay.LobbyUpdate(lobby, data)
        elseif (data.state == "arena") then
            -- message_handler.send.SyncWandStats(lobby, data)
            networking.send.sync_wand_stats(lobby, data)
            ArenaGameplay.ArenaUpdate(lobby, data)
            ArenaGameplay.KillCheck(lobby, data)
        end
        if (GameHasFlagRun("no_shooting")) then
            ArenaGameplay.CancelFire(lobby, data)
        end
        ArenaGameplay.UpdateTweens(lobby, data)
        if (GameGetFrameNum() % 60 == 0) then
            ArenaGameplay.ValidatePlayers(lobby, data)
        end
    end,
    LateUpdate = function(lobby, data)

        --data.controlled_physics_entities

        local first_update = {}
        local kicked_item_string = GlobalsGetValue("arena_items_controlled", "") or ""
        for item in string.gmatch(kicked_item_string, "([^;]+)") do
            local item_entity = tonumber(item) or 0
            local has_control = false
            for k, v in ipairs(data.controlled_physics_entities)do
                if(v == item_entity)then
                    has_control = true
                    break
                end
            end
            if(EntityGetIsAlive(item_entity) and not first_update[item_entity] and not has_control)then
                table.insert(data.controlled_physics_entities, item_entity)
                first_update[item_entity] = true
                local arena_entity_id = EntityHelper.GetVariable(item_entity, "arena_entity_id")

                if(arena_entity_id ~= nil)then
                    --GamePrint("We took controls of item: "..tostring(item_entity))
                end
            end
        end
        if(kicked_item_string ~= "")then
            GlobalsSetValue("arena_items_controlled", "")
        end

        for i = #data.controlled_physics_entities, 1, -1 do
            local entity = data.controlled_physics_entities[i]
            if(not EntityGetIsAlive(entity))then
                table.remove(data.controlled_physics_entities, i)
            else
                local arena_entity_id = EntityHelper.GetVariable(entity, "arena_entity_id")

                if(arena_entity_id ~= nil)then
                    local body_ids = PhysicsBodyIDGetFromEntity( entity )
                    if(body_ids ~= nil and #body_ids > 0)then
                        local body_id = body_ids[1]
                        local x, y, r, vel_x, vel_y, vel_a =  PhysicsBodyIDGetTransform( body_id )

                        networking.send.physics_update(lobby, arena_entity_id, x, y, r, vel_x, vel_y, vel_a, first_update[entity])
                    end
                end
            end
        end

        local fungal_shift_from = GlobalsGetValue("arena_fungal_shift_from", "")
        local fungal_shift_to = GlobalsGetValue("arena_fungal_shift_to", "")
        if(fungal_shift_from ~= "" and fungal_shift_to ~= "")then
            local from_table = {}
            local to = fungal_shift_to

            for material in string.gmatch(fungal_shift_from, "([^;]+)") do
                table.insert(from_table, material)
            end

            networking.send.fungal_shift(lobby, from_table, to)
        end
        GlobalsSetValue("arena_fungal_shift_from", "")
        GlobalsSetValue("arena_fungal_shift_to", "")

        if (data.state == "arena") then
            ArenaGameplay.KillCheck(lobby, data)

            local player = player.Get()

            local inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")

            local inventory_open = ComponentGetValue2(inventory_gui_comp, "mActive")
            if(inventory_open)then
                if(not data.client.inventory_was_open)then
                    --GamePrint("inventory_was_opened")
                end
                data.client.inventory_was_open = true
            else
                if(data.client.inventory_was_open)then
                    --GamePrint("inventory_was_closed")
                    networking.send.item_update(lobby, data, nil, true, false)
                end
                data.client.inventory_was_open = false
            end

            if(GlobalsGetValue("arena_item_pickup", "0") ~= "0")then
                networking.send.item_picked_up(lobby, tonumber(GlobalsGetValue("arena_item_pickup", "0")))
                GlobalsSetValue("arena_item_pickup", "0")
            end
            
            --
        --[[else
            data.client.projectile_rng_stack = {}
            data.client.projectiles_fired = 0]]
        else
            local player = player.Get()

            local inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")

            local inventory_open = ComponentGetValue2(inventory_gui_comp, "mActive")
            if(inventory_open)then
                data.client.inventory_was_open = true
            else
                if(data.client.inventory_was_open)then
                    networking.send.item_update(lobby, data, nil, true, true)
                end
                data.client.inventory_was_open = false
            end

            if(GlobalsGetValue("arena_item_pickup", "0") ~= "0")then
                networking.send.item_picked_up(lobby, tonumber(GlobalsGetValue("arena_item_pickup", "0")), true)
                GlobalsSetValue("arena_item_pickup", "0")
            end

        end



        local current_inventory_info = player.GetInventoryInfo()

        no_switching = no_switching or 0

        if(data.client.last_inventory == nil or player.DidInventoryChange(data.client.last_inventory, current_inventory_info))then
           -- GamePrint("Inventory has changed!")
            GameAddFlagRun("ForceUpdateInventory")
            no_switching = 10
            data.client.last_inventory = current_inventory_info
        end

        if(no_switching > 0)then
            --GamePrint("No switching: "..tostring(no_switching))
            no_switching = no_switching - 1
        else
            
            if(GameHasFlagRun("ForceUpdateInventory"))then
                --GamePrint("Updating inventory!")
                GameRemoveFlagRun("ForceUpdateInventory")
                if (data.state == "arena") then
                    networking.send.item_update(lobby, data, nil, true, false)
                else
                    networking.send.item_update(lobby, data, nil, true, true)
                end
            end

            if (data.state == "arena") then
                networking.send.switch_item(lobby, data)
            else
                networking.send.switch_item(lobby, data, nil, nil, true)
            end
        end


        
        local current_player = player.Get()

        local projectiles_fired = tonumber(GlobalsGetValue( "wand_fire_count", "0" ))

        if (projectiles_fired > 0--[[data.client.projectiles_fired ~= nil and data.client.projectiles_fired > 0]]) then
            local special_seed = tonumber(GlobalsGetValue("player_rng", "0"))
            --local cast_state = GlobalsGetValue("player_cast_state") or nil

            --print(tostring(cast_state))

            --GamePrint("Sending special seed:"..tostring(special_seed))
            --message_handler.send.WandFired(lobby, data.client.projectile_rng_stack, special_seed, cast_state)
            if(data.state == "arena")then
                networking.send.fire_wand(lobby, data.client.projectile_rng_stack, special_seed)
            else
                networking.send.fire_wand(lobby, data.client.projectile_rng_stack, special_seed, true)
            end
            GlobalsSetValue("wand_fire_count", "0")
            data.client.projectile_rng_stack = {}
        end


        GlobalsSetValue("wand_fire_count", "0")


        if ((not GameHasFlagRun("player_unloaded")) and current_player == nil) then
            ArenaGameplay.LoadPlayer(lobby, data)
            arena_log:print("Player is missing, spawning player.")
        else
            if (GameGetFrameNum() % 30 == 0 and GameHasFlagRun("can_save_player")) then
                ArenaGameplay.SavePlayerData(lobby, data)
            end
        end


        if (data.current_player ~= current_player) then
            data.current_player = current_player
            if (current_player ~= nil) then
                np.RegisterPlayerEntityId(current_player)
            end
        end

        if (GameHasFlagRun("in_hm") and current_player) then
            player.Move(0, 0)
            GameRemoveFlagRun("in_hm")
        end

        if (GameGetFrameNum() % 5 == 0) then
            -- if we are host
            if (steamutils.IsOwner(lobby)) then
                ArenaGameplay.SendGameData(lobby, data)
            end
        end

        for k, v in pairs(data.players) do
            if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                local controls = EntityGetFirstComponentIncludingDisabled(v.entity, "ControlsComponent")
                if (controls) then
                    if (ComponentGetValue2(controls, "mButtonDownKick") == false) then
                        data.players[k].controls.kick = false
                    end
                    -- mButtonDownFire
                    if (ComponentGetValue2(controls, "mButtonDownFire") == false) then
                        data.players[k].controls.fire = false
                    end
                    -- mButtonDownFire2
                    if (ComponentGetValue2(controls, "mButtonDownFire2") == false) then
                        data.players[k].controls.fire2 = false
                    end
                    -- mButtonDownLeft
                    if (ComponentGetValue2(controls, "mButtonDownLeftClick") == false) then
                        data.players[k].controls.leftClick = false
                    end
                    -- mButtonDownRight
                    if (ComponentGetValue2(controls, "mButtonDownRightClick") == false) then
                        data.players[k].controls.rightClick = false
                    end
                    -- mButtonDownAction
                    if (ComponentGetValue2(controls, "mButtonDownAction") == false) then
                        data.players[k].controls.action = false
                    end
                    -- mButtonDownThrow
                    if (ComponentGetValue2(controls, "mButtonDownThrow") == false) then
                        data.players[k].controls.throw = false
                    end
                    -- mButtonDownInteract
                    if (ComponentGetValue2(controls, "mButtonDownInteract") == false) then
                        data.players[k].controls.interact = false
                    end
                    -- mButtonDownLeft
                    if (ComponentGetValue2(controls, "mButtonDownLeft") == false) then
                        data.players[k].controls.left = false
                    end
                    -- mButtonDownRight
                    if (ComponentGetValue2(controls, "mButtonDownRight") == false) then
                        data.players[k].controls.right = false
                    end
                    -- mButtonDownUp
                    if (ComponentGetValue2(controls, "mButtonDownUp") == false) then
                        data.players[k].controls.up = false
                    end
                    -- mButtonDownDown
                    if (ComponentGetValue2(controls, "mButtonDownDown") == false) then
                        data.players[k].controls.down = false
                    end
                    -- mButtonDownJump
                    if (ComponentGetValue2(controls, "mButtonDownJump") == false) then
                        data.players[k].controls.jump = false
                    end
                    -- mButtonDownFly
                    if (ComponentGetValue2(controls, "mButtonDownFly") == false) then
                        data.players[k].controls.fly = false
                    end
                end
            end
        end

        local current_player = player.Get()

        if ((not GameHasFlagRun("player_unloaded")) and current_player ~= nil and EntityGetIsAlive(current_player)) then
            --print("Running player function queue")
            -- run playerRunQueue
            for i = 1, #playerRunQueue do
                local func = playerRunQueue[i]
                arena_log:print("Ran item #" .. i .. " in playerRunQueue")
                func()
            end
            playerRunQueue = {}
        end
    end,
    OnProjectileFired = function(lobby, data, shooter_id, projectile_id, rng, position_x, position_y, target_x, target_y, send_message, unknown1, multicast_index, unknown3)
        --print(tostring(shooter_id))
        
        local playerEntity = player.Get()
        if (playerEntity ~= nil and playerEntity == shooter_id) then
    
            local projectileComponent = EntityGetFirstComponentIncludingDisabled(projectile_id,
                "ProjectileComponent")

            --print("yeah??")

            data.client.projectiles_fired = data.client.projectiles_fired + 1

            local who_shot            = ComponentGetValue2(projectileComponent, "mWhoShot")
            local entity_that_shot    = ComponentGetValue2(projectileComponent, "mEntityThatShot")
            if (entity_that_shot == 0 and multicast_index ~= -1 and unknown3 == 0) then
                
                --rng = data.client.spread_index
                local rand = data.random.range(0, 100000)
                local rng = math.floor(rand)

                table.insert(data.client.projectile_rng_stack, rng)

                --GamePrint("Setting spread rng: "..tostring(rng))

                np.SetProjectileSpreadRNG(rng)

                --data.client.spread_index = data.client.spread_index + 1

                --[[if(data.client.spread_index > 10)then
                    data.client.spread_index = 1
                end]]
            else
                if (data.projectile_seeds[entity_that_shot]) then
                    local new_seed = data.projectile_seeds[entity_that_shot] + 25
                    np.SetProjectileSpreadRNG(new_seed)
                    data.projectile_seeds[entity_that_shot] = data.projectile_seeds[entity_that_shot] + 10
                    data.projectile_seeds[projectile_id] = new_seed
                end
            end

        end
        if (EntityGetName(shooter_id) ~= nil and tonumber(EntityGetName(shooter_id))) then
            if (data.players[EntityGetName(shooter_id)]) then
                --print("whar")

                --GamePrint("Setting RNG: "..tostring(arenaPlayerData[EntityGetName(shooter_id)].next_rng))
                local projectileComponent = EntityGetFirstComponentIncludingDisabled(projectile_id,
                    "ProjectileComponent")

                local who_shot            = ComponentGetValue2(projectileComponent, "mWhoShot")
                local entity_that_shot    = ComponentGetValue2(projectileComponent, "mEntityThatShot")
                if (entity_that_shot == 0 and multicast_index ~= -1 and unknown3 == 0) then
                    local rng = 0
                    if (#(data.players[EntityGetName(shooter_id)].projectile_rng_stack) > 0) then
                        -- set rng to first in stack, remove
                        rng = table.remove(data.players[EntityGetName(shooter_id)].projectile_rng_stack, 1)
                    end
                    --GamePrint("Setting client spread rng: "..tostring(rng))

                    np.SetProjectileSpreadRNG(rng)

                    data.players[EntityGetName(shooter_id)].next_rng = rng + 1
                else
                    if (data.projectile_seeds[entity_that_shot]) then
                        local new_seed = data.projectile_seeds[entity_that_shot] + 25
                        np.SetProjectileSpreadRNG(new_seed)
                        data.projectile_seeds[entity_that_shot] = data.projectile_seeds[entity_that_shot] + 10
                    end
                end
            end
        end
        --end
        --[[
        if(data.state == "arena")then
            local playerEntity = player.Get()
            if(playerEntity ~= nil)then
                if(playerEntity == shooter_id)then
                    local projectileComponent = EntityGetFirstComponentIncludingDisabled(projectile_id, "ProjectileComponent")

                    local who_shot = ComponentGetValue2(projectileComponent, "mWhoShot")
                    local entity_that_shot  = ComponentGetValue2(projectileComponent, "mEntityThatShot")

                    if(entity_that_shot == 0)then
                        --math.randomseed( tonumber(tostring(steam.user.getSteamID())) + ((os.time() + GameGetFrameNum()) / 2))
                        local rand = data.random.range(0, 100000)
                        local rng = math.floor(rand)
                        --GamePrint("Setting RNG: "..tostring(rng))
                        np.SetProjectileSpreadRNG(rng)

                        data.client.projectile_seeds[projectile_id] = rng
                        --GamePrint("generated_rng: "..tostring(rng))

                        --local special_seed = tonumber(GlobalsGetValue("player_rng", "0"))

                        --local fire_count = GlobalsGetValue( "wand_fire_count", "0" )


                        --message_handler.send.WandFired(lobby, rng, nil, special_seed)

                    else
                        if(data.client.projectile_seeds[entity_that_shot])then
                            local new_seed = data.client.projectile_seeds[entity_that_shot] + 10
                            np.SetProjectileSpreadRNG(new_seed)
                            data.client.projectile_seeds[entity_that_shot] = data.client.projectile_seeds[entity_that_shot] + 1
                            data.client.projectile_seeds[projectile_id] = new_seed
                        end
                    end
                    return
                end
            end

            if(EntityGetName(shooter_id) ~= nil and tonumber(EntityGetName(shooter_id)))then
                if(data.players[EntityGetName(shooter_id)] and data.players[EntityGetName(shooter_id)].next_rng)then

                    data.players[EntityGetName(shooter_id)].next_fire_data = nil

                    --GamePrint("Setting RNG: "..tostring(arenaPlayerData[EntityGetName(shooter_id)].next_rng))
                    local projectileComponent = EntityGetFirstComponentIncludingDisabled(projectile_id, "ProjectileComponent")

                    local who_shot = ComponentGetValue2(projectileComponent, "mWhoShot")
                    local entity_that_shot  = ComponentGetValue2(projectileComponent, "mEntityThatShot")
                    if(entity_that_shot == 0)then
                        np.SetProjectileSpreadRNG(data.players[EntityGetName(shooter_id)].next_rng)
                        data.client.projectile_seeds[projectile_id] = data.players[EntityGetName(shooter_id)].next_rng
                    else
                        if(data.client.projectile_seeds[entity_that_shot])then
                            local new_seed = data.client.projectile_seeds[entity_that_shot] + 10
                            np.SetProjectileSpreadRNG(new_seed)
                            data.client.projectile_seeds[entity_that_shot] = data.client.projectile_seeds[entity_that_shot] + 1
                        end
                    end
                end
                return
            end
        end
        ]]
    end,
    OnProjectileFiredPost = function(lobby, data, shooter_id, projectile_id, rng, position_x, position_y, target_x,
                                     target_y, send_message, unknown1, multicast_index, unknown3)
        --[[local projectileComp = EntityGetFirstComponentIncludingDisabled(projectile_id, "ProjectileComponent")
        if(projectileComp ~= nil)then
            local who_shot = ComponentGetValue2(projectileComp, "mWhoShot")
            --GamePrint("who_shot: "..tostring(who_shot))
        end]]
        local homingComponents = EntityGetComponentIncludingDisabled(projectile_id, "HomingComponent")

        local shooter_x, shooter_y = EntityGetTransform(shooter_id)

        if(shooter_id == nil or shooter_x == nil)then
            return
        end

        if (homingComponents ~= nil) then
            for k, v in pairs(homingComponents) do
                local target_who_shot = ComponentGetValue2(v, "target_who_shot")
                if (target_who_shot == false) then
                    if (EntityHasTag(shooter_id, "client")) then
                        -- find closest player which isn't us
                        local closest_player = nil
                        local distance = 9999999
                        local clients = EntityGetWithTag("client") or {}
                        -- add local player to list
                        if (player.Get()) then
                            table.insert(clients, player.Get())
                        end


                        for k, v in pairs(clients) do
                            if (v ~= shooter_id) then
                                if (closest_player == nil) then
                                    closest_player = v
                                else
                                    local x, y = EntityGetTransform(v)
                                    local dist = math.abs(x - shooter_x) + math.abs(y - shooter_y)
                                    if (dist < distance) then
                                        distance = dist
                                        closest_player = v
                                    end
                                end
                            end
                        end

                        if (closest_player) then
                            ComponentSetValue2(v, "predefined_target", closest_player)
                            ComponentSetValue2(v, "target_tag", "mortal")
                        end
                    else
                        local closest_player = nil
                        local distance = 9999999
                        local clients = EntityGetWithTag("client") or {}

                        for k, v in pairs(clients) do
                            if (v ~= shooter_id) then
                                if (closest_player == nil) then
                                    closest_player = v
                                else
                                    local x, y = EntityGetTransform(v)
                                    local dist = math.abs(x - shooter_x) + math.abs(y - shooter_y)
                                    if (dist < distance) then
                                        distance = dist
                                        closest_player = v
                                    end
                                end
                            end
                        end

                        if (closest_player) then
                            ComponentSetValue2(v, "predefined_target", closest_player)
                            ComponentSetValue2(v, "target_tag", "mortal")
                        end
                    end
                end
            end
        end
    end,
}

return ArenaGameplay
