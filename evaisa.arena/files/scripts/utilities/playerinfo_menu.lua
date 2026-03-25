local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")

local function get_health_bar_color(health, max_health)
    local health_ratio = health / max_health
    -- generate color between green and red based on health ratio
    local r = 255 * (1 - health_ratio)
    local g = 255 * health_ratio
    local b = 0
    
    return {r = r, g = g, b = b}
end

local round = function(num)
    return math.floor(num + 0.5)
end

local playerinfo_menu = {}

function playerinfo_menu:New()
    local o = {
        current_offset_percentage = 1,
        width = 120,
        height = 200,
        offset_x = 10,
        offset_y = 50,
        open = false,
        was_open = true,
        was_clicked = false,
        current_frame = 0,
        total_frames = 60,
        scroll_bar_visible = false,
        player_index = 0,
    }

    o.gui = GuiCreate()

    local player_id = steam_utils.getSteamID()
    local self_name = steamutils.getTranslatedPersonaName(player_id)

    o.Destroy = function(self)
        GuiDestroy(self.gui)
    end

    o.Close = function(self)
        self.open = false
    end

    o.Open = function(self)
        self.open = true
    end

    o.Update = function(self, data, lobby)

        local gui_id = 23532624
        local new_id = function()
            gui_id = gui_id + 1
            return gui_id
        end

        local function elasticEaseOut(t, b, c, d, a, p)
            if t == 0 then return b end
            t = t / d
            if t == 1 then return b + c end
            if not p then p = d * 0.3 end
            local s
            if not a or a < math.abs(c) then
                a = c
                s = p / 3
            else
                s = p / (2 * math.pi) * math.asin(c / a)
            end
            return b + a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c
        end

        if((not self.was_open and self.open) or (self.was_open and not self.open))then
            self.current_frame = 0
        end

        if self.open then
            self.current_offset_percentage = elasticEaseOut(self.current_frame, 0, 1, self.total_frames, nil, nil)
        else
            self.current_offset_percentage = elasticEaseOut(self.current_frame, 1, -1, self.total_frames, nil, nil)
        end

        self.current_frame = self.current_frame + 1

        self.was_open = self.open




        GuiStartFrame(self.gui)

        
        if(data.using_controller)then
            GuiOptionsAdd(self.gui, GUI_OPTION.NonInteractive)
        end

        GuiOptionsAdd(self.gui, GUI_OPTION.NoPositionTween)

        GuiZSetForNextWidget(self.gui, 1000)

        local current_x = -(self.width - (self.width * self.current_offset_percentage))
        -- add the offset
        current_x = current_x + (self.offset_x * self.current_offset_percentage)
        
        local button_id = new_id()

        local player_count = 0
        for k, v in pairs(data.players)do
            player_count = player_count + 1
        end

        --local player_count = #player_test_list
        local debug_repeat = 0

        if(debug_repeat > 0)then
            player_count = debug_repeat
        end

        local spectator = data.spectator_mode

        local offset_count = player_count

        if(spectator)then
            offset_count = offset_count - 1
        end

        local scrollbar_offset = offset_count > 2 and -8 or 0
        
        local index = spectator and 0 or 1

        local player_perk_sprites = {}
        local perk_draw_x = 0
        local perk_draw_y = 0

        local scroll_offset = 0

        local draw_perks = false

        local draw_hp_info = false
        local hovered_max_hp = 0
        local hovered_hp = 0

        local text_height_self = 0
        local text_height_other = 0

        if(not self.open)then
            scrollbar_offset = 0
        end

        GuiBeginScrollContainer(self.gui, new_id(), current_x, self.offset_y, self.width + scrollbar_offset, self.height)
        
        if(self.open)then
            GuiLayoutBeginVertical(self.gui, 0, 0, true)

            local DrawTextElement = function(formatting_string, value)
                GuiZSetForNextWidget(self.gui, 900)
                GuiColorSetForNextWidget(self.gui, 1, 1, 1, 0.8)
                GuiText(self.gui, 0, value and -2 or 0, string.format(GameTextGetTranslatedOrNot(formatting_string), tostring(value or "")))
                local _, _, _, _, _, elem_w, elem_h = GuiGetPreviousWidgetInfo(self.gui)
                return elem_h
            end

            local teams_mode = GlobalsGetValue("teams_mode", "false") == "true"
            local is_owner = steam_utils.IsOwner()

            local draw_player_card = function(playerid, hp, max_hp, perks, ready, is_self)
                if hp == nil then hp = 0 end
                if max_hp == nil then max_hp = 100 end
                if hp < 0 then hp = 0 end
                if max_hp < 0 then max_hp = 100 end
                if hp > max_hp then hp = max_hp end

                local username
                if is_self then
                    username = self_name .. " (" .. GameTextGetTranslatedOrNot("$arena_playerinfo_you") .. ")"
                else
                    username = steamutils.getTranslatedPersonaName(gameplay_handler.FindUser(lobby, playerid))
                end

                if ready then
                    GuiZSetForNextWidget(self.gui, 900)
                    GuiLayoutBeginHorizontal(self.gui, 0, 0, true)
                    GuiImage(self.gui, new_id(), 0, 2, "mods/evaisa.arena/files/sprites/ui/check.png", 1, 1, 1, 0)
                end

                GuiZSetForNextWidget(self.gui, 900)
                local color = game_funcs.ID2Color(playerid)
                if color == nil then color = {r = 255, g = 255, b = 255} end
                GuiColorSetForNextWidget(self.gui, color.r / 255, color.g / 255, color.b / 255, 1)
                GuiText(self.gui, 0, 0, username)
                local _, _, _, _, scroll_y_val, _, name_height = GuiGetPreviousWidgetInfo(self.gui)
                text_height_self = text_height_self + name_height
                if is_self then
                    scroll_offset = scroll_y_val - self.offset_y - 2
                end

                if ready then
                    GuiLayoutEnd(self.gui)
                end

                local health_ratio = hp / max_hp
                local health_bar_width = 90
                local health_width = health_bar_width * health_ratio
                local rest_width = health_bar_width - health_width
                local health_percentage = health_width / health_bar_width
                local rest_percentage = rest_width / health_bar_width
                local health_bar_color = get_health_bar_color(hp, max_hp)

                GuiLayoutBeginHorizontal(self.gui, 0, 0, true, 0, 0)
                GuiZSetForNextWidget(self.gui, 900)
                GuiColorSetForNextWidget(self.gui, health_bar_color.r / 255, health_bar_color.g / 255, health_bar_color.b / 255, 1)
                GuiImage(self.gui, new_id(), 0, 0, "mods/evaisa.arena/files/sprites/ui/bar90px.png", 1, health_percentage, 1, 0)
                local _, _, hp_hovered1, _, _, _, _ = GuiGetPreviousWidgetInfo(self.gui)
                if hp_hovered1 then
                    self.player_index = index
                    hovered_max_hp = max_hp
                    hovered_hp = hp
                    draw_hp_info = true
                end

                GuiZSetForNextWidget(self.gui, 900)
                GuiColorSetForNextWidget(self.gui, 0.2, 0.2, 0.2, 1)
                GuiImage(self.gui, new_id(), 0, 0, "mods/evaisa.arena/files/sprites/ui/bar90px.png", 1, rest_percentage, 1, 0)
                local _, _, hp_hovered2, _, _, _, _ = GuiGetPreviousWidgetInfo(self.gui)
                if hp_hovered2 then
                    self.player_index = index
                    hovered_max_hp = max_hp
                    hovered_hp = hp
                    draw_hp_info = true
                end

                GuiZSetForNextWidget(self.gui, 900)
                GuiImageButton(self.gui, new_id(), 0, -7, "", "data/ui_gfx/perk_icons/perks_hover_for_more.png")
                local clicked, right_clicked, hovered, draw_x, draw_y, _, _ = GuiGetPreviousWidgetInfo(self.gui)
                if hovered then
                    self.player_index = index
                    if perks then
                        for _, p in ipairs(perks) do
                            local perk = p[1]
                            local count = p[2]
                            local perk_sprite = perk_sprites[perk]
                            if perk_sprite then
                                for i = 1, count do
                                    table.insert(player_perk_sprites, perk_sprite)
                                end
                            end
                        end
                    end
                    draw_perks = true
                    perk_draw_y = draw_y
                end
                perk_draw_x = draw_x
                GuiLayoutEnd(self.gui)
            end

            if teams_mode then
                local teams = teams_manager.GetTeams(lobby)
                local my_id = steam_utils.getSteamID()
                local my_id_str = tostring(my_id)

                local all_player_data = {}
                if not spectator then
                    all_player_data[my_id_str] = {
                        id = my_id,
                        id_str = my_id_str,
                        hp = data.client.hp or 100,
                        max_hp = data.client.max_hp or 100,
                        perks = data.client.perks,
                        ready = GameHasFlagRun("ready_check"),
                        is_self = true,
                    }
                end
                for k, v in pairs(data.players) do
                    local uid = gameplay_handler.FindUser(lobby, k)
                    if uid ~= nil then
                        all_player_data[tostring(uid)] = {
                            id = uid,
                            id_str = tostring(uid),
                            hp = v.health or 0,
                            max_hp = v.max_health or 100,
                            perks = v.perks,
                            ready = v.ready,
                            is_self = false,
                        }
                    end
                end

                local drawn_players = {}

                local draw_team_section = function(team)
                    local team_r = team.r or 1
                    local team_g = team.g or 1
                    local team_b = team.b or 1
                    local team_id_str = tostring(team.id)

                    GuiZSetForNextWidget(self.gui, 900)
                    GuiLayoutBeginHorizontal(self.gui, 0, 0, true, 0, 2)
                    GuiColorSetForNextWidget(self.gui, team_r, team_g, team_b, 1)
                    GuiText(self.gui, 0, 0, team.name)

                    local my_team = teams_manager.GetPlayerTeam(lobby, my_id)
                    local i_am_in_this_team = tostring(my_team) == team_id_str

                    if not i_am_in_this_team then
                        GuiZSetForNextWidget(self.gui, 900)
                        local join_clicked = GuiButton(self.gui, new_id(), 4, 0, GameTextGetTranslatedOrNot("$arena_teams_join"))
                        if join_clicked then
                            if is_owner then
                                teams_manager.AssignPlayer(lobby, my_id, team.id)
                            else
                                networking.send.request_join_team(lobby, team.id)
                            end
                        end
                    else
                        GuiZSetForNextWidget(self.gui, 900)
                        local leave_clicked = GuiButton(self.gui, new_id(), 4, 0, GameTextGetTranslatedOrNot("$arena_teams_leave"))
                        if leave_clicked then
                            if is_owner then
                                teams_manager.UnassignPlayer(lobby, my_id)
                            else
                                networking.send.request_join_team(lobby, "")
                            end
                        end
                    end

                    if is_owner then
                        GuiZSetForNextWidget(self.gui, 900)
                        local remove_clicked = GuiButton(self.gui, new_id(), 4, 0, "X")
                        if remove_clicked then
                            teams_manager.RemoveTeam(lobby, team.id)
                        end
                    end
                    GuiLayoutEnd(self.gui)

                    local members = teams_manager.GetTeamMembers(lobby, team.id)
                    for _, mid in ipairs(members) do
                        local mid_str = tostring(mid)
                        local pdata = all_player_data[mid_str]
                        if pdata then
                            drawn_players[mid_str] = true
                            index = index + 1
                            GuiLayoutBeginHorizontal(self.gui, 4, 0, true, 0, 0)
                            draw_player_card(tostring(mid), pdata.hp, pdata.max_hp, pdata.perks, pdata.ready, pdata.is_self)
                            if is_owner and not pdata.is_self then
                                GuiZSetForNextWidget(self.gui, 900)
                                local kick_clicked = GuiButton(self.gui, new_id(), 2, 0, "X")
                                if kick_clicked then
                                    teams_manager.UnassignPlayer(lobby, mid)
                                end
                            end
                            GuiLayoutEnd(self.gui)
                        end
                    end
                end

                for _, team in ipairs(teams) do
                    draw_team_section(team)
                end

                local has_unassigned_header = false
                for id_str, pdata in pairs(all_player_data) do
                    if not drawn_players[id_str] then
                        if not has_unassigned_header then
                            GuiZSetForNextWidget(self.gui, 900)
                            GuiLayoutBeginHorizontal(self.gui, 0, 0, true, 0, 2)
                            GuiColorSetForNextWidget(self.gui, 0.6, 0.6, 0.6, 1)
                            GuiText(self.gui, 0, 0, GameTextGetTranslatedOrNot("$arena_teams_unassigned"))
                            GuiLayoutEnd(self.gui)
                            has_unassigned_header = true
                        end
                        index = index + 1
                        draw_player_card(tostring(pdata.id), pdata.hp, pdata.max_hp, pdata.perks, pdata.ready, pdata.is_self)
                    end
                end

                if is_owner then
                    GuiZSetForNextWidget(self.gui, 900)
                    local add_clicked = GuiButton(self.gui, new_id(), 0, 4, GameTextGetTranslatedOrNot("$arena_teams_add_team"))
                    if add_clicked then
                        teams_manager.AddTeam(lobby)
                    end
                end

            else
                ------------- DRAW OUR OWN CARD (if not spectator) ---------------

                if(not spectator)then

                    local hp = data.client.hp or 100
                    local max_hp = data.client.max_hp or 100

                    index = index + 1
                    local self_ready = GameHasFlagRun("ready_check")
                    draw_player_card(tostring(player_id), hp, max_hp, data.client.perks, self_ready, true)
                end
                -----------------------------------------------

                for k, v in pairs(data.players)do
                    local draw_player_data = function()
                        index = index + 1
                        local playerid = k
                        if(playerid ~= nil)then
                            draw_player_card(playerid, v.health, v.max_health, v.perks, v.ready, false)
                            if(index ~= player_count)then
                                GuiText(self.gui, 0, -15, " ")
                            end
                        end
                    end

                    if(debug_repeat > 0)then
                        for i = 1, debug_repeat do
                            draw_player_data()
                        end
                    else
                        draw_player_data()
                    end
                end
            end


            GuiLayoutEnd(self.gui)
        end

        GuiEndScrollContainer(self.gui)

        --print(tostring(text_height_self))
        
        local draw_pos = 0
        if((not spectator) and self.player_index == 1)then
            draw_pos = self.offset_y + text_height_self
        else
            local additional_offset = text_height_self
            local magic_number = text_height_other
            local player_index_offset = 1
            if(spectator)then
                player_index_offset = 0
            end

            draw_pos = self.offset_y + additional_offset + (magic_number * (self.player_index - player_index_offset))
            draw_pos = draw_pos + 4
        end

        draw_pos = draw_pos + scroll_offset

        --draw_pos = draw_pos + 11

        if(draw_perks)then
            perk_draw_x = perk_draw_x + 11
            GuiBeginAutoBox(self.gui)
            if(#player_perk_sprites > 0)then
                local width = 7
                local pdg_x = 16 -- sprite width + padding between each icon
                local pdg_y = 16 -- sprite height + padding between each icon
                -- optionally add offset
                for i = 0, #player_perk_sprites - 1 do
                    local pos_x = i % width
                    local pos_y = math.floor(i / width)
                    GuiZSetForNextWidget(self.gui, 800)
                    --GuiImage(self.gui, new_id(), perk_draw_x + (pos_x * pdg_x), 1 + (draw_pos + (pos_y * pdg_y)), player_perk_sprites[i+1], 1, 1, 1)
                    GuiImage(self.gui, new_id(), perk_draw_x + (pos_x * pdg_x), 10 + (perk_draw_y + (pos_y * pdg_y)), player_perk_sprites[i+1], 1, 1, 1)
                end
            else
                GuiZSetForNextWidget(self.gui, 800)
                --GuiText(self.gui, perk_draw_x, draw_pos + 1, GameTextGetTranslatedOrNot("$arena_playerinfo_no_perks"))
                GuiText(self.gui, perk_draw_x, 10 + perk_draw_y, GameTextGetTranslatedOrNot("$arena_playerinfo_no_perks"))
            end
            GuiZSetForNextWidget(self.gui, 850)

            GuiEndAutoBoxNinePiece(self.gui, 1)
        end


        if(draw_hp_info)then
            GuiBeginAutoBox(self.gui)
            GuiZSetForNextWidget(self.gui, 800)
            GuiText(self.gui, perk_draw_x - 35, draw_pos + 3, tostring(round(hovered_hp * 25)).."/"..tostring(round(hovered_max_hp * 25)))
            GuiZSetForNextWidget(self.gui, 850)
            GuiEndAutoBoxNinePiece(self.gui, 1)
        end

        GuiZSetForNextWidget(self.gui, 1000)
        local tab = GuiImage(self.gui, button_id, current_x + self.width + 6, self.offset_y + 10, "mods/evaisa.arena/files/sprites/ui/player_info_tab.png", 1, 1, 1)
        local clicked, right_clicked, hovered = GuiGetPreviousWidgetInfo(self.gui)
        if clicked and not self.was_clicked then
            self.open = not self.open
            self.was_clicked = true 
        elseif(not clicked)then
            self.was_clicked = false
        end
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

return playerinfo_menu