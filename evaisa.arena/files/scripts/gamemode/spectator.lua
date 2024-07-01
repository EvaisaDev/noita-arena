SpectatorMode = {
    UpdateSpectatorEntity = function(lobby, data)
        if(data.spectator_entity == nil or not EntityGetIsAlive(data.spectator_entity))then
            data.spectator_entity = EntityLoad("mods/evaisa.arena/files/entities/spectator_entity.xml", 0, 0)
            np.RegisterPlayerEntityId(data.spectator_entity)
        end
        
        if(data.spectator_entity)then
            local camera_x, camera_y = GameGetCameraPos()
            --EntitySetTransform(data.spectator_entity, camera_x, camera_y)
            EntityApplyTransform(data.spectator_entity, camera_x, camera_y)
        end
    end,
    SpectatorText = function(lobby, data)

        --[[if (data.spectator_gui_entity == nil or not EntityGetIsAlive(data.spectator_gui_entity)) then
            data.spectator_gui_entity = EntityLoad("mods/evaisa.arena/files/entities/misc/spectator_text.xml")

            EntitySetTransform(data.spectator_gui_entity, 0, 0, 0, 0.25, 0.25)
        end]]

        if (data.spectator_text_gui == nil) then
            data.spectator_text_gui = GuiCreate()
        end


        local text = GameTextGetTranslatedOrNot("$arena_spectating_text")

        if (data.selected_player_name ~= nil) then
            text = string.format(text, data.selected_player_name)
        else
            text = string.format(text, "")
        end

        local language = GameTextGetTranslatedOrNot("$current_language")

        local font = data.spectator_fonts[language] or data.spectator_fonts["unknown"]

        if(font.upper)then
            text = utf8.upper(text)
        end

        --print(text)

        local font_width, font_height = GuiGetTextDimensions(data.spectator_text_gui, text, font.size, nil, font.font, not font.smooth)

        GuiStartFrame(data.spectator_text_gui)
        
        local screen_text_width, screen_text_height = GuiGetScreenDimensions(data.spectator_text_gui)

        local text_x = screen_text_width / 2 - font_width / 2
        local text_y = 2

        GuiText(data.spectator_text_gui, text_x, text_y, text, font.size, font.font, not font.smooth)

    end,
    HandleSpectatorSync = function(lobby, data)
        if(data.spectated_player == nil)then
            --print("No spectated player")
            return
        end
        local player = data.players[tostring(data.spectated_player)]
        if(player == nil)then
            --print("No player")
            return
        end

        if(GameGetFrameNum() % 30 == 0 and player.entity and EntityGetIsAlive(player.entity) and data.spectator_entity and EntityGetIsAlive(data.spectator_entity))then
            -- We will sync wand stats and stuff.
            local inventory2_comp = EntityGetFirstComponentIncludingDisabled(player.entity, "Inventory2Component")
            local spectator_inventory2_comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "Inventory2Component")
            local inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(player.entity, "InventoryGuiComponent")
            local spectator_inventory_gui_comp = EntityGetFirstComponentIncludingDisabled(data.spectator_entity, "InventoryGuiComponent")

            local active_item = ComponentGetValue2(inventory2_comp, "mActiveItem")
            local active_item2 = ComponentGetValue2(spectator_inventory2_comp, "mActiveItem")

            local mFrameShake_reloadBar = ComponentGetValue2(inventory_gui_comp, "mFrameShake_reloadBar")
            local mFrameShake_ManaBar = ComponentGetValue2(inventory_gui_comp, "mFrameShake_ManaBar")
            local mFrameShake_FlyBar = ComponentGetValue2(inventory_gui_comp, "mFrameShake_FlyBar")
            local mFrameShake_FireRateWaitBar = ComponentGetValue2(inventory_gui_comp, "mFrameShake_FireRateWaitBar")

            -- set values
            ComponentSetValue2(spectator_inventory_gui_comp, "mFrameShake_reloadBar", mFrameShake_reloadBar)
            ComponentSetValue2(spectator_inventory_gui_comp, "mFrameShake_ManaBar", mFrameShake_ManaBar)
            ComponentSetValue2(spectator_inventory_gui_comp, "mFrameShake_FlyBar", mFrameShake_FlyBar)
            ComponentSetValue2(spectator_inventory_gui_comp, "mFrameShake_FireRateWaitBar", mFrameShake_FireRateWaitBar)

            if(active_item and active_item2)then

                -- if has ability component
                local abilityComp = EntityGetFirstComponentIncludingDisabled(active_item, "AbilityComponent")
                local abilityComp2 = EntityGetFirstComponentIncludingDisabled(active_item2, "AbilityComponent")
                if (abilityComp and abilityComp2) then
                    -- get current mana
                    local mana = ComponentGetValue2(abilityComp, "mana")
                    -- mCastDelayStartFrame
                    local cast_delay_start_frame = ComponentGetValue2(abilityComp, "mCastDelayStartFrame")
                    -- mReloadFramesLeft
                    local reload_frames_left = ComponentGetValue2(abilityComp, "mReloadFramesLeft")
                    -- mReloadNextFrameUsable
                    local reload_next_frame_usable = ComponentGetValue2(abilityComp, "mReloadNextFrameUsable")
                    -- mNextChargeFramemNextChargeFrame
                    local next_charge_frame = ComponentGetValue2(abilityComp, "mNextChargeFrame")
                    -- cooldown_frames
                    local cooldown_frames = ComponentGetValue2(abilityComp, "cooldown_frames")
                    -- charge_wait_frames
                    local charge_wait_frames = ComponentGetValue2(abilityComp, "charge_wait_frames")

                    -- set values
                    ComponentSetValue2(abilityComp2, "mana", mana)
                    ComponentSetValue2(abilityComp2, "mCastDelayStartFrame", cast_delay_start_frame)
                    ComponentSetValue2(abilityComp2, "mReloadFramesLeft", reload_frames_left)
                    ComponentSetValue2(abilityComp2, "mReloadNextFrameUsable", reload_next_frame_usable)
                    ComponentSetValue2(abilityComp2, "mNextChargeFrame", next_charge_frame)
                    ComponentSetValue2(abilityComp2, "cooldown_frames", cooldown_frames)
                    ComponentSetValue2(abilityComp2, "charge_wait_frames", charge_wait_frames)

                    
                end
            end

            local perk_data = player.perks
            local perk_string = bitser.dumps(player.perks)

   
            -- ahh need to clear this when switching scene duhh
            if(data.last_selected_perk_string ~= perk_string)then
                local children = EntityGetChildrenWithTag(data.spectator_entity, "perk") or {}

                for i, child in ipairs(children) do
                    EntityRemoveFromParent(child)
                    EntityKill(child)
                end
    
                for i, perk in ipairs(perk_data) do
                    local perk_id = perk[1]
                    local perk_stack = perk[2]
    
                    local perk_info = all_perks[perk_id]
    
                    
    
                    if(perk_info ~= nil)then
                        
                        for i = 1, perk_stack do
                            local child = EntityCreateNew()
                            EntityAddTag(child, "perk")
                            EntityAddChild(data.spectator_entity, child)
    
                            --print("Adding perk: " .. tostring(perk_info.ui_name))
                            local perk_comp = EntityAddComponent2(child, "UIIconComponent", {
                                icon_sprite_file = perk_info.ui_icon,
                                name = perk_info.ui_name,
                                description = perk_info.ui_description,
                                display_in_hud = true,
                                is_perk = true
                            })
    
                            ComponentAddTag(perk_comp, "perk")
                        end
                    end
                end    
            end

            data.last_selected_perk_string = perk_string

            --[[
            local effects = {}
            local effect_names = {}

            local children = EntityGetAllChildren(player.entity) or {}

            for i, child in ipairs(children) do
                local ui_icon_comp = EntityGetFirstComponentIncludingDisabled(child, "UIIconComponent")
                if(ui_icon_comp ~= nil)then
                    local is_perk = ComponentGetValue2(ui_icon_comp, "is_perk")
                    if(not is_perk)then
                        local icon_sprite_file = ComponentGetValue2(ui_icon_comp, "icon_sprite_file")
                        local name = ComponentGetValue2(ui_icon_comp, "name")
                        local description = ComponentGetValue2(ui_icon_comp, "description")
                        table.insert(effects, {icon_sprite_file, name, description})
                        table.insert(effect_names, name)
                    end
                end
            end

            effect_string = table.concat(effect_names, ",")

            data.last_effect_string = data.last_effect_string or ""

            if(data.last_effect_string ~= effect_string)then
                local children = EntityGetChildrenWithTag(data.spectator_entity, "effect") or {}

                for i, child in ipairs(children) do
                    EntityRemoveFromParent(child)
                    EntityKill(child)
                end

                for i, effect in ipairs(effects) do
                    local icon_sprite_file = effect[1]
                    local name = effect[2]
                    local description = effect[3]

                    local child = EntityCreateNew()
                    EntityAddTag(child, "effect")
                    EntityAddChild(data.spectator_entity, child)

                    local effect_comp = EntityAddComponent2(child, "UIIconComponent", {
                        icon_sprite_file = icon_sprite_file,
                        name = name,
                        description = description,
                        display_in_hud = true,
                        is_perk = false
                    })

                    ComponentAddTag(effect_comp, "effect")
                end
            end

            data.last_effect_string = effect_string

            ]]



        end
    end,
    SpectateUpdate = function(lobby, data)
        if (data.is_spectating and not GameHasFlagRun("arena_trailer_mode")) then

            SpectatorMode.SpectatorText(lobby, data)

            if (data.spectator_gui == nil) then
                data.spectator_gui = GuiCreate()
            end

            local camera_x, camera_y = GameGetCameraPos()

            GuiStartFrame(data.spectator_gui)

            --GuiOptionsAdd(data.spectator_gui, GUI_OPTION.NonInteractive)
            --GuiOptionsAdd(data.spectator_gui, GUI_OPTION.NoPositionTween)

            local id = 39582
            local function new_id()
                id = id + 1
                return id
            end

            local screen_width, screen_height = GuiGetScreenDimensions(data.spectator_gui)

            --[[if(data.last_selected_player ~= nil and data.players[tostring(data.last_selected_player)] ~= nil and data.spectated_player == nil)then
                if(data.players[tostring(data.last_selected_player)].entity ~= nil and EntityGetIsAlive(data.players[tostring(data.last_selected_player)].entity))then
                    data.selected_player = data.players[tostring(data.last_selected_player)].entity
                    data.spectated_player = data.last_selected_player
                    data.selected_player_name = steamutils.getTranslatedPersonaName(data.last_selected_player)
                    data.last_selected_player = nil
                end
            else
                data.last_selected_player = nil
            end]]

            --GamePrint("Spectator mode")

            if(data.spectated_player ~= nil and data.players[tostring(data.spectated_player)] ~= nil and EntityGetIsAlive(data.players[tostring(data.spectated_player)].entity))then
                data.selected_player = data.players[tostring(data.spectated_player)].entity
                data.selected_player_name = steamutils.getTranslatedPersonaName(data.spectated_player)
            end

            if (data.selected_player ~= nil) then
                local client_entity = data.selected_player
                if (client_entity ~= nil and EntityGetIsAlive(client_entity)) then
                    local x, y = EntityGetTransform(client_entity)

                    if (x ~= nil and y ~= nil) then
                        -- camera smoothing
                        local camera_speed = 0.1

                        local camera_x_diff = x - camera_x
                        local camera_y_diff = y - camera_y
                        local camera_x_new = camera_x + camera_x_diff * camera_speed
                        local camera_y_new = camera_y + camera_y_diff * camera_speed
                        GameSetCameraPos(camera_x_new, camera_y_new)
                    end
                end
            end

            local keys_pressed = {
                w = bindings:IsJustDown("arena_spectator_up"),
                a = bindings:IsJustDown("arena_spectator_left"),
                s = bindings:IsJustDown("arena_spectator_down"),
                d = bindings:IsJustDown("arena_spectator_right"),
                q = bindings:IsJustDown("arena_spectator_switch_left"),
                e = bindings:IsJustDown("arena_spectator_switch_right"),
                space = bindings:IsJustDown("arena_spectator_quick_switch"),
            }
    
            local keys_down = {
                w = bindings:IsDown("arena_spectator_up"),
                a = bindings:IsDown("arena_spectator_left"),
                s = bindings:IsDown("arena_spectator_down"),
                d = bindings:IsDown("arena_spectator_right"),
                switch = bindings:IsDown("arena_spectator_quick_switch"),
                fast_move = bindings:IsDown("arena_spectator_fast_move"),
            }

            local stick_x, stick_y = bindings:GetAxis("arena_spectator_move_joy")--input:GetGamepadAxis("left_stick")
            local r_stick_x, r_stick_y = bindings:GetAxis("arena_spectator_switch_stick_joy")
            local left_trigger = bindings:GetAxis("arena_spectator_quick_switch_joy")
            local right_trigger = bindings:GetAxis("arena_spectator_quick_switch_joy")
            local fast_move = bindings:GetAxis("arena_spectator_fast_move_joy")

            local left_bumper = bindings:IsJustDown("arena_spectator_switch_left_joy")
            local right_bumper = bindings:IsJustDown("arena_spectator_switch_right_joy")

            local right_trigger_pressed = right_trigger >= 0.5 and data.spectator_quick_switch_trigger < 0.5
            
            data.spectator_quick_switch_trigger = right_trigger

            if (not GameHasFlagRun("chat_input_hovered")) then

                local camera_speed = 2
                local movement_x = (stick_x * (camera_speed * (1 + (fast_move * 5))))
                local movement_y = (stick_y * (camera_speed * (1 + (fast_move * 5))))
    
                local movement_x2 = ((keys_down.a and -1 or 0) + (keys_down.d and 1 or 0)) * (camera_speed * (1 + (keys_down.fast_move and 5 or 0)))
                local movement_y2 = ((keys_down.w and -1 or 0) + (keys_down.s and 1 or 0)) * (camera_speed * (1 + (keys_down.fast_move and 5 or 0)))
    
                local stick_average = ((stick_x + stick_y) / 2)
    
                if(stick_average >= 0.1 or stick_average <= -0.1)then
                    --arena_log:print("x_move: "..tostring(movement_x)..", y_move: "..tostring(movement_y))
                    GameSetCameraPos(camera_x + movement_x, camera_y + movement_y)
                end
    
                if(movement_x2 ~= 0 or movement_y2 ~= 0)then
                    GameSetCameraPos(camera_x + movement_x2, camera_y + movement_y2)
                end

                if (keys_pressed.w or keys_pressed.a or keys_pressed.s or keys_pressed.d or stick_average >= 0.1 or stick_average <= -0.1) then
                    data.selected_player = nil
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, false)
                    end
                    data.spectated_player = nil
                    data.selected_player_name = nil
                    
                    if(data.spectator_entity ~= nil)then
                        GameDestroyInventoryItems(data.spectator_entity)
                    end
                end

                if (keys_pressed.q or left_bumper) then
                    -- GamePrint("Q pressed")
                    local players = ArenaGameplay.GetAlivePlayers(lobby, data)
                    local player_count = #players
                    if (player_count > 0) then
                        local selected_index = 1
                        if (data.selected_player ~= nil) then
                            for k, v in ipairs(players) do
                                if (v.entity == data.selected_player) then
                                    selected_index = k
                                    break
                                end
                            end
                        end
                        selected_index = selected_index - 1
                        if (selected_index < 1) then
                            selected_index = player_count
                        end
                        data.selected_player = players[selected_index].entity
                        arena_log:print("Spectating player: " .. EntityGetName(data.selected_player))

                        local player = ArenaGameplay.FindUser(lobby, EntityGetName(data.selected_player))

                        data.selected_player_name = "Unknown Player"
                        if (player ~= nil) then
                            data.selected_player_name = steamutils.getTranslatedPersonaName(player)
                            
                            if(data.spectated_player)then
                                networking.send.is_spectating(data.spectated_player, false)
                            end

                            data.spectated_player = player

                            if(data.spectated_player)then
                                networking.send.is_spectating(data.spectated_player, true)
                            end

                            data.spectator_active_player = player

                            networking.send.request_item_update(lobby, player)
                            networking.send.request_character_position(lobby, player)
                            networking.send.request_dummy_target(lobby, player)
                            networking.send.request_card_list(lobby, user)
                        end
                    end
                end

                if (keys_pressed.e or right_bumper) then
                    -- GamePrint("E pressed")
                    local players = ArenaGameplay.GetAlivePlayers(lobby, data)
                    local player_count = #players
                    if (player_count > 0) then
                        local selected_index = 1
                        if (data.selected_player ~= nil) then
                            for k, v in ipairs(players) do
                                if (v.entity == data.selected_player) then
                                    selected_index = k
                                    break
                                end
                            end
                        end
                        selected_index = selected_index + 1
                        if (selected_index > player_count) then
                            selected_index = 1
                        end
                        data.selected_player = players[selected_index].entity
                        arena_log:print("Spectating player: " .. EntityGetName(data.selected_player))

                        local player = ArenaGameplay.FindUser(lobby, EntityGetName(data.selected_player))

                        data.selected_player_name = "Unknown Player"
                        if (player ~= nil) then
                            data.selected_player_name = steamutils.getTranslatedPersonaName(player)
                            
                            if(data.spectated_player)then
                                networking.send.is_spectating(data.spectated_player, false)
                            end
                            
                            data.spectated_player = player

                            if(data.spectated_player)then
                                networking.send.is_spectating(data.spectated_player, true)
                            end

                            data.spectator_active_player = player

                            networking.send.request_item_update(lobby, player)
                            networking.send.request_character_position(lobby, player)
                            networking.send.request_dummy_target(lobby, player)
                            networking.send.request_card_list(lobby, user)
                        end
                    end
                end

                if(keys_down.switch or left_trigger > 0.5)then
                    local circle_image = "mods/evaisa.arena/files/sprites/ui/spectator/circle_selection-2.png"
                    --local inner_circle_image = "mods/evaisa.arena/files/sprites/ui/spectator/circle_selection_inner.png"
                    local circle_width, circle_height = GuiGetImageDimensions(data.spectator_gui, circle_image)
                    local circle_x = screen_width / 2 - circle_width / 2
                    local circle_y = screen_height / 2 - circle_height / 2
                    GuiImage(data.spectator_gui, new_id(), circle_x, circle_y, circle_image, 0.2, 1, 1)
                    --GuiImage(data.spectator_gui, new_id(), circle_x, circle_y, inner_circle_image, 0.4, 1, 1)

                    local marker_distance_from_center = 16

                    local camera_x, camera_y = GameGetCameraPos()
                    local mouse_x, mouse_y = DEBUG_GetMouseWorld()
                    
                    -- get mouse direction
                    local x_diff = mouse_x - camera_x
                    local y_diff = mouse_y - camera_y
                    local dist = math.sqrt(x_diff * x_diff + y_diff * y_diff)
                    local aim_x, aim_y = x_diff / dist, y_diff / dist

                    if(GameGetIsGamepadConnected())then
                        aim_x = r_stick_x
                        aim_y = r_stick_y
                    end
                    
                    local player_marker = "mods/evaisa.arena/files/sprites/ui/spectator/marker-2.png"
                    local selected_player_marker = "mods/evaisa.arena/files/sprites/ui/spectator/marker-selected.png"
                    local players = ArenaGameplay.GetAlivePlayers(lobby, data)
                    local player_count = #players
                    if (player_count > 0) then
                        local closest_player = nil
                        local highest_dot_product = -1
                        local selected_marker_x = nil
                        local selected_marker_y = nil
                        for k, v in ipairs(players) do
                            if(v.entity ~= data.selected_player)then
                                local x, y = EntityGetTransform(v.entity)
                                if (x ~= nil and y ~= nil) then
                                    local x_diff = x - camera_x
                                    local y_diff = y - camera_y
                                    local dist = math.sqrt(x_diff * x_diff + y_diff * y_diff)
                                    local to_player_x, to_player_y = x_diff / dist, y_diff / dist
                        
                                    local dot_product = aim_x * to_player_x + aim_y * to_player_y
                        
                                    local angle = math.atan2(y_diff, x_diff)
                                    local marker_x = screen_width / 2 + math.cos(angle) * marker_distance_from_center
                                    local marker_y = screen_height / 2 + math.sin(angle) * marker_distance_from_center
                                    GuiImage(data.spectator_gui, new_id(), marker_x - 3.5, marker_y - 3.5, player_marker, 0.8, 1, 1)
                        
                                    if dot_product > highest_dot_product then
                                        highest_dot_product = dot_product
                                        closest_player = v
                                        selected_marker_x = marker_x
                                        selected_marker_y = marker_y
                                    end


                                end
                            end
                        end
                        
                        if(closest_player ~= nil)  then
                            GuiImage(data.spectator_gui, new_id(), selected_marker_x - 3.5, selected_marker_y - 3.5, selected_player_marker, 0.8, 1, 1)
                            if(input:WasMousePressed("left") or right_trigger_pressed)then
                                data.selected_player = closest_player.entity
                                arena_log:print("Spectating player: " .. EntityGetName(data.selected_player))

                                local player = ArenaGameplay.FindUser(lobby, EntityGetName(data.selected_player))

                                data.selected_player_name = "Unknown Player"
                                if (player ~= nil) then
                                    data.selected_player_name = steamutils.getTranslatedPersonaName(player)
                                    
                                    if(data.spectated_player)then
                                        networking.send.is_spectating(data.spectated_player, false)
                                    end
                                    
                                    data.spectated_player = player

                                    if(data.spectated_player)then
                                        networking.send.is_spectating(data.spectated_player, true)
                                    end

                                    data.spectator_active_player = player

                                    networking.send.request_item_update(lobby, player)
                                    networking.send.request_character_position(lobby, player)
                                    networking.send.request_dummy_target(lobby, player)
                                    networking.send.request_card_list(lobby, user)
                                end
                            end
                        end
                        
                    end
                end
            end

        end
    end,
    SpawnSpectatedPlayer = function(lobby, data)
        if(data.spectated_player ~= nil)then
  
            if(data.players[tostring(data.spectated_player)] == nil)then
                return
            end
            if (data.spectated_player ~= steam_utils.getSteamID() and (data.players[tostring(data.spectated_player)].entity == nil or not EntityGetIsAlive(data.players[tostring(data.spectated_player)].entity))) then

                --GamePrint("Loading player " .. tostring(member.id))
                ArenaGameplay.SpawnClientPlayer(lobby, data.spectated_player, data, 0, 0)

                --[[delay.new(5, function()

                    networking.send.request_item_update(lobby, data.spectated_player)
                    networking.send.request_spectate_data(lobby, data.spectated_player)
                    networking.send.request_sync_hm(lobby, data.spectated_player)
                    networking.send.request_second_row(lobby, data.spectated_player)
                    networking.send.request_skin(lobby, data.spectated_player)
                    networking.send.request_perk_update(lobby)
                end)]]
            end
        end
    end,
    ClearHM = function()
         
        local entities = EntityGetInRadius(0, 0, 1000000)
    
        local illegal_clear_tags = {
            "spectator_no_clear",
            "workshop_spell_visualizer",
            "workshop_aabb",
            "world_state",
            "coop_respawn"
        }

        for k, v in ipairs(entities)do
            local valid = true
            for k2, v2 in ipairs(illegal_clear_tags)do
                if(EntityHasTag(v, v2))then
                    valid = false
                    break
                end
            end

            if(valid and v == EntityGetRootEntity(v))then
                local comps = EntityGetAllComponents(v)

                for k2, v2 in ipairs(comps)do
                    local type = ComponentGetTypeName(v2)
                    if(type ~= "GameEffectComponent")then
                        EntitySetComponentIsEnabled(v, v2, false)
                    else
                        ComponentSetValue2(v2, "mIsExtension", true)
                    end
                end

                local material_storage = EntityGetFirstComponentIncludingDisabled(v, "MaterialInventoryComponent")
                if(material_storage ~= nil)then
                    EntityRemoveComponent(v, material_storage)
                end
                EntityKill(v)
            end
        end
    end,
    LobbySpectateUpdate = function(lobby, data)
        local members = steamutils.getLobbyMembers(lobby)
        local spectated_player = data.spectated_player

        -- check if spectated player is still in the lobby
        local found = false
        for k, v in ipairs(members)do
            if(v.id == spectated_player)then
                found = true
                break
            end
        end

        if(not found)then
            if(data.spectated_player)then
                networking.send.is_spectating(data.spectated_player, false)
            end
            data.spectated_player = nil
            data.selected_player_name = nil
            data.spectator_active_player = nil
        end


        if(spectated_player == nil and members ~= nil and #members > 0)then
            if(data.spectated_player)then
                networking.send.is_spectating(data.spectated_player, false)
            end
            data.spectated_player = members[1].id
            if(data.spectated_player)then
                networking.send.is_spectating(data.spectated_player, true)
            end
            data.selected_player_name = steamutils.getTranslatedPersonaName(data.spectated_player)
            data.spectator_lobby_loaded = false

            --delay.new(5, function()
                data.last_hm_switch = data.last_hm_switch or 1
                if(GameGetFrameNum() - data.last_hm_switch < 30)then
                    return
                end

                data.last_hm_switch = GameGetFrameNum()

                local spectated_player = data.spectated_player
                data.last_hm_sync = nil

                if(spectated_player ~= nil and members ~= nil and #members > 0)then
                    local index = 1
                    for k, v in ipairs(members)do
                        if(v.id == spectated_player)then
                            index = k
                            break
                        end
                    end

                    index = index - 1

                    if(index < 1)then
                        index = #members
                    end

                    for k, v in ipairs(EntityGetWithTag("client") or {})do
                        EntityKill(v)
                    end
    
                    SpectatorMode.ClearHM()
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, false)
                    end
                    data.spectated_player = members[index].id
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, true)
                    end
                    data.spectator_active_player = members[index].id
                    data.selected_player_name = steamutils.getTranslatedPersonaName(data.spectated_player)
                    data.spectator_lobby_loaded = false
                    data.selected_player = nil
                end
            --end)
            
        end

        for k, v in pairs(data.players)do
            if(k ~= tostring(data.spectated_player))then
                v:Destroy()
            end
        end

        local camera_x, camera_y = GameGetCameraPos()

        if ( data.selected_player ~= nil) then
            local client_entity = data.selected_player
            if (client_entity ~= nil and EntityGetIsAlive(client_entity)) then
                local x, y = EntityGetTransform(client_entity)

                if (x ~= nil and y ~= nil) then
                    -- camera smoothing
                    local camera_speed = 0.1

                    local camera_x_diff = x - camera_x
                    local camera_y_diff = y - camera_y
                    local camera_x_new = camera_x + camera_x_diff * camera_speed
                    local camera_y_new = camera_y + camera_y_diff * camera_speed
                    GameSetCameraPos(camera_x_new, camera_y_new)
                else
                    data.selected_player = nil
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, false)
                    end
                    data.spectated_player = nil
                    data.selected_player_name = nil
                    data.spectator_active_player = nil
                end
            else
                data.selected_player = nil
                if(data.spectated_player)then
                    networking.send.is_spectating(data.spectated_player, false)
                end
                data.spectated_player = nil
                data.selected_player_name = nil
                data.spectator_active_player = nil

                print("Deselected player!!")
            end
        end

        local keys_pressed = {
            w = bindings:IsJustDown("arena_spectator_up"),
            a = bindings:IsJustDown("arena_spectator_left"),
            s = bindings:IsJustDown("arena_spectator_down"),
            d = bindings:IsJustDown("arena_spectator_right"),
            q = bindings:IsJustDown("arena_spectator_switch_left"),
            e = bindings:IsJustDown("arena_spectator_switch_right"),
            space = bindings:IsJustDown("arena_spectator_quick_switch"),
        }

        local keys_down = {
            w = bindings:IsDown("arena_spectator_up"),
            a = bindings:IsDown("arena_spectator_left"),
            s = bindings:IsDown("arena_spectator_down"),
            d = bindings:IsDown("arena_spectator_right"),
            switch = bindings:IsDown("arena_spectator_quick_switch"),
            fast_move = bindings:IsDown("arena_spectator_fast_move"),
        }

        local stick_x, stick_y = bindings:GetAxis("arena_spectator_move_joy")--input:GetGamepadAxis("left_stick")
        local r_stick_x, r_stick_y = bindings:GetAxis("arena_spectator_switch_stick_joy")
        local left_trigger = bindings:GetAxis("arena_spectator_quick_switch_joy")
        local right_trigger = bindings:GetAxis("arena_spectator_quick_switch_joy")
        local fast_move = bindings:GetAxis("arena_spectator_fast_move_joy")

        local left_bumper = bindings:IsJustDown("arena_spectator_switch_left_joy")
        local right_bumper = bindings:IsJustDown("arena_spectator_switch_right_joy")

        local right_trigger_pressed = right_trigger >= 0.5 and data.spectator_quick_switch_trigger < 0.5
        
        data.spectator_quick_switch_trigger = right_trigger

        if (not GameHasFlagRun("chat_input_hovered")) then

            local camera_speed = 2
            local movement_x = (stick_x * (camera_speed * (1 + (fast_move * 5))))
            local movement_y = (stick_y * (camera_speed * (1 + (fast_move * 5))))

            local movement_x2 = ((keys_down.a and -1 or 0) + (keys_down.d and 1 or 0)) * (camera_speed * (1 + (keys_down.fast_move and 5 or 0)))
            local movement_y2 = ((keys_down.w and -1 or 0) + (keys_down.s and 1 or 0)) * (camera_speed * (1 + (keys_down.fast_move and 5 or 0)))

            local stick_average = ((stick_x + stick_y) / 2)

            if(stick_average >= 0.1 or stick_average <= -0.1)then
                --arena_log:print("x_move: "..tostring(movement_x)..", y_move: "..tostring(movement_y))
                GameSetCameraPos(camera_x + movement_x, camera_y + movement_y)
            end

            if(movement_x2 ~= 0 or movement_y2 ~= 0)then
                GameSetCameraPos(camera_x + movement_x2, camera_y + movement_y2)
            end

            if (keys_pressed.w or keys_pressed.a or keys_pressed.s or keys_pressed.d or stick_average >= 0.1 or stick_average <= -0.1) then
                data.selected_player = nil
            end

            if(right_trigger_pressed or keys_pressed.space)then
                local player_entities = EntityGetWithTag("client") or {}

                if(#player_entities > 0)then
                    data.selected_player = player_entities[1]
                end
            end

            if (keys_pressed.q or left_bumper) then
                data.last_hm_switch = data.last_hm_switch or 1
                if(GameGetFrameNum() - data.last_hm_switch < 30)then
                    return
                end

                data.last_hm_switch = GameGetFrameNum()

                --[[
                    data.spectated_player = 
                    data.selected_player_name = 
                ]]
                local spectated_player = data.spectated_player
                data.last_hm_sync = nil

                if(spectated_player ~= nil and members ~= nil and #members > 0)then
                    local index = 1
                    for k, v in ipairs(members)do
                        if(v.id == spectated_player)then
                            index = k
                            break
                        end
                    end

                    index = index - 1

                    if(index < 1)then
                        index = #members
                    end

                    for k, v in ipairs(EntityGetWithTag("client") or {})do
                        EntityKill(v)
                    end
    
                    SpectatorMode.ClearHM()

                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, false)
                    end
                    data.spectated_player = members[index].id
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, true)
                    end
                    data.spectator_active_player = members[index].id
                    data.selected_player_name = steamutils.getTranslatedPersonaName(data.spectated_player)
                    data.spectator_lobby_loaded = false
                    data.selected_player = nil
                end
            end

            if(GameHasFlagRun("lock_ready_state"))then
                return
            end

            if (keys_pressed.e or right_bumper) then
                data.last_hm_switch = data.last_hm_switch or 1
                if(GameGetFrameNum() - data.last_hm_switch < 30)then
                    return
                end

                data.last_hm_switch = GameGetFrameNum()

                local spectated_player = data.spectated_player

                data.last_hm_sync = nil

                if(spectated_player ~= nil and members ~= nil and #members > 0)then
                    local index = 1
                    for k, v in ipairs(members)do
                        if(v.id == spectated_player)then
                            index = k
                            break
                        end
                    end

                    index = index + 1

                    if(index > #members)then
                        index = 1
                    end

                    for k, v in ipairs(EntityGetWithTag("client") or {})do
                        EntityKill(v)
                    end
    
         
                    local entities = EntityGetInRadius(0, 0, 1000000)
    
                    local illegal_clear_tags = {
                        "spectator_no_clear",
                        "workshop_spell_visualizer",
                        "workshop_aabb",
                        "world_state",
                        "coop_respawn"
                    }
    
                    for k, v in ipairs(entities)do
                        local valid = true
                        for k2, v2 in ipairs(illegal_clear_tags)do
                            if(EntityHasTag(v, v2))then
                                valid = false
                                break
                            end
                        end
    
                        if(valid and v == EntityGetRootEntity(v))then
                            local comps = EntityGetAllComponents(v)
    
                            for k2, v2 in ipairs(comps)do
                                local type = ComponentGetTypeName(v2)
                                if(type ~= "GameEffectComponent")then
                                    EntitySetComponentIsEnabled(v, v2, false)
                                else
                                    ComponentSetValue2(v2, "mIsExtension", true)
                                end
                            end
    
                            local material_storage = EntityGetFirstComponentIncludingDisabled(v, "MaterialInventoryComponent")
                            if(material_storage ~= nil)then
                                EntityRemoveComponent(v, material_storage)
                            end
                            EntityKill(v)
                        end
                    end
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, false)
                    end
                    data.spectated_player = members[index].id
                    if(data.spectated_player)then
                        networking.send.is_spectating(data.spectated_player, true)
                    end
                    data.spectator_active_player = members[index].id
                    data.selected_player_name = steamutils.getTranslatedPersonaName(data.spectated_player)
                    data.spectator_lobby_loaded = false
                    data.selected_player = nil
                end
            end
        end
    end,
    LateUpdate = function(lobby, data)

    end,
}

return SpectatorMode