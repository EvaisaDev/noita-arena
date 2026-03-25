dofile("data/scripts/lib/utilities.lua")

local scoreboard = {
    gui = GuiCreate(),
    open = false,
    data = {},
    win_condition = nil,
    win_condition_value = nil
}


scoreboard.update = function(lobby)
    local id = 35423
    function new_id()
        id = id + 1
        return id
    end

    GuiStartFrame(scoreboard.gui)

    if(not scoreboard.open or IsPaused()) then
        return
    end

    local w, h = GuiGetScreenDimensions(scoreboard.gui)

    local scoreboard_width = 400
    local scoreboard_height = 300
    local window_text = GameTextGetTranslatedOrNot("$arena_end_of_round_overview")

    local x = w / 2
    local y = h / 2

    ---@diagnostic disable-next-line: undefined-global
    DrawWindow(scoreboard.gui, -9000, x, y, scoreboard_width, scoreboard_height, window_text, true, function(w_x, w_y, w_width, w_height)

        GuiImage(scoreboard.gui, new_id(), 0, 0, "mods/evaisa.arena/files/sprites/ui/pixel.png", 0, 1, 1)
        local _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(scoreboard.gui)

        -- calculate scroll offset
        local scroll_offset = w_y - draw_y
        GuiZSet(scoreboard.gui, -9150)
        local i_w, i_h = GuiGetImageDimensions(scoreboard.gui, "mods/evaisa.arena/files/sprites/ui/bar_scoreboard_2.png")
    
        local pin_y = scroll_offset + i_h

        GuiImage(scoreboard.gui, new_id(), -2, pin_y, "mods/evaisa.arena/files/sprites/ui/bar_scoreboard.png", 1, 1, 1)
    

        
        
        local text_name = GameTextGetTranslatedOrNot("$arena_scores_name")

        -- name starts from left
        local name_w, name_h = GuiGetTextDimensions(scoreboard.gui, text_name)
        local name_x_orig = 2

        -- everything else starts from right

        local text_deaths = GameTextGetTranslatedOrNot("$arena_scores_deaths")
        local deaths_w, deaths_h = GuiGetTextDimensions(scoreboard.gui, text_deaths)
        local deaths_x = w_width - deaths_w - 20
        local text_kills = GameTextGetTranslatedOrNot("$arena_scores_kills")
        local kills_w, kills_h = GuiGetTextDimensions(scoreboard.gui, text_kills)
        local kills_x = deaths_x - kills_w - 20
        local text_streak = GameTextGetTranslatedOrNot("$arena_scores_winstreak")
        local streak_w, streak_h = GuiGetTextDimensions(scoreboard.gui, text_streak)
        local streak_x = kills_x - streak_w - 20
        local text_wins = GameTextGetTranslatedOrNot("$arena_scores_wins")
        local wins_w, wins_h = GuiGetTextDimensions(scoreboard.gui, text_wins)
        local wins_x = streak_x - wins_w - 20
        local text_ping = GameTextGetTranslatedOrNot("$arena_scores_ping")
        local ping_w, ping_h = GuiGetTextDimensions(scoreboard.gui, text_ping)
        local ping_x = wins_x - ping_w - 20
        local text_delay = GameTextGetTranslatedOrNot("$arena_scores_delay")
        local delay_w, delay_h = GuiGetTextDimensions(scoreboard.gui, text_delay)
        local delay_x = ping_x - delay_w - 20
        
        GuiZSet(scoreboard.gui, -9160)

        
        GuiText(scoreboard.gui, name_x_orig,     pin_y + (i_h / 2) - (name_h / 2), text_name)
        GuiText(scoreboard.gui, wins_x,     pin_y + (i_h / 2) - (wins_h / 2), text_wins)
        GuiText(scoreboard.gui, streak_x,   pin_y + (i_h / 2) - (streak_h / 2), text_streak)
        GuiText(scoreboard.gui, kills_x,    pin_y + (i_h / 2) - (kills_h / 2), text_kills)
        GuiText(scoreboard.gui, deaths_x,   pin_y + (i_h / 2) - (deaths_h / 2), text_deaths)
        GuiText(scoreboard.gui, ping_x,     pin_y + (i_h / 2) - (ping_h / 2), text_ping)
        GuiText(scoreboard.gui, delay_x,    pin_y + (i_h / 2) - (delay_h / 2), text_delay)

        GuiZSet(scoreboard.gui, -9100)

        local medal_width = 10
        local medal_height = 10

        local y = pin_y + i_h + 6
        for i, v in ipairs(scoreboard.data)do

            if v.is_team_header then
                local team_r = v.r or 1
                local team_g = v.g or 1
                local team_b = v.b or 1

                local text_name = v.name or ""
                local text_wins = tostring(v.wins or 0)
                local text_kills = tostring(v.kills or 0)
                local text_deaths = tostring(v.deaths or 0)

                local name_w, name_h = GuiGetTextDimensions(scoreboard.gui, text_name)
                local wins_w, wins_h = GuiGetTextDimensions(scoreboard.gui, text_wins)
                local kills_w, kills_h = GuiGetTextDimensions(scoreboard.gui, text_kills)
                local deaths_w, deaths_h = GuiGetTextDimensions(scoreboard.gui, text_deaths)

                GuiZSet(scoreboard.gui, -9100)
                GuiColorSetForNextWidget(scoreboard.gui, team_r * 0.6, team_g * 0.6, team_b * 0.6, 1)
                GuiImage(scoreboard.gui, new_id(), 0, y, "mods/evaisa.arena/files/sprites/ui/bar_scoreboard_2.png", 1, 1, 1)

                GuiZSet(scoreboard.gui, -9110)
                local name_y = y + (i_h / 2) - (name_h / 2)
                GuiColorSetForNextWidget(scoreboard.gui, team_r, team_g, team_b, 1)
                GuiText(scoreboard.gui, name_x_orig, name_y, text_name)
                GuiColorSetForNextWidget(scoreboard.gui, team_r, team_g, team_b, 0.9)
                GuiText(scoreboard.gui, wins_x, y + (i_h / 2) - (wins_h / 2), text_wins)
                GuiColorSetForNextWidget(scoreboard.gui, team_r, team_g, team_b, 0.9)
                GuiText(scoreboard.gui, kills_x, y + (i_h / 2) - (kills_h / 2), text_kills)
                GuiColorSetForNextWidget(scoreboard.gui, team_r, team_g, team_b, 0.9)
                GuiText(scoreboard.gui, deaths_x, y + (i_h / 2) - (deaths_h / 2), text_deaths)

                y = y + i_h + 3
            else
                local name = v.name
                local wins = v.wins
                local streak = v.streak
                local kills = v.kills or 0
                local deaths = v.deaths or 0

                local name_indent = v.is_team_member and 8 or 0

                local text_name = GameTextGetTranslatedOrNot(name)
                local text_wins = tostring(wins)
                local text_streak = tostring(streak)
                local text_kills = tostring(kills)
                local text_deaths = tostring(deaths)
                local text_ping = string.format(GameTextGetTranslatedOrNot("$arena_scores_ping_format"), tostring(v.ping))
                local text_delay = string.format(GameTextGetTranslatedOrNot("$arena_scores_delay_format"), tostring(v.delay_frames))

                local name_w, name_h = GuiGetTextDimensions(scoreboard.gui, text_name)
                local wins_w, wins_h = GuiGetTextDimensions(scoreboard.gui, text_wins)
                local streak_w, streak_h = GuiGetTextDimensions(scoreboard.gui, text_streak)
                local kills_w, kills_h = GuiGetTextDimensions(scoreboard.gui, text_kills)
                local deaths_w, deaths_h = GuiGetTextDimensions(scoreboard.gui, text_deaths)
                local ping_w, ping_h = GuiGetTextDimensions(scoreboard.gui, text_ping)
                local delay_w, delay_h = GuiGetTextDimensions(scoreboard.gui, text_delay)

                GuiZSet(scoreboard.gui, -9100)

                GuiImage(scoreboard.gui, new_id(), 0, y, "mods/evaisa.arena/files/sprites/ui/bar_scoreboard_2.png", 1, 1, 1)

                GuiZSet(scoreboard.gui, -9110)

                local name_y = y + (i_h / 2) - (name_h / 2)

                local medal = "mods/evaisa.arena/files/sprites/ui/medals/"..tostring(i)..".png"

                local name_x = name_x_orig + name_indent

                if not v.is_team_member and ModImageDoesExist(medal) then
                    local medal_y = y + (i_h / 2) - (medal_height / 2)
                    GuiImage(scoreboard.gui, new_id(), name_x, medal_y, medal, 1, 1, 1)
                    name_x = name_x + medal_width + 2
                end

                GuiText(scoreboard.gui, name_x,     name_y, text_name)
                local wins_y = y + (i_h / 2) - (wins_h / 2)
                GuiText(scoreboard.gui, wins_x,     wins_y, text_wins)
                local streak_y = y + (i_h / 2) - (streak_h / 2)
                GuiText(scoreboard.gui, streak_x,   streak_y, text_streak)
                local kills_y = y + (i_h / 2) - (kills_h / 2)
                GuiText(scoreboard.gui, kills_x,    kills_y, text_kills)
                local deaths_y = y + (i_h / 2) - (deaths_h / 2)
                GuiText(scoreboard.gui, deaths_x,   deaths_y, text_deaths)
                if(v.ping > 0)then
                    local ping_y = y + (i_h / 2) - (ping_h / 2)
                    GuiText(scoreboard.gui, ping_x,     ping_y, text_ping)
                end
                if(v.delay_frames > 0)then
                    local delay_y = y + (i_h / 2) - (delay_h / 2)
                    GuiText(scoreboard.gui, delay_x,    delay_y, text_delay)
                end

                y = y + i_h + 6
            end
        end
      

    end, function()
        scoreboard.open = false;
    end, "chat_window", 0, 0, true)


