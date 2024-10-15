local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
local counter = dofile_once("mods/evaisa.arena/files/scripts/utilities/ready_counter.lua")
local countdown = dofile_once("mods/evaisa.arena/files/scripts/utilities/countdown.lua")
local EZWand = dofile("mods/evaisa.arena/files/scripts/utilities/EZWand.lua")
world_sync = dofile("mods/evaisa.arena/files/scripts/gamemode/world_sync.lua")
dofile("mods/evaisa.arena/files/scripts/gamemode/cosmetics/cosmetics.lua")
dofile("mods/evaisa.arena/files/scripts/gamemode/misc/hamis_utils.lua")

ArenaLoadCountdown = ArenaLoadCountdown or nil

ArenaGameplay = {
    SaveShiftData = function(lobby, from_materials, to_mat)
        if(steamutils.IsOwner())then
            local shifts = ArenaGameplay.GetShiftData(lobby)

            table.insert(shifts, {from_materials, to_mat})
            
            steamutils.TrySetLobbyData(lobby, "fungal_shifts", bitser.dumps(shifts))
        end
    end,
    GetShiftData = function()
        local shifts_data = steamutils.GetLobbyData("fungal_shifts") or ""
        local shifts = {}
        if(shifts_data == "")then
            shifts = {}
        else
            shifts = bitser.loads(shifts_data)
        end
        return shifts
    end,
    FungalShift = function(from_materials, to_mat, no_effects)
        local iter = tonumber( GlobalsGetValue( "fungal_shift_iteration", "0" ) )
        GlobalsSetValue( "fungal_shift_iteration", tostring(iter+1) )
        if iter > 20 then
            return
        end
        local frame = GameGetFrameNum()

        SetRandomSeed( 89346, 42345+iter )

        local converted_any = false
    
        local player_entity = player.Get()

        if(no_effects)then
            player_entity = nil
        end

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
            if(player_entity ~= nil)then
                EntityRemoveIngestionStatusEffect( player_entity, "TRIP" );
            end
        
            local x, y = GameGetCameraPos()

            -- audio
            if(no_effects)then
                GameTriggerMusicFadeOutAndDequeueAll( 5.0 )
                GameTriggerMusicEvent( "music/oneshot/tripping_balls_01", false, x, y )
            end
            -- particle fx
            if(player_entity ~= nil)then
                local eye = EntityLoad( "data/entities/particles/treble_eye.xml", x,y-10 )
                if eye ~= 0 then
                    EntityAddChild( player_entity, eye )
                end
            end
            -- log
            if no_effects then
                local log_msg = ""
                if from_material_name ~= "" then
                    log_msg = GameTextGet( "$logdesc_reality_mutation", from_material_name )
                    GamePrint( log_msg )
                end
                GamePrintImportant( random_from_array( log_messages ), log_msg, "data/ui_gfx/decorations/3piece_fungal_shift.png" )
            end
            GlobalsSetValue( "fungal_shift_last_frame", tostring(frame) )
    
            -- add ui icon
            local add_icon = true
            if(player_entity ~= nil)then
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
        end
    end,
    GetNumRounds = function(lobby)
        local holyMountainCount = tonumber(GlobalsGetValue("holyMountainCount", "0"))
        return holyMountainCount
    end,
    GetPlayerIndex = function(lobby)
        local player_ids = {}
        local members = steamutils.getLobbyMembers(lobby)
        for i, member in ipairs(members) do
            table.insert(player_ids, tostring(member.id))
        end
        table.sort(player_ids, function(a, b) return a < b end)
        local local_player = tostring(steam_utils.getSteamID())
        for i, player_id in ipairs(player_ids) do
            if(player_id == local_player)then
                return i
            end
        end
        return 1
    end,
    AddRound = function(lobby)
        if(steam_utils.IsOwner())then
            local rounds = ArenaGameplay.GetNumRounds(lobby)
            rounds = tonumber(rounds) or 0
            rounds = rounds + 1
            if(GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous")then
                networking.send.update_round(lobby, rounds)
            end
            GlobalsSetValue("holyMountainCount", tostring(rounds))
            steam_utils.TrySetLobbyData(lobby, "holyMountainCount", tostring(rounds))
        elseif(GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
            local rounds = ArenaGameplay.GetNumRounds(lobby)
            rounds = tonumber(rounds) or 0
            rounds = rounds + 1
            GlobalsSetValue("holyMountainCount", tostring(rounds))
        end
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
    GetRoundTier = function(lobby)
        local rounds = ArenaGameplay.GetNumRounds(lobby)
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
                    print("Checking wins ["..tostring(member.id).."] : " .. wins .. " - " .. value)
                    if(wins >= value)then
                        return member.id
                    end
                end
            end,
            ["best_of"] = function(value)
                local current_round = ArenaGameplay.GetNumRounds(lobby)
                print("Checking best of: " .. current_round .. " - " .. value)
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
        local ready_players = {}
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].ready) then
                    table.insert(ready_players, tostring(member.id))
                end
            end
        end
        steam_utils.TrySetLobbyData(lobby, "ready_players", bitser.dumps(ready_players))
    end,
    GetGameData = function(lobby, data)
        local mountainCount = tonumber(steamutils.GetLobbyData( "holyMountainCount"))
        if (mountainCount ~= nil) then
            GlobalsSetValue("holyMountainCount", tostring(mountainCount))
            arena_log:print("Holymountain count: " .. mountainCount)
        end
        local goldCount = tonumber(steamutils.GetLobbyData( "total_gold"))
        if (goldCount ~= nil) then
            data.client.first_spawn_gold = goldCount
            arena_log:print("Gold count: " .. goldCount)
        end
        local playerData = steamutils.GetLocalLobbyData(lobby, "player_data") --steam.matchmaking.getLobbyMemberData(lobby, steam_utils.getSteamID(), "player_data")
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
        local match_data_serialized = steamutils.GetLocalLobbyData(lobby, "match_data")
        if(match_data_serialized ~= nil)then
            local match_data = bitser.loads(match_data_serialized)

            if(match_data ~= nil)then

                data.client.reroll_count = tonumber(match_data.reroll_count)
                GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", tostring(data.client.reroll_count))
                print("Reroll count overwritten: "..tostring(data.client.reroll_count))

                local round = tonumber(match_data.round)

                -- make sure this is the same round
                if(round == ArenaGameplay.GetNumRounds(lobby))then
                    if(match_data.picked_health)then
                        GameAddFlagRun("picked_health")
                    end
                    if(match_data.picked_perk)then
                        GameAddFlagRun("picked_perk")
                    end
                    if(match_data.picked_card)then
                        GameAddFlagRun("card_picked")
                    end
                    if(match_data.cards and match_data.cards[1] ~= nil)then
                        data.client.cards = match_data.cards
                    else
                        data.client.cards = nil
                    end
                    local floor_items = match_data.floor_items or {}
                    local shop_platforms = match_data.shop_platforms or {}
                    
                    GlobalsSetValue("temple_second_row_spots", smallfolk.dumps(shop_platforms))

                    delay.new(function()
                        local valid = #(EntityGetWithTag("workshop") or {}) > 0
                        --print("Valid: "..tostring(valid))
                        return valid
                    end, function()

                        for i, v in ipairs(shop_platforms)do
                            local x = v[1]
                            local y = v[2]
                            
                            delay.new(function()
                                local valid = DoesWorldExistAt(x - 2, y - 2, x + 2, y + 2)
                                return valid
                            end, function()
                                print("Deserializing shop platform: "..i)
                                LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x, y, "", true )
                            end)
                        end

                        for k, v in pairs(floor_items)do
                            local item = v.data
                            local x = v.x
                            local y = v.y

                            if(item ~= nil)then
                                delay.new(function()
                                    local valid = DoesWorldExistAt(x - 2, y - 2, x + 2, y + 2)
                                    return valid
                                end, function()
                                    print("Deserializing item: "..k)
                                    local new_entity = EntityCreateNew()
                                    np.DeserializeEntity(new_entity, item)
                                end)
                            end
                        end
                    end)
                    GameAddFlagRun("DeserializedHolyMountain")
                end
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
        
        local ready_players_string = steamutils.GetLobbyData( "ready_players")
        local ready_players = (ready_players_string ~= nil and ready_players_string ~= "null") and
            bitser.loads(ready_players_string) or nil

        local members = steamutils.getLobbyMembers(lobby)

        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
                local user = member.id
                local wins = tonumber(steamutils.GetLobbyData( tostring(user) .. "_wins")) or 0
                local winstreak = tonumber(steamutils.GetLobbyData( tostring(user) .. "_winstreak")) or 0
                local kills = tonumber(steamutils.GetLobbyData( tostring(user) .. "_kills")) or 0
                local deaths = tonumber(steamutils.GetLobbyData( tostring(user) .. "_deaths")) or 0
                data.players[tostring(user)].wins = wins
                data.players[tostring(user)].winstreak = winstreak
            end
        end

        -- get our own wins and winstreak and kills and deaths
        local player_id = steam_utils.getSteamID()
        local wins = tonumber(steamutils.GetLobbyData( tostring(player_id) .. "_wins")) or 0
        local winstreak = tonumber(steamutils.GetLobbyData( tostring(player_id) .. "_winstreak")) or 0
        local kills = tonumber(steamutils.GetLobbyData( tostring(player_id) .. "_kills")) or 0
        local deaths = tonumber(steamutils.GetLobbyData( tostring(player_id) .. "_deaths")) or 0

        data.client.wins = wins
        data.client.winstreak = winstreak
        data.client.kills = kills
        data.client.deaths = deaths

        --print(tostring(ready_players_string))


        if (ready_players ~= nil) then
            for k, member in pairs(members) do
                if (member.id ~= steam_utils.getSteamID()) then
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

        -- reapply fungal shifts
        local shifts = ArenaGameplay.GetShiftData(lobby)
        for i, shift in ipairs(shifts) do
            ArenaGameplay.FungalShift(shift[1], shift[2])
        end
    end,
    GracefulReset = function(lobby, data)
        if(data.unstuck_ui)then
            GuiDestroy(data.unstuck_ui)
            data.unstuck_ui = nil
        end
        if (data.spectator_gui) then
            GuiDestroy(data.spectator_gui)
            data.spectator_gui = nil
            if(data.spectator_text_gui)then
                GuiDestroy(data.spectator_text_gui)
                data.spectator_text_gui = nil
            end

            --[[if (data.spectator_gui_entity and EntityGetIsAlive(data.spectator_gui_entity)) then
                EntityKill(data.spectator_gui_entity)
            end]]
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

        GameRemoveFlagRun("Immortal")
        GameRemoveFlagRun("no_shooting")
    end,
    ResetEverything = function(lobby, skip_owner_check)
        local player_entity = player.Get()

        scoreboard.open = false

        -- FUNGAL SHIFT RESET
        local world_state = GameGetWorldStateEntity()
        local world_comp = EntityGetFirstComponent(world_state, "WorldStateComponent")
        if world_comp then
            ComponentSetValue(world_comp, "changed_materials", "")
        end

        --[[ffi = require("ffi")
        arg = ffi.cast("int**", 0x012216cc)[0][6]
        remove_materials = ffi.cast("void(__fastcall*)(int)", 0x006fa100)
        remove_materials(arg)
        load_materials = ffi.cast("void(__thiscall*)(int, char)", 0x00706e30)
        load_materials(arg, 1)]]

        np.ReloadMaterials()
        -- END FUNGAL SHIFT RESET
                

        dofile_once("data/scripts/perks/perk_list.lua")
        apply_perk_fixes()
        for i, perk_data in ipairs(get_active_perk_list()) do
            local perk_id = perk_data.id
            local flag_name = get_perk_picked_flag_name(perk_id)

            local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

            if (pickup_count > 0) then
                if (perk_data.func_remove ~= nil) then
                    perk_data.func_remove(player_entity)
                end
            end
            GameRemoveFlagRun(flag_name)
            GlobalsSetValue(flag_name .. "_PICKUP_COUNT", "0")
        end

        if (player_entity ~= nil) then
            EntityKill(player_entity)
        end


        print("Resetting everything!!!")


        if (steam_utils.IsOwner() and not skip_owner_check) then
            steam_utils.DeleteLobbyData(lobby, "holyMountainCount")
            steam_utils.DeleteLobbyData(lobby, "total_gold")
            steam_utils.DeleteLobbyData(lobby, "ready_players")
            steam_utils.TrySetLobbyData(lobby, "custom_lobby_string", "( round 0 )")

            --[[
            -- loop through all players and remove their data
            local members = steamutils.getLobbyMembers(lobby)
            for k, member in pairs(members) do
                local winner_key = tostring(member.id) .. "_wins"
                steam_utils.DeleteLobbyData(lobby, winner_key)
                local winstreak_key = tostring(member.id) .. "_winstreak"
                steam_utils.DeleteLobbyData(lobby, winstreak_key)
            end
            ]]

            print("Resetting player data!!!")

            local ending_keys_to_kill = {
                "_wins",
                "_winstreak",
                "treak",
                "winner_keys",
                "winner_key",
                "_ready",
                "_loaded",
                "current_map",
                "_deaths",
                "_kills",
            }

            steamutils.CleanLobbyData(function(key, value)
                print("Checking key: " .. key)
                for i, ending in ipairs(ending_keys_to_kill) do
                    local length = #ending
                    if (key:sub(-length) == ending) then
                        return true
                    end
                end
                return false
            end)

            DestroyDataTable()


            --[[local winner_keys = steamutils.GetLobbyData( "winner_keys")
            if (winner_keys == nil) then
                winner_keys = {}
            else
                winner_keys = bitser.loads(winner_keys)
            end]]

            --[[for k, key in pairs(winner_keys) do
                steam_utils.DeleteLobbyData(lobby, key)
                steam_utils.DeleteLobbyData(lobby, key .. "treak")
            end]]

            --steam_utils.DeleteLobbyData(lobby, "winner_keys")

        end

        -- kill globals and run flags
        -- save keybinds!!!
        local keybinds_global = GlobalsGetValue("evaisa.mp.keybinds", "{}")
        local keybinds_order_global = GlobalsGetValue("evaisa.mp.keybinds_order", "{}")

        ComponentSetValue(EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent"), "lua_globals", "")
        ComponentSetValue(EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent"), "flags", "")

        
        GlobalsSetValue("evaisa.mp.keybinds", keybinds_global)
        GlobalsSetValue("evaisa.mp.keybinds_order", keybinds_order_global)

    end,
    ReadyAmount = function(data, lobby)
        if(data.state ~= "lobby")then
            return 0
        end
        
        local amount = data.client.ready and 1 or 0

        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil and data.players[tostring(member.id)].ready) then
                    amount = amount + 1
                end
            end
        end
        return amount
    end,
    ForceReady = function(lobby, data)
        data.client.ready = true

        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
                if (data.players[tostring(member.id)] ~= nil) then
                    data.players[tostring(member.id)].ready = true
                end
            end
        end

        GameAddFlagRun("lock_ready_state")
        networking.send.lock_ready_state(lobby)
    end,
    CheckFiringBlock = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
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
        local members = steamutils.getLobbyMembers(lobby, true)
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
        return steamutils.getPlayerCount(lobby, false)
    end,
    ReadyCounter = function(lobby, data)
        data.ready_counter = counter.create("$arena_players_ready", function()
            local playersReady = ArenaGameplay.ReadyAmount(data, lobby)
            local totalPlayers = ArenaGameplay.TotalPlayers(lobby)

            return playersReady, totalPlayers
        end)
    end,
    LoadPlayer = function(lobby, data, x, y)

        if(data.is_spectating)then
            return
        end

        data.is_polymorphed = false
        print("Loading player entity!!!")

        local player_xml = "data/entities/player.xml"

        if(GameHasFlagRun("super_secret_hamis_mode"))then
            player_xml = "mods/evaisa.arena/files/entities/hamis_player.xml"

            if(not HasFlagPersistent("super_secret_hamis_mode"))then
                AddFlagPersistent("super_secret_hamis_mode")
            
                GamePrint("Super Secret Hämis Mode Unlocked!")
                GamePrintImportant("SUPER SECRET HÄMIS MODE UNLOCKED!")
            end
           
            np.MagicNumbersSetValue("UI_QUICKBAR_OFFSET_Y", "-1000")
        else
            np.MagicNumbersSetValue("UI_QUICKBAR_OFFSET_Y", "0")
        end
        

        local current_player = EntityLoad(player_xml, x or 0, y or 0)

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


        if(current_player and EntityGetIsAlive(current_player))then
            local inventory_items = GameGetAllInventoryItems(current_player)

            local lowest_slot = 100
            local lowest_item = nil
            for i, v in ipairs(inventory_items or {})do
                local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                local ability_comp = EntityGetFirstComponentIncludingDisabled(v, "AbilityComponent")
                if(item_comp ~= nil and ability_comp ~= nil and ComponentGetValue2(ability_comp, "use_gun_script") == true)then
                    local slot = ComponentGetValue2(item_comp, "inventory_slot")
                    if(slot < lowest_slot)then
                        lowest_slot = slot
                        lowest_item = v
                    end
                end
            end
            if(lowest_item ~= nil)then
                game_funcs.SetActiveHeldEntity(current_player, lowest_item, false, false)
            end
        end


        -- Mark inventory as initialised, else the game will change the item
        -- after we've set it in the deserialization.
        local inventory = EntityGetFirstComponentIncludingDisabled(current_player, "Inventory2Component")
        ComponentSetValue2(inventory, "mInitialized", true)

        player.Deserialize(data.client.serialized_player, (not data.client.player_loaded_from_data), lobby, data)

        --gameplay_handler.UpdateCosmetics(lobby, data, "load", current_player, false)

        cosmetics_handler.LoadPlayerCosmetics(lobby, data, current_player)

        if(data.state == "lobby")then
            networking.send.did_spectate(lobby)
        end
        
        local shifts = gameplay_handler.GetShiftData(lobby)
        if(#shifts > 0)then
            print("Fungal shift data found!!!")

            local icon_entity = EntityCreateNew( "fungal_shift_ui_icon" )
            EntityAddComponent( icon_entity, "UIIconComponent", 
            { 
                name = "$status_reality_mutation",
                description = "$statusdesc_reality_mutation",
                icon_sprite_file = "data/ui_gfx/status_indicators/fungal_shift.png"
            })
            EntityAddChild( current_player, icon_entity )

        end

        GameRemoveFlagRun("player_unloaded")
    end,
    ResetPlayerData = function(lobby, data)
        for k, v in pairs(data.players) do
            v.polymorph_entity = nil
        end
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
                    --ComponentSetValue2(abilityComponent, "mReloadFramesLeft", 10)
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
                        --ComponentSetValue2(abilityComponent, "mReloadFramesLeft", 10)
                        -- set mReloadNextFrameUsable to false
                        ComponentSetValue2(abilityComponent, "mReloadNextFrameUsable", GameGetFrameNum() + 10)
                    end
                end
            end
        end
    end,
    IsInBounds = function(x, y, max_distance)
        local players = GetPlayers()
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
        local players = GetPlayers()
        for k, v in pairs(players) do
            local x2, y2 = EntityGetTransform(v)
            local distance = math.sqrt((x2 - x) ^ 2 + (y2 - y) ^ 2)
            if (distance > max_distance) then
                local healthComp = EntityGetFirstComponentIncludingDisabled(v, "DamageModelComponent")
                if (healthComp ~= nil) then
                    print("inflicted zone damage!")
                    local health = tonumber(ComponentGetValue(healthComp, "hp"))
                    local max_health = tonumber(ComponentGetValue(healthComp, "max_hp"))
                    local base_health = 4
                    local damage_percentage = (distance - max_distance) / distance_cap
                    local damage = (max_health * damage_percentage) + 0.04
                    EntityInflictDamage(v, damage, "DAMAGE_HEALING", "Out of bounds", "BLOOD_EXPLOSION", 0, 0, GameGetWorldStateEntity())
                end
            end
        end
    end,
    DamageFloorCheck = function(depth, max_depth)
        -- if player goes under depth, do proportional damage based on depth
        local players = GetPlayers()
        for k, v in pairs(players) do
            local x, y = EntityGetTransform(v)
            if(y >= depth)then
                local healthComp = EntityGetFirstComponentIncludingDisabled(v, "DamageModelComponent")
                if (healthComp ~= nil) then
                    print("inflicted zone damage!")
                    local health = tonumber(ComponentGetValue(healthComp, "hp"))
                    local max_health = tonumber(ComponentGetValue(healthComp, "max_hp"))
                    local base_health = 4
                    local damage_percentage = (y - depth) / max_depth
                    local damage = (max_health * damage_percentage)  + 0.04
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
            local zone_time = tonumber(GlobalsGetValue("zone_time", "120")) -- time in seconds it should take for the zone to reach minimum size
            local zone_steps = tonumber(GlobalsGetValue("zone_steps", "6"))                                                -- seconds between steps

            if(data.zone_size == nil)then
                data.zone_size = default_size or 600
            end

            GlobalsSetValue("arena_area_floor", tostring(zone_floor))

            if (zone_type ~= "disabled") then
                if (data.ready_for_zone and not data.zone_spawned) then
                    EntityLoad("mods/evaisa.arena/files/entities/area_indicator.xml", 0, 0)

                    print("Zone loaded successfully.")

                    data.zone_size = default_size
                    data.ready_for_zone = false
                    data.zone_spawned = true

                    GlobalsSetValue("arena_area_size", tostring(data.zone_size))
                    GlobalsSetValue("arena_area_size_cap", tostring(data.zone_size + 200))
                end


                if (data.zone_size ~= nil and can_shrink and steam_utils.IsOwner()) then
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

                        -- calculate the step size
                        -- it should take zone_time seconds to reach 0 from default_size
                        local step_size = default_size / (zone_time * 60)
                    

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
                        local step_time = ((zone_time / zone_steps) * 60) / 2 -- 120 seconds / 6 steps = 20 seconds per step = 1200 frames

                        if (GameGetFrameNum() - data.last_step_frame > step_time) then

                            -- we need to divide the zone time with the number of steps
                            -- note that we take pauses between every step, these pauses are equal duration to the step time
                  
                            local step_size = default_size / (step_time * zone_steps)

                            data.zone_size = data.zone_size - step_size
                            

                            if (data.zone_size < 0) then
                                data.zone_size = 0
                            end

                            if (GameGetFrameNum() - data.last_step_frame > step_time + step_time) then
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

            
                                zone_shrink_time = math.ceil((step_time - (GameGetFrameNum() - data.last_step_frame)) /
                                    60)

                                local text = string.format(GameTextGetTranslatedOrNot("$arena_zone_shrink_countdown"), tostring( zone_shrink_time))


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

                if ((not steam_utils.IsOwner()) and (not IsPaused()) and data.zone_size ~= nil) then
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

                            local text = string.format(GameTextGetTranslatedOrNot("$arena_zone_shrink_countdown"), tostring(data.shrink_time))

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

                GlobalsSetValue("arena_area_size", "0")

            end
        end
    end,
    GetWins = function(lobby, user, data)
        local wins = tonumber(steamutils.GetLobbyData( tostring(user) .. "_wins")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].wins = wins
            --print("Updated wins for " .. tostring(user) .. " to " .. tostring(wins))
        elseif(user == steam_utils.getSteamID())then
            data.client.wins = wins
            --print("Updated local wins to " .. tostring(wins))
        end
        return wins
    end,
    GetWinstreak = function(lobby, user, data)
        local winstreak = tonumber(steamutils.GetLobbyData( tostring(user) .. "_winstreak")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].winstreak = winstreak
            --print("Updated winstreak for " .. tostring(user) .. " to " .. tostring(winstreak))
        elseif(user == steam_utils.getSteamID())then
            data.client.winstreak = winstreak
            --print("Updated local winstreak to " .. tostring(winstreak))
        end
        return winstreak
    end,
    GetKills = function(lobby, user, data)
        local kills = tonumber(steamutils.GetLobbyData( tostring(user) .. "_kills")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].kills = kills
            --print("Updated kills for " .. tostring(user) .. " to " .. tostring(kills))
        elseif(user == steam_utils.getSteamID())then
            data.client.kills = kills
            --print("Updated local kills to " .. tostring(kills))
        end
        return kills
    end,
    GetDeaths = function(lobby, user, data)
        local deaths = tonumber(steamutils.GetLobbyData( tostring(user) .. "_deaths")) or 0
        if(data.players[tostring(user)] ~= nil)then 
            data.players[tostring(user)].deaths = deaths
            --print("Updated deaths for " .. tostring(user) .. " to " .. tostring(deaths))
        elseif(user == steam_utils.getSteamID())then
            data.client.deaths = deaths
            --print("Updated local deaths to " .. tostring(deaths))
        end
        return deaths
    end,
    WinnerCheck = function(lobby, data, manual)

        --[[if not manual then
            return
        end]]

        if(GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
            return
        end

        print("winner check?")
        if(GameHasFlagRun("round_finished"))then
            return
        end

        local alive = (not data.spectator_mode and data.client.alive) and 1 or 0
        local winner = data.spectator_mode and nil or steam_utils.getSteamID() 
        for k, v in pairs(data.players) do
            if (v.alive) then
                alive = alive + 1
                winner = v.id
            end
        end

        print("Alive: " .. tostring(alive) .. ", winner: " .. tostring(winner))

        if (alive == 1) then
            ArenaGameplay.AddRound(lobby)

            local winner_key = tostring(winner) .. "_wins"
            local winstreak_key = tostring(winner) .. "_winstreak"

            local winner_keys = steamutils.GetLobbyData( "winner_keys")
            
            if (winner_keys == nil) then
                winner_keys = {}
            else
                winner_keys = bitser.loads(winner_keys)
            end


            for k, v in pairs(winner_keys) do
                if (tostring(v) ~= tostring(winner_key)) then
                    --print(v .. "treak")
                    steam_utils.TrySetLobbyData(lobby, v .. "treak", "0")
                end
            end


            if (not table.contains(winner_keys, winner_key)) then
                table.insert(winner_keys, winner_key)
                steam_utils.TrySetLobbyData(lobby, "winner_keys", bitser.dumps(winner_keys))
            end


            for k, v in pairs(data.players) do
                local id = v.id
                if (tostring(id) ~= tostring(winner)) then
                    steam_utils.TrySetLobbyData(lobby, tostring(id) .. "_winstreak", "0")
                end
            end

            local current_wins = tonumber(tonumber(steamutils.GetLobbyData( winner_key)) or "0")
            local current_winstreak = tonumber(tonumber(steamutils.GetLobbyData( winstreak_key)) or "0")

            print("incrementing win count for "..tostring(winner).." to "..tostring(current_wins + 1))
            steam_utils.TrySetLobbyData(lobby, winner_key, tostring(current_wins + 1))
            steam_utils.TrySetLobbyData(lobby, winstreak_key, tostring(current_winstreak + 1))

            if(winner ~= steam_utils.getSteamID())then
                data.players[tostring(winner)].winstreak = current_winstreak + 1
                data.players[tostring(winner)].wins = current_wins + 1
            else
                -- grant coin
                local currency = ModSettingGet("arena_cosmetics_currency") or 0
                currency = currency + 100
                ModSettingSet("arena_cosmetics_currency", currency)
                
                data.client.winstreak = current_winstreak + 1
                data.client.wins = current_wins + 1

                        
                local player_entity = player.Get()
                if(player_entity)then
                    cosmetics_handler.OnWin(lobby, data, player_entity, data.client.wins, data.client.winstreak)
                end
            end


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
            local win_condition_user = ArenaGameplay.CheckWinCondition(lobby, data)

            if(win_condition_user ~= nil)then
                GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_win_condition_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_win_condition_description"))
                networking.send.round_end(lobby, winner, true)
                print("Sent win condition message")
            else
                GamePrintImportant(string.format(GameTextGetTranslatedOrNot("$arena_winner_text"), steamutils.getTranslatedPersonaName(winner)), GameTextGetTranslatedOrNot("$arena_round_end_text"))
                networking.send.round_end(lobby, winner)
                print("Sent round end message")
            end

            print("Win condition: "..tostring(win_condition_user))

            if(win_condition_user == nil or not GameHasFlagRun("win_condition_end_match"))then
                local new_seed = tonumber(GlobalsGetValue("original_seed", "1"))

                networking.send.update_world_seed(lobby, new_seed)
                SetWorldSeed(new_seed)

                print("Loading lobby in 5 seconds")

                delay.new(300, function()
                    ArenaGameplay.LoadLobby(lobby, data, false)
                    
                end, function(frames)
                    if (frames % 60 == 0) then
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                    end
                end)
            else
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
            
        elseif (alive == 0) then
            ArenaGameplay.AddRound(lobby)

            GameAddFlagRun("round_finished")

            networking.send.round_end(lobby, nil)
            GamePrintImportant(GameTextGetTranslatedOrNot("$arena_tie_text"), GameTextGetTranslatedOrNot("$arena_round_end_text"))
            local new_seed = tonumber(GlobalsGetValue("original_seed", "1"))

            networking.send.update_world_seed(lobby, new_seed)
            SetWorldSeed(new_seed)

            print("Loading lobby in 5 seconds")
            
            delay.new(300, function()
                ArenaGameplay.LoadLobby(lobby, data, false)
            end, function(frames)
                if (frames % 60 == 0) then
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                end
            end)

        end
    end,
    KillCheck = function(lobby, data)
        if (GameHasFlagRun("player_died") and not GameHasFlagRun("killcheck_finished")) then
           
            local killer = GlobalsGetValue("killer", "");

            if(GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
                ArenaGameplay.AddRound(lobby)
                delay.new(300, function()
                    ArenaGameplay.LoadLobby(lobby, data, false)
                end, function(frames)
                    if (frames % 60 == 0) then
                        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_returning_to_lobby_text"), tostring(math.floor(frames / 60))))
                    end
                end)
            end

            if(killer == "")then
                killer = nil
            end

            local username = steamutils.getTranslatedPersonaName(steam_utils.getSteamID())

            if (killer == nil) then
                GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_other_player_died"), tostring(username)))
            else
                local killer_id = ArenaGameplay.FindUser(lobby, killer)
                if (killer_id ~= nil) then
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_kill"), tostring(username), steamutils.getTranslatedPersonaName(killer_id))--[[tostring(username) .. " was killed by " .. steamutils.getTranslatedPersonaName(killer_id)]])
                
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
            if(GameHasFlagRun("upgrades_system"))then
                local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")

                -- check if we were the last to die
                local alive = (not data.spectator_mode and data.client.alive) and 1 or 0
                for k, v in pairs(data.players) do
                    if (v.alive) then
                        alive = alive + 1
                    end
                end

                local last = alive == 1

                if((catchup_mechanic_upgrades == "losers" and not last) or (data.deaths == 0 and catchup_mechanic_upgrades == "first_death"))then
                    GameAddFlagRun("pick_upgrade")
                end
            end

            data.deaths = data.deaths + 1
            data.client.alive = false

            --message_handler.send.Death(lobby, killer)
            networking.send.death(lobby, killer)

            GamePrintImportant(GameTextGetTranslatedOrNot("$arena_player_died"))

            GameSetCameraFree(true)

            GameAddFlagRun("killcheck_finished")

            if(not data.spectator_mode)then
                data.is_spectating = true
            end
            --player.Lock()
            --player.Immortal(true)
            --player.Move(-3000, -3000)

            if(steam_utils.IsOwner())then
                local user = steam_utils.getSteamID()
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
        local player_entity = player.Get()
        if ((not GameHasFlagRun("player_unloaded")) and player_entity and not EntityHasTag( player_entity, "polymorphed_player") ) then
            --[[local profile = profiler.new()
            profile:start()]]
            local serialized_player_data, compare_string = player.Serialize(nil, data)


            if (force or compare_string ~= data.client.player_data_old) then
                steamutils.SetLocalLobbyData(lobby, "player_data", serialized_player_data)

                --print("Backing up Player Data: \n"..serialized_player_data)

                data.client.serialized_player = serialized_player_data
                data.client.player_data_old = compare_string
            end

            --[[profile:stop()

            print("Profiler result: "..tostring(profile:time()) .. "ms")]]

            local upgrades_system = data.upgrade_system
            local cards = {}
            if(upgrades_system ~= nil)then
                for k, v in pairs(upgrades_system.upgrades)do
                    table.insert(cards, v.id)
                end
            end


            local match_data = data.client.match_data_unpacked or {
                shop_platforms = {},
                floor_items = {},
            }

            match_data.round = ArenaGameplay.GetNumRounds(lobby)
            match_data.reroll_count = GlobalsGetValue("TEMPLE_PERK_REROLL_COUNT", "0")
            match_data.picked_health = GameHasFlagRun("picked_health")
            match_data.picked_perk = GameHasFlagRun("picked_perk")
            match_data.picked_card = GameHasFlagRun("card_picked")
            match_data.cards = cards

            
            if(data.state == "lobby")then

                match_data.shop_platforms = smallfolk.loads(GlobalsGetValue("temple_second_row_spots", "{}"))

                local entities = EntityGetInRadius(0, 0, 10000000)
                for i, v in pairs(entities) do
                    if(EntityGetRootEntity(v) == v)then
                        -- find wands

                        local item_comp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
                        if(item_comp ~= nil)then
                            --print("Saved item: "..tostring(v))
                            local x, y = EntityGetTransform(v)
                            local item_data = {
                                x = x,
                                y = y,
                                data = np.SerializeEntity(v)
                            }
                            match_data.floor_items[v] = item_data
                            --print("Saved item: "..tostring(v))
                        end
                    else
                        if(match_data.floor_items[v] ~= nil)then
                            match_data.floor_items[v] = nil
                            --rint("Removed item: "..tostring(v))
                        end
                    end
                end
            end
            

            local serialized = bitser.dumps(match_data)

            if(data.client.match_data ~= serialized)then
                steamutils.SetLocalLobbyData(lobby, "match_data", serialized)
                data.client.match_data_unpacked = match_data
                data.client.match_data = serialized
            end
        end
    end,
    GetRoundGold = function(lobby, data)
        local rounds_limited = ArenaGameplay.GetRoundTier(lobby) --math.max(0, math.min(math.ceil(rounds / 2), 7))

        local extra_gold_count = tonumber( GlobalsGetValue( "EXTRA_MONEY_COUNT", "0" ) )

        extra_gold_count = extra_gold_count + 1

        local scaling_type = GlobalsGetValue("gold_scaling_type", "none")

        print("scaling type: "..scaling_type)

        local extra_gold = 400 + (extra_gold_count * (70 * (rounds_limited * rounds_limited)))

        if(scaling_type == "none")then
            extra_gold = 400
        elseif(scaling_type == "exponential")then
            rounds_limited = (0.5 * rounds_limited) + ( 0.5 * rounds_limited * rounds_limited )
            extra_gold = 400 + ( 50 + rounds_limited * 210 )
        end

        return extra_gold
    end,
    LoadLobby = function(lobby, data, show_message, first_entry)
        ArenaGameplay.ResetPlayerData(lobby, data)
        data.is_polymorphed = false
        data.picked_up_items = {}

        data.time_remaining = nil

        if(GameHasFlagRun("shop_sync"))then
            GameAddFlagRun("sync_item_generation")
        else
            GameRemoveFlagRun("sync_item_generation")
        end

        GameRemoveFlagRun("wardrobe_locked")
        GameRemoveFlagRun("wardrobe_locked_2")
        if(data.client.match_data_unpacked)then
            data.client.match_data_unpacked.floor_items = {}
        end

        GameRemoveFlagRun("player_died")
        GameRemoveFlagRun("killcheck_finished")

        data.projectiles_hit = {}
        
        local respawn_count = tonumber( GlobalsGetValue( "RESPAWN_COUNT", "0" ) )
        local extra_respawn_count = tonumber(GlobalsGetValue("EXTRA_RESPAWN_COUNT", "0"))

        if(respawn_count < extra_respawn_count)then
            respawn_count = respawn_count + extra_respawn_count
            GlobalsSetValue("RESPAWN_COUNT", tostring(respawn_count))
            GlobalsSetValue("EXTRA_RESPAWN_COUNT", "0")
        end

        networking.send.update_state(lobby, "lobby")
        data.network_entity_cache = {}
        if(data.unstuck_ui)then
            GuiDestroy(data.unstuck_ui)
            data.unstuck_ui = nil
        end
        if(data.low_framerate_popup ~= nil)then
            data.low_framerate_popup:destroy()
            np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
            np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
            np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
            np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
            np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
            np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)
        end
        if(data.hm_timer ~= nil)then
            data.hm_timer.clear()
            data.hm_timer = nil
        end
        local has_picked_heart = steamutils.HasLobbyFlag(lobby, tostring(steam_utils.getSteamID()).."picked_heart")

        if(has_picked_heart)then
            GameAddFlagRun("picked_health")
        else
            GameRemoveFlagRun("picked_health")
        end

        if(Parallax)then
            Parallax.push(nil, 30)
        end
        if(data.current_arena ~= nil and data.current_arena.unload)then
            data.current_arena:unload(lobby, data)
        end

        GameSetCameraPos(0, 0)
        GameSetCameraFree(false)

        GameAddFlagRun("refresh_dummy")

        -- get rounds
        local rounds = ArenaGameplay.GetNumRounds(lobby)

        if(not data.spectator_mode)then
            local catchup_mechanic = GlobalsGetValue("perk_catchup", "losers")
            if(catchup_mechanic == "everyone")then
                GameAddFlagRun("first_death")
            end
            if(GameHasFlagRun("upgrades_system"))then
                local catchup_mechanic_upgrades = GlobalsGetValue("upgrades_catchup", "losers")

                print("Card catchup: "..tostring(catchup_mechanic_upgrades))

                if(catchup_mechanic_upgrades == "everyone")then
                    print("Okay player should pick card!")
                    GameAddFlagRun("pick_upgrade")
                end
            end
        else
            print("Loading lobby as spectator")
        end

        ArenaGameplay.GracefulReset(lobby, data)

        data.allow_round_end = false
        data.controlled_entities = {}
        GameRemoveFlagRun("lock_ready_state")
        GameRemoveFlagRun("can_save_player")
        GameRemoveFlagRun("countdown_completed")
        GameRemoveFlagRun("round_finished")
        GameRemoveFlagRun("was_last_ready")
        GameRemoveFlagRun("Immortal")
        GameRemoveFlagRun("no_shooting")
        GlobalsSetValue("smash_knockback", "1" )
        GlobalsSetValue("smash_knockback_dummy", "1")
        data.last_selected_perk_string = nil
        show_message = show_message or false
        first_entry = first_entry or false

        --np.ComponentUpdatesSetEnabled("CellEaterSystem", false)
        --np.ComponentUpdatesSetEnabled("LooseGroundSystem", false)
        --np.ComponentUpdatesSetEnabled("BlackHoleSystem", false)
        --np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", false)

        --[[local members = steamutils.getLobbyMembers(lobby)
        for k, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID()) then
                local user = member.id
                local wins = tonumber(steamutils.GetLobbyData( tostring(user) .. "_wins")) or 0
                local winstreak = tonumber(steamutils.GetLobbyData( tostring(user) .. "_winstreak")) or 0
                local kills = tonumber(steamutils.GetLobbyData( tostring(user) .. "_kills")) or 0
                local deaths = tonumber(steamutils.GetLobbyData( tostring(user) .. "_deaths")) or 0
                if(data.players[tostring(user)])then
                    data.players[tostring(user)].wins = wins
                    data.players[tostring(user)].winstreak = winstreak
                    data.players[tostring(user)].kills = kills
                    data.players[tostring(user)].deaths = deaths
                end
            end
        end]]

        
        if(not data.spectator_mode)then
            if (not first_entry) then
                ArenaGameplay.SavePlayerData(lobby, data, true)
                ArenaGameplay.ClearWorld()
            end

            if (data.client.serialized_player) then
                first_entry = false
            end

            player.Immortal(true)

            RunWhenPlayerExists(function()
                local player_entity = player.Get()
                -- update local wins
                if (first_entry and player_entity) then
                    GameDestroyInventoryItems(player_entity)
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
        if(not data.spectator_mode)then
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

        if(not data.spectator_mode)then
            player.Immortal(true)

            RunWhenPlayerExists(function()
                -- clean and unlock player entity
                player.Clean(first_entry)
                player.Unlock(data)

                GameRemoveFlagRun("player_is_unlocked")

                -- move player to correct position
                player.Move(0, 0)
            end)



            if (not data.client.player_loaded_from_data) then
                GameRemoveFlagRun("card_picked")
                GameRemoveFlagRun("picked_health")
                GameRemoveFlagRun("picked_perk")
                data.client.cards = nil
            end


            if GameHasFlagRun("upgrades_system") and not GameHasFlagRun("card_picked") then
                RunWhenPlayerExists(function()
                    if(GameHasFlagRun("pick_upgrade") or data.client.cards)then
                        data.upgrade_system = upgrade_system.create(data.client.cards or 3, function(upgrade)
                            data.upgrade_system = nil
                        end)

                        networking.send.card_list(lobby, data)
                    end
                end)
            end
        end


        -- Give gold
        local extra_gold = gameplay_handler.GetRoundGold(lobby, data)

        --print("First spawn gold = "..tostring(data.client.first_spawn_gold))

        if(not data.spectator_mode)then
            arena_log:print("First entry = " .. tostring(first_entry))

            if (first_entry and data.client.first_spawn_gold > 0) then
                extra_gold = data.client.first_spawn_gold
            end
        end

        --GamePrint("You were granted " ..tostring(extra_gold) .. " gold for this round. (Rounds: " .. tostring(rounds) .. ")")


        if(not data.spectator_mode)then
            arena_log:print("Loaded from data: " .. tostring(data.client.player_loaded_from_data))

            RunWhenPlayerExists(function()
                if (not data.client.player_loaded_from_data and not GameHasFlagRun("DeserializedHolyMountain")) then
                    arena_log:print("Giving gold: " .. tostring(extra_gold))
                    player.GiveGold(extra_gold)
                    GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_round_gold"), tostring(extra_gold), tostring(rounds)))
                end
            end)


            RunWhenPlayerExists(function()
                -- if we are the owner of the lobby
                if (steam_utils.IsOwner()) then
                    -- get the gold count from the lobby
                    local gold = tonumber(steamutils.GetLobbyData( "total_gold")) or 0
                    -- add the new gold
                    gold = gold + extra_gold
                    -- set the new gold count
                    steam_utils.TrySetLobbyData(lobby, "total_gold", tostring(gold))
                end
            end)
        else
            if (steam_utils.IsOwner()) then
                -- get the gold count from the lobby
                local gold = tonumber(steamutils.GetLobbyData( "total_gold")) or 0
                -- add the new gold
                gold = gold + extra_gold
                -- set the new gold count
                steam_utils.TrySetLobbyData(lobby, "total_gold", tostring(gold))
            end
        end


        if(not data.spectator_mode)then
            RunWhenPlayerExists(function()
                local player_entity = player.Get()
                
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

                
                --[[local beamstone_count = tonumber( GlobalsGetValue( "MEGA_BEAM_STONE_COUNT", "0" ) )
                for i = 0, beamstone_count do
                    local x,y = EntityGetTransform( player_entity )
                    EntityLoad( "mods/evaisa.arena/files/entities/perks/beamstone.xml", x, y-10 )
                    EntityLoad( "data/entities/particles/poof_white_appear.xml", x, y-10 )
                end
                GlobalsSetValue( "MEGA_BEAM_STONE_COUNT", "0" )]]
                
                -- give starting gear if first entry
                dofile("mods/evaisa.arena/files/scripts/misc/heart_fullhp.lua")
                if (first_entry) then
                    player.GiveStartingGear()
                    local rounds = (ArenaGameplay.GetNumRounds(lobby) - 1)
                    print("Rounds: "..tostring(rounds))

                    if(rounds > 0)then
                        for i = 0, rounds do
                            give_health(player_entity)
                        end
                    end
                end

                GameAddFlagRun("can_save_player")

                networking.send.request_perk_update(lobby)

                GameAddFlagRun("should_save_player")
             
          
                if(not GameHasFlagRun("DeserializedHolyMountain") and GameHasFlagRun("instant_health"))then
                    print("Rounds: "..tostring(rounds))
                    give_health(player_entity)
                    GameAddFlagRun("picked_health")
                end

                
                local effect, effect_entity = GetGameEffectLoadTo(player_entity, "EDIT_WANDS_EVERYWHERE", false)
                if(effect ~= nil and effect_entity ~= nil)then
                    EntitySetName(effect_entity, "wand_edit")
                    ComponentSetValue2(effect, "frames", -1)
                end
            end)

        else

            -- kill player unit
            local player_entity = player.Get()

            if(player_entity ~= nil)then
                EntityKill(player_entity)
            end

            data.spectator_entity = EntityLoad("mods/evaisa.arena/files/entities/spectator_entity.xml", 0, 0)
            np.RegisterPlayerEntityId(data.spectator_entity)
        end
        --message_handler.send.Unready(lobby, true)
        if(not data.spectator_mode)then
            -- load map
            if(GameHasFlagRun("item_shop"))then
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby.lua",
                "mods/evaisa.arena/files/biome/pixelscenes/temple_itemshop.xml")
            else
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby.lua",
                "mods/evaisa.arena/files/biome/pixelscenes/temple.xml")
                 
            end


            -- show message
            
            if (show_message) then
                GamePrintImportant("$arena_holymountain_enter", "$arena_holymountain_enter_sub")
            end
        else
            -- load map
            if(GameHasFlagRun("item_shop"))then
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby_spectator.lua",
                "mods/evaisa.arena/files/biome/pixelscenes/temple_itemshop.xml")
            else
                BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_lobby_spectator.lua",
                "mods/evaisa.arena/files/biome/pixelscenes/temple.xml")
                
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
    round_to_decimal = function(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end,
    LoadArena = function(lobby, data, show_message, map)
        ArenaGameplay.ResetPlayerData(lobby, data)
        data.is_polymorphed = false
        data.picked_up_items = {}


        GameAddFlagRun("sync_item_generation")

        GameRemoveFlagRun("card_picked")
        data.client.cards = nil
        ArenaGameplay.GracefulReset(lobby, data)

        data.network_entity_cache = {}
        data.last_selected_perk_string = nil
        networking.send.update_state(lobby, "arena")
        

        if(data.unstuck_ui)then
            GuiDestroy(data.unstuck_ui)
            data.unstuck_ui = nil
        end
        if(data.low_framerate_popup ~= nil)then
            data.low_framerate_popup:destroy()
            np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
            np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
            np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
            np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
            np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
            np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)
        end
        if(data.hm_timer ~= nil)then
            data.hm_timer.clear()
            data.hm_timer = nil
        end
        if(not steam_utils.IsOwner())then
            networking.send.picked_heart(lobby, false)
        else
            steamutils.RemoveLobbyFlag(lobby, tostring(steam_utils.getSteamID()).."picked_heart")
        end
        if(not data.spectator_mode)then
            ArenaGameplay.SavePlayerData(lobby, data, true)

            GameRemoveFlagRun("can_save_player")
        end



        
        GameRemoveFlagRun("DeserializedHolyMountain")
        GameRemoveFlagRun("player_is_unlocked")
        GameRemoveFlagRun("wardrobe_open")
        GameRemoveFlagRun("chat_bind_disabled")
        GameRemoveFlagRun("pick_upgrade")

        show_message = show_message or false

        


        ArenaGameplay.ClearWorld()

        if(playermenu ~= nil)then
            playermenu:Close()
        end
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
        data.controlled_entities = {}
        data.client.player_loaded_from_data = false

        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID() and data.players[tostring(member.id)] ~= nil) then
                data.players[tostring(member.id)].alive = true
            end
        end

        --message_handler.send.SendPerks(lobby)
        if(not data.spectator_mode)then
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
            print("Loading map: "..tostring(map))
            for k, v in ipairs(available_map_list)do
                if(v.id == map)then
                    arena = v
                    break
                end
            end
        else
            local map_picker = GlobalsGetValue("map_picker", "random")

            if(map_picker == "random")then
                SetRandomSeed(ArenaGameplay.GetNumRounds(lobby), (tonumber(GlobalsGetValue("world_seed", "0")) or 1) + GameGetFrameNum())
                arena = available_map_list[Random(1, #available_map_list)]
            elseif(map_picker == "ordered" or map_picker == "ordered_random")then

                if(map_picker == "ordered_random")then
                    local seed = tonumber(GlobalsGetValue("original_seed", "1")) or 1
                    -- random shuffle map list
                    math.randomseed(seed)
                    for i = #available_map_list, 2, -1 do
                        local j = math.random(1, i)
                        available_map_list[i], available_map_list[j] = available_map_list[j], available_map_list[i]
                    end
                end

                local last_arena = data.current_arena and data.current_arena.id or nil
                print("Last arena: "..tostring(last_arena) )
                if(last_arena == nil)then
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
                print("new arena: "..tostring(arena.id))
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

        if(steam_utils.IsOwner())then
            print("Setting current map to "..tostring(arena.id))
            steam_utils.TrySetLobbyData(lobby, "current_map", arena.id)
        else
            networking.send.set_map(lobby, arena.id)
        end


        GamePrint(string.format(GameTextGetTranslatedOrNot("$arena_map_loaded"), GameTextGetTranslatedOrNot(tostring(arena.name))))

        if(arena.pixel_scenes ~= nil)then
            BiomeMapLoad_KeepPlayer(arena.biome_map, arena.pixel_scenes)
        else
            BiomeMapLoad_KeepPlayer(arena.biome_map, "data/biome/_pixel_scenes.xml")
        end
        if(data.current_arena.load)then
            data.current_arena:load(lobby, data)
        end

        
        if(not data.spectator_mode)then
            RunWhenPlayerExists(function()
                player.Lock()

                -- move player to correct position

                ArenaGameplay.LoadClientPlayers(lobby, data)

                --GamePrint("Loading arena")

                GameAddFlagRun("can_save_player")
                
                if(GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
                    GameAddFlagRun("player_is_unlocked") 
                    GameRemoveFlagRun("no_shooting")    

                    player.Unlock(data)

                    --[[local player_entity = player.Get()
                    gameplay_handler.UpdateCosmetics(lobby, data, "arena_unlocked", player_entity, false)
        
                    for k, v in pairs(data.players) do
                        if(v.entity ~= nil)then
                            gameplay_handler.UpdateCosmetics(lobby, data, "arena_unlocked", v.entity, true)
                        end
                    end]]

                    delay.new(5, function()
                        cosmetics_handler.ArenaUnlocked(lobby, data)
                    end)
                    
        
                    GameAddFlagRun("countdown_completed")
                    if(not data.spectator_mode)then
                        player.Immortal(false)
                    end
                    ArenaGameplay.AllowFiring(data)
                
                    networking.send.request_item_update(lobby)
                end
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

        
        if(ready and GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
            -- we go directly into arena!!
            local current_map = steamutils.GetLobbyData("current_map")

            print("Current map: "..tostring(current_map))

            if(not ArenaGameplay.IsArenaLoaded(lobby, data))then
                current_map = nil
                if(steam_utils.IsOwner())then
                    steam_utils.DeleteLobbyData(lobby, "current_map")
                end
            end

            if(current_map == nil)then
                local map_picker = GlobalsGetValue("map_picker", "random")

                if(map_picker == "vote")then
                    map_picker = "random"
                end

                if(steam_utils.IsOwner())then
                    local new_seed = ((tonumber(GlobalsGetValue("original_seed", "1")) + (GameGetFrameNum() * 12)) % 4294967294)

                    networking.send.update_world_seed(lobby, new_seed)
                    SetWorldSeed(new_seed)
    
                end

                ArenaGameplay.LoadArena(lobby, data, true)
            else

                ArenaGameplay.LoadArena(lobby, data, true, current_map)
            end
            
            return
        end

        --print("SetReady called: "..tostring(ready))

        if (ready) then
            GamePrint(GameTextGetTranslatedOrNot("$arena_self_ready"))
        else
            GamePrint(GameTextGetTranslatedOrNot("$arena_self_unready"))
            GameRemoveFlagRun("ready_check")
        end

        local ready_count = ArenaGameplay.ReadyAmount(data, lobby)
        local total_count = ArenaGameplay.TotalPlayers(lobby)

        networking.send.ready(lobby, ready, silent or false)
        data.client.ready = ready

        if(total_count > 1 and ready_count == (total_count - 1) and data.client.ready)then
            GameAddFlagRun("was_last_ready")
        end

        if (steam_utils.IsOwner()) then
            steam_utils.TrySetLobbyData(lobby, tostring(steam_utils.getSteamID()) .. "_ready", tostring(ready))
        end
    end,
    CleanMembers = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do
            if (member.id ~= steam_utils.getSteamID() and data.players[tostring(member.id)] ~= nil) then
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
        if (steam_utils.IsOwner()) then
            --print("we are owner!")
            -- check if all players are ready


            if (ArenaGameplay.ReadyCheck(lobby, data)) then

                if(ArenaLoadCountdown == nil)then

                    local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
                    local new_seed = ((tonumber(GlobalsGetValue("original_seed", "1")) + ((rounds + 1) * 1225)) % 4294967294)


                    print("New world seed: "..tostring(new_seed))

                    networking.send.update_world_seed(lobby, new_seed)
                    SetWorldSeed(new_seed)
        

                    print("all players ready!")
                    GameAddFlagRun("lock_ready_state")
                    networking.send.lock_ready_state(lobby)
                    -- kill any entity with workshop tag to prevent wand edits
                    if(not data.spectator_mode)then
                        --[[local all_entities = EntityGetWithTag("workshop")
                        for k, v in pairs(all_entities) do
                            EntityKill(v)
                        end]]

                        local player_entity = player.Get()

                        if(player_entity)then
                            local effect = EntityGetNamedChild(player_entity, "wand_edit")
                            if(effect ~= nil and effect ~= 0)then
                                EntityKill(effect)
                            end
                        end
                    end

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
            if(steam_utils.IsOwner())then
                -- find highest vote, if there is a tie, pick random
                
                ArenaGameplay.LoadArena(lobby, data, true, data.vote_loop.winner)
                networking.send.enter_arena(lobby, data.vote_loop.winner)
            end
            GuiDestroy(vote_gui)
        end, function(frames)
            --print("Current game frame: "..tostring(GameGetFrameNum()))
            if(steam_utils.IsOwner())then
                --print("Sending map vote timer update")
                networking.send.map_vote_timer_update(lobby, frames)
            end

            -- tick
            local frames_left = frames - finish_time

            if(data.vote_loop.vote_finished and frames_left > 0)then
                frames = finish_time
                frames_left = 0
            end

            if(frames_left < 0)then
                frames_left = 0
            end
            --GamePrint("Voting ends in "..tostring(math.floor(frames / 60)).." seconds")

            if(steam_utils.IsOwner())then
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

                        if(not was_tie)then
                            data.vote_loop.frames = 30
                        end
                        
                        data.vote_loop.winner = highest_vote_id
                        data.vote_loop.was_tie = was_tie
                        networking.send.map_vote_finish(lobby, highest_vote_id, was_tie)
                    end
                    data.vote_loop.vote_finished = true
                else
                    local total_votes = 0
                    for k, v in pairs(data.map_vote)do
                        total_votes = total_votes + v
                    end
                    -- check if everyone voted
                    local total_players = ArenaGameplay.TotalPlayers(lobby)
                    if(total_votes >= total_players)then

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

                            if(not was_tie)then
                                data.vote_loop.frames = 30
                            else
                                data.vote_loop.frames = finish_time
                            end
                            
                            data.vote_loop.winner = highest_vote_id
                            data.vote_loop.was_tie = was_tie
                            networking.send.map_vote_finish(lobby, highest_vote_id, was_tie)
                        end
                        data.vote_loop.vote_finished = true
                    end
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
                if(data.vote_loop.vote_finished)then
                    map_header = GameTextGetTranslatedOrNot("$arena_map_vote_completed")
                end
                local map_header_width, map_header_height = GuiGetTextDimensions(vote_gui, map_header, 1)
                GuiZSetForNextWidget(vote_gui, -11)
                GuiText(vote_gui, (screen_w / 2) - (map_header_width / 2), (screen_h / 2) - (max_height / 2) - 30, map_header)

                local timer_text = string.format(GameTextGetTranslatedOrNot("$arena_map_vote_timer"), tostring(math.floor(frames_left / 60)))
                local timer_text_width, timer_text_height = GuiGetTextDimensions(vote_gui, timer_text, 1)
                if(not data.vote_loop.vote_finished)then
                    GuiZSetForNextWidget(vote_gui, -11)
                    GuiColorSetForNextWidget(vote_gui, 0.6, 0.6, 0.6, 1)
                    
                    GuiText(vote_gui, (screen_w / 2) - (timer_text_width / 2), (screen_h / 2) + (max_height / 2) + 7 + (last_hovered ~= nil and (timer_text_height + 1) or 0), timer_text)
                end
                local x = (screen_w / 2) - (total_card_width / 2)
                
                for i = 1, #all_vote_maps do
                    local was_hovered = last_hovered ~= nil and last_hovered == i

                    local v = all_vote_maps[i]
                    local size = 1
                    if(was_hovered)then
                        size = 1.1
                    end
                    
                    local frame_width, frame_height = GuiGetImageDimensions(vote_gui, v.frame, 1)
                    local thumbnail_width, thumbnail_height = GuiGetImageDimensions(vote_gui, v.thumbnail or "mods/evaisa.arena/content/arenas/default_thumbnail.png", 1)

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
                    GuiText(vote_gui, card_x + 8, card_y + 6, GameTextGetTranslatedOrNot(v.name))
                    GuiZSetForNextWidget(vote_gui, -10)
                    GuiImage(vote_gui, new_id(), card_x, card_y, v.frame, 1, size, size)
                    GuiZSetForNextWidget(vote_gui, -9)
                    GuiImage(vote_gui, new_id(), (card_x + (frame_width / 2)) - (thumbnail_width / 2), (card_y + (frame_height / 2)) - (thumbnail_height / 2), v.thumbnail or "mods/evaisa.arena/content/arenas/default_thumbnail.png", 1, size, size)
                    local clicked, _, hovered = GuiGetPreviousWidgetInfo(vote_gui)
                    if(frames_left > 0 and not data.vote_loop.vote_finished)then
                        if(hovered)then
                            last_hovered = i
                            local text_width = GuiGetTextDimensions(vote_gui, GameTextGetTranslatedOrNot(v.description))
                            GuiText(vote_gui, (screen_w / 2) - (text_width / 2), old_card_y + max_height + 7, GameTextGetTranslatedOrNot(v.description))
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
                data.ready_counter:apply_offset(9, 28)
            else
                data.ready_counter:apply_offset(9, 9)
            end



            data.ready_counter:update(lobby, data)
        end



        --[[
        if (not IsPaused()) then
            if(data.unstuck_ui == nil)then
                data.unstuck_ui = GuiCreate()
            end

            GuiStartFrame(data.unstuck_ui)

            local screen_width, screen_height = GuiGetScreenDimensions(data.unstuck_ui)

            GuiOptionsAdd(data.unstuck_ui, 6)

            if(GameGetIsGamepadConnected())then
                GuiOptionsAdd(data.unstuck_ui, 2)
            else
                GuiOptionsRemove(data.unstuck_ui, 2)
            end

            if (GuiImageButton(data.unstuck_ui, 21312, screen_width - 60, screen_height - 20, "", "mods/evaisa.arena/files/sprites/ui/unstuck.png")) then
                
                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)

                np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
                np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
                np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
                np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
                np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
                np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)

                GameAddFlagRun("DeserializedHolyMountain")

                ArenaGameplay.SavePlayerData(lobby, data)
                delay.new(15, function()
                    gameplay_handler.ResetEverything(lobby)
                    delay.new(15, function()
                        if(not data.spectator_mode)then
                            gameplay_handler.GetGameData(lobby, data)
                        end

                        gameplay_handler.LoadLobby(lobby, data, true, true)
                    end)
                end)
            end
            local _, _, hovered, draw_x, draw_y = GuiGetPreviousWidgetInfo(data.unstuck_ui)

            --GuiTooltip(data.unstuck_ui, GameTextGetTranslatedOrNot("$arena_reset_hm"), GameTextGetTranslatedOrNot("$arena_reset_hm_description"))

            if(hovered)then
                GuiOptionsAddForNextWidget(data.unstuck_ui, 2)
                local total_height = 0
                local max_width = 0
                local strings = {
                    GameTextGetTranslatedOrNot("$arena_reset_hm"),
                    GameTextGetTranslatedOrNot("$arena_reset_hm_description"),
                    GameTextGetTranslatedOrNot("$arena_reset_hm_description_2")
                }
                local colors = {
                    {1, 1, 1, 1},
                    {0.9, 0.4, 0.4, 1},
                    {0.7, 0.7, 0.7, 1}
                }
                for k, v in ipairs(strings)do
                    local width, height = GuiGetTextDimensions(data.unstuck_ui, v)
                    if(width > max_width)then
                        max_width = width
                    end
                    total_height = total_height + height
                end

                
                -- offset
                local box_x = draw_x - max_width - 10
                local box_y = draw_y - total_height - 10

                local current_height = 0

                GuiBeginAutoBox(data.unstuck_ui)

                for k, v in ipairs(strings)do
                    local color = colors[k]
                    GuiColorSetForNextWidget(data.unstuck_ui, color[1], color[2], color[3], color[4])
                    GuiZSetForNextWidget(data.unstuck_ui, -12)
                    local width, height = GuiGetTextDimensions(data.unstuck_ui, v)
                    GuiText(data.unstuck_ui, box_x, box_y + current_height, v)
                    current_height = current_height + height
                end
                GuiZSetForNextWidget(data.unstuck_ui, -11)
                GuiEndAutoBoxNinePiece(data.unstuck_ui)
            end
        end]]

        if(GameHasFlagRun("lock_ready_state") and data.low_framerate_popup ~= nil )then
            data.low_framerate_popup:destroy()
        end
  

        local framerate = ArenaGameplay.GetFramerate(data)


        if(ModSettingGet("evaisa.arena.lag_detection") and #(EntityGetWithTag("workshop") or {}) > 0 and framerate < 10 and not data.low_framerate_popup)then

            --[[np.ComponentUpdatesSetEnabled("ProjectileSystem", false)
            np.ComponentUpdatesSetEnabled("CellEaterSystem", false)
            np.ComponentUpdatesSetEnabled("LooseGroundSystem", false)
            np.ComponentUpdatesSetEnabled("BlackHoleSystem", false)
            np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", false)
            np.ComponentUpdatesSetEnabled("PhysicsBodySystem", false)]]

            local entities = EntityGetInRadius(0, 0, 10000000)

            for k, v in pairs(entities)do
                local projectile_comp = EntityGetFirstComponentIncludingDisabled(v, "ProjectileComponent")
                if(projectile_comp ~= nil and EntityGetRootEntity(v) == v)then
                    EntityRemoveComponent(v, projectile_comp)
                    EntityKill(v)
                end
            end

            --[[delay.new(15, function()
                np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
                np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
                np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
                np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
                np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
                np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)
            end)]]

            --[[
            data.low_framerate_popup = popup.create("low_framerate", GameTextGetTranslatedOrNot("$arena_lag_detected_name"),{
                {
                    text = GameTextGetTranslatedOrNot("$arena_lag_detected_description"),
                    color = {214 / 255, 60 / 255, 60 / 255, 1}
                },
                GameTextGetTranslatedOrNot("$arena_lag_detected_description_2")
            }, {
                {
                    text = GameTextGetTranslatedOrNot("$mp_close_popup"),
                    callback = function()
                        np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
                        np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
                        np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
                        np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
                        np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
                        np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)
                    end
                },
                {
                    text = GameTextGetTranslatedOrNot("$arena_lag_detected_kill"),
                    callback = function()
                        np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
                        np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
                        np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
                        np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
                        np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
                        np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)

                        ArenaGameplay.SavePlayerData(lobby, data)

                        GameAddFlagRun("DeserializedHolyMountain")
                        delay.new(15, function()
                            gameplay_handler.ResetEverything(lobby)
                            delay.new(15, function()
                                if(not data.spectator_mode)then
                                    gameplay_handler.GetGameData(lobby, data)
                                end
        
                                gameplay_handler.LoadLobby(lobby, data, true, true)
                            end)
                        end)
                    end
                }
            }, -6000)]]
        elseif(not (ModSettingGet("evaisa.arena.lag_detection") and #(EntityGetWithTag("workshop") or {}) > 0))then
            data.frame_times = {}
            data.last_frame_time = nil
        end

        -- get ready percentage
        local ready_percentage = math.floor((ArenaGameplay.ReadyAmount(data, lobby) / ArenaGameplay.TotalPlayers(lobby)) * 100)

        if(ArenaGameplay.TotalPlayers(lobby) <= 1)then
            ready_percentage = 0

        end
        --print("Total players: "..tostring(ArenaGameplay.TotalPlayers(lobby)))

        local hm_timer_percentage = tonumber(GlobalsGetValue("hm_timer_count", "80"))
        local hm_timer_time = tonumber(GlobalsGetValue("hm_timer_time", "60"))
        local hm_timer_passive = tonumber(GlobalsGetValue("hm_timer_passive", "0"))
        if(hm_timer_passive > 0 or (hm_timer_percentage < 100 and not ArenaGameplay.ReadyCheck(lobby, data) and ready_percentage >= tonumber(hm_timer_percentage)))then
            if(data.hm_timer == nil)then
                local second_valid = (hm_timer_percentage < 100 and not ArenaGameplay.ReadyCheck(lobby, data) and ready_percentage >= tonumber(hm_timer_percentage))
                local timer_frames = tonumber(hm_timer_passive) * 60

                if(second_valid)then
                    timer_frames = tonumber(hm_timer_time) * 60
                end

                local time_remaining = math.min(data.time_remaining or timer_frames, timer_frames)

                data.hm_timer = delay.new(time_remaining, function()
                    if(steam_utils.IsOwner())then
                        ArenaGameplay.ForceReady(lobby, data)
                    end
                    if(data.hm_timer_gui)then
                        GuiDestroy(data.hm_timer_gui)
                        data.hm_timer_gui = nil
                    end
                end, function(frame)

                    -- update time remaining
                    data.time_remaining = math.floor(frame)

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
  
                    if(steam_utils.IsOwner())then
                        networking.send.hm_timer_update(lobby, frame)
                    end

                    data.hm_timer_gui = data.hm_timer_gui or GuiCreate()
                    GuiStartFrame(data.hm_timer_gui)

                    local screen_w, screen_h = GuiGetScreenDimensions(data.hm_timer_gui)

                    -- draw text at bottom center of screen
                    local text_width, text_height = GuiGetTextDimensions(data.hm_timer_gui, message)

                    GuiZSetForNextWidget(data.hm_timer_gui, -11)
                    GuiText(data.hm_timer_gui, (screen_w / 2) - (text_width / 2), screen_h - text_height - 10, message)
                end)
            else
                print("Timer already exists, should be reduced??")
                local second_valid = (hm_timer_percentage < 100 and not ArenaGameplay.ReadyCheck(lobby, data) and ready_percentage >= tonumber(hm_timer_percentage))
               

                if(second_valid)then
                    local timer_frames = tonumber(hm_timer_time) * 60

                    local time_remaining = math.min(data.time_remaining or timer_frames, timer_frames)

                    print("Time remaining: "..tostring(time_remaining))
    
                    -- if time is below timer frame
                    if(time_remaining < data.hm_timer.frames)then
                        data.hm_timer.frames = time_remaining
                    end
                end


            end
        else
            if(data.hm_timer ~= nil)then
                if(steam_utils.IsOwner())then
                    networking.send.hm_timer_clear(lobby)
                end
                data.hm_timer.clear()
                data.hm_timer = nil
            end
        end


        if(not IsPaused() and not (data.spectator_mode and data.spectated_player == nil))then
            ArenaGameplay.UpdateDummy(lobby, data, true)
        end

        if(data.spectator_mode)then
            
            SpectatorMode.SpectatorText(lobby, data)
            SpectatorMode.LobbySpectateUpdate(lobby, data)
            data.is_spectating = true

            if(#(EntityGetWithTag("workshop") or {}) > 0 and not data.spectator_lobby_loaded)then
                data.spectator_lobby_loaded = true
                SpectatorMode.SpawnSpectatedPlayer(lobby, data)
            end
            if(GameGetFrameNum() % 15 == 0 and GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous")then
                ArenaGameplay.RunReadyCheck(lobby, data)
            end

            if(data.spectated_player ~= nil and GameGetFrameNum() % 120 == 0)then
                networking.send.request_sync_hm(lobby, data.spectated_player, data.last_synced_entity_count)
            end
        else

            networking.send.character_position(lobby, data, true)

        -- networking.send.wand_update(lobby, data, nil, nil, true)
            networking.send.keyboard(lobby, data, true)
            networking.send.mouse(lobby, data, true)
            --networking.send.animation_update(lobby, data, true)
            if(GameGetFrameNum() % 15 == 0)then
                networking.send.player_data_update(lobby, data, true)
                if(GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous")then
                    ArenaGameplay.RunReadyCheck(lobby, data)
                
                    networking.send.ready(lobby, data.client.ready or false, false)
                end
            end
            networking.send.player_stats_update(lobby, data, true)
            --networking.send.spectate_data(lobby, data, nil, false)

            GameAddFlagRun("Immortal")

            data.is_spectating = false


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
                        
        end

        if(GameGetFrameNum() % 120 == 0)then
            networking.send.request_perk_update(lobby)
        end

    end,
    UpdateHealthbars = function(data)
        for k, v in pairs(data.players) do
            if (v.hp_bar) then
                if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                    local x, y = EntityGetTransform(v.entity)
                    y = y + 10
                    --print("Updating hp bar for "..tostring(k).." at "..tostring(x).." "..tostring(y))
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
        RunWhenPlayerExists(function()
            print("Unlocking player!!")
            player.Unlock(data)
        end)
        EntityCreateNew("dummy_damage")
        
        data.countdown = countdown.create({
            "mods/evaisa.arena/files/sprites/ui/countdown_new/ready.png",
            "mods/evaisa.arena/files/sprites/ui/countdown_new/3.png",
            "mods/evaisa.arena/files/sprites/ui/countdown_new/2.png",
            "mods/evaisa.arena/files/sprites/ui/countdown_new/1.png",
            "mods/evaisa.arena/files/sprites/ui/countdown_new/fight.png",
        }, 60, function()
            print("Countdown completed")
            data.countdown:cleanup()
            data.countdown = nil
            --message_handler.send.Unlock(lobby)
            networking.send.check_can_unlock(lobby)

            --[[local player_entity = player.Get()
            gameplay_handler.UpdateCosmetics(lobby, data, "arena_unlocked", player_entity, false)

            for k, v in pairs(data.players) do
                if(v.entity ~= nil)then
                    gameplay_handler.UpdateCosmetics(lobby, data, "arena_unlocked", v.entity, true)
                end
            end]]
            
            delay.new(5, function()
                cosmetics_handler.ArenaUnlocked(lobby, data)
            end)

            GameAddFlagRun("countdown_completed")
            if(not data.spectator_mode)then
                player.Immortal(false)
            end
            ArenaGameplay.AllowFiring(data)
            

            arena_log:print("Completed countdown.")

            networking.send.request_item_update(lobby)
        end, function(frame, index) 
            -- if we are host
            if (steam_utils.IsOwner()) then
                networking.send.sync_countdown(lobby, frame, index)
            end
        end)

    end,
    TransformPlayer = function(lobby, user, data, target_entity)

        print("Attempting to transform player "..tostring(user).." to "..tostring(target_entity))

        local player_data = data.players[tostring(user)]

        local target_file = ""
        if(target_entity)then
            local poly_effect_file = "mods/evaisa.arena/playerpoly/" .. target_entity
            if not ModDoesFileExist(poly_effect_file) then
                local template = get_content("mods/evaisa.arena/files/entities/misc/polymorph_template.xml")
                set_content(poly_effect_file, template:gsub("{TARGET}", target_entity))
            end
            target_file = poly_effect_file
        end

        if(player_data.entity == 0 or not EntityGetIsAlive(player_data.entity))then
            player_data.entity = nil
        end

        player_data.polymorph_entity = target_entity

        if(player_data.entity and player_data.entity ~= 0 and EntityGetIsAlive(player_data.entity))then
            print("Player is alive, transforming!")
            if(target_entity)then
                EntityRemoveTag(player_data.entity, "polymorphable_NOT")

                GameDestroyInventoryItems(player_data.entity)

                local original_entity = player_data.entity

                local effect =  LoadGameEffectEntityTo(player_data.entity, target_file)
                local new_entity = EntityGetRootEntity(effect)


                -- if root entity is the same as original entity, return null
                if(new_entity == effect)then
                    return nil
                end
                
                --[[delay.new(function()
                    return EntityGetRootEntity(effect) ~= entity
                end, function()

                
                end)]]
                
                -- update name
                EntitySetName(new_entity, tostring(user))
                EntityRemoveTag(new_entity, "polymorphed_player")
                EntityAddTag(new_entity, "client")

                EntityAddComponent2(new_entity, "LuaComponent", {
                    script_source_file = "mods/evaisa.arena/files/scripts/gamemode/misc/viewer_player_poly.lua",
                    enable_coroutines = true,
                    execute_on_added = true,
                    execute_every_n_frame = -1,
                })

                local genome_component = EntityGetFirstComponentIncludingDisabled(new_entity, "GenomeDataComponent")
                if(genome_component)then
                    ComponentSetValue2(genome_component, "herd_id", StringToHerdId("pvp_client"))
                end

                local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(new_entity, "AnimalAIComponent")

                if(animal_ai_comp)then
                    EntitySetComponentIsEnabled(new_entity, animal_ai_comp, false)
                end

                for k, v in ipairs(EntityGetComponentIncludingDisabled(new_entity, "LuaComponent", "remote_polymorph_remove") or {})do
                    EntityRemoveComponent(new_entity, v)
                end


                --[[ Add these to make sure the game doesn't break
                    <LuaComponent
                        script_damage_about_to_be_received = "mods/evaisa.arena/files/scripts/gamemode/misc/immortal_client.lua"
                        script_damage_received = "mods/evaisa.arena/files/scripts/gamemode/misc/immortal_client.lua"
                        >
                    </LuaComponent>

                    <LuaComponent
                        script_wand_fired = "mods/evaisa.arena/files/scripts/gamemode/misc/on_wand_fire_client.lua"
                        >
                    </LuaComponent>
                ]]

                -- remove components marked for removal

                EntityAddComponent2(new_entity, "LuaComponent", {
                    script_damage_about_to_be_received = "mods/evaisa.arena/files/scripts/gamemode/misc/immortal_client.lua",
                    script_damage_received = "mods/evaisa.arena/files/scripts/gamemode/misc/immortal_client.lua",
                })

                EntityAddComponent2(new_entity, "LuaComponent", {
                    script_wand_fired = "mods/evaisa.arena/files/scripts/gamemode/misc/on_wand_fire_client.lua",
                })


                -- get child entities
                for k, v in ipairs(EntityGetAllChildren(new_entity) or {})do
                   -- get GameEffectComponent
                   local game_effect = EntityGetFirstComponentIncludingDisabled(v, "GameEffectComponent")
                   if(game_effect)then
                       EntityRemoveComponent(v, game_effect)
                   end
                end

                EntityKill(effect)
                
                player_data.entity = new_entity
                if(data.spectated_player == user)then
                    data.selected_player = new_entity
                end

                -- stacktrace
        
                print("Transformed player "..tostring(user) .. "from " .. original_entity .." to "..tostring(new_entity))


                return new_entity
            else
                local entity = ArenaGameplay.SpawnClientPlayer(lobby, user, data)
                if(data.spectated_player == user)then
                    data.selected_player = entity
                end
                return entity
            end
        end
    end,
    SpawnClientPlayer = function(lobby, user, data, x, y)


        if((not data.state == "arena" and not data.spectator_mode) or (data.state == "lobby" and data.spectator_mode and (data.spectator_entity == nil or not EntityGetIsAlive(data.spectator_entity))))then
            print("skipped spawn!!")
            return
        end

        if(data.client_spawn_x and data.client_spawn_y)then
            x = data.client_spawn_x
            y = data.client_spawn_y

            data.client_spawn_x = nil
            data.client_spawn_y = nil
        end

        local client_xml = "mods/evaisa.arena/files/entities/client.xml"

        if(GameHasFlagRun("super_secret_hamis_mode"))then
            client_xml = "mods/evaisa.arena/files/entities/hamis_client.xml"
        end

        local client = EntityLoad(client_xml, x or -1000, y or -1000)

        local was_poly = false


        EntitySetName(client, tostring(user))
        --local usernameSprite = EntityGetFirstComponentIncludingDisabled(client, "SpriteComponent", "username")
        local name = steamutils.getTranslatedPersonaName(user)

        --ArenaGameplay.UpdateNametag(lobby, data, usernameSprite, name)


        data.players[tostring(user)].entity = client
        data.players[tostring(user)].alive = true

        if(data.players[tostring(user)].polymorph_entity)then
            print("Spawned polymorphed player!")
            client = ArenaGameplay.TransformPlayer(lobby, user, data, data.players[tostring(user)].polymorph_entity)
            EntitySetName(client, tostring(user))
            was_poly = true
            data.players[tostring(user)].entity = client

            EntitySetName(client, tostring(user))
            EntityRemoveTag(client, "polymorphed_player")
            EntityAddTag(client, "client")
        end


        arena_log:print("Spawned client player for " .. name)

        if(not was_poly)then
            if (data.players[tostring(user)].perks) then
                for k, v in ipairs(data.players[tostring(user)].perks) do
                    local perk = v[1]
                    local count = v[2]

                    for i = 1, count do
                        EntityHelper.GivePerk(client, perk, i, true)
                    end
                end
            end
        end

        
        if(skin_system and lobby)then
            skin_system.apply_skin_to_entity(lobby, client, user, data)
        end
        
        networking.send.request_sync_hm(lobby, user)
        networking.send.request_item_update(lobby, user)
        --networking.send.request_spectate_data(lobby, user)
        networking.send.request_skin(lobby, user)
        networking.send.request_perk_update(lobby, user)
        
        if(not was_poly and data.spectated_player == user)then
            networking.send.is_spectating(data.spectated_player, true)
        end
        --print(debug.traceback())

        if(data.spectator_mode and data.state == "lobby" and data.spectated_player == user)then
            data.selected_player = client
            networking.send.request_character_position(lobby, user)
            networking.send.request_dummy_target(lobby, user)
            networking.send.request_card_list(lobby, user)
        end

        --cosmetics_handler.LoadClientCosmetics(lobby, data, client)

        local cosmetics = {}
        
        for k, v in pairs(data.players[tostring(user)].cosmetics or {})do
            print("Applying cosmetic: "..tostring(k))
            table.insert(cosmetics, k)
        end

        cosmetics_handler.ApplyCosmeticsList(lobby, data, client, cosmetics, true, user)

        
        return client
    end,
    CheckPlayer = function(lobby, user, data)
        if(not data.players[tostring(user)])then
            return false
        end

        if (not (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))))) then
            return false
        end
        

        if(GlobalsGetValue("arena_gamemode", "ffa") == "continuous" and not data.spectator_mode and data.players[tostring(user)].state ~= "arena")then
            return false
        end

        -- if we are in lobby and player is not being spectated
        if(data.spectator_mode and data.state == "lobby" and data.spectated_player ~= user)then
            return false
        end

        if (not data.players[tostring(user)].entity and data.players[tostring(user)].alive) then

            -- find entity by name
            local entity = EntityGetWithName(tostring(user))

            if (entity ~= nil) then
                data.players[tostring(user)].entity = entity
                return false
            else
                ArenaGameplay.SpawnClientPlayer(lobby, user, data)
            end
            return false
        end
        return true
    end,
    DrawNametag = function(lobby, data, entity, name, offset_y)

        name = name or "unknown"

        local language = GameTextGetTranslatedOrNot("$current_language")

        --local font = data.username_fonts[language] or data.username_fonts["unknown"]

        --local width = GuiGetTextDimensions(username_gui, name, nil, nil, font.font, font.smooth)

        local width = GuiGetTextDimensions(username_gui, name)

        local x, y = EntityGetTransform(entity)

        local screen_x, screen_y = WorldToScreenPos(username_gui, x, y)

        local offset_x = width / 2

        GuiZSetForNextWidget(username_gui, -11)
        GuiText(username_gui, screen_x - offset_x, screen_y - (offset_y or 0), name)


        --[[
        local language = GameTextGetTranslatedOrNot("$current_language")

        local font = data.username_fonts[language] or data.username_fonts["unknown"]

        local width = GuiGetTextDimensions(username_gui, name, 1, nil, font.font, font.smooth)


        ComponentSetValue2(usernameSprite, "text", name)
        --ComponentSetValue2(usernameSprite, "offset_x", string.len(name) * (1.8))
        ComponentSetValue2(usernameSprite, "offset_x", width * (font.size or 1))
        ComponentSetValue2(usernameSprite, "image_file", font.font)
        ComponentSetValue2(usernameSprite, "smooth_filtering", font.smooth)
        ComponentSetValue2(usernameSprite, "special_scale_x", font.size)
        ComponentSetValue2(usernameSprite, "special_scale_y", font.size)
        ]]
    end,
    UpdateDummyData = function(dummy, lobby, data)


        if(data.target_dummy_player == nil)then
            return
        end


        local players = {
            [tostring(steam_utils.getSteamID())] = {
                perks = data.client.perks or {},
                health = data.client.hp or 100,
                max_health = data.client.max_hp or 100,
            }
        }

        for k, v in pairs(data.players) do
            players[tostring(k)] = {
                perks = v.perks or {},
                health = v.health or 100,
                max_health = v.max_health or 100,
            }
        end



        local target_data = nil
        for k, v in pairs(players) do
            if (k == tostring(data.target_dummy_player)) then
                target_data = v
                break
            end
        end

        if target_data == nil then
            for k, v in pairs(players) do
                target_data = v
                break
            end
        end

        
        local new_target_avatar = steamutils.getUserAvatar(data.target_dummy_player)

        local faceSprite = EntityGetFirstComponentIncludingDisabled(dummy, "SpriteComponent", "face")
        ComponentSetValue2(faceSprite, "image_file", new_target_avatar)

        
        EntityRefreshSprite(dummy, usernameSprite)
        EntityRefreshSprite(dummy, faceSprite)

        if (target_data and target_data.perks) then
            for k, v in ipairs(target_data.perks) do
                local perk = v[1]
                local count = v[2]

                for i = 1, count do
                    EntityHelper.GivePerk(dummy, perk, i, false, true)
                end
            end
        end

        if (target_data and target_data.health) then
            local hp = target_data.health
            local max_hp = target_data.max_health
            local hp_component = EntityGetFirstComponentIncludingDisabled(dummy, "DamageModelComponent")
            ComponentSetValue2(hp_component, "hp", hp)
            ComponentSetValue2(hp_component, "max_hp", max_hp)
        end

    end,
    SwitchDummy = function(dummy, lobby, data)

        local dummy_target = data.target_dummy_player or steam_utils.getSteamID()
        local new_target = nil
        -- check if target is in lobby
        local next_is_target = false

        -- kill dummy and respawn in same location
        local x, y = EntityGetTransform(dummy)
        EntityKill(dummy)
        dummy = EntityLoad("mods/evaisa.arena/files/entities/dummy_target/dummy_target.xml", x, y)

        local players = {
        }

        local player_count = 0

        if(not data.spectator_mode)then
            player_count = player_count + 1
            players[tostring(steam_utils.getSteamID())] = {
                perks = data.client.perks or {},
                health = data.client.hp or 100,
                max_health = data.client.max_hp or 100,
            }
        end

        for k, v in pairs(data.players or {}) do
            player_count = player_count + 1
            players[tostring(k)] = {
                perks = v.perks or {},
                health = v.health or 100,
                max_health = v.max_health or 100,
            }
        end
        --local inspect = dofile("mods/evaisa.arena/lib/inspect.lua")
        --print(inspect(players))

        --local target_data = nil

        if(player_count <= 0)then
            return
        end

        for k, v in pairs(players) do
            if (k == tostring(dummy_target)) then
                next_is_target = true
                --print("Got current target: " .. tostring(dummy_target))
            elseif (next_is_target)then
                new_target = gameplay_handler.FindUser(lobby, k)
                --print("Switched dummy to " .. tostring(new_target))
                --target_data = v
                break
            end
        end

        if (new_target == nil) then
            -- first player
            for k, v in pairs(players) do
                new_target = gameplay_handler.FindUser(lobby, k)
                --target_data = v
                break
            end
        end

        data.target_dummy_player = new_target

        networking.send.dummy_target(lobby, new_target)

        GameAddFlagRun("refresh_dummy")

    end,
    UpdateDummy = function(lobby, data, pre)
        local dummies = EntityGetWithTag("target_dummy") or {}

        local id = 322352
        local new_id = function()
            id = id + 1
            return id
        end

        if(#dummies > 0)then
        
            local updated_dummies = false
            local switched_dummies = false
            for i, v in ipairs(dummies)do
                if(pre)then
                    if(data.target_dummy_player == nil or GameHasFlagRun( "target_dummy_switch" ))then
                        ArenaGameplay.SwitchDummy(v, lobby, data)
                        switched_dummies = true
                    elseif(data.target_dummy_player ~= nil and GameHasFlagRun("refresh_dummy"))then
                        ArenaGameplay.UpdateDummyData(v, lobby, data)
                        updated_dummies = true
                    end
                end

                if(not pre)then
                    if(data.target_dummy_player)then
                        local new_target_name = steamutils.getTranslatedPersonaName(data.target_dummy_player)
                        ArenaGameplay.DrawNametag(lobby, data, v, new_target_name, -16)
                    end
                end
            end

            if(switched_dummies)then
                GameRemoveFlagRun( "target_dummy_switch" )
            end

            if(updated_dummies)then
                GameRemoveFlagRun( "refresh_dummy" )
            end

        end
        
    end,
    IsArenaLoaded = function(lobby, data)
        local players = steamutils.getLobbyMembers(lobby)
        for _, member in pairs(players) do
            if (data.players[tostring(member.id)] and data.players[tostring(member.id)].state == "arena") then
                return true
            end
        end

        return false
    end,
    LoadClientPlayers = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)

        for _, member in pairs(members) do

            if (member.id ~= steam_utils.getSteamID() and data.players[tostring(member.id)].entity) then
                data.players[tostring(member.id)]:Clean(lobby)
            end

            --[[if(member.id ~= steam_utils.getSteamID())then
                print(json.stringify(data.players[tostring(member.id)]))
            end]]
            if (member.id ~= steam_utils.getSteamID() and data.players[tostring(member.id)].entity == nil) then

                if(not (GlobalsGetValue("arena_gamemode", "ffa") == "continuous" and not data.spectator_mode and data.players[tostring(member.id)].state ~= "arena"))then
                    --GamePrint("Loading player " .. tostring(member.id))
                    ArenaGameplay.SpawnClientPlayer(lobby, member.id, data)
                end

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
        if (data.preparing and data.current_arena ~= nil) then
            --game_funcs.LoadRegion(0, 0, map_size * 2, map_size * 2)
            data.load_frames = data.load_frames or 0
            if(data.load_frames < 30)then
                data.load_frames = data.load_frames + 1
                
                local map_size = data.current_arena.zone_size
                if(not data.chunkloaders_initialized)then
                    data.chunkloaders_initialized = true
                    data.spawn_loader = EntityCreateNew("chunk_loader")
                    EntityAddComponent2(data.spawn_loader, "StreamingKeepAliveComponent")
                    EntityAddComponent2(data.spawn_loader, "HitboxComponent", {
                        aabb_min_x=-map_size,
                        aabb_min_y=-map_size,
                        aabb_max_x=map_size,
                        aabb_max_y=map_size,
                    })
                end
            else
               
                local spawn_seed = (ArenaGameplay.GetNumRounds(lobby) * 62362)

                if(GlobalsGetValue("arena_gamemode", "ffa") == "continuous")then
                    spawn_seed = spawn_seed + GameGetFrameNum()
                end


                SetRandomSeed(spawn_seed, spawn_seed * 4)
                local spawn_points = ArenaGameplay.GetSpawnPoints()
                local spawn_points_predefined = data.current_arena.spawn_points

                if(type(data.current_arena.spawn_points) == "function")then
                    print("Using spawn point function")
                    spawn_points_predefined = data.current_arena:spawn_points(lobby, data)
                end
               
                -- shuffle spawn points randomly
                for i = #spawn_points, 2, -1 do
                    local j = Random(1, i)
                    spawn_points[i], spawn_points[j] = spawn_points[j], spawn_points[i]
                end

    
                --print("Spawn RNG: "..tostring(spawn_seed))
                --print("spawnpoint_count: " .. tostring(#spawn_points))
    
                local x, y = 0, 0

                data.ready_for_zone = true

                
                if(spawn_points ~= nil and #spawn_points > 0)then
                    print("Using entity spawn points")
                    local spawn_index = math.floor(ArenaGameplay.GetPlayerIndex(lobby) % #spawn_points)
    
                    if(spawn_index < 1)then
                        spawn_index = 1
                    end
    
                    local spawn_point = spawn_points[spawn_index]
                    x, y = EntityGetTransform(spawn_point)
                elseif(spawn_points_predefined and #spawn_points_predefined > 0)then
                    print("Using predefined spawn points")
                    local spawn_index = math.floor(ArenaGameplay.GetPlayerIndex(lobby) % #spawn_points_predefined)
    
                    if(spawn_index < 1)then
                        spawn_index = 1
                    end
    
                    local spawn_point = spawn_points_predefined[spawn_index]
                    x, y = spawn_point.x, spawn_point.y
                end

                local spawn_loaded = DoesWorldExistAt(x - 100, y - 100, x + 100, y + 100)

                --player.Move(x, y)

                arena_log:print("Arena loaded? " .. tostring(spawn_loaded))

                local in_bounds = ArenaGameplay.IsInBounds(0, 0, data.current_arena.zone_size)

                if (not in_bounds) then
                    arena_log:print("Game tried to spawn player out of bounds, retrying...")
                    --GamePrint("Game attempted to spawn you out of bounds, retrying...")
                end

                if (spawn_loaded and in_bounds) then
                    data.preparing = false
                    data.chunkloaders_initialized = false
                    if(EntityGetIsAlive(data.spawn_loader))then
                        EntityKill(data.spawn_loader)
                    end

                    data.load_frames = 0
                    --GamePrint("Spawned!!")

                    if(not data.spectator_mode)then
                        ArenaGameplay.LoadPlayer(lobby, data, x, y)

                        if (not steam_utils.IsOwner()) then
                            RunWhenPlayerExists(function()
                                networking.send.arena_loaded(lobby)
                            end)
                            
                            --message_handler.send.Loaded(lobby)
                        end
    
                        --message_handler.send.Health(lobby)
                        networking.send.health_update(lobby, data, true)
                    else
                        data.is_spectating = true
                    end
                end

                --   player.Move(data.spawn_point.x, data.spawn_point.y)
            end

        else
                                    
            for k, v in ipairs(EntityGetWithTag("spawn_point") or {})do
                EntityKill(v)
            end
        end
        
        SpectatorMode.SpectateUpdate(lobby, data)

        
        local player_entity = nil

        if (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))) then
            ArenaGameplay.DamageZoneHandler(lobby, data, true)
        else
            ArenaGameplay.DamageZoneHandler(lobby, data, false)
        end

        if(not data.spectator_mode)then
            player_entity = player.Get()
        end

        if (steam_utils.IsOwner() and GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous") then

            if ((data.spectator_mode or player_entity ~= nil) and (not data.players_loaded and ArenaGameplay.CheckAllPlayersLoaded(lobby, data))) then
                data.players_loaded = true
                arena_log:print("All players loaded")
                --message_handler.send.StartCountdown(lobby)
                networking.send.start_countdown(lobby)
                ArenaGameplay.FightCountdown(lobby, data)
            end
        else
            data.players_loaded = true
        end
        if (data.countdown ~= nil) then
            data.countdown:update()
        end

        if(data.current_arena.update)then
            data.current_arena:update(lobby, data)
        end

        if(not data.spectator_mode)then
            networking.send.character_position(lobby, data)

            if(player_entity and GameHasFlagRun("player_died") and not GameHasFlagRun("player_unloaded"))then
                local damage_model = EntityGetFirstComponentIncludingDisabled(player_entity, "DamageModelComponent")

                

                if(damage_model)then
                    ComponentSetValue2(damage_model, "hp", 0.04)
                    ArenaGameplay.SavePlayerData(lobby, data)
                    ComponentSetValue2(damage_model, "hp", -5)
                    ComponentSetValue2(damage_model, "kill_now", true)
                    GameAddFlagRun("player_unloaded")
                end
                
            end

            if (GameHasFlagRun("took_damage")) then
                GameRemoveFlagRun("took_damage")
                networking.send.health_update(lobby, data, true)
            end
            if (data.players_loaded) then

                if(GameGetFrameNum() % 15 == 0)then
                    networking.send.player_data_update(lobby, data)
                end
                
                networking.send.player_stats_update(lobby, data)

                networking.send.keyboard(lobby, data)
                networking.send.mouse(lobby, data)

                --ArenaGameplay.CheckFiringBlock(lobby, data)
            end
        end
    end,
    GetFramerate = function(data)
        data.frame_times = data.frame_times or {}
        local now_time = GameGetRealWorldTimeSinceStarted()
        local seconds_passed_since_last_frame = GameGetRealWorldTimeSinceStarted() - (data.last_frame_time or now_time)
        data.last_frame_time = now_time
        table.insert(data.frame_times, seconds_passed_since_last_frame)
        if #data.frame_times > 60 then
          table.remove(data.frame_times, 1)
        end
        local average_frame_time = 0
        for i, v in ipairs(data.frame_times) do
          average_frame_time = average_frame_time + v
        end
        average_frame_time = average_frame_time / #data.frame_times
        local FPS = 1 / average_frame_time

        return FPS
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
    GetActionInfo = function(id)
        if(card_action_list == nil)then
            card_action_list = {}
            dofile("data/scripts/gun/gun_actions.lua")
            for k, v in ipairs(actions)do
                card_action_list[v.id] = v
            end
            return card_action_list[id] or nil
        else
            return card_action_list[id] or nil
        end


    end,
    Update = function(lobby, data)

        -- remove homing targets from non targets!!!
        if(GameGetFrameNum() % 25 == 0)then
            local targets = EntityGetWithTag("homing_target")

            for k, v in ipairs(targets or {})do
                if(not EntityHasTag(v, "enemy") and not EntityHasTag(v, "player_unit"))then
                    EntityRemoveTag(v, "homing_target")
                end
            end

            networking.send.uses_update(lobby, data)
        end

        local player_entity = player.Get()

        if(player_entity and not data.is_spectating)then

            if(GameHasFlagRun("super_secret_hamis_mode"))then

                SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() * 5435 % 1000 )

                local inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "InventoryGuiComponent")
                
                if(inventory_gui_comp)then
                    ComponentSetValue2(inventory_gui_comp, "mActive", false)
                end

                local regen = data.client.regen or 0
                
                if(GameGetFrameNum() % 40 == 0)then
                    if(regen > 0)then
                        local count = tonumber( GlobalsGetValue( "hamis_leech_count", "0" ) )

                        local total_heal = 0.01 + (count * 0.005)
                        

                        data.client.regen = regen - total_heal


                        EntityInflictDamage(player_entity, -math.abs(total_heal), "DAMAGE_HEALING", "leech", "NONE", 0, 0, player_entity)
                        local player_x, player_y = EntityGetTransform(player_entity)
                        local heal = EntityLoad("data/entities/particles/heal_effect.xml", player_x, player_y)
                        EntityAddChild(player_entity, heal)
                        networking.send.hamis_heal(lobby)
                    end
    
                end
               

    
                local controlsComp = EntityGetFirstComponentIncludingDisabled(player_entity, "ControlsComponent")
                local fire = ComponentGetValue2(controlsComp, "mButtonDownFire")
                local fire2 = ComponentGetValue2(controlsComp, "mButtonDownFire2")
                local fire2_frame = ComponentGetValue2(controlsComp, "mButtonFrameFire2")
                local aim_x, aim_y = ComponentGetValue2(controlsComp, "mAimingVectorNormalized")
                local throw = ComponentGetValue2(controlsComp, "mButtonDownThrow")
                local throw_frame = ComponentGetValue2(controlsComp, "mButtonFrameThrow")
                local jump = ComponentGetValue2(controlsComp, "mButtonDownFly")
                local jump_frame = ComponentGetValue2(controlsComp, "mButtonFrameFly")
                
                
                local sprite_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "SpriteComponent", "character")

                local animation = ComponentGetValue2(sprite_comp, "rect_animation")
                local player_x, player_y = EntityGetTransform(player_entity)
    
                local allowed_items = MergeTables(EntityGetInRadiusWithTag(player_x, player_y, 10, "heart") or {}, EntityGetInRadiusWithTag(player_x, player_y, 10, "perk") or {}, EntityGetInRadiusWithTag(player_x, player_y, 10, "perk_reroll_machine") or {})
                local itemPickUpperComp = EntityGetFirstComponentIncludingDisabled(player_entity, "ItemPickUpperComponent")
    
                for k, v in ipairs(allowed_items)do
                    ComponentSetValue2(itemPickUpperComp, "only_pick_this_entity", v) 
                end
    
                local mouse2 = false
                local mouse2_frame = 0
                
                if(fire2 and fire == false)then
                  GlobalsSetValue("throw_scheme", "1")
                elseif(throw and fire == false)then
                  GlobalsSetValue("throw_scheme", "2")
                end
                
                if(GlobalsGetValue("throw_scheme", "1") == "1")then
                  mouse2 = fire2
                  mouse2_frame = fire2_frame
                else
                  mouse2 = throw
                  mouse2_frame = throw_frame
                end
    
                
                local target_x, target_y = aim_x * 200, aim_y * 200
                
                local characterDataComponent = EntityGetFirstComponentIncludingDisabled(player_entity, "CharacterDataComponent")
    
                local on_ground = ComponentGetValue2(characterDataComponent, "is_on_ground")

                on_ground_last_frame = on_ground_last_frame or false

                if(on_ground)then
                    on_ground_last_frame = true
                end

                was_on_ground = was_on_ground or tonumber(GlobalsGetValue("hamis_dash_count", "1"))
                time_in_air = time_in_air or 0
                last_time_in_air = last_time_in_air or 0
    
                if(on_ground)then
                    was_on_ground = tonumber(GlobalsGetValue("hamis_dash_count", "1"))
                else
                    time_in_air = time_in_air + 1
                end
                
                
                local vel_x, vel_y = ComponentGetValue2(characterDataComponent, "mVelocity")

                local velocity = math.sqrt(vel_x * vel_x + vel_y * vel_y)

                last_velocity = last_velocity or velocity


                last_damaged_targets = last_damaged_targets or {}
                if(animation == "attack")then

                    last_chomp = last_chomp or nil
                    last_chomp_aim = last_chomp_aim or {0, 0}

                    local big_chomper = GameHasFlagRun( "hamis_big_bite" )

                    local targets = EntityGetInRadiusWithTag(player_x, player_y, 5, "mortal") or {}

                    if(big_chomper)then

                        local attack_aim_x, attack_aim_y = aim_x, aim_y
                        local aim_length = math.sqrt(attack_aim_x * attack_aim_x + attack_aim_y * attack_aim_y)
                        if (aim_length > 0) then
                            attack_aim_x = attack_aim_x / aim_length
                            attack_aim_y = attack_aim_y / aim_length
                        end

                        if(not was_attack)then

                            last_chomp = EntityLoad("mods/evaisa.arena/files/custom/perks/hamis/big_bite/chomp_entity.xml", player_x + attack_aim_x * 20, player_y + attack_aim_y * 20)
                            GameShootProjectile(player_entity, player_x + attack_aim_x * 20, player_y + attack_aim_y * 20, player_x + attack_aim_x * 1000, player_y + attack_aim_y * 1000, last_chomp)
                            last_chomp_aim = {attack_aim_x, attack_aim_y}
                        end

                        EntityApplyTransform(last_chomp, player_x + last_chomp_aim[1] * 20, player_y + last_chomp_aim[2] * 20)

                        targets = MergeTables(targets, EntityGetInRadiusWithTag(player_x + last_chomp_aim[1] * 20, player_y + last_chomp_aim[2] * 20, 25, "mortal") or {})
                    end

                    for k, v in ipairs(targets)do
                        -- if target is not us
                        if(v ~= player_entity)then
                            if(last_damaged_targets[v] == nil or GameGetFrameNum() > last_damaged_targets[v] + 50)then
                                local damage_mult = tonumber(GlobalsGetValue("hamis_damage_mult", "1"))
                                EntityInflictDamage(v, (Random(200, 400) / 1000) * damage_mult, "DAMAGE_MELEE", "hämis", "BLOOD_EXPLOSION", 0, 0, player_entity, player_x, player_y, 200)

                                if(not EntityHasTag(v, "client"))then
                                    local count = tonumber( GlobalsGetValue( "hamis_leech_count", "0" ) )
                                    if(count > 0 and data.client.alive)then
                                        local players = GetPlayers()
                                        if(#players > 0)then
                                            for i = 1, count do
                                                data.client.regen = data.client.regen or 0
                                                data.client.regen = data.client.regen + 0.04
                        
                                            end
                                        end
                                    end
                                end


                                local explosion_count = tonumber( GlobalsGetValue( "hamis_explosive_dash_count", "0" ) )

                                
                                if(velocity > 100 and last_time_in_air >= 50 and explosion_count > 0 and Random(0, 100) >= 50)then
                                    local x, y = EntityGetTransform(v)
                                    networking.send.hamis_explosion(lobby, explosion_count, x, y)
                                    HamisMode.explode(player_entity, x, y, explosion_count)
                                end

                                last_damaged_targets[v] = GameGetFrameNum()
                            end
                    
                        end
                    end
                    was_attack = true
                else
                    was_attack = false
                end



                if(last_velocity > 100 and velocity < 80 and last_time_in_air >= 50 and Random(0, 100) >= 50)then
                    -- consider this an impact!

                    local explosion_count = tonumber( GlobalsGetValue( "hamis_explosive_dash_count", "0" ) )

                    if(explosion_count > 0)then
                        print("Velocity: " .. tostring(velocity))
                        local x, y = EntityGetTransform(player_entity)
                        networking.send.hamis_explosion(lobby, explosion_count, x, y)
                        HamisMode.explode(player_entity, x, y, explosion_count)
                    end

                end

                if(on_ground and time_in_air ~= 0)then
                    last_time_in_air = time_in_air
                    time_in_air = 0
                end


                last_velocity = velocity

                if(fire)then
                    GamePlayAnimation(player_entity, "attack", 100, "idle", 1)
                    networking.send.hamis_attack(lobby, tonumber(GlobalsGetValue("hamis_damage_mult", "1")))
                elseif(mouse2 and mouse2_frame == GameGetFrameNum() and was_on_ground > 0)then
                    GamePlayAnimation(player_entity, "attack", 100, "idle", 1)
                    
                    ComponentSetValue2(characterDataComponent, "is_on_ground", true)
                    ComponentSetValue2(controlsComp, "mJumpVelocity", target_x, target_y)
                    ComponentSetValue2(characterDataComponent, "mVelocity", target_x, target_y)
                    networking.send.hamis_attack(lobby, tonumber(GlobalsGetValue("hamis_damage_mult", "1")))
                    was_on_ground = was_on_ground - 1
                elseif(on_ground_last_frame and jump and jump_frame <= GameGetFrameNum() + 1)then
                    ComponentSetValue2(controlsComp, "mJumpVelocity", target_x, target_y)
                end

                on_ground_last_frame = on_ground
            end


            if(EntityHasTag(player_entity, "polymorphed_player") and not data.is_polymorphed and EntityGetFilename(player_entity) ~= "")then

                data.is_polymorphed = true

                -- SEVERAL FIXES

                --[[We need to add these to make sure the game still works
                <LuaComponent
                    script_wand_fired = "mods/evaisa.arena/files/scripts/gamemode/misc/on_wand_fire.lua"
                    >
                </LuaComponent>

                    <LuaComponent
                    script_damage_about_to_be_received = "mods/evaisa.arena/files/scripts/gamemode/misc/kill_check.lua"
                    script_damage_received = "mods/evaisa.arena/files/scripts/gamemode/misc/kill_check.lua"
                    >
                </LuaComponent>
                ]]

                
                networking.send.polymorphed(lobby, true)

                print("Player polymorphed!! wawa!")

                local genome_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "GenomeDataComponent")
                if(genome_comp)then
                    ComponentSetValue2(genome_comp, "herd_id", StringToHerdId("pvp"))
                end

                local character_platforming_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "CharacterPlatformingComponent")
                if(character_platforming_comp)then
                    ComponentSetValue2(character_platforming_comp, "fly_speed_mult", 0)
                    ComponentSetValue2(character_platforming_comp, "fly_speed_change_spd", 0)
                end

                EntityAddTag(player_entity, "player_unit")

                -- add InventoryGuiComponent
                EntityAddComponent2(player_entity, "InventoryGuiComponent")

                EntityAddComponent2(player_entity, "LuaComponent", {
                    script_wand_fired = "mods/evaisa.arena/files/scripts/gamemode/misc/on_wand_fire.lua"
                })

                EntityAddComponent2(player_entity, "LuaComponent", {
                    script_damage_about_to_be_received = "mods/evaisa.arena/files/scripts/gamemode/misc/kill_check.lua",
                    script_damage_received = "mods/evaisa.arena/files/scripts/gamemode/misc/kill_check.lua"
                })
        

            elseif(not EntityHasTag(player_entity, "polymorphed_player") and data.is_polymorphed)then
                data.is_polymorphed = false
                networking.send.polymorphed(lobby, false)
            end
        end

        world_sync.update(lobby, data)


        data.picked_up_items = data.picked_up_items or {}
        local network_entities = EntityGetWithTag("does_physics_update") or {}

        for i = #data.picked_up_items, 1, -1 do
            local item_id = data.picked_up_items[i]
            for k, v in ipairs(network_entities)do
                if(EntityGetFirstComponentIncludingDisabled(v, "ItemComponent") ~= nil)then
                    local entity_id = EntityHelper.GetVariable(v, "arena_entity_id")
                    if(entity_id ~= nil and entity_id == item_id)then
                        local entity_x, entity_y = EntityGetTransform(v)
    
                
                        local comps = EntityGetAllComponents(v)
    
                        for k2, v2 in ipairs(comps)do
                            EntitySetComponentIsEnabled(v, v2, false)
                        end
    
                        local material_storage = EntityGetFirstComponentIncludingDisabled(v, "MaterialInventoryComponent")
                        if(material_storage ~= nil)then
                            EntityRemoveComponent(v, material_storage)
                        end
                  
    
                       

                        if(EntityGetRootEntity(v) == v)then
                            EntityLoad("data/entities/particles/image_emitters/shop_effect.xml", entity_x, entity_y - 8)
                            EntityKill(v)
                        elseif(not EntityHasTag(EntityGetRootEntity(v), "client") and not EntityHasTag(EntityGetRootEntity(v), "spectator"))then
                            EntityKill(v)
                        end

                        table.remove(data.picked_up_items, i)

                        print("Picked up item removed")
    
                       
                    end
                end
            end
        end


        if(data.low_framerate_popup ~= nil and data.low_framerate_popup.destroyed)then
            np.ComponentUpdatesSetEnabled("ProjectileSystem", true)
            np.ComponentUpdatesSetEnabled("CellEaterSystem", true)
            np.ComponentUpdatesSetEnabled("LooseGroundSystem", true)
            np.ComponentUpdatesSetEnabled("BlackHoleSystem", true)
            np.ComponentUpdatesSetEnabled("MagicConvertMaterialSystem", true)
            np.ComponentUpdatesSetEnabled("PhysicsBodySystem", true)
            data.low_framerate_popup = nil
        end

        username_gui = username_gui or GuiCreate()

        GuiStartFrame(username_gui)

        if(player_entity ~= nil)then
            --[[gameplay_handler.UpdateCosmetics(lobby, data, "try_unlock", player_entity, false)
            gameplay_handler.UpdateCosmetics(lobby, data, "update", player_entity, false)
            for k, v in pairs(data.players) do
                if(v.entity ~= nil)then
                    gameplay_handler.UpdateCosmetics(lobby, data, "update", v.entity, true)
                end
            end]]
            cosmetics_handler.Update(lobby, data)
        end

        if(GameHasFlagRun("sync_hm_to_spectators"))then


            if(data.state == "lobby")then
                if(data.client.match_data_unpacked ~= nil)then
                    data.client.match_data_unpacked.floor_items = {}
                end
                GameAddFlagRun("should_save_player")
                networking.send.sync_hm(lobby, data)
            end
            
            GameRemoveFlagRun("sync_hm_to_spectators")
        end


        if(data.spectator_mode)then
            SpectatorMode.UpdateSpectatorEntity(lobby, data)
            SpectatorMode.HandleSpectatorSync(lobby, data)

            if(GameGetFrameNum() % 60 == 0)then
                local InventoryGuiComponent = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "InventoryGuiComponent")
                if(InventoryGuiComponent ~= nil)then
                    EntitySetComponentIsEnabled(data.spectator_entity, InventoryGuiComponent, data.spectated_player ~= nil)
                end
            end


            local inventory2Comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "Inventory2Component")

            if(inventory2Comp ~= nil)then

                if(data.spectator_selected_item ~= nil and EntityGetIsAlive(data.spectator_selected_item ))then
                    game_funcs.SetActiveHeldEntity(data.spectator_entity, data.spectator_selected_item, false, false)
                else
                    data.spectator_selected_item = nil
                    ComponentSetValue2(inventory2Comp, "mActiveItem", -1)
                    ComponentSetValue2(inventory2Comp, "mActualActiveItem", -1)
                end
                

                local inventory_items = GameGetAllInventoryItems(data.spectator_entity)

                for k, v in ipairs(inventory_items or {})do
                    local potionComp = EntityGetFirstComponentIncludingDisabled(v, "PotionComponent")
                    if(potionComp ~= nil)then
                        EntitySetComponentIsEnabled(v, potionComp, false)
                    end
                end
            end


        end

        if(data.upgrade_system ~= nil and not IsPaused())then
            data.upgrade_system:draw(data.is_spectating)
        end

        if(GameHasFlagRun("update_card_menu_state") and not data.spectator_mode)then
            print("Sending card list state")
            networking.send.card_list_state(lobby, data)
            GameRemoveFlagRun("update_card_menu_state")
        end
        

        np.SetInventoryCursorEnabled(not data.is_spectating)
        if(data.is_spectating)then

            local polymorph_players = EntityGetWithTag("polymorphed_player") or {}
            for k, v in ipairs(polymorph_players)do
                if(not EntityHasTag(v, "client"))then
                    --EntityKill(v)
                end
            end
            
            
            -- handle hover tooltips for world wands
            local mouse_x, mouse_y = DEBUG_GetMouseWorld()

            local wands = EntityGetInRadiusWithTag(mouse_x, mouse_y, 15, "wand")

            local closest_wand = nil
            local closest_distance = 9999
            for k, v in ipairs(wands)do
                if(EntityGetRootEntity(v) ~= v)then
                    goto continue
                end

                local ability_comp = EntityGetFirstComponentIncludingDisabled(v, "AbilityComponent")

                if(ability_comp == nil)then
                    goto continue
                end

                if(not ComponentGetValue2(ability_comp, "use_gun_script"))then
                    goto continue
                end

                local x, y = EntityGetTransform(v)
                local distance = math.sqrt((x - mouse_x) ^ 2 + (y - mouse_y) ^ 2)
                if(distance < closest_distance)then
                    closest_distance = distance
                    closest_wand = v
                end
                ::continue::
            end

            if(closest_wand ~= nil)then
                if(data.last_inspected_wand_id ~= closest_wand)then
                    data.last_inspected_wand_id = closest_wand
                    data.last_inspected_wand = EZWand(closest_wand)
                else
                    local gui = GuiCreate()
                    GuiStartFrame(gui)
                    local x, y = EntityGetTransform(closest_wand)
                    local w_x, w_y = WorldToScreenPos(gui, x, y)
                    data.last_inspected_wand:RenderTooltip(w_x, w_y)
                    GuiDestroy(gui)
                end
            end


        end

    

        local spells = EntityGetWithTag("card_action")
        for k, card in ipairs(spells)do
            if(not EntityHasTag(card, "patched_unlimited"))then
                local root = EntityGetRootEntity(card)
                local changed = false
                if((GameHasFlagRun( "arena_unlimited_spells" ) and not EntityHasTag(root, "client")) or EntityHasTag(root, "unlimited_spells"))then
                    local item_action_comp = EntityGetFirstComponentIncludingDisabled(card, "ItemActionComponent")
                    if(item_action_comp ~= nil)then
                        local action_id = ComponentGetValue2(item_action_comp, "action_id")

                        local action_info = ArenaGameplay.GetActionInfo(action_id)

                        if(action_info and not action_info.never_unlimited)then

                            local ability_comp = EntityGetFirstComponentIncludingDisabled(card, "AbilityComponent")
                            if(ability_comp ~= nil)then
                                ComponentObjectSetValue2(ability_comp, "gunaction_config", "action_max_uses", -1)
                            end
                            local item_comp = EntityGetFirstComponentIncludingDisabled(card, "ItemComponent")
                            if(item_comp ~= nil)then
                                ComponentSetValue2(item_comp, "uses_remaining", -2)
                            end
                        end
                    end
                    local inventory2_comp = EntityGetFirstComponentIncludingDisabled( root, "Inventory2Component" )
                    if( inventory2_comp ) then
                        ComponentSetValue( inventory2_comp, "mActualActiveItem", "0" )
                    end
                    EntityAddTag(card, "patched_unlimited")
                end
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
        --[[for k, v in pairs(data.players) do
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
        end]]

        if (data.state == "lobby") then
            if(not data.spectator_mode)then
                local pickup = GlobalsGetValue("hm_item_pickup", "")
                if(pickup ~= "")then
                    networking.send.pick_hm_entity(lobby, pickup)
                    if(data.client.match_data_unpacked ~= nil)then
                        data.client.match_data_unpacked.floor_items = {}
                    end
                    GameAddFlagRun("should_save_player")
                    GlobalsSetValue("arena_item_pickup", "0")
                    GlobalsSetValue("hm_item_pickup", "")
                    
                end

                if(GameHasFlagRun("picked_up_new_heart"))then
                    GameRemoveFlagRun("picked_up_new_heart")

                    if(not steam_utils.IsOwner())then
                        networking.send.picked_heart(lobby, true)
                    else
                        steamutils.AddLobbyFlag(lobby, tostring(steam_utils.getSteamID()).."picked_heart")

                    end

                    if(data.client.match_data_unpacked ~= nil)then
                        data.client.match_data_unpacked.floor_items = {}
                    end

                    GameAddFlagRun("should_save_player")
    
                end
            end

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
    end,
    LateUpdate = function(lobby, data)

        if(GameHasFlagRun("super_secret_hamis_mode"))then
            SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() * 5435 % 1000 )
            if (data.state == "arena") then
                -- loop through other players
                for k, v in pairs(data.players) do
                    if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                        local sprite_comp = EntityGetFirstComponentIncludingDisabled(v.entity, "SpriteComponent", "character")
    
                        local animation = ComponentGetValue2(sprite_comp, "rect_animation")
    
                        local x, y = EntityGetTransform(v.entity)
    
                        v.last_damaged_targets = v.last_damaged_targets or {}
    
                        --print(animation)
    
                        if (animation == "attack") then
                            local targets = EntityGetInRadiusWithTag(x, y, 15, "mortal") or {}

                            local big_chomper = v.big_chomper



                            if(big_chomper)then
                                local controls_component = EntityGetFirstComponentIncludingDisabled(v.entity, "ControlsComponent")
                                local aim_x, aim_y = ComponentGetValue2(controls_component, "mAimingVectorNormalized")

                                local aim_length = math.sqrt(aim_x * aim_x + aim_y * aim_y)
                                if (aim_length > 0) then
                                    aim_x = aim_x / aim_length
                                    aim_y = aim_y / aim_length
                                end

                                if(not v.was_attack)then
                                    v.last_chomp = EntityLoad("mods/evaisa.arena/files/custom/perks/hamis/big_bite/chomp_entity.xml", x + aim_x * 20, y + aim_y * 20)
                                    GameShootProjectile(v.entity, x + aim_x * 20, y + aim_y * 20, x + aim_x * 1000, y + aim_y * 1000, v.last_chomp)
                                    v.last_chomp_x = aim_x
                                    v.last_chomp_y = aim_y
                                end
                                EntityApplyTransform(v.last_chomp, x + v.last_chomp_x * 20, y + v.last_chomp_y * 20)
                                targets = MergeTables(targets, EntityGetInRadiusWithTag(x + v.last_chomp_x * 20, y + v.last_chomp_y * 20, 25, "mortal") or {})
                            end

                            for k, targ in ipairs(targets) do
                                -- if target is not us
                                if (targ ~= v.entity) then
                                    --print("Attacking target!")
                                    --print(tostring(v.last_damaged_targets[targ]))
                                    --print(tostring(GameGetFrameNum()))

                                    local damage_mult = v.hamis_damage or 1


                                    if (v.last_damaged_targets[targ] == nil or GameGetFrameNum() > v.last_damaged_targets[targ] + 50) then
                                        print("Dealing damage to target!")
                                        EntityInflictDamage(targ, (Random(200, 400) / 1000) * damage_mult, "DAMAGE_BITE", "hämis", "BLOOD_EXPLOSION", 0, 0, v.entity, x, y, 200)

                                        local venom_count = tonumber(v.venom)

                                        for i = 1, venom_count do
                                            if(Random(0, 100) > 60)then
                                                EntityIngestMaterial( targ, CellFactory_GetType("poison"), 40 )
                                            end
                                        end

                                        v.last_damaged_targets[targ] = GameGetFrameNum()
                                    end
                                end
                            end

                            v.was_attack = true
                        else
                            v.was_attack = false
                        end
                        
                    end
                end
            end
        end

        if(data.force_open_inventory)then
            if(data.spectator_entity)then
                local inventoryGuiComp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "InventoryGuiComponent")
                if (inventoryGuiComp ~= nil) then
                    ComponentSetValue2(inventoryGuiComp, "mActive", true)
                    ComponentSetValue2(inventoryGuiComp, "mLastFrameActionsVisible", GameGetFrameNum())

                end
            end
            data.force_open_inventory = false
        end

        if(not GameHasFlagRun("arena_trailer_mode"))then
            if(data.state == "lobby")then
                if(not IsPaused() and not (data.spectator_mode and data.spectated_player == nil))then
                    ArenaGameplay.UpdateDummy(lobby, data)
                    for k, v in pairs(data.players) do
                        if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                            ArenaGameplay.DrawNametag(lobby, data, v.entity, lobby_member_names[k], 44)
                        end
                    end
                end
            else
                local player_entities = {}
                if(not IsPaused())then
                    for k, v in pairs(data.players) do
                        if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                            player_entities[k] = v.entity
                            
                            ArenaGameplay.DrawNametag(lobby, data, v.entity, lobby_member_names[k], 44)
                        end
                    end
                end
                if (not IsPaused() and (data.spectator_mode or (GameHasFlagRun("player_is_unlocked") and (not GameHasFlagRun("no_shooting"))))) then
                    --print("drawing markers!!")
                    game_funcs.RenderOffScreenMarkers(player_entities)
                    game_funcs.RenderAboveHeadMarkers(player_entities, 0, 37)
                    ArenaGameplay.UpdateHealthbars(data)
                end
            end
        end



        --data.controlled_entities
        if(not data.spectator_mode)then
            local first_update = {}
            local kicked_item_string = GlobalsGetValue("arena_items_controlled", "") or ""
            for item in string.gmatch(kicked_item_string, "([^;]+)") do
                local item_entity = tonumber(item) or 0
                local has_control = false
                for k, v in ipairs(data.controlled_entities)do
                    if(v == item_entity)then
                        has_control = true
                        break
                    end
                end
                if(EntityGetIsAlive(item_entity) and not first_update[item_entity] and not has_control)then
                    table.insert(data.controlled_entities, item_entity)
                    first_update[item_entity] = true
                    print("We took controls of item: "..tostring(item_entity))
                    local arena_entity_id = EntityHelper.GetVariable(item_entity, "arena_entity_id")

                    if(arena_entity_id ~= nil)then
                        --GamePrint("We took controls of item: "..tostring(item_entity))
                    end
                end
            end
            if(kicked_item_string ~= "")then
                GlobalsSetValue("arena_items_controlled", "")
            end

            for i = #data.controlled_entities, 1, -1 do
                local entity = data.controlled_entities[i]
                if(not EntityGetIsAlive(entity) or EntityGetRootEntity(entity) ~= entity)then
                    table.remove(data.controlled_entities, i)
                else
                    local arena_entity_id = EntityHelper.GetVariable(entity, "arena_entity_id")

                    if(arena_entity_id ~= nil)then
                        if(first_update[entity] and GameHasFlagRun("was_item_throw"))then
                            print("Item was thrown")
                            -- serialize entity 
                            local entity_data = np.SerializeEntity(entity)
                            if(data.state == "arena")then
                                networking.send.sync_entity(lobby, arena_entity_id, entity_data)
                            else
                                networking.send.sync_entity(lobby, arena_entity_id, entity_data, true)
                            end
                        end

                        local body_ids = PhysicsBodyIDGetFromEntity( entity )
                        if(body_ids ~= nil and #body_ids > 0)then
                            local body_id = body_ids[1]
                            local x, y, r, vel_x, vel_y, vel_a =  PhysicsBodyIDGetTransform( body_id )
                            
                            networking.send.physics_update(lobby, arena_entity_id, gameplay_handler.round_to_decimal(x, 2), gameplay_handler.round_to_decimal(y, 2), gameplay_handler.round_to_decimal(r, 2), gameplay_handler.round_to_decimal(vel_x, 2), gameplay_handler.round_to_decimal(vel_y, 2), gameplay_handler.round_to_decimal(vel_a, 2), first_update[entity], GameHasFlagRun("was_item_kick"))
                        else
                            -- if not physics body, update manually!!
                            local velocity_comp = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
                            local vel_x, vel_y = 0, 0
                            local x, y, r = EntityGetTransform(entity)

                            if(velocity_comp ~= nil)then
                                vel_x, vel_y = ComponentGetValue2(velocity_comp, "mVelocity")
                            end

                            networking.send.entity_update(lobby, arena_entity_id, gameplay_handler.round_to_decimal(x, 2), gameplay_handler.round_to_decimal(y, 2), gameplay_handler.round_to_decimal(r, 2), gameplay_handler.round_to_decimal(vel_x, 2), gameplay_handler.round_to_decimal(vel_y, 2), first_update[entity])
                        end
                    end
                end
            end
            GameRemoveFlagRun("was_item_kick")
            GameRemoveFlagRun("was_item_throw")

            local fungal_shift_from = GlobalsGetValue("arena_fungal_shift_from", "")
            local fungal_shift_to = GlobalsGetValue("arena_fungal_shift_to", "")
            if(fungal_shift_from ~= "" and fungal_shift_to ~= "")then
                local from_table = {}
                local to = fungal_shift_to

                for material in string.gmatch(fungal_shift_from, "([^;]+)") do
                    table.insert(from_table, material)
                end

                gameplay_handler.SaveShiftData(lobby, from_table, to)

                networking.send.fungal_shift(lobby, from_table, to)
            end
            GlobalsSetValue("arena_fungal_shift_from", "")
            GlobalsSetValue("arena_fungal_shift_to", "")

            --[[if(GameGetFrameNum() % 10 == 0)then
                networking.send.item_update(lobby, data, nil, true, true)
            end]]
            local player_entity = player.Get()


                

            if(player_entity)then
                local inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "InventoryGuiComponent")

                if(inventory_gui_comp ~= nil)then

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
                            networking.send.switch_item(lobby, data, nil, true, false)
                            GameAddFlagRun("should_save_player")
                        end
                        data.client.inventory_was_open = false
                    end

                    local items = GameGetAllInventoryItems(player_entity) or {}

                    last_edited_times = last_edited_times or {}
                    local was_wand = {}

                    for i, v in ipairs(items)do
                        local ability_comp = EntityGetFirstComponentIncludingDisabled(v, "AbilityComponent")
                        if(ability_comp)then
                            local edited_times = ComponentGetValue2(ability_comp, "stat_times_player_has_edited")

                            if(last_edited_times[v] ~= edited_times)then
                                networking.send.item_update(lobby, data, nil, true, false)
                                networking.send.switch_item(lobby, data, nil, true, false)
                            end

                            was_wand[v] = true
                            last_edited_times[v] = edited_times
                        end
                        local material_inventory_comp = EntityGetFirstComponentIncludingDisabled(v, "MaterialInventoryComponent")
                        if(material_inventory_comp)then
                            local last_frame_drank = ComponentGetValue2(material_inventory_comp, "last_frame_drank")
                            if(last_frame_drank == GameGetFrameNum())then
                                networking.send.item_update(lobby, data, nil, true, false)
                                networking.send.switch_item(lobby, data, nil, true, false)
                            end
                        end
                    end

                    for k, v in pairs(last_edited_times)do
                        if(not was_wand[k])then
                            last_edited_times[k] = nil
                        end
                    end
                end
            end
            if(GlobalsGetValue("arena_item_pickup", "0") ~= "0")then
                networking.send.item_picked_up(lobby, tonumber(GlobalsGetValue("arena_item_pickup", "0")))
                GameAddFlagRun("should_save_player")
                GlobalsSetValue("arena_item_pickup", "0")
                if(data.client.match_data_unpacked ~= nil)then
                    data.client.match_data_unpacked.floor_items = {}
                end
            end
            
            if (data.state == "arena") then
                ArenaGameplay.KillCheck(lobby, data)
            end


        
            local current_inventory_info = player.GetInventoryInfo()

            no_switching = no_switching or 0

            if(data.client.last_inventory == nil or player.DidInventoryChange(data.client.last_inventory, current_inventory_info))then
            -- GamePrint("Inventory has changed!")
                GameAddFlagRun("ForceUpdateInventory")
                no_switching = 3
                data.client.last_inventory = current_inventory_info
                GameAddFlagRun("should_save_player")
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

                local inventory_2_comp = EntityGetFirstComponentIncludingDisabled(player_entity, "Inventory2Component")
                if inventory_2_comp ~= nil then
                    local mLastItemSwitchFrame = ComponentGetValue2(inventory_2_comp, "mLastItemSwitchFrame")
                    if (mLastItemSwitchFrame == GameGetFrameNum()) then
                        if (data.state == "arena") then
                            networking.send.switch_item(lobby, data)
                        else
                            networking.send.switch_item(lobby, data, nil, false, true)
                        end
                    end
                end
            end


            
            local current_player = player.Get()

            local projectiles_fired = tonumber(GlobalsGetValue( "wand_fire_count", "0" ))

            if (projectiles_fired > 0--[[data.client.projectiles_fired ~= nil and data.client.projectiles_fired > 0]]) then

                --[[local controls_comp = EntityGetFirstComponentIncludingDisabled(current_player, "ControlsComponent")
            
                if(controls_comp)then
                    local change_item_r = ComponentGetValue2(controls_comp, "mButtonDownChangeItemR")
                    local change_item_l = ComponentGetValue2(controls_comp, "mButtonDownChangeItemL")
                    local change_frame_r = ComponentGetValue2(controls_comp, "mButtonFrameChangeItemR")
                    local change_frame_l = ComponentGetValue2(controls_comp, "mButtonFrameChangeItemL")


                    print("Fire wand! "..tostring(projectiles_fired))
                    print("Change item r: "..tostring(change_item_r))
                    print("Change item l: "..tostring(change_item_l))
                    print("Change frame r: "..tostring(change_frame_r))
                    print("Change frame l: "..tostring(change_frame_l))]]

                    local special_seed = tonumber(GlobalsGetValue("player_rng", "0"))
                    -- only allow fire if not switching items
                    --if(not (change_item_r or change_item_l))then
    
                        if(data.state == "arena")then
                            networking.send.fire_wand(lobby, data.client.projectile_rng_stack, special_seed)
                        else
                            networking.send.fire_wand(lobby, data.client.projectile_rng_stack, special_seed, true)
                        end

                    --end
                    GlobalsSetValue("wand_fire_count", "0")
                    data.client.projectile_rng_stack = {}
                --end
        
            end


            if(data.state == "lobby" and current_player ~= nil and GameGetFrameNum() % 120 == 0 and not data.preparing)then
                GameAddFlagRun("should_save_player")
            end

            if ((not GameHasFlagRun("player_unloaded")) and current_player == nil and not data.preparing) then
                ArenaGameplay.LoadPlayer(lobby, data)
                arena_log:print("Player is missing, spawning player.")
            else
                if (GameHasFlagRun("should_save_player") and GameHasFlagRun("can_save_player")) then
                    --print("Saving player data")
                    ArenaGameplay.SavePlayerData(lobby, data)
                    GameRemoveFlagRun("should_save_player")
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

            if(GameHasFlagRun("prepared_damage") and not GameHasFlagRun("finished_damage"))then
                -- damage was blocked
                print("Damage was blocked, sending update")
                networking.send.health_update(lobby, data, true)
                GameRemoveFlagRun("prepared_damage")
            end
        end

        if (GameGetFrameNum() % 5 == 0) then
            -- if we are host
            if (steam_utils.IsOwner()) then
                ArenaGameplay.SendGameData(lobby, data)
            end
        end

        --[[for k, v in pairs(data.players) do
            if (v.entity ~= nil and EntityGetIsAlive(v.entity)) then
                local characterData = EntityGetFirstComponentIncludingDisabled(v.entity, "CharacterDataComponent")

                if (characterData and v.last_velocity) then
                    ComponentSetValue2(characterData, "mVelocity", v.last_velocity.x or 0, v.last_velocity.y or 0)
                end

            end
        end]]

        --[[
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
        ]]

        local current_player = player.Get()

        if (data.spectator_mode or ((not GameHasFlagRun("player_unloaded")) and current_player ~= nil and EntityGetIsAlive(current_player))) then
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
        
        --local is_physics = #(PhysicsBodyIDGetFromEntity(projectile_id) or {}) > 0

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
                local rng = math.floor(rand + position_x + position_y + projectile_id)

                table.insert(data.client.projectile_rng_stack, rng)

                --GamePrint("Setting spread rng: "..tostring(rng))

                np.SetProjectileSpreadRNG(rng)
                
                

                --[[if(is_physics)then
                    EntityHelper.NetworkRegister(projectile_id, position_x, position_y, rng)
                    table.insert(data.controlled_entities, projectile_id)
                end]]
                --data.client.spread_index = data.client.spread_index + 1

                --[[if(data.client.spread_index > 10)then
                    data.client.spread_index = 1
                end]]
            else
                if (data.projectile_seeds[entity_that_shot]) then
                    local new_seed = data.projectile_seeds[entity_that_shot] + 25
                    np.SetProjectileSpreadRNG(new_seed)
                    --[[if(is_physics)then
                        EntityHelper.NetworkRegister(projectile_id, position_x, position_y, new_seed)
                        table.insert(data.controlled_entities, projectile_id)
                    end]]
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
                    --[[if(is_physics)then
                        EntityHelper.NetworkRegister(projectile_id, position_x, position_y, rng)
                        table.insert(data.controlled_entities, projectile_id)
                    end]]

                    data.players[EntityGetName(shooter_id)].next_rng = rng + 1
                else
                    if (data.projectile_seeds[entity_that_shot]) then
                        local new_seed = data.projectile_seeds[entity_that_shot] + 25
                        np.SetProjectileSpreadRNG(new_seed)
                        --[[if(is_physics)then
                            EntityHelper.NetworkRegister(projectile_id, position_x, position_y, new_seed)
                            table.insert(data.controlled_entities, projectile_id)
                        end]]
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
                        --math.randomseed( tonumber(tostring(steam_utils.getSteamID())) + ((os.time() + GameGetFrameNum()) / 2))
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
        
        local homing_mult = tonumber(GlobalsGetValue("homing_mult", "100")) or 100

        local homingComponents = EntityGetComponentIncludingDisabled(projectile_id, "HomingComponent")

        if (homingComponents ~= nil) then
            for k, v in pairs(homingComponents) do
                local target_who_shot = ComponentGetValue2(v, "target_who_shot")
                
                if (target_who_shot == false) then
                    local homing_target = ComponentGetValue2(v, "target_tag")
                    if(homing_target == "prey")then
                        ComponentSetValue2(v, "target_tag", "enemy")
                    end

                    if(math.ceil(homing_mult) < 100)then
                        local coeff = ComponentGetValue2(v, "homing_targeting_coeff")
                        local velocity_mult = ComponentGetValue2(v, "homing_velocity_multiplier")
                        local max_turn_rate = ComponentGetValue2(v, "max_turn_rate")
                        local detect_distance = ComponentGetValue2(v, "detect_distance")
                        coeff = coeff * (homing_mult / 100)
                        max_turn_rate = max_turn_rate * (homing_mult / 100)
                        detect_distance = detect_distance * (homing_mult / 100)
                        local velocity_mult_diff = 1 - velocity_mult

                        velocity_mult = velocity_mult + (velocity_mult_diff * (1 - (homing_mult / 100)))

                        ComponentSetValue2(v, "homing_targeting_coeff", coeff)
                        ComponentSetValue2(v, "homing_velocity_multiplier", velocity_mult)
                        ComponentSetValue2(v, "max_turn_rate", max_turn_rate)
                        ComponentSetValue2(v, "detect_distance", detect_distance)
                    end
                elseif(GameHasFlagRun("homing_mult_self"))then
                    if(math.ceil(homing_mult) < 100)then
                        local coeff = ComponentGetValue2(v, "homing_targeting_coeff")
                        local velocity_mult = ComponentGetValue2(v, "homing_velocity_multiplier")
                        local max_turn_rate = ComponentGetValue2(v, "max_turn_rate")
                        local detect_distance = ComponentGetValue2(v, "detect_distance")
                        coeff = coeff * (homing_mult / 100)
                        max_turn_rate = max_turn_rate * (homing_mult / 100)
                        detect_distance = detect_distance * (homing_mult / 100)
                        local velocity_mult_diff = 1 - velocity_mult

                        velocity_mult = velocity_mult + (velocity_mult_diff * (1 - (homing_mult / 100)))

                        ComponentSetValue2(v, "homing_targeting_coeff", coeff)
                        ComponentSetValue2(v, "homing_velocity_multiplier", velocity_mult)
                        ComponentSetValue2(v, "max_turn_rate", max_turn_rate)
                        ComponentSetValue2(v, "detect_distance", detect_distance)
                    end
                end
            end
        end
    end,
}

return ArenaGameplay
