local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")

local TEAMS_LIST_KEY = "teams_list"
local TEAM_NEXT_ID_KEY = "teams_next_id"
local DEFAULT_TEAM_COLORS = {
    { r = 0.9, g = 0.2, b = 0.2 },
    { r = 0.2, g = 0.4, b = 1.0 },
    { r = 0.2, g = 0.8, b = 0.3 },
    { r = 0.9, g = 0.7, b = 0.1 },
    { r = 0.8, g = 0.2, b = 0.8 },
    { r = 0.1, g = 0.8, b = 0.8 },
}

teams_manager = {
    GetTeams = function(lobby)
        local raw = steamutils.GetLobbyData(TEAMS_LIST_KEY)
        if raw == nil or raw == "" then
            return {}
        end
        local ok, result = pcall(bitser.loads, raw)
        if ok then
            return result
        end
        return {}
    end,

    GetNextTeamId = function(lobby)
        local raw = steamutils.GetLobbyData(TEAM_NEXT_ID_KEY)
        local id = tonumber(raw) or 1
        return id
    end,

    GetPlayerTeam = function(lobby, user)
        local raw = steamutils.GetLobbyData(tostring(user) .. "_team")
        if raw == nil or raw == "" then
            return nil
        end
        return raw
    end,

    GetTeamById = function(lobby, team_id)
        local teams = teams_manager.GetTeams(lobby)
        for _, team in ipairs(teams) do
            if tostring(team.id) == tostring(team_id) then
                return team
            end
        end
        return nil
    end,

    GetTeamMembers = function(lobby, team_id)
        local members = steamutils.getLobbyMembers(lobby, true, true)
        local result = {}
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                local t = teams_manager.GetPlayerTeam(lobby, member.id)
                if tostring(t) == tostring(team_id) then
                    table.insert(result, member.id)
                end
            end
        end
        return result
    end,

    GetUnassignedPlayers = function(lobby)
        local members = steamutils.getLobbyMembers(lobby, true, true)
        local result = {}
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                local t = teams_manager.GetPlayerTeam(lobby, member.id)
                if t == nil or t == "" then
                    table.insert(result, member.id)
                end
            end
        end
        return result
    end,

    AreTeammates = function(lobby, user1, user2)
        if user1 == user2 then return true end
        local t1 = teams_manager.GetPlayerTeam(lobby, user1)
        local t2 = teams_manager.GetPlayerTeam(lobby, user2)
        if t1 == nil or t1 == "" then return false end
        return t1 == t2
    end,

    AddTeam = function(lobby, existing_teams)
        if not steam_utils.IsOwner() then return nil end
        local teams = existing_teams or teams_manager.GetTeams(lobby)
        local next_id = teams_manager.GetNextTeamId(lobby)
        if existing_teams ~= nil then
            next_id = 1
            for _, t in ipairs(existing_teams) do
                local n = tonumber(t.id)
                if n and n >= next_id then next_id = n + 1 end
            end
        end
        local color_idx = ((#teams) % #DEFAULT_TEAM_COLORS) + 1
        local color = DEFAULT_TEAM_COLORS[color_idx]
        local new_team = {
            id = tostring(next_id),
            name = GameTextGetTranslatedOrNot("$arena_teams_default_name") .. " " .. tostring(next_id),
            r = color.r,
            g = color.g,
            b = color.b,
        }
        table.insert(teams, new_team)
        steam_utils.TrySetLobbyData(lobby, TEAMS_LIST_KEY, bitser.dumps(teams))
        steam_utils.TrySetLobbyData(lobby, TEAM_NEXT_ID_KEY, tostring(next_id + 1))
        return teams
    end,

    RemoveTeam = function(lobby, team_id)
        if not steam_utils.IsOwner() then return end
        local teams = teams_manager.GetTeams(lobby)
        for i, team in ipairs(teams) do
            if tostring(team.id) == tostring(team_id) then
                table.remove(teams, i)
                break
            end
        end
        steam_utils.TrySetLobbyData(lobby, TEAMS_LIST_KEY, bitser.dumps(teams))

        local members = steamutils.getLobbyMembers(lobby)
        for _, member in ipairs(members) do
            local t = teams_manager.GetPlayerTeam(lobby, member.id)
            if tostring(t) == tostring(team_id) then
                steam_utils.TrySetLobbyData(lobby, tostring(member.id) .. "_team", "")
            end
        end
    end,

    AssignPlayer = function(lobby, user, team_id)
        if not steam_utils.IsOwner() then return end
        steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_team", tostring(team_id))
    end,

    UnassignPlayer = function(lobby, user)
        if not steam_utils.IsOwner() then return end
        steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_team", "")
    end,

    AutoAssignToSmallestTeam = function(lobby, user, teams_override)
        if not steam_utils.IsOwner() then return end
        local teams = teams_override or teams_manager.GetTeams(lobby)
        if #teams == 0 then return end
        local current = teams_manager.GetPlayerTeam(lobby, user)
        if current ~= nil and current ~= "" then return end
        local members = steamutils.getLobbyMembers(lobby, true, true)
        local counts = {}
        for _, team in ipairs(teams) do
            counts[tostring(team.id)] = 0
        end
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                local t = teams_manager.GetPlayerTeam(lobby, member.id)
                if t ~= nil and t ~= "" and counts[tostring(t)] ~= nil then
                    counts[tostring(t)] = counts[tostring(t)] + 1
                end
            end
        end
        local best_team = teams[1]
        local best_count = counts[tostring(teams[1].id)] or 0
        for _, team in ipairs(teams) do
            local c = counts[tostring(team.id)] or 0
            if c < best_count then
                best_count = c
                best_team = team
            end
        end
        steam_utils.TrySetLobbyData(lobby, tostring(user) .. "_team", tostring(best_team.id))
    end,

    AutoAssignAllUnassigned = function(lobby, teams_override)
        if not steam_utils.IsOwner() then return end
        local teams = teams_override or teams_manager.GetTeams(lobby)
        if #teams == 0 then return end
        local members = steamutils.getLobbyMembers(lobby, true, true)
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                teams_manager.AutoAssignToSmallestTeam(lobby, member.id, teams)
            end
        end
    end,

    ClearAllTeams = function(lobby)
        if not steam_utils.IsOwner() then return end
        steam_utils.TrySetLobbyData(lobby, TEAMS_LIST_KEY, "")
        steam_utils.TrySetLobbyData(lobby, TEAM_NEXT_ID_KEY, "1")
        local members = steamutils.getLobbyMembers(lobby, true, true)
        for _, member in ipairs(members) do
            steam_utils.TrySetLobbyData(lobby, tostring(member.id) .. "_team", "")
        end
    end,

    GetTeamWins = function(lobby, team_id, data)
        local raw = steamutils.GetLobbyData("team_" .. tostring(team_id) .. "_wins")
        return tonumber(raw) or 0
    end,

    GetTeamWinstreak = function(lobby, team_id, data)
        local raw = steamutils.GetLobbyData("team_" .. tostring(team_id) .. "_winstreak")
        return tonumber(raw) or 0
    end,

    GetTeamKills = function(lobby, team_id, data)
        local members = steamutils.getLobbyMembers(lobby)
        local total = 0
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                local t = teams_manager.GetPlayerTeam(lobby, member.id)
                if tostring(t) == tostring(team_id) then
                    total = total + (ArenaGameplay.GetKills(lobby, member.id, data) or 0)
                end
            end
        end
        return total
    end,

    GetTeamDeaths = function(lobby, team_id, data)
        local members = steamutils.getLobbyMembers(lobby)
        local total = 0
        for _, member in ipairs(members) do
            if not steamutils.IsSpectator(lobby, member.id) then
                local t = teams_manager.GetPlayerTeam(lobby, member.id)
                if tostring(t) == tostring(team_id) then
                    total = total + (ArenaGameplay.GetDeaths(lobby, member.id, data) or 0)
                end
            end
        end
        return total
    end,

    AddTeamWin = function(lobby, team_id)
        if not steam_utils.IsOwner() then return end
        local current = tonumber(steamutils.GetLobbyData("team_" .. tostring(team_id) .. "_wins")) or 0
        steam_utils.TrySetLobbyData(lobby, "team_" .. tostring(team_id) .. "_wins", tostring(current + 1))
        local streak = tonumber(steamutils.GetLobbyData("team_" .. tostring(team_id) .. "_winstreak")) or 0
        steam_utils.TrySetLobbyData(lobby, "team_" .. tostring(team_id) .. "_winstreak", tostring(streak + 1))
    end,

    ResetOtherTeamStreaks = function(lobby, winning_team_id)
        if not steam_utils.IsOwner() then return end
        local teams = teams_manager.GetTeams(lobby)
        for _, team in ipairs(teams) do
            if tostring(team.id) ~= tostring(winning_team_id) then
                steam_utils.TrySetLobbyData(lobby, "team_" .. tostring(team.id) .. "_winstreak", "0")
            end
        end
    end,

    GetAliveTeams = function(lobby, data)
        local alive_teams = {}
        local my_id = steam_utils.getSteamID()
        if not data.spectator_mode and data.client.alive then
            local t = teams_manager.GetPlayerTeam(lobby, my_id)
            if t ~= nil and t ~= "" then
                alive_teams[tostring(t)] = tostring(t)
            else
                alive_teams["solo_" .. tostring(my_id)] = "solo_" .. tostring(my_id)
            end
        end
        for id_str, v in pairs(data.players) do
            if v.alive then
                local user_id = gameplay_handler.FindUser(lobby, id_str) or id_str
                local t = teams_manager.GetPlayerTeam(lobby, user_id)
                if t ~= nil and t ~= "" then
                    alive_teams[tostring(t)] = tostring(t)
                else
                    alive_teams["solo_" .. tostring(id_str)] = "solo_" .. tostring(id_str)
                end
            end
        end
        return alive_teams
    end,

    IsTeamsMode = function()
        return GlobalsGetValue("teams_mode", "false") == "true"
    end,

    UpdateTeamGlobals = function(lobby)
        local members = steamutils.getLobbyMembers(lobby)
        for _, member in ipairs(members) do
            local t = teams_manager.GetPlayerTeam(lobby, member.id) or ""
            GlobalsSetValue("player_team_" .. tostring(member.id), t)
        end
        local my_id = steam_utils.getSteamID()
        local my_t = teams_manager.GetPlayerTeam(lobby, my_id) or ""
        GlobalsSetValue("player_team_" .. tostring(my_id), my_t)
        GlobalsSetValue("my_steam_id", tostring(my_id))
    end,
}

return teams_manager