end

scoreboard.apply_data = function(lobby, data)
    scoreboard.data = {}

    local win_condition = GlobalsGetValue("win_condition", "unlimited")
    local value = tonumber(GlobalsGetValue("win_condition_value", "5"))

    scoreboard.win_condition = win_condition
    scoreboard.win_condition_value = value

    local teams_mode = GlobalsGetValue("teams_mode", "false") == "true"

    if teams_mode then
        local teams = teams_manager.GetTeams(lobby)
        local all_player_ids = {}

        if not data.spectator_mode then
            local pid = steamutils.getSteamID()
            all_player_ids[tostring(pid)] = {
                id = pid,
                ping = 0,
                delay_frames = 0,
            }
        end
        for k, v in pairs(data.players) do
            local playerid = gameplay_handler.FindUser(lobby, k)
            if playerid ~= nil then
                all_player_ids[tostring(playerid)] = {
                    id = playerid,
                    ping = v.ping or 0,
                    delay_frames = v.delay_frames or 0,
                }
            end
        end

        for _, team in ipairs(teams) do
            local team_wins = teams_manager.GetTeamWins(lobby, team.id, data)
            local team_streak = teams_manager.GetTeamWinstreak(lobby, team.id, data)
            local team_kills = teams_manager.GetTeamKills(lobby, team.id, data)
            local team_deaths = teams_manager.GetTeamDeaths(lobby, team.id, data)

            table.insert(scoreboard.data, {
                is_team_header = true,
                team_id = team.id,
                name = team.name,
                wins = team_wins,
                streak = team_streak,
                kills = team_kills,
                deaths = team_deaths,
                r = team.r,
                g = team.g,
                b = team.b,
                ping = 0,
                delay_frames = 0,
            })

            local member_ids = teams_manager.GetTeamMembers(lobby, team.id)
            for _, mid in ipairs(member_ids) do
                local mid_str = tostring(mid)
                local entry = all_player_ids[mid_str]
                if entry then
                    table.insert(scoreboard.data, {
                        is_team_member = true,
                        id = mid,
                        id_string = mid_str,
                        name = steamutils.getTranslatedPersonaName(mid),
                        wins = ArenaGameplay.GetWins(lobby, mid, data),
                        streak = ArenaGameplay.GetWinstreak(lobby, mid, data),
                        kills = ArenaGameplay.GetKills(lobby, mid, data),
                        deaths = ArenaGameplay.GetDeaths(lobby, mid, data),
                        ping = entry.ping,
                        delay_frames = entry.delay_frames,
                    })
                    all_player_ids[mid_str] = nil
                end
            end
        end

        local has_unassigned = false
        for _, entry in pairs(all_player_ids) do
            if not has_unassigned then
                table.insert(scoreboard.data, {
                    is_team_header = true,
                    team_id = nil,
                    name = GameTextGetTranslatedOrNot("$arena_teams_unassigned"),
                    wins = 0,
                    streak = 0,
                    kills = 0,
                    deaths = 0,
                    r = 0.5, g = 0.5, b = 0.5,
                    ping = 0,
                    delay_frames = 0,
                })
                has_unassigned = true
            end
            local mid = entry.id
            local mid_str = tostring(mid)
            table.insert(scoreboard.data, {
                is_team_member = true,
                id = mid,
                id_string = mid_str,
                name = steamutils.getTranslatedPersonaName(mid),
                wins = ArenaGameplay.GetWins(lobby, mid, data),
                streak = ArenaGameplay.GetWinstreak(lobby, mid, data),
                kills = ArenaGameplay.GetKills(lobby, mid, data),
                deaths = ArenaGameplay.GetDeaths(lobby, mid, data),
                ping = entry.ping,
                delay_frames = entry.delay_frames,
            })
        end

        return
    end

    -- Add our own entry
    if(not data.spectator_mode)then
        local player_id = steamutils.getSteamID()
        local self_name = steamutils.getTranslatedPersonaName(player_id)

        local own_wins = ArenaGameplay.GetWins(lobby, player_id, data)
        local own_streak = ArenaGameplay.GetWinstreak(lobby, player_id, data)
        local own_kills = ArenaGameplay.GetKills(lobby, player_id, data)
        local own_deaths = ArenaGameplay.GetDeaths(lobby, player_id, data)

        table.insert(scoreboard.data, {
            id = player_id,
            id_string = tostring(player_id),
            name = self_name,
            wins = own_wins,
            streak = own_streak,
            kills = own_kills,
            deaths = own_deaths,
            ping = 0,
            delay_frames = 0
        })
    end
    -- Add other players
    for k, v in pairs(data.players)do
     
        local playerid = gameplay_handler.FindUser(lobby, k)
        
        if(playerid ~= nil)then
            local wins = ArenaGameplay.GetWins(lobby, playerid, data)
            local winstreak = ArenaGameplay.GetWinstreak(lobby, playerid, data)
            local kills = ArenaGameplay.GetKills(lobby, playerid, data)
            local deaths = ArenaGameplay.GetDeaths(lobby, playerid, data)

            local ping = v.ping or 0
            local delay_frames = v.delay_frames or 0


            table.insert(scoreboard.data, {
                id = playerid,
                id_string = tostring(playerid),
                name = steamutils.getTranslatedPersonaName(playerid),
                wins = wins,
                streak = winstreak,
                kills = kills,
                deaths = deaths,
                ping = ping,
                delay_frames = delay_frames
            })
        end
    end

    -- Sort the data
    table.sort(scoreboard.data, function(a, b)
        if(scoreboard.win_condition == "winstreak")then
            if(a.streak == b.streak)then
                return a.id_string < b.id_string
            end
            return a.streak > b.streak
        else
            if(a.wins == b.wins)then
                return a.id_string < b.id_string
            end
            return a.wins > b.wins
        end
    end)
                

end

scoreboard.show = function()
    scoreboard.open = true
end

return scoreboard