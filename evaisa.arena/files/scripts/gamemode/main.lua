arena_log = logger.init("noita-arena.log")
perk_log = logger.init("noita-arena-perk.log")
perk_info_saved = logger.init("perk_info_saved.lua")
perk_info_loaded = logger.init("perk_info_loaded.lua")
arena_data_file = logger.init("arena_data.log")

if(not debugging)then
	arena_log.enabled = false
end

dofile_once("mods/evaisa.arena/content/data.lua")


dofile("mods/evaisa.arena/files/scripts/utilities/utils.lua")

mp_helpers = dofile("mods/evaisa.mp/files/scripts/helpers.lua")
local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
game_funcs = dofile("mods/evaisa.mp/files/scripts/game_functions.lua")
EZWand = dofile("mods/evaisa.arena/files/scripts/utilities/EZWand.lua")
smallfolk = dofile("mods/evaisa.arena/lib/smallfolk.lua")

wait = dofile("mods/evaisa.arena/files/scripts/utilities/wait.lua")
local inspect = dofile("mods/evaisa.arena/lib/inspect.lua")

local data_holder = dofile("mods/evaisa.arena/files/scripts/gamemode/data.lua")
local data = nil

last_player_entity = nil

local player = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/player.lua")
local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

--font_helper = dofile("mods/evaisa.arena/lib/font_helper.lua")
--message_handler = dofile("mods/evaisa.arena/files/scripts/gamemode/message_handler_stub.lua")
networking = dofile("mods/evaisa.arena/files/scripts/gamemode/networking.lua")
--spectator_networking = dofile("mods/evaisa.arena/files/scripts/gamemode/spectator_networking.lua")

upgrade_system = dofile("mods/evaisa.arena/files/scripts/gamemode/misc/upgrade_system.lua")

gameplay_handler = dofile("mods/evaisa.arena/files/scripts/gamemode/gameplay.lua")
spectator_handler = dofile("mods/evaisa.arena/files/scripts/gamemode/spectator.lua")


if(MP_VERSION > 350)then
    skin_system = dofile("mods/evaisa.arena/files/scripts/gui/skins.lua").init()

    scoreboard = dofile("mods/evaisa.arena/files/scripts/gui/scoreboard.lua")
end

if(ModSettingGet("evaisa.arena.custom_parallax"))then
    Parallax = dofile("mods/evaisa.arena/files/scripts/parallax/parallax.lua")
end
local randomized_seed = true

local playerinfo_menu = dofile("mods/evaisa.arena/files/scripts/utilities/playerinfo_menu.lua")

dofile_once("data/scripts/perks/perk_list.lua")

local applied_seed = 0

perks_sorted = {}
perk_enum = {}
all_perks = {}
all_perks_by_name = {}
perk_sprites = {}
for k, perk in pairs(perk_list) do
    perk_sprites[perk.id] = perk.ui_icon
    table.insert(perks_sorted, perk.id)
    all_perks[perk.id] = perk
    all_perks_by_name[perk.ui_name] = perk
end

table.sort(perks_sorted)

for i, perk_id in ipairs(perks_sorted) do
    perk_enum[perk_id] = i
end


local parallax_textures = {}

if(ModSettingGet("evaisa.arena.custom_parallax"))then
    local max_layers = 1
    for k, arena in pairs(arena_list) do
        if(arena.parallax_layers and arena.parallax_layers > max_layers)then
            max_layers = arena.parallax_layers
        end
        if(arena.parallax_textures)then
            for _, texture in ipairs(arena.parallax_textures) do
                table.insert(parallax_textures, texture)
            end
        end
    end

    Parallax.registerLayers(max_layers)
end
for k, arena in pairs(arena_list) do
    if(arena.init)then
        arena:init()
    end
end
if(ModSettingGet("evaisa.arena.custom_parallax"))then
    Parallax.registerTextures(parallax_textures)

    Parallax.postInit()
end
playermenu = nil

local was_content_mismatched = false

playerRunQueue = {}

local player_mods = "";

function RunWhenPlayerExists(func)
    table.insert(playerRunQueue, func)
end

if(MP_VERSION > 350)then
    np.CrossCallAdd("Swap", function(shooter_id)
        if(data ~= nil and lobby_code)then
            local user = gameplay_handler.FindUser(lobby_code, EntityGetName(shooter_id))

            local shooter_x, shooter_y = EntityGetTransform(shooter_id)

            local player_entity = player.Get()

            if(player_entity and user)then
                local x, y = EntityGetTransform(player_entity)

                EntityLoad("data/entities/particles/teleportation_source.xml", shooter_x, shooter_y)
                EntityLoad("data/entities/particles/teleportation_target.xml", x, y)

                networking.send.swap_positions(user, x, y)
                EntityApplyTransform(player_entity, shooter_x, shooter_y)
            end
        end
    end)
end

local oldSetWorldSeed = SetWorldSeed
SetWorldSeed = function(seed)
    GlobalsSetValue("world_seed", tostring(seed))
    oldSetWorldSeed(seed)
end

lobby_member_names = {}

content_hash = content_hash or 0
content_string = content_string or ""

perk_blacklist_data = perk_blacklist_data or {}
perk_blacklist_string = perk_blacklist_string or ""
spell_blacklist_data = spell_blacklist_data or {}
spell_blacklist_string = spell_blacklist_string or ""
map_blacklist_data = map_blacklist_data or {}
map_blacklist_string = map_blacklist_string or ""
card_blacklist_data = card_blacklist_data or {}
card_blacklist_string = card_blacklist_string or ""
material_blacklist_data = material_blacklist_data or {}
material_blacklist_string = material_blacklist_string or ""
item_blacklist_data = item_blacklist_data or {}
item_blacklist_string = item_blacklist_string or ""


sorted_spell_list = sorted_spell_list or nil
sorted_spell_list_ids = sorted_spell_list_ids or nil
sorted_perk_list = sorted_perk_list or nil
sorted_perk_list_ids = sorted_perk_list_ids or nil
sorted_map_list = sorted_map_list or nil
sorted_map_list_ids = sorted_map_list_ids or nil
sorted_item_list = sorted_item_list or nil
sorted_item_list_ids = sorted_item_list_ids or nil
sorted_material_list = sorted_material_list or nil
sorted_material_list_ids = sorted_material_list_ids or nil

checksum_materials_done = false


local function ifind(s, pattern, init, plain)
    return string.find(s:lower(), pattern:lower(), init, plain)
end

local function search(id, name, term, blacklist_func)

    local blacklisted = blacklist_func(id)

    local flags = {}

    -- get any words starting with #
    for word in string.gmatch(term, "#%w+") do
        flags[word] = true
        -- remove the word from the search term
        term = term:gsub(word, "")
    end

    local valid = false

    if(flags["#blacklisted"] and blacklisted)then
        valid = true
    end

    if(flags["#whitelisted"] and not blacklisted)then
        valid = true
    end

    -- trim string and check if it's empty
    term = term:match("^%s*(.-)%s*$")
    if(term == "")then
        return valid
    end

    if(ifind(string.lower(GameTextGetTranslatedOrNot(name)), string.lower(term), 1, true) or ifind(string.lower(id), string.lower(term), 1, true))then
        return true
    end
end

dofile("data/scripts/perks/perk_list.lua")
dofile("data/scripts/gun/gun_actions.lua")
dofile("mods/evaisa.arena/files/scripts/gamemode/misc/upgrades.lua")
dofile("data/scripts/item_spawnlists.lua")
local materials = {}

local function SetNewSeed(lobby)
    local seed = 0
    print("Randomized seed? " .. tostring(randomized_seed))
    print("Is owner? " .. tostring(steam_utils.IsOwner()))
    if(randomized_seed and steam_utils.IsOwner())then
        local a, b, c, d, e, f = GameGetDateAndTimeLocal()
        math.randomseed(GameGetFrameNum() + a + b + c + d + e + f)
        seed = math.random(1, 4294967294)
        steam_utils.TrySetLobbyData(lobby, "seed", tostring(seed))
    else
        seed = tonumber(steam.matchmaking.getLobbyData(lobby, "seed") or 1)
    end
    print("Setting seed to " .. tostring(seed))
    return seed
end

local function UpdateMaterials()
    materials = {}
    local materials_added = {}

    local tryAddMaterial = function(v)
        if(not materials_added[v.material])then
            v.id = v.material
            v.type = CellFactory_GetType(v.material)
            v.ui_name = CellFactory_GetUIName(v.type)
            table.insert(materials, v)
            materials_added[v.material] = true
        end
    end

    dofile("data/scripts/items/potion_aggressive.lua")
    for i, v in ipairs(flask_materials) do
        tryAddMaterial(v)
    end
    dofile("data/scripts/items/potion_starting.lua")
    for i, v in ipairs(flask_materials) do
        tryAddMaterial(v)
    end
    dofile("data/scripts/items/powder_stash.lua")
    for i, v in ipairs(flask_materials) do
        tryAddMaterial(v)
    end
    dofile("data/scripts/items/potion.lua")
    for i, v in ipairs(flask_materials) do
        tryAddMaterial(v)
    end
end

local function TryUpdateData(lobby)

    
    
    if(sorted_spell_list == nil)then
        content_hash = 0
        sorted_spell_list = {}
        sorted_spell_list_ids = {}

        for _, spell in pairs(actions)do
            table.insert(sorted_spell_list, spell)
            table.insert(sorted_spell_list_ids, spell)
            content_hash = content_hash + string.bytes(spell.id)
            content_string = content_string .. spell.id .. "\n"
        end

        table.sort(sorted_spell_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.name) < GameTextGetTranslatedOrNot(b.name)
        end)

        table.sort(sorted_spell_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
    end

    if(sorted_perk_list == nil)then
        sorted_perk_list = {}
        sorted_perk_list_ids = {}
        for _, perk in pairs(perk_list)do
            table.insert(sorted_perk_list, perk)
            table.insert(sorted_perk_list_ids, perk)
            content_hash = content_hash + string.bytes(perk.id)
            content_string = content_string .. perk.id .. "\n"
        end

        table.sort(sorted_perk_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.ui_name) < GameTextGetTranslatedOrNot(b.ui_name)
        end)

        table.sort(sorted_perk_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
    end

    if(not checksum_materials_done)then
        checksum_materials_done = true

        local mats = {
            CellFactory_GetAllFires(true, true),
            CellFactory_GetAllGases(true, true),
            CellFactory_GetAllLiquids(true, true),
            CellFactory_GetAllSolids(true, true),
            CellFactory_GetAllSands(true, true),
        }
        
        local index = 1
        for _, mat_list in ipairs(mats)do
            for _, material in ipairs(mat_list)do
                content_hash = content_hash + (string.bytes(material) * index)
                index = index + 1
            end
        end
    end

    if(sorted_map_list == nil)then
        -- sort map list blah
        sorted_map_list = {}
        sorted_map_list_ids = {}
        for _, map in pairs(arena_list)do
            table.insert(sorted_map_list, map)
            table.insert(sorted_map_list_ids, map)
            content_hash = content_hash + string.bytes(map.id)
            content_string = content_string .. map.id .. "\n"
        end

        table.sort(sorted_map_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.name) < GameTextGetTranslatedOrNot(b.name)
        end)

        table.sort(sorted_map_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
    end

    if(sorted_card_list == nil)then
        -- sort card list blah
        sorted_card_list = {}
        sorted_card_list_ids = {}
        for _, card in pairs(upgrades)do
            table.insert(sorted_card_list, card)
            table.insert(sorted_card_list_ids, card)
            content_hash = content_hash + string.bytes(card.id)
            content_string = content_string .. card.id .. "\n"
        end

        table.sort(sorted_card_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.ui_name) < GameTextGetTranslatedOrNot(b.ui_name)
        end)

        table.sort(sorted_card_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
    end

    if(sorted_item_list == nil)then
        -- sort item list blah
        sorted_item_list = {}
        sorted_item_list_ids = {}
        for _, item in pairs(item_spawnlist)do
            table.insert(sorted_item_list, item)
            table.insert(sorted_item_list_ids, item)
            content_hash = content_hash + string.bytes(item.id)
            content_string = content_string .. item.id .. "\n"
        end

        table.sort(sorted_item_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.ui_name) < GameTextGetTranslatedOrNot(b.ui_name)
        end)

        table.sort(sorted_item_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
    end

    if(sorted_material_list == nil)then
        -- sort material list blah
        sorted_material_list = {}
        sorted_material_list_ids = {}
        
        UpdateMaterials()

        
        for _, material in pairs(materials)do
            table.insert(sorted_material_list, material)
            table.insert(sorted_material_list_ids, material)
            content_hash = content_hash + string.bytes(material.id)
            content_string = content_string .. material.id .. "\n"
        end

        table.sort(sorted_material_list, function(a, b)
            return GameTextGetTranslatedOrNot(a.ui_name) < GameTextGetTranslatedOrNot(b.ui_name)
        end)

        table.sort(sorted_material_list_ids, function(a, b)
            return GameTextGetTranslatedOrNot(a.id) < GameTextGetTranslatedOrNot(b.id)
        end)
        
    end


    GlobalsSetValue("content_string", tostring(content_string))

    if(tostring(content_hash) ~= steam.matchmaking.getLobbyData(lobby, "content_hash") and not steam_utils.IsOwner())then
        print("content mismatch!")
        return
    end

    if(cached_lobby_data["perk_blacklist_data"] ~= nil and perk_blacklist_string ~= cached_lobby_data["perk_blacklist_data"])then
        print("Updating perk blacklist data")
        -- split byte string into table
        perk_blacklist_data = {}
        perk_blacklist_string = cached_lobby_data["perk_blacklist_data"]
        for i = 1, #perk_blacklist_string do
            local enabled = perk_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                perk_blacklist_data[sorted_perk_list_ids[i].id] = enabled
            else
                perk_blacklist_data[sorted_perk_list_ids[i].id] = nil
            end
        end
    end

    if(cached_lobby_data["spell_blacklist_data"] ~= nil and spell_blacklist_string ~= cached_lobby_data["spell_blacklist_data"])then
        print("Updating spell blacklist data")
        -- split byte string into table
        spell_blacklist_data = {}
        spell_blacklist_string = cached_lobby_data["spell_blacklist_data"]
        for i = 1, #spell_blacklist_string do
            local enabled = spell_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                spell_blacklist_data[sorted_spell_list_ids[i].id] = enabled
            else
                spell_blacklist_data[sorted_spell_list_ids[i].id] = nil
            end
        end
    end

    if(cached_lobby_data["map_blacklist_data"] ~= nil and map_blacklist_string ~= cached_lobby_data["map_blacklist_data"])then
        print("Updating map blacklist data")
        -- split byte string into table
        map_blacklist_data = {}
        map_blacklist_string = cached_lobby_data["map_blacklist_data"]
        for i = 1, #map_blacklist_string do
            local enabled = map_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                map_blacklist_data[sorted_map_list_ids[i].id] = enabled
            else
                map_blacklist_data[sorted_map_list_ids[i].id] = nil
            end
        end
    end

    -- card blacklist
    if(cached_lobby_data["card_blacklist_data"] ~= nil and card_blacklist_string ~= cached_lobby_data["card_blacklist_data"])then
        print("Updating card blacklist data")
        -- split byte string into table
        card_blacklist_data = {}
        card_blacklist_string = cached_lobby_data["card_blacklist_data"]
        for i = 1, #card_blacklist_string do
            local enabled = card_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                card_blacklist_data[sorted_card_list_ids[i].id] = enabled
            else
                card_blacklist_data[sorted_card_list_ids[i].id] = nil
            end
        end
    end

    -- item blacklist
    if(cached_lobby_data["item_blacklist_data"] ~= nil and item_blacklist_string ~= cached_lobby_data["item_blacklist_data"])then
        print("Updating item blacklist data")
        -- split byte string into table
        item_blacklist_data = {}
        item_blacklist_string = cached_lobby_data["item_blacklist_data"]
        for i = 1, #item_blacklist_string do
            local enabled = item_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                item_blacklist_data[sorted_item_list_ids[i].id] = enabled
            else
                item_blacklist_data[sorted_item_list_ids[i].id] = nil
            end
        end
    end

    -- material blacklist
    if(cached_lobby_data["material_blacklist_data"] ~= nil and material_blacklist_string ~= cached_lobby_data["material_blacklist_data"])then
        print("Updating material blacklist data")
        -- split byte string into table
        material_blacklist_data = {}
        material_blacklist_string = cached_lobby_data["material_blacklist_data"]
        for i = 1, #material_blacklist_string do
            local enabled = material_blacklist_string:sub(i, i) == "1"
            if(enabled)then
                material_blacklist_data[sorted_material_list_ids[i].id] = enabled
            else
                material_blacklist_data[sorted_material_list_ids[i].id] = nil
            end
        end
    end
    
end


local function SendLobbyData(lobby)

    if(sorted_perk_list_ids)then
        local perk_blacklist_string_temp = ""
        for _, perk in pairs(sorted_perk_list_ids)do
            if(perk_blacklist_data[perk.id] == nil)then
                perk_blacklist_string_temp = perk_blacklist_string_temp .. "0"
            else
                perk_blacklist_string_temp = perk_blacklist_string_temp .. (perk_blacklist_data[perk.id] and "1" or "0")
            end
        end
        --print(perk_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "perk_blacklist_data", perk_blacklist_string_temp)
    end

    if(sorted_spell_list_ids)then
        local spell_blacklist_string_temp = ""
        for _, spell in pairs(sorted_spell_list_ids)do
            if(spell_blacklist_data[spell.id] == nil)then
                spell_blacklist_string_temp = spell_blacklist_string_temp .. "0"
            else
                spell_blacklist_string_temp = spell_blacklist_string_temp .. (spell_blacklist_data[spell.id] and "1" or "0")
            end
        end
        --print(spell_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "spell_blacklist_data", spell_blacklist_string_temp)
    end

    if(sorted_map_list_ids)then
        local map_blacklist_string_temp = ""
        for _, map in pairs(sorted_map_list_ids)do
            if(map_blacklist_data[map.id] == nil)then
                map_blacklist_string_temp = map_blacklist_string_temp .. "0"
            else
                map_blacklist_string_temp = map_blacklist_string_temp .. (map_blacklist_data[map.id] and "1" or "0")
            end
        end
        --print(map_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "map_blacklist_data", map_blacklist_string_temp)
    end

    if(sorted_card_list_ids)then
        local card_blacklist_string_temp = ""
        for _, card in pairs(sorted_card_list_ids)do
            if(card_blacklist_data[card.id] == nil)then
                card_blacklist_string_temp = card_blacklist_string_temp .. "0"
            else
                card_blacklist_string_temp = card_blacklist_string_temp .. (card_blacklist_data[card.id] and "1" or "0")
            end
        end
        --print(card_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "card_blacklist_data", card_blacklist_string_temp)
    end

    if(sorted_item_list_ids)then
        local item_blacklist_string_temp = ""
        for _, item in pairs(sorted_item_list_ids)do
            if(item_blacklist_data[item.id] == nil)then
                item_blacklist_string_temp = item_blacklist_string_temp .. "0"
            else
                item_blacklist_string_temp = item_blacklist_string_temp .. (item_blacklist_data[item.id] and "1" or "0")
            end
        end
        --print(item_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "item_blacklist_data", item_blacklist_string_temp)
    end

    if(sorted_material_list_ids)then
        local material_blacklist_string_temp = ""
        for _, material in pairs(sorted_material_list_ids)do
            if(material_blacklist_data[material.id] == nil)then
                material_blacklist_string_temp = material_blacklist_string_temp .. "0"
            else
                material_blacklist_string_temp = material_blacklist_string_temp .. (material_blacklist_data[material.id] and "1" or "0")
            end
        end
        --print(material_blacklist_string_temp)
        steam_utils.TrySetLobbyData(lobby, "material_blacklist_data", material_blacklist_string_temp)
    end
        
    steam.matchmaking.sendLobbyChatMsg(lobby, "refresh")
end

function DestroyDataTable()
    data = nil
end

local filter_types = {
    all = "$arena_blacklist_filter_all",
    blacklist = "$arena_blacklist_filter_blacklist",
    whitelist = "$arena_blacklist_filter_whitelist" 
}

np.SetGameModeDeterministic(true)


ArenaMode = {
    id = "arena",
    name = "$arena_gamemode_name",
    version = 187,
    required_online_version = 367,
    version_display = function(version_string)
        return version_string .. " - " .. tostring(content_hash)
    end,
    version_flavor_text = "$arena_release",
    custom_lobby_string = function(lobby)
        return string.format(GameTextGetTranslatedOrNot("$arena_lobby_string"), tostring(tonumber(steam.matchmaking.getLobbyData(lobby, "holyMountainCount")) or "0") + 1)
    end,
    spectator_unfinished_warning = false,
    enable_spectator = true,--not ModSettingGet("evaisa.arena.spectator_unstable"),
    enable_presets = true,
    custom_enter_check = function(lobby)
        local lobby_state = steam.matchmaking.getLobbyData(lobby, "arena_state") or "lobby"

        -- if we are the only player in the lobby and arena state is not lobby, allow entry
        if(steam_utils.getNumLobbyMembers() == 1 and lobby_state ~= "lobby")then
            return true, "Preparing in Holy Mountain"
        end

        if(lobby_state == "lobby")then
            return true, "Preparing in Holy Mountain"
        else
            return false, "Game is in progress, please wait"
        end
    end,
    custom_spectator_check = function(lobby)
        local lobby_state = steam.matchmaking.getLobbyData(lobby, "arena_state") or "lobby"

        -- if we are the only player in the lobby and arena state is not lobby, allow entry
        if(steam_utils.getNumLobbyMembers() == 1 and lobby_state ~= "lobby")then
            return true, "Preparing in Holy Mountain"
        end

        if(lobby_state == "lobby")then
            return true, "Preparing in Holy Mountain"
        else
            return false, "Game is in progress, please wait"
        end
    end,
    binding_register = function(bindings)
        print("Registering bindings for Noita Arena")
        -- Arena Spectator keyboard bindings
        bindings:RegisterBinding("arena_spectator_up", "Arena - Spectator [keyboard]", "Up", "Key_w", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_down", "Arena - Spectator [keyboard]", "Down", "Key_s", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_left", "Arena - Spectator [keyboard]", "Left", "Key_a", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_right", "Arena - Spectator [keyboard]", "Right", "Key_d", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_switch_left", "Arena - Spectator [keyboard]", "Switch Player Left", "Key_q", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_switch_right", "Arena - Spectator [keyboard]", "Switch Player Right", "Key_e", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_fast_move", "Arena - Spectator [keyboard]", "Move Fast", "Key_LSHIFT", "key", false, true, false, false)

        -- Arena Spectator gamepad bindings
        bindings:RegisterBinding("arena_spectator_quick_switch", "Arena - Spectator [keyboard]", "Quick select", "Key_SPACE", "key", false, true, false, false)
        bindings:RegisterBinding("arena_spectator_move_joy", "Arena - Spectator [gamepad]", "Movement stick", "gamepad_left_stick", "axis", false, false, false, true)
        bindings:RegisterBinding("arena_spectator_switch_stick_joy", "Arena - Spectator [gamepad]", "Quick select stick", "gamepad_right_stick", "axis", false, false, false, true)
        bindings:RegisterBinding("arena_spectator_quick_switch_joy", "Arena - Spectator [gamepad]", "Quick select", "gamepad_left_trigger", "axis_button", false, false, false, false, true)
        bindings:RegisterBinding("arena_spectator_quick_switch_joy_confirm", "Arena - Spectator [gamepad]", "Quick switch confirm", "gamepad_right_trigger", "axis_button", false, false, false, false, true)
        bindings:RegisterBinding("arena_spectator_switch_left_joy", "Arena - Spectator [gamepad]", "Switch Player Left", "JOY_BUTTON_LEFT_SHOULDER", "joy", false, false, true, false)
        bindings:RegisterBinding("arena_spectator_switch_right_joy", "Arena - Spectator [gamepad]", "Switch Player Right", "JOY_BUTTON_RIGHT_SHOULDER", "joy", false, false, true, false)
        bindings:RegisterBinding("arena_spectator_fast_move_joy", "Arena - Spectator [gamepad]", "Move Fast", "gamepad_right_trigger", "axis_button", false, false, false, false, true)
    
        -- Card system keyboard bindings
        bindings:RegisterBinding("arena_cards_select_card1", "Arena - Cards [keyboard]", "Take selected card", "Key_ENTER", "key", false, true, false, false)

        -- Card system gamepad bindings
        bindings:RegisterBinding("arena_cards_select_card_joy", "Arena - Cards [gamepad]", "Take selected card", "JOY_BUTTON_A", "joy", false, false, true, false)
        
        -- Scoreboard keyboard bindings
        bindings:RegisterBinding("arena_scoreboard_toggle", "Arena - Scoreboard [keyboard]", "Toggle Scoreboard", "", "key", false, true, false, false)

        -- Scoreboard gamepad bindings
        bindings:RegisterBinding("arena_scoreboard_toggle_joy", "Arena - Scoreboard [gamepad]", "Toggle Scoreboard", "", "joy", false, false, true, false)

    end,
    default_presets = {
        ["Wand Locked"] = {
            ["version"] = 2,
            ["settings"] = {
                ["shop_start_level"] = 0,
                ["shop_random_ratio"] = 50,
                ["shop_type"] = "spell_only",
                ["shop_jump"] = 1,
                ["upgrades_catchup"] = "losers",
                ["damage_cap"] = "0.25",
                ["shop_scaling"] = 2,
                ["zone_shrink"] = "static",
                ["shop_wand_chance"] = 40,
                ["max_shop_level"] = 5,
                ["shop_price_multiplier"] = 0,
                ["perk_catchup"] = "losers",
                ["upgrades_system"] = true,         
            }
        }
    },
    preset_registry = function()
        local presets = {}

        local default_preset_folder = "mods/evaisa.arena/content/default_presets"

        local files = {}
        local pfile = io.popen([[dir "]] .. default_preset_folder .. [[" /b]])

        for filename in pfile:lines() do

            -- if filename ends in .mp_preset
            if(filename:sub(-10) == ".mp_preset")then
                local preset_data = {}
                local file = io.open(default_preset_folder .. "\\" .. filename, "r")
                if(file ~= nil)then
                    local data = file:read("*all")
                    file:close()
                    filename = filename:gsub(".mp_preset", "")
                    local valid, preset_data = pcall(bitser.loads, data)
                    if(valid and preset_data ~= nil)then
                        table.insert(presets, {name = filename, extension = ".mp_preset", data = preset_data})
                    else
                        table.insert(presets, {name = filename, extension = ".mp_preset",	corrupt = true, data = {
                            version = MP_PRESET_VERSION,
                            settings = {}
                        }})
                    end
                end
            elseif(filename:sub(-5) == ".json")then
                local preset_data = {}
                local file = io.open(default_preset_folder .. "\\" .. filename, "r")
                if(file ~= nil)then
                    local data = file:read("*all")
                    file:close()
                    filename = filename:gsub(".json", "")
                    local valid, preset_data = pcall(json.parse, data)
                    if(valid and preset_data ~= nil)then
                        table.insert(presets, {name = filename, extension = ".json", data = preset_data})
                    else
                        table.insert(presets, {name = filename, extension = ".json", corrupt = true, data = {
                            version = MP_PRESET_VERSION,
                            settings = {}
                        }})
                    end
                end
            end
        end

        return presets
    end,
    settings = {
        {
            id = "random_seed",
            name = "$arena_settings_random_seed_name",
            description = "$arena_settings_random_seed_description",
            type = "bool",
            default = true
        },  
        {
            id = "arena_gamemode",
            name = "$arena_settings_gamemode_name",
            description = "$arena_settings_gamemode_description",
            type = "enum",
            options = { { "ffa", "$arena_settings_gamemode_ffa" }, { "continuous", "$arena_settings_gamemode_continuous", {"$arena_settings_experimental", "$arena_settings_experimental_desc"} }, },
            default = "ffa"
        },
        {
            id = "map_picker",
            name = "$arena_settings_map_picker_name",
            description = "$arena_settings_map_picker_description",
            type = "enum",
            options = { { "ordered", "$arena_settings_map_picker_enum_order" }, { "random", "$arena_settings_map_picker_enum_random" }, { "vote", "$arena_settings_map_picker_enum_vote" } },
            default = "random"
        },
        {
			id = "map_vote_timer",
            require = function(setting_self)
                return GlobalsGetValue("map_picker", "random") == "vote"
            end,
			name = "$arena_settings_map_vote_timer_name",
			description = "$arena_settings_map_vote_timer_description",
			type = "slider",
			min = 15,
			max = 300,
			default = 90;
			display_multiplier = 1,
			formatting_func = function(value)
                -- trim spaces around value
                value = value:match("^%s*(.-)%s*$")
                -- if under 60, show seconds
                if(tonumber(value) < 60)then
                    return " "..tostring(value) .. "s"
                else
                    return " "..tostring(math.floor(value / 60)) .. "m"
                end
            end,
			width = 100
		},
        {
            id = "win_condition",
            name = "$arena_settings_win_condition_name",
            description = "$arena_settings_win_condition_description",
            type = "enum",
            options = { { "unlimited", "$arena_settings_win_condition_enum_unlimited" }, { "first_to", "$arena_settings_win_condition_enum_first_to" }, { "best_of", "$arena_settings_win_condition_enum_best_of" }, { "winstreak", "$arena_settings_win_condition_enum_winstreak" }},
            default = "unlimited"
        },
        {
			id = "win_condition_value",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_win_condition", "unlimited") ~= "unlimited"
            end,
			name = "$arena_settings_win_condition_value_name",
			description = "$arena_settings_win_condition_value_description",
			type = "slider",
			min = 1,
			max = 20,
			default = 5;
			display_multiplier = 1,
			formatting_string = " $0",
			width = 100
		},
        {
            id = "win_condition_end_match",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_win_condition", "unlimited") ~= "unlimited"
            end,
            name = "$arena_settings_win_condition_end_match_name",
            description = "$arena_settings_win_condition_end_match_description",
            type = "bool",
            default = true
        },
        {
            id = "perk_catchup",
            name = "$arena_settings_perk_reward_system_name",
            description = "$arena_settings_perk_reward_system_description",
            type = "enum",
            options = { { "everyone", "$arena_settings_reward_enum_everyone" }, { "winner", "$arena_settings_reward_enum_winner" }, { "losers", "$arena_settings_reward_enum_losers" }, { "first_death", "$arena_settings_reward_enum_first_death" }},
            default = "losers"
        },
        {
            id = "perk_sync",
            name = "$arena_settings_perk_sync_name",
            description = "$arena_settings_perk_sync_description",
            type = "bool",
            default = false
        },  
        {
            id = "item_shop",
            name = "$arena_settings_item_shop_name",
            description = "$arena_settings_item_shop_description",
            type = "bool",
            default = true
        },  
        {
            id = "shop_no_tiers",
			name = "$arena_settings_shop_disable_tiers_name",
			description = "$arena_settings_shop_disable_tiers_description",
            type = "bool",
            default = false
        },
		{
			id = "shop_type",
			name = "$arena_settings_shop_type_name",
			description = "$arena_settings_shop_type_description",
			type = "enum",
			options = { { "alternating", "$arena_settings_shop_type_alternating" }, { "random", "$arena_settings_shop_type_random" }, { "mixed", "$arena_settings_shop_type_mixed" },
				{ "spell_only", "$arena_settings_shop_type_spell_only" }, { "wand_only", "$arena_settings_shop_type_wand_only" } },
			default = "random"
		},
        {
            id = "shop_sync",
            name = "$arena_settings_shop_sync_name",
            description = "$arena_settings_shop_sync_description",
            type = "bool",
            default = false
        },  
		{
			id = "shop_wand_chance",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_shop_type", "random") == "mixed"
            end,
			name = "$arena_settings_shop_wand_chance_name",
			description = "$arena_settings_shop_wand_chance_description",
			type = "slider",
			min = 20,
			max = 80,
			default = 40;
			display_multiplier = 1,
			formatting_string = " $0%",
			width = 100
		},
        {
            id = "shop_start_level",
			name = "$arena_settings_shop_start_level_name",
			description = "$arena_settings_shop_start_level_description",
			type = "slider",
			min = 0,
			max = 10,
			default = 0;
			display_multiplier = 1,
			formatting_string = " $0",
			width = 100
        },
        {
			id = "shop_random_ratio",
			require = function(setting_self)
                return GlobalsGetValue("setting_next_shop_type", "random") == "random"
            end,
			name = "$arena_settings_shop_random_ratio_name",
			description = "$arena_settings_shop_random_ratio_description",
			type = "slider",
			min = 10,
			max = 90,
			default = 50;
			display_multiplier = 1,
			formatting_string = " $0%",
			width = 100
		},
        {
            id = "shop_scaling",
			name = "$arena_settings_shop_scaling_name",
			description = "$arena_settings_shop_scaling_description",
			type = "slider",
			min = 1,
			max = 10,
			default = 2;
			display_multiplier = 1,
			formatting_string = " $0",
			width = 100
        },
        {
            id = "shop_jump",
			name = "$arena_settings_shop_jump_name",
			description = "$arena_settings_shop_jump_description",
			type = "slider",
			min = 0,
			max = 10,
			default = 1;
			display_multiplier = 1,
			formatting_string = " $0",
			width = 100
        },
        {
            id = "max_shop_level",
			name = "$arena_settings_max_shop_level_name",
			description = "$arena_settings_max_shop_level_description",
			type = "slider",
			min = 1,
			max = 10,
			default = 5;
			display_multiplier = 1,
			formatting_string = " $0",
			width = 100
        },
        {
            id = "max_tier_true_random",
            name = "$arena_settings_max_tier_true_random_name",
            description = "$arena_settings_max_tier_true_random_desc",
            type = "bool",
            default = false
        },  
        {
            id = "shop_price_multiplier",
			name = "$arena_settings_shop_price_multiplier_name",
			description = "$arena_settings_shop_price_multiplier_description",
			type = "slider",
			min = 0,
			max = 30,
			default = 10;
			display_multiplier = 0.1,
            display_fractions = 1,
            modifier = function(value) 
                return math.floor(value)
            end,
			formatting_string = " $0",
			width = 100
        },
        --[[
        {
            id = "no_shop_cost",
            name = "$arena_settings_no_cost_name",
            description = "$arena_settings_no_cost_description",
            type = "bool",
            default = false
        },
        ]]
        {
            id = "damage_cap",
            name = "$arena_settings_damage_cap_name",
            description = "$arena_settings_damage_cap_description",
            type = "enum",
            options = { { "0.25", "$arena_settings_damage_cap_25" }, { "0.5", "$arena_settings_damage_cap_50" }, { "0.75", "$arena_settings_damage_cap_75" },
                { "disabled", "$arena_settings_damage_cap_disabled" } },
            default = "0.25"
        },
        {
            id = "zone_shrink",
            name = "$arena_settings_zone_shrink_name",
            description = "$arena_settings_zone_shrink_description",
            type = "enum",
            options = { { "disabled", "$arena_settings_zone_shrink_disabled" }, { "static", "$arena_settings_zone_shrink_static" }, { "shrinking_Linear", "$arena_settings_zone_shrink_linear" },
                { "shrinking_step", "$arena_settings_zone_shrink_stepped" } },
            default = "static"
        },
        {
            id = "zone_time",
            require = function(setting_self)
                return GlobalsGetValue("zone_shrink", "static") == "shrinking_Linear" or GlobalsGetValue("zone_shrink", "static") == "shrinking_step"
            end,
            name = "$arena_settings_zone_time_name",
            description = "$arena_settings_zone_time_description",
            type = "slider",    
            min = 1,
            max = 600,
            default = 120,
            display_multiplier = 1,
			formatting_func = function(value)
                -- trim spaces around value
                value = value:match("^%s*(.-)%s*$")
                -- if under 60, show seconds
                if(tonumber(value) < 60)then
                    return " "..tostring(value) .. "s"
                else
                    return " "..tostring(math.floor((value / 60) * 10) / 10) .. "m"
                end
            end,
            width = 100
        },
        {
            id = "zone_steps",
            require = function(setting_self)
                return GlobalsGetValue("zone_shrink", "static") == "shrinking_step"
            end,
            name = "$arena_settings_zone_steps_name",
            description = "$arena_settings_zone_steps_description",
            type = "slider",
            min = 1,
            max = 30,
            default = 6,
            display_multiplier = 1,
            formatting_string = " $0",
        },
        {
            id = "upgrades_system",
            name = "$arena_settings_upgrades_system_name",
            description = "$arena_settings_upgrades_system_description",
            type = "bool",
            default = false
        },
        {
            id = "upgrades_catchup",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_upgrades_system", "false") == "true"
            end,
            name = "$arena_settings_upgrades_reward_system_name",
            description = "$arena_settings_upgrades_reward_system_description",
            type = "enum",
            options = {{ "everyone", "$arena_settings_reward_enum_everyone" }, { "winner", "$arena_settings_reward_enum_winner" }, { "losers", "$arena_settings_reward_enum_losers" }, { "first_death", "$arena_settings_reward_enum_first_death" }},
            default = "losers"
        },
        {
            id = "wand_removal",
            name = "$arena_settings_wand_removal_name",
            description = "$arena_settings_wand_removal_description",
            type = "enum",
            options = { { "disabled", "$arena_settings_wand_removal_enum_none" }, { "random", "$arena_settings_wand_removal_enum_random" }, { "all", "$arena_settings_wand_removal_enum_all" } },
            default = "disabled"
        },
        {
            id = "wand_removal_who",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_wand_removal", "disabled") ~= "disabled"
            end,
            name = "$arena_settings_wand_removal_who_name",
            description = "$arena_settings_wand_removal_who_description",
            type = "enum",
            options = {{ "everyone", "$arena_settings_reward_enum_everyone" }, { "winner", "$arena_settings_reward_enum_winner" }, { "losers", "$arena_settings_reward_enum_losers" }, { "first_death", "$arena_settings_reward_enum_first_death" }},
            default = "everyone"
        },
        {
            id = "smash_mode",
            name = "$arena_settings_smash_mode_name",
            description = "$arena_settings_smash_mode_description",
            type = "bool",
            default = false
        }, 
        {
            id = "dunce",
            name = "$arena_cosmetics_dunce_hat_name",
            description = "$arena_cosmetics_dunce_hat_description",
            type = "bool",
            default = false
        }, 
        {
            id = "refresh",
            name = "$arena_settings_refresh_name",
            description = "$arena_settings_refresh_description",
            type = "bool",
            default = false
        }, 
        {
            id = "hm_timer_count",
			name = "$arena_settings_hm_timer_count_name",
			description = "$arena_settings_hm_timer_count_description",
			type = "slider",
			min = 0,
			max = 100,
			default = 80;
			display_multiplier = 1,
			formatting_string = " $0%",
			width = 100
        },
        {
			id = "hm_timer_time",
			require = function(setting_self)
                return tonumber(GlobalsGetValue("setting_next_hm_timer_count", "80")) < 100
            end,
			name = "$arena_settings_hm_timer_time_name",
			description = "$arena_settings_hm_timer_time_description",
			type = "slider",
			min = 1,
			max = 5 * 60,
			default = 60;
			display_multiplier = 1,
			formatting_func = function(value)
                value = math.floor(value)
                -- show seconds or minutes, if minutes, round to 1 decimal
                if(value < 60)then
                    return " "..tostring(value) .. "s"
                else
                    -- round to 1 decimal
                    return " "..tostring(math.floor((value / 60) * 100) / 100) .. "m"
                end
            end,
			width = 100
		},
        {
            id = "homing_mult",
			name = "$arena_settings_homing_mult_name",
			description = "$arena_settings_homing_mult_description",
			type = "slider",
			min = 0,
			max = 100,
			default = 100;
			display_multiplier = 1,
			formatting_string = " $0%",
			width = 100
        },
        {
            id = "homing_mult_self",
            name = "$arena_settings_homing_mult_self_name",
            description = "$arena_settings_homing_mult_self_description",
            type = "bool",
            default = false
        }, 
        {
            id = "health_scaling_type",
            name = "$arena_settings_health_scaling_type_name",
            description = "$arena_settings_health_scaling_type_description",
            type = "enum",
            options = { { "flat", "$arena_settings_health_scaling_enum_flat" }, { "mult", "$arena_settings_health_scaling_enum_mult" }},
            default = "mult"
        },
        {
            id = "health_scaling_mult_amount",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_health_scaling_type", "mult") == "mult"
            end,
			name = "$arena_settings_health_scaling_multiplier_amount_name",
			description = "$arena_settings_health_scaling_multiplier_amount_description",
			type = "slider",
			min = 10,
			max = 100,
			default = 12;
            formatting_func = function(value)
                value = math.floor(value)

                value = value / 10
                
                return " "..tostring(value).."x"
            end,
			display_multiplier = 1,
			width = 100
        },
        {
            id = "health_scaling_flat_amount",
            require = function(setting_self)
                return GlobalsGetValue("setting_next_health_scaling_type", "mult") == "flat"
            end,
            name = "$arena_settings_health_scaling_flat_amount_name",
            description = "$arena_settings_health_scaling_flat_amount_description",
            type = "slider",
            min = 0,
            max = 1000,
            default = 50;
            display_multiplier = 1,
            formatting_string = " $0",
            width = 100
        },
        {
            id = "instant_health",
            name = "$arena_settings_instant_health_name",
            description = "$arena_settings_instant_health_description",
            type = "bool",
            default = false
        }, 
        {
            id = "gold_scaling_type",
            name = "$arena_settings_gold_scaling_type_name",
            description = "$arena_settings_gold_scaling_type_description",
            type = "enum",
            options = { { "none", "$arena_settings_gold_scaling_type_none" }, { "exponential", "$arena_settings_gold_scaling_type_exponential" }, { "old", "$arena_settings_gold_scaling_type_old" }},
            default = "none"
        },
    },
    lobby_menus = {

        {
            id = "perk_blacklist",
            name = "$arena_settings_perk_blacklist_name",
            button_text = "$arena_settings_perk_blacklist_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)
                
                TryUpdateData(lobby)

                local id = new_id("perk_search_input")
                GuiZSetForNextWidget(gui, -5600)
                perk_search_content = GuiTextInput(gui, id, 0, 0, perk_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, perk in ipairs(sorted_perk_list)do
  
                            perk_blacklist_data[perk.id] = true
                        end
                        SendLobbyData(lobby)
                    end
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        for i, perk in ipairs(sorted_perk_list)do
 
                            perk_blacklist_data[perk.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end


                perk_filter_type = perk_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[perk_filter_type]))) then
                    if(perk_filter_type == "all")then
                        perk_filter_type = "blacklist"
                    elseif(perk_filter_type == "blacklist")then
                        perk_filter_type = "whitelist"
                    else
                        perk_filter_type = "all"
                    end
                end

                local iteration = 0
                for i, perk in ipairs(sorted_perk_list)do

                    local valid = true
                    if(perk_filter_type == "blacklist")then
                        valid = perk_blacklist_data[perk.id] == true
                    elseif(perk_filter_type == "whitelist")then
                        valid = not perk_blacklist_data[perk.id]
                    end


                    if(valid and (perk_search_content == "" or search(perk.id, perk.ui_name, perk_search_content, function() return perk_blacklist_data[perk.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, -((iteration - 1) * 2), true)
                        local is_blacklisted = perk_blacklist_data[perk.id]--steam.matchmaking.getLobbyData(lobby,"perk_blacklist_"..perk.id) == "true"
                        GuiZSetForNextWidget(gui, -5600)
                        GuiImage(gui, new_id(), 0, 0, perk.ui_icon, is_blacklisted and 0.4 or 1, 1, 1)
                        local visible, clicked, _, hovered = get_widget_info(gui)

                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                perk_blacklist_data[perk.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", perk.ui_description)
                        end
                        local icon_width, icon_height = GuiGetImageDimensions(gui, perk.ui_icon)
                        SetRandomSeed(iteration * 21, iteration * 245)
                        local strike_out = "mods/evaisa.arena/files/sprites/ui/strikeout/small_"..tostring(Random(1, 4))..".png"
                        local offset = 0
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -(icon_width - 1), 2, strike_out, 1, 1, 1)
                            offset = 2
                        end
                        local text_width, text_height = GuiGetTextDimensions(gui, perk.ui_name)
                        GuiZSetForNextWidget(gui, -5600)
                        if(is_blacklisted)then
                            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1)
                        end
                        if(GuiButton(gui, new_id(), offset, ((icon_height / 2) - (text_height / 2)), perk.ui_name))then
                            if(steam_utils.IsOwner())then
                                perk_blacklist_data[perk.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", perk.ui_description)
                        end
                        GuiLayoutEnd(gui)
                    end
                end
                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
        {
            id = "spell_blacklist",
            name = "$arena_settings_spell_blacklist_name",
            button_text = "$arena_settings_spell_blacklist_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)

                TryUpdateData(lobby)

                local id = new_id("spell_search_input")
                GuiZSetForNextWidget(gui, -5600)
                spell_search_content = GuiTextInput(gui, id, 0, 0, spell_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, spell in ipairs(sorted_spell_list)do
                            spell_blacklist_data[spell.id] = true
                        end
                        SendLobbyData(lobby)
                    end
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        for i, spell in ipairs(sorted_spell_list)do
                            spell_blacklist_data[spell.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end
                
                --GuiIdPushString(gui, "spell_blacklist")

                --[[local id = 21
                local new_id = function()
                    id = id + 1
                    return id
                end]]


                spell_filter_type = spell_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[spell_filter_type]))) then
                    if(spell_filter_type == "all")then
                        spell_filter_type = "blacklist"
                    elseif(spell_filter_type == "blacklist")then
                        spell_filter_type = "whitelist"
                    else
                        spell_filter_type = "all"
                    end
                end



                local iteration = 0

                for i, spell in ipairs(sorted_spell_list)do
                    
                    local valid = true
                    if(spell_filter_type == "blacklist")then
                        valid = spell_blacklist_data[spell.id] == true
                    elseif(spell_filter_type == "whitelist")then
                        valid = not spell_blacklist_data[spell.id]
                    end


                    if(valid and (spell_search_content == "" or search(spell.id, spell.name, spell_search_content, function() return spell_blacklist_data[spell.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, -((iteration - 1) * 2), true)
                        local is_blacklisted = spell_blacklist_data[spell.id] --steam.matchmaking.getLobbyData(lobby,"spell_blacklist_"..spell.id) == "true"
                        GuiZSetForNextWidget(gui, -5600)
                        GuiImage(gui, new_id(), 0, 0, spell.sprite, is_blacklisted and 0.4 or 1, 1, 1)
                        local visible, clicked, _, hovered = get_widget_info(gui)

                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                spell_blacklist_data[spell.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", spell.description)
                        end
                        local icon_width, icon_height = GuiGetImageDimensions(gui, spell.sprite)
                        SetRandomSeed(iteration * 21, iteration * 245)
                        local strike_out = "mods/evaisa.arena/files/sprites/ui/strikeout/small_"..tostring(Random(1, 4))..".png"
                        local offset = 0
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -(icon_width - 1), 2, strike_out, 1, 1, 1)
                            offset = 2
                        end
                        local text_width, text_height = GuiGetTextDimensions(gui, spell.name)
                        --GuiText(gui, offset, ((icon_height / 2) - (text_height / 2)), spell.name)
                        if(is_blacklisted)then
                            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1)
                        end
                        GuiZSetForNextWidget(gui, -5600)
                        if(GuiButton(gui, new_id(), offset, ((icon_height / 2) - (text_height / 2)), spell.name))then
                            if(steam_utils.IsOwner())then
                                spell_blacklist_data[spell.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", spell.description)
                        end
                        GuiLayoutEnd(gui)
                    end
                end

                --GuiIdPop(gui)

                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
        {
            id = "card_blacklist",
            name = "$arena_settings_card_blacklist_name",
            button_text = "$arena_settings_card_blacklist_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)
                
                TryUpdateData(lobby)

                local id = new_id("card_search_input")
                GuiZSetForNextWidget(gui, -5600)
                card_search_content = GuiTextInput(gui, id, 0, 0, card_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, card in ipairs(sorted_card_list)do
  
                            card_blacklist_data[card.id] = true
                        end
                        SendLobbyData(lobby)
                    end
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        for i, card in ipairs(sorted_card_list)do
 
                            card_blacklist_data[card.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end


                card_filter_type = card_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[card_filter_type]))) then
                    if(card_filter_type == "all")then
                        card_filter_type = "blacklist"
                    elseif(card_filter_type == "blacklist")then
                        card_filter_type = "whitelist"
                    else
                        card_filter_type = "all"
                    end
                end

                local iteration = 0
                for i, card in ipairs(sorted_card_list)do

                    local valid = true
                    if(card_filter_type == "blacklist")then
                        valid = card_blacklist_data[card.id] == true
                    elseif(card_filter_type == "whitelist")then
                        valid = not card_blacklist_data[card.id]
                    end


                    if(valid and (card_search_content == "" or search(card.id, card.ui_name, card_search_content, function() return card_blacklist_data[card.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, -((iteration - 1) * 2), true)
                        local is_blacklisted = card_blacklist_data[card.id]--steam.matchmaking.getLobbyData(lobby,"card_blacklist_"..card.id) == "true"
                        GuiZSetForNextWidget(gui, -5600)
                        GuiColorSetForNextWidget(gui, card.card_symbol_tint and card.card_symbol_tint[1] or 1, card.card_symbol_tint and card.card_symbol_tint[2] or 1, card.card_symbol_tint and card.card_symbol_tint[3] or 1, 1)
                        GuiImage(gui, new_id(), 0, 0, card.card_symbol, is_blacklisted and 0.4 or 1, 1, 1)
                        local visible, clicked, _, hovered = get_widget_info(gui)

                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                card_blacklist_data[card.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", card.ui_description)
                        end
                        local icon_width, icon_height = GuiGetImageDimensions(gui, card.card_symbol)
                        SetRandomSeed(iteration * 21, iteration * 245)
                        local strike_out = "mods/evaisa.arena/files/sprites/ui/strikeout/small_"..tostring(Random(1, 4))..".png"
                        local offset = 0
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -(icon_width - 1), 2, strike_out, 1, 1, 1)
                            offset = 2
                        end
                        local text_width, text_height = GuiGetTextDimensions(gui, card.ui_name)
                        GuiZSetForNextWidget(gui, -5600)
                        if(is_blacklisted)then
                            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1)
                        end
                        if(GuiButton(gui, new_id(), offset, ((icon_height / 2) - (text_height / 2)), card.ui_name))then
                            if(steam_utils.IsOwner())then
                                card_blacklist_data[card.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", card.ui_description)
                        end
                        GuiLayoutEnd(gui)
                    end
                end
                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
        {
            id = "item_blacklist",
            name = "$arena_settings_item_blacklist_name",
            button_text = "$arena_settings_item_blacklist_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)
                
                TryUpdateData(lobby)

                local id = new_id("item_search_input")
                GuiZSetForNextWidget(gui, -5600)
                item_search_content = GuiTextInput(gui, id, 0, 0, item_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, item in ipairs(sorted_item_list)do
  
                            item_blacklist_data[item.id] = true
                        end
                        SendLobbyData(lobby)
                    end
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        for i, item in ipairs(sorted_item_list)do
 
                            item_blacklist_data[item.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end


                item_filter_type = item_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[item_filter_type]))) then
                    if(item_filter_type == "all")then
                        item_filter_type = "blacklist"
                    elseif(item_filter_type == "blacklist")then
                        item_filter_type = "whitelist"
                    else
                        item_filter_type = "all"
                    end
                end

                local iteration = 0
                for i, item in ipairs(sorted_item_list)do

                    local valid = true
                    if(item_filter_type == "blacklist")then
                        valid = item_blacklist_data[item.id] == true
                    elseif(item_filter_type == "whitelist")then
                        valid = not item_blacklist_data[item.id]
                    end

                    if(valid and (item_search_content == "" or search(item.id, item.ui_name, item_search_content, function() return item_blacklist_data[item.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, -((iteration - 1) * 2), true)
                        local is_blacklisted = item_blacklist_data[item.id]--steam.matchmaking.getLobbyData(lobby,"item_blacklist_"..item.id) == "true"
                        GuiZSetForNextWidget(gui, -5600)
                        GuiImage(gui, new_id(), 0, 0, item.sprite, is_blacklisted and 0.4 or 1, 1, 1)
                        local visible, clicked, _, hovered = get_widget_info(gui)

                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                item_blacklist_data[item.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", item.ui_description)
                        end
                        local icon_width, icon_height = GuiGetImageDimensions(gui, item.sprite)
                        SetRandomSeed(iteration * 21, iteration * 245)
                        local strike_out = "mods/evaisa.arena/files/sprites/ui/strikeout/small_"..tostring(Random(1, 4))..".png"
                        local offset = 0
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -(icon_width - 1), 2, strike_out, 1, 1, 1)
                            offset = 2
                        end
                        local text_width, text_height = GuiGetTextDimensions(gui, item.ui_name)
                        GuiZSetForNextWidget(gui, -5600)
                        if(is_blacklisted)then
                            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1)
                        end
                        if(GuiButton(gui, new_id(), offset, ((icon_height / 2) - (text_height / 2)), item.ui_name))then
                            if(steam_utils.IsOwner())then
                                item_blacklist_data[item.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", item.ui_description)
                        end
                        GuiLayoutEnd(gui)
                    end
                end
                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
        {
            id = "material_blacklist",
            name = "$arena_settings_material_blacklist_name",
            button_text = "$arena_settings_material_blacklist_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)
                
                TryUpdateData(lobby)

                local id = new_id("material_search_input")
                GuiZSetForNextWidget(gui, -5600)
                material_search_content = GuiTextInput(gui, id, 0, 0, material_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, material in ipairs(sorted_material_list)do
  
                            material_blacklist_data[material.id] = true
                        end
                        SendLobbyData(lobby)
                    end
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        for i, material in ipairs(sorted_material_list)do
 
                            material_blacklist_data[material.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end

                material_filter_type = material_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[material_filter_type]))) then
                    if(material_filter_type == "all")then
                        material_filter_type = "blacklist"
                    elseif(material_filter_type == "blacklist")then
                        material_filter_type = "whitelist"
                    else
                        material_filter_type = "all"
                    end
                end

                local iteration = 0
                for i, material in ipairs(sorted_material_list)do
                    local sprite_path = "data/generated/material_icons/"..material.id..".png"
                    if(not ModImageDoesExist(sprite_path))then
                        sprite_path = "data/generated/material_icons/trailer_text.png"
                    end
                    material.sprite = sprite_path

                    local valid = true
                    if(material_filter_type == "blacklist")then
                        valid = material_blacklist_data[material.id] == true
                    elseif(material_filter_type == "whitelist")then
                        valid = not material_blacklist_data[material.id]
                    end


                    if(valid and (material_search_content == "" or search(material.id, material.ui_name, material_search_content, function() return material_blacklist_data[material.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, -((iteration - 1) * 2), true)
                        local is_blacklisted = material_blacklist_data[material.id]--steam.matchmaking.getLobbyData(lobby,"material_blacklist_"..material.id) == "true"
                        GuiZSetForNextWidget(gui, -5600)
                        GuiImage(gui, new_id(), 0, 0, material.sprite, is_blacklisted and 0.4 or 1, 1, 1)
                        local visible, clicked, _, hovered = get_widget_info(gui)

                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                material_blacklist_data[material.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", "")
                        end
                        local icon_width, icon_height = GuiGetImageDimensions(gui, material.sprite)
                        SetRandomSeed(iteration * 21, iteration * 245)
                        local strike_out = "mods/evaisa.arena/files/sprites/ui/strikeout/medium_"..tostring(Random(1, 4))..".png"
                        local offset = 0
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -(icon_width + 2), 2, strike_out, 1, 1, 1)
                        end
                        local text_width, text_height = GuiGetTextDimensions(gui, material.ui_name)
                        GuiZSetForNextWidget(gui, -5600)
                        if(is_blacklisted)then
                            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1)
                        end
                        if(GuiButton(gui, new_id(), offset, ((icon_height / 2) - (text_height / 2)), material.ui_name))then
                            if(steam_utils.IsOwner())then
                                material_blacklist_data[material.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        if(visible and hovered)then
                            GuiTooltip(gui, steamutils.IsOwner() and GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist") or "", "")
                        end
                        GuiLayoutEnd(gui)
                    end
                end
                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
        {
            id = "map_pool",
            name = "$arena_settings_map_pool_name",
            button_text = "$arena_settings_map_pool_name",
            draw = function(lobby, gui, new_id)
                GuiLayoutBeginVertical(gui, 0, 0, true, 0, 0)

                TryUpdateData(lobby)

                local id = new_id("map_search_input")
                GuiZSetForNextWidget(gui, -5600)
                map_search_content = GuiTextInput(gui, id, 0, 0, map_search_content or "", 140, 20)

                local _, _, hover = GuiGetPreviousWidgetInfo(gui)

                
                if(hover)then
                    GameAddFlagRun("chat_bind_disabled")
                end

                if(steam_utils.IsOwner())then
                    GuiZSetForNextWidget(gui, -5600)
                    if GuiButton(gui, new_id(), 0, 0, "$arena_disable_all") then
                        for i, map in ipairs(sorted_map_list)do
                            map_blacklist_data[map.id] = true
                        end
                        SendLobbyData(lobby)
                    end

                    if GuiButton(gui, new_id(), 0, 0, "$arena_enable_all") then
                        GuiZSetForNextWidget(gui, -5600)
                        for i, map in ipairs(sorted_map_list)do
                            map_blacklist_data[map.id] = false
                        end
                        SendLobbyData(lobby)
                    end
                end
                
                --GuiIdPushString(gui, "spell_blacklist")

                --[[local id = 21
                local new_id = function()
                    id = id + 1
                    return id
                end]]

                
                map_filter_type = map_filter_type or "all"

                GuiZSetForNextWidget(gui, -5600)
                if GuiButton(gui, new_id(), 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_blacklist_filter"), GameTextGetTranslatedOrNot(filter_types[map_filter_type]))) then
                    if(map_filter_type == "all")then
                        map_filter_type = "blacklist"
                    elseif(map_filter_type == "blacklist")then
                        map_filter_type = "whitelist"
                    else
                        map_filter_type = "all"
                    end
                end

                local iteration = 0

                for i, map in ipairs(sorted_map_list)do
                    local valid = true
                    if(map_filter_type == "blacklist")then
                        valid = map_blacklist_data[map.id] == true
                    elseif(map_filter_type == "whitelist")then
                        valid = not map_blacklist_data[map.id]
                    end

                    if(valid and (map_search_content == "" or search(map.id, map.name, map_search_content, function() return map_blacklist_data[map.id] end))) then
                        iteration = iteration + 1
                        GuiLayoutBeginHorizontal(gui, 0, ((iteration - 1)), true)
                        local is_blacklisted = map_blacklist_data[map.id]
                        local scale = 1

                        GuiZSetForNextWidget(gui, -5605)
                        local icon_width, icon_height = GuiGetImageDimensions(gui, map.thumbnail or "mods/evaisa.arena/content/arenas/default_thumbnail.png")
                        GuiImage(gui, new_id("map_list_stuff"), 0, 0, map.frame, 1, scale, scale)
                        local frame_width, frame_height = GuiGetImageDimensions(gui, map.frame)

                        
                        if(is_blacklisted)then
                            GuiZSetForNextWidget(gui, -5610)
                            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
                            GuiImage(gui, new_id(), -frame_width-2, 0, "mods/evaisa.arena/content/arenas/disabled.png", 1, 1, 1)
                        end

                        GuiZSetForNextWidget(gui, -5600)
                        local alpha = 1
                        if(is_blacklisted)then
                            alpha = 0.4
                        end
                        
                        GuiImage(gui, new_id("map_list_stuff"), -(icon_width * scale) - 2.5, 1, map.thumbnail or "mods/evaisa.arena/content/arenas/default_thumbnail.png", alpha, scale * 0.99, scale * 0.99)
                        
                        

                        local visible, clicked, _, hovered = get_widget_info(gui)


                        if(visible and clicked)then
                            if(steam_utils.IsOwner())then
                                map_blacklist_data[map.id] = not is_blacklisted

                                GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos() )
                                SendLobbyData(lobby)
                            end
                        end
                        if(visible and hovered)then
                            CustomTooltip(gui, function() 

                                local widest_string = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist"))

                                local text_width, text_height = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(map.name))

                                if text_width > widest_string then
                                    widest_string = text_width
                                end

                                local text_width, text_height = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(map.description))

                                if text_width > widest_string then
                                    widest_string = text_width
                                end

                                local text_width, text_height = GuiGetTextDimensions(gui, string.format(GameTextGetTranslatedOrNot("$arena_maps_credits"), GameTextGetTranslatedOrNot(map.credits or "???")))

                                if text_width > widest_string then
                                    widest_string = text_width
                                end



                                --GuiZSetForNextWidget(menu_gui, -5110)
                                if(steamutils.IsOwner())then
                                    GuiColorSetForNextWidget( gui, 1, 0.4, 0.4, 1 )
                                    GuiZSetForNextWidget(gui, -7110)
                                    GuiText(gui, -widest_string, 0, GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist"))
                                end
                                GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
                                GuiZSetForNextWidget(gui, -7110)
                                GuiText(gui, -widest_string, 0, GameTextGetTranslatedOrNot(map.name))
                                GuiColorSetForNextWidget( gui, 1, 1, 1, 0.8 )
                                GuiZSetForNextWidget(gui, -7110)
                                GuiText(gui, -widest_string, 0, GameTextGetTranslatedOrNot(map.description))
                                GuiColorSetForNextWidget( gui, 1, 1, 1, 0.6 )
                                GuiZSetForNextWidget(gui, -7110)
                                GuiText(gui, -widest_string, 0, string.format(GameTextGetTranslatedOrNot("$arena_maps_credits"), GameTextGetTranslatedOrNot(map.credits or "???")))
                            end, -7100, -255, 10)
                            --GuiTooltip(gui, GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist"), GameTextGetTranslatedOrNot(map.name))
                        end
                        

                        SetRandomSeed(iteration * 21, iteration * 245)
       
                        GuiZSetForNextWidget(gui, -5630)
                        local text_width, text_height = GuiGetTextDimensions(gui, GameTextGetTranslatedOrNot(map.name))

                        local offset = 6

                        GuiColorSetForNextWidget(gui, 0, 0, 0, 1)
                        GuiText(gui, -(icon_width * scale) + offset, offset, GameTextGetTranslatedOrNot(map.name))
                        GuiZSetForNextWidget(gui, -5631)
                        if(GuiButton(gui, new_id("map_list_stuff"), -(text_width + 2) - 1, offset-1, GameTextGetTranslatedOrNot(map.name)))then
                            if(steam_utils.IsOwner())then
                                map_blacklist_data[map.id] = not is_blacklisted
                                SendLobbyData(lobby)
                            end
                        end
                        local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
                        --[[if(visible and hovered)then
                            CustomTooltip(gui, function() 
                                --GuiZSetForNextWidget(menu_gui, -5110)
                                GuiColorSetForNextWidget( gui, 1, 1, 1, 0.8 )
                                --GuiText(menu_gui, 0, 0, "Show Code")
                                GuiZSetForNextWidget(gui, -5110)
                                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist"))
                                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(map.name))
                                GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(map.description))
                                GuiText(gui, 0, 0, string.format(GameTextGetTranslatedOrNot("$arena_maps_credits"), GameTextGetTranslatedOrNot(map.credits)))
                            end, -5100, -68, -20)
                            --GuiTooltip(gui, GameTextGetTranslatedOrNot("$arena_settings_hover_tooltip_blacklist"), GameTextGetTranslatedOrNot(map.name))
                        end]]
                        GuiLayoutEnd(gui)
                    end
                end

                GuiLayoutEnd(gui)
            end,
            close = function()

            end
        },
    },
    commands = {
        ready = function(command_name, arguments)
            if(GameHasFlagRun("lock_ready_state"))then
                return
            end
            
            if(GameHasFlagRun("ready_check"))then
                ChatPrint(GameTextGetTranslatedOrNot("$arena_self_unready"))
                GameAddFlagRun("player_unready")
                GameRemoveFlagRun("ready_check")
                GameRemoveFlagRun("player_ready")
            else
                ChatPrint(GameTextGetTranslatedOrNot("$arena_self_ready"))
                GameAddFlagRun("player_ready")
                GameAddFlagRun("ready_check")
                GameRemoveFlagRun("player_unready")
            end


        end
    },
    default_data = {
        total_gold = "0",
        holyMountainCount = "0",
        ready_players = "null",
    },
    save_preset = function(lobby, preset_data)
        preset_data.perk_blacklist_data = perk_blacklist_data
        preset_data.spell_blacklist_data = spell_blacklist_data
        preset_data.map_blacklist_data = map_blacklist_data
        preset_data.card_blacklist_data = card_blacklist_data
        preset_data.item_blacklist_data = item_blacklist_data
        preset_data.material_blacklist_data = material_blacklist_data
        return preset_data
    end,
    load_preset = function(lobby, preset_data)
        perk_blacklist_data = preset_data.perk_blacklist_data or {}
        spell_blacklist_data = preset_data.spell_blacklist_data or {}
        map_blacklist_data = preset_data.map_blacklist_data or {}
        card_blacklist_data = preset_data.card_blacklist_data or {}
        item_blacklist_data = preset_data.item_blacklist_data or {}
        material_blacklist_data = preset_data.material_blacklist_data or {}

        --print(json.stringify(perk_blacklist_data))

        if(steam_utils.IsOwner())then
            SendLobbyData(lobby)
        end
    end,
    refresh = function(lobby)


        if(MP_VERSION < ArenaMode.required_online_version)then
            invalid_version_popup_active = invalid_version_popup_active or false
            if(not invalid_version_popup_active)then
                popup.create("bad_online", GameTextGetTranslatedOrNot("$arena_bad_online_version"), string.format(GameTextGetTranslatedOrNot("$arena_bad_online_version_desc"), ArenaMode.required_online_version), {
                    {
                        text = GameTextGetTranslatedOrNot("$arena_online_update"),
                        callback = function()
                            invalid_version_popup_active = false
                            os.execute("start explorer \"" .. noita_online_download .. "\"")
                        end
                    },
                    {
                        text = GameTextGetTranslatedOrNot("$mp_close_popup"),
                        callback = function()
                            invalid_version_popup_active = false
                        end
                    }
                }, -6000)

                invalid_version_popup_active = true
                        
                disconnect({
                    lobbyID = lobby,
                    message = GameTextGetTranslatedOrNot("$arena_bad_online_version")
                })
            end
        end

        print("refreshing arena settings")
        --GamePrint("refreshing arena settings")

        TryUpdateData(lobby)

        if(not invalid_version_popup_active and tostring(content_hash) ~= steam.matchmaking.getLobbyData(lobby,"content_hash"))then
            if(steam_utils.IsOwner())then
                print("content hash mismatch, updating")
                steam_utils.TrySetLobbyData(lobby, "content_hash", content_hash)
                steam_utils.TrySetLobbyData(lobby, "mod_list", player_mods)
            else
                was_content_mismatched = true
                content_hash_popup_active = content_hash_popup_active or false
                if(content_hash_popup_active)then
                    return
                end

                popup.create("content_mismatch", GameTextGetTranslatedOrNot("$arena_content_mismatch_name"),{
					{
						text = GameTextGetTranslatedOrNot("$arena_content_mismatch_description"),
						color = {214 / 255, 60 / 255, 60 / 255, 1}
					},
                    {
						text = GameTextGetTranslatedOrNot("$arena_content_mismatch_description_2"),
						color = {214 / 255, 60 / 255, 60 / 255, 1}
					},
                    GameTextGetTranslatedOrNot("$arena_content_mismatch_description_3")
				}, {
					{
						text = GameTextGetTranslatedOrNot("$mp_close_popup"),
						callback = function()
                            content_hash_popup_active = false
						end
					}
				}, -6000)
            end
        end
  

        dofile("data/scripts/perks/perk_list.lua")
        dofile("data/scripts/gun/gun_actions.lua")

        for i, perk in ipairs(perk_list)do
            local is_blacklisted = perk_blacklist_data[perk.id]--steam.matchmaking.getLobbyData(lobby, "perk_blacklist_"..perk.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("perk_blacklist_"..perk.id)
            else
                GameRemoveFlagRun("perk_blacklist_"..perk.id)
            end
        end

        for _, spell in pairs(actions)do
            local is_blacklisted = spell_blacklist_data[spell.id]--steam.matchmaking.getLobbyData(lobby, "spell_blacklist_"..spell.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("spell_blacklist_"..spell.id)
            else
                GameRemoveFlagRun("spell_blacklist_"..spell.id)
            end
        end

        for _, map in pairs(arena_list)do
            local is_blacklisted = map_blacklist_data[map.id]--steam.matchmaking.getLobbyData(lobby, "map_blacklist_"..map.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("map_blacklist_"..map.id)
            else
                GameRemoveFlagRun("map_blacklist_"..map.id)
            end
        end

        for _, card in pairs(upgrades)do
            local is_blacklisted = card_blacklist_data[card.id]--steam.matchmaking.getLobbyData(lobby, "card_blacklist_"..card.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("card_blacklist_"..card.id)
            else
                GameRemoveFlagRun("card_blacklist_"..card.id)
            end
        end

        for _, item in pairs(item_spawnlist)do
            local is_blacklisted = item_blacklist_data[item.id]--steam.matchmaking.getLobbyData(lobby, "item_blacklist_"..item.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("item_blacklist_"..item.id)
            else
                GameRemoveFlagRun("item_blacklist_"..item.id)
            end
        end

        UpdateMaterials()

        for _, material in pairs(materials)do
            local is_blacklisted = material_blacklist_data[material.id]--steam.matchmaking.getLobbyData(lobby, "material_blacklist_"..material.id) == "true"
            if(is_blacklisted)then
                GameAddFlagRun("material_blacklist_"..material.id)
            else
                GameRemoveFlagRun("material_blacklist_"..material.id)
            end
        end

        local random_seeds = steam.matchmaking.getLobbyData(lobby, "setting_random_seed")
        if (random_seeds == nil) then
            random_seeds = "true"
        end
        local old_randomized_seed = randomized_seed
        randomized_seed = random_seeds == "true"
        --[[if(randomized_seed and randomized_seed ~= old_randomized_seed)then
            SetNewSeed(lobby)
        end]]

        local gamemode = steam.matchmaking.getLobbyData(lobby, "setting_arena_gamemode")
        if (gamemode == nil) then
            gamemode = "ffa"
        end
        GlobalsSetValue("arena_gamemode", tostring(gamemode))

        local map_picker = steam.matchmaking.getLobbyData(lobby, "setting_map_picker")
        if (map_picker == nil) then
            map_picker = "random"
        end
        GlobalsSetValue("map_picker", tostring(map_picker))

        local map_vote_timer = tonumber(tonumber(steam.matchmaking.getLobbyData(lobby, "setting_map_vote_timer")))
        if (map_vote_timer == nil) then
            map_vote_timer = 90
        end
        GlobalsSetValue("map_vote_timer", tostring(map_vote_timer))

        local win_condition = steam.matchmaking.getLobbyData(lobby, "setting_win_condition")
        if (win_condition == nil)then
            win_condition = "unlimited"
        end
        GlobalsSetValue("win_condition", tostring(win_condition))

        local win_condition_value = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_win_condition_value"))
        if (win_condition_value == nil)then
            win_condition_value = 5
        end
        GlobalsSetValue("win_condition_value", tostring(math.floor(win_condition_value)))

        local win_condition_end_match = steam.matchmaking.getLobbyData(lobby, "setting_win_condition_end_match")
        if (win_condition_end_match == nil)then
            win_condition_end_match = "true"
        end
        if(win_condition_end_match == "true")then
            GameAddFlagRun("win_condition_end_match")
        else
            GameRemoveFlagRun("win_condition_end_match")
        end

        local perk_catchup = steam.matchmaking.getLobbyData(lobby, "setting_perk_catchup")
        if (perk_catchup == nil) then
            perk_catchup = "losers"
        end
        GlobalsSetValue("perk_catchup", tostring(perk_catchup))

        local perk_sync = steam.matchmaking.getLobbyData(lobby, "setting_perk_sync")
        if (perk_sync == nil) then
            perk_sync = "false"
        end
        if(perk_sync == "true")then
            GameAddFlagRun("perk_sync")
        else
            GameRemoveFlagRun("perk_sync")
        end
        

		local shop_type = steam.matchmaking.getLobbyData(lobby, "setting_shop_type")
		if (shop_type == nil) then
			shop_type = "random"
		end
        --print("shop_type: " .. shop_type)
		GlobalsSetValue("shop_type", tostring(shop_type))

        local shop_sync = steam.matchmaking.getLobbyData(lobby, "setting_shop_sync")
        if (shop_sync == nil) then
            shop_sync = "false"
        end
        if(shop_sync == "true")then
            GameAddFlagRun("shop_sync")
        else
            GameRemoveFlagRun("shop_sync")
        end

        local item_shop = steam.matchmaking.getLobbyData(lobby, "setting_item_shop")
        if (item_shop == nil) then
            item_shop = "true"
        end
        if(item_shop == "true")then
            GameAddFlagRun("item_shop")
        else
            GameRemoveFlagRun("item_shop")
        end

        local shop_no_tiers = steam.matchmaking.getLobbyData(lobby, "setting_shop_no_tiers")
        if (shop_no_tiers == nil) then
            shop_no_tiers = "false"
        end
        if(shop_no_tiers == "true")then
            GameAddFlagRun("shop_no_tiers")
        else
            GameRemoveFlagRun("shop_no_tiers")
        end

		local shop_wand_chance = steam.matchmaking.getLobbyData(lobby, "setting_shop_wand_chance")
		if (shop_wand_chance == nil) then
			shop_wand_chance = 20
		end
		GlobalsSetValue("shop_wand_chance", tostring(shop_wand_chance))

        local shop_random_ratio = steam.matchmaking.getLobbyData(lobby, "setting_shop_random_ratio")
        if (shop_random_ratio == nil) then
            shop_random_ratio = 50
        end
        GlobalsSetValue("shop_random_ratio", tostring(shop_random_ratio))

        local shop_start_level = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_shop_start_level"))
        if (shop_start_level == nil) then
            shop_start_level = 0
        end
        GlobalsSetValue("shop_start_level", tostring(shop_start_level))

        local shop_scaling = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_shop_scaling"))
        if (shop_scaling == nil) then
            shop_scaling = 2
        end
        GlobalsSetValue("shop_scaling", tostring(shop_scaling))

        local shop_jump = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_shop_jump"))
        if (shop_jump == nil) then
            shop_jump = 1
        end
        GlobalsSetValue("shop_jump", tostring(shop_jump))

        local max_shop_level = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_max_shop_level"))
        if (max_shop_level == nil) then
            max_shop_level = 5
        end
        GlobalsSetValue("max_shop_level", tostring(max_shop_level))

        local max_tier_true_random = steam.matchmaking.getLobbyData(lobby, "setting_max_tier_true_random")
        if (max_tier_true_random == nil) then
            max_tier_true_random = "false"
        end
        if(max_tier_true_random == "true")then
            GameAddFlagRun("max_tier_true_random")
        else
            GameRemoveFlagRun("max_tier_true_random")
        end

        shop_price_multiplier = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_shop_price_multiplier"))
        if (shop_price_multiplier == nil) then
            shop_price_multiplier = 10
        end
        GlobalsSetValue("shop_price_multiplier", tostring(shop_price_multiplier * 0.1))
        if(shop_price_multiplier < 1)then
            GlobalsSetValue("no_shop_cost", "true")
        else
            GlobalsSetValue("no_shop_cost", "false")
        end

        --[[local no_shop_cost = steam.matchmaking.getLobbyData(lobby, "setting_no_shop_cost")	
        if (no_shop_cost == nil) then
            no_shop_cost = false
        end
        print("no_shop_cost: " .. tostring(no_shop_cost))
        GlobalsSetValue("no_shop_cost", tostring(no_shop_cost))]]
        

        local damage_cap = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_damage_cap"))
        if (damage_cap == nil) then
            damage_cap = 0.25
        end
        GlobalsSetValue("damage_cap", tostring(damage_cap))

        local zone_shrink = steam.matchmaking.getLobbyData(lobby, "setting_zone_shrink")
        if (zone_shrink == nil) then
            zone_shrink = "static"
        end
        GlobalsSetValue("zone_shrink", tostring(zone_shrink))

        local zone_time = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_zone_time"))
        if (zone_time == nil) then
            zone_time = 120
        end
        GlobalsSetValue("zone_time", tostring(zone_time))

        local zone_steps = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_zone_steps"))
        if (zone_steps == nil) then
            zone_steps = 6
        end
        GlobalsSetValue("zone_steps", tostring(zone_steps))

        local upgrades_system = steam.matchmaking.getLobbyData(lobby, "setting_upgrades_system")
        if (upgrades_system == nil) then
            upgrades_system = "false"
        end
        if (upgrades_system == "true") then
            GameAddFlagRun("upgrades_system")
        else
            GameRemoveFlagRun("upgrades_system")
        end

        local upgrades_catchup = steam.matchmaking.getLobbyData(lobby, "setting_upgrades_catchup")
        if (upgrades_catchup == nil) then
            upgrades_catchup = "losers"
        end
        GlobalsSetValue("upgrades_catchup", tostring(upgrades_catchup))

        local wand_removal = steam.matchmaking.getLobbyData(lobby, "setting_wand_removal")
        if (wand_removal == nil) then
            wand_removal = "disabled"
        end
        GlobalsSetValue("wand_removal", tostring(wand_removal))

        local wand_removal_who = steam.matchmaking.getLobbyData(lobby, "setting_wand_removal_who")
        if (wand_removal_who == nil) then
            wand_removal_who = "everyone"
        end
        GlobalsSetValue("wand_removal_who", tostring(wand_removal_who))

        local smash_mode = steam.matchmaking.getLobbyData(lobby, "setting_smash_mode")
        if (smash_mode == nil) then
            smash_mode = "false"
        end
        if(smash_mode == "true")then
            GameAddFlagRun("smash_mode")
        else
            GameRemoveFlagRun("smash_mode")
        end

        local dunce = steam.matchmaking.getLobbyData(lobby, "setting_dunce")
        if (dunce == nil) then
            dunce = "false"
        end
        if(dunce == "true")then
            GameAddFlagRun("dunce")
        else
            GameRemoveFlagRun("dunce")
        end

        local refresh = steam.matchmaking.getLobbyData(lobby, "setting_refresh")
        if (refresh == nil) then
            refresh = "false"
        end
        if(refresh == "true")then
            GameAddFlagRun("refresh_all_charges")
        else
            GameRemoveFlagRun("refresh_all_charges")
        end

        local hm_timer_count = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_hm_timer_count"))
        if (hm_timer_count == nil) then
            hm_timer_count = 0
        end
        GlobalsSetValue("hm_timer_count", tostring(math.floor(hm_timer_count)))

        local hm_timer_time = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_hm_timer_time"))
        if (hm_timer_time == nil) then
            hm_timer_time = 60
        end
        GlobalsSetValue("hm_timer_time", tostring(math.floor(hm_timer_time)))

        local homing_mult = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_homing_mult"))
        if (homing_mult == nil) then
            homing_mult = 100
        end
        GlobalsSetValue("homing_mult", tostring(homing_mult))
        
        local homing_mult_self = steam.matchmaking.getLobbyData(lobby, "setting_homing_mult_self")
        if (homing_mult_self == nil) then
            homing_mult_self = "false"
        end
        if(homing_mult_self == "true")then
            GameAddFlagRun("homing_mult_self")
        else
            GameRemoveFlagRun("homing_mult_self")
        end

        local health_scaling_type = steam.matchmaking.getLobbyData(lobby, "setting_health_scaling_type")
        if (health_scaling_type == nil) then
            health_scaling_type = "mult"
        end
        GlobalsSetValue("health_scaling_type", tostring(health_scaling_type))

        local health_scaling_flat_amount = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_health_scaling_flat_amount"))
        if (health_scaling_flat_amount == nil) then
            health_scaling_flat_amount = 50
        end
        GlobalsSetValue("health_scaling_flat_amount", tostring(health_scaling_flat_amount))

        local health_scaling_mult_amount = tonumber(steam.matchmaking.getLobbyData(lobby, "setting_health_scaling_mult_amount"))
        if (health_scaling_mult_amount == nil) then
            health_scaling_mult_amount = 15
        end
        GlobalsSetValue("health_scaling_mult_amount", tostring(health_scaling_mult_amount / 10))

        local instant_health = steam.matchmaking.getLobbyData(lobby, "setting_instant_health")
        if (instant_health == nil) then
            instant_health = "false"
        end
        if(instant_health == "true")then
            GameAddFlagRun("instant_health")
        else
            GameRemoveFlagRun("instant_health")
        end

        local gold_scaling_type = steam.matchmaking.getLobbyData(lobby, "setting_gold_scaling_type")
        if (gold_scaling_type == nil) then
            gold_scaling_type = "none"
        end
        GlobalsSetValue("gold_scaling_type", tostring(gold_scaling_type))

        


        arena_log:print("Lobby data refreshed")
    end,
    start_data = function(lobby)
        applied_seed = SetNewSeed(lobby)
        lobby_seed = applied_seed
        return applied_seed
    end,
    apply_start_data = function(lobby, start_data)
        applied_seed = start_data
        lobby_seed = applied_seed
    end,
    enter = function(lobby)
        print("MP Version: " .. MP_VERSION .." < " .. ArenaMode.required_online_version)



        was_content_mismatched = false

        player_mods = ""
        local mod_data = ModData()
        if (mod_data ~= nil) then
            for i, v in ipairs(mod_data)do
                player_mods = player_mods .. (v.name .. (v.id ~= nil and " ( "..v.id.." )" or "")) .. (i < #mod_data and ", " or "")
            end
        end
        
        if(steam_utils.IsOwner())then
            steam_utils.TrySetLobbyData(lobby, "mod_list", player_mods)
            steam_utils.TrySetLobbyData(lobby, "custom_lobby_string", "( round 0 )")
        end

        
        GlobalsSetValue("holyMountainCount", "0")
        GameAddFlagRun("player_unloaded")

        local player_ent = player.Get()
        if (player_ent ~= nil) then
            EntityKill(player_ent)
        end
        
        print("Game mode deterministic? "..tostring(GameIsModeFullyDeterministic()))

        --print("WE GOOD???")

        --debug_log:print(GameTextGetTranslatedOrNot("$arena_predictive_netcode_name"))

        arena_log:print("Enter called!!!")

        GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", "0")

        local upgrade_translation_keys = ""
        local upgrade_translation_values = ""
        for k, v in ipairs(upgrades)do
            local id = v.id
            local ui_name = v.ui_name
            local ui_description = v.ui_description

            upgrade_translation_keys = upgrade_translation_keys .. "arena_upgrades_" .. string.lower(id) .. "_name\n"
            upgrade_translation_keys = upgrade_translation_keys .. "arena_upgrades_" .. string.lower(id) .. "_description\n"

            upgrade_translation_values = upgrade_translation_values .. ui_name .. "\n"
            upgrade_translation_values = upgrade_translation_values .. ui_description .. "\n"
        end

        -- write to files
        local upgrade_translation_keys_file = io.open("noita_online_logs/arena_upgrades_keys.txt", "w")
        upgrade_translation_keys_file:write(upgrade_translation_keys)
        upgrade_translation_keys_file:close()

        local upgrade_translation_values_file = io.open("noita_online_logs/arena_upgrades_values.txt", "w")
        upgrade_translation_values_file:write(upgrade_translation_values)
        upgrade_translation_values_file:close()

        ArenaMode.refresh(lobby)

        applied_seed = SetNewSeed(lobby)
        lobby_seed = applied_seed

        --[[
        local game_in_progress = steam.matchmaking.getLobbyData(lobby, "in_progress") == "true"
        if(game_in_progress)then
            ArenaMode.start(lobby, true)
        end
        ]]
        --message_handler.send.Handshake(lobby)
    end,
    stop = function(lobby)
        arena_log:print("Stop called!!!")
        delay.reset()
        wait.reset()
        if (data ~= nil) then
            ArenaGameplay.GracefulReset(lobby, data) 
        end

        ArenaMode.refresh(lobby)
        
        gameplay_handler.ResetEverything(lobby)

        data = nil

        steamutils.RemoveLocalLobbyData(lobby, "player_data")
        steamutils.RemoveLocalLobbyData(lobby, "reroll_count")
        steamutils.RemoveLocalLobbyData(lobby, "match_data")

        BiomeMapLoad_KeepPlayer("mods/evaisa.arena/files/scripts/world/map_arena.lua")
    end,
    start = function(lobby, was_in_progress)

        for i, v in ipairs(EntityGetWithTag("player_unit"))do
            EntityKill(v)
        end
        
        print("Start called.")
        arena_log:print("Start called!!!")

        if(was_content_mismatched)then
            -- reopen lobby menu
            in_game = false
            gui_closed = false
            invite_menu_open = false 
            selected_player = nil
            -- show content mismatch popup
            ArenaMode.refresh(lobby)
            return
        end

        delay.reset()
        wait.reset()
        if (data ~= nil) then
            ArenaGameplay.GracefulReset(lobby, data)
        end

        GameRemoveFlagRun("DeserializedHolyMountain")
        
        gameplay_handler.ResetEverything(lobby)

        ArenaMode.refresh(lobby)

        data = data_holder:New()
        data.state = "lobby"
        data.spectator_mode = steamutils.IsSpectator(lobby)

        if(data.frame_spawned ~= nil)then
            print("NEW DATA TABLE, SPAWNED FRAME: " .. tostring(data.frame_spawned))
            print("CURR FRAME: " .. tostring(GameGetFrameNum()))
            print("WINS: " .. tostring(data.client.wins))
        end

        data:DefinePlayers(lobby)


        if (not was_in_progress or data.spectator_mode) then
            steamutils.RemoveLocalLobbyData(lobby, "player_data")
            steamutils.RemoveLocalLobbyData(lobby, "reroll_count")
            steamutils.RemoveLocalLobbyData(lobby, "match_data")
        else
            local unique_game_id_server = steam.matchmaking.getLobbyData(lobby, "unique_game_id") or "0"
            local unique_game_id_client = steamutils.GetLocalLobbyData(lobby, "unique_game_id") or "1523523"
    
            if (unique_game_id_server ~= unique_game_id_client) then
                arena_log:print("Unique game id mismatch, removing player data")
                GlobalsSetValue("TEMPLE_PERK_REROLL_COUNT", "0")
                steamutils.RemoveLocalLobbyData(lobby, "player_data")
                steamutils.RemoveLocalLobbyData(lobby, "reroll_count")
                steamutils.RemoveLocalLobbyData(lobby, "match_data")

                GameAddFlagRun("give_hp_catchup")
            end
            gameplay_handler.GetGameData(lobby, data)

            
        end

        GameAddFlagRun("initial_player_load")



        GameAddFlagRun("player_unloaded")

        GlobalsSetValue("original_seed", tostring(applied_seed))

        SetWorldSeed(applied_seed)


        local player_entity = player.Get()



        --local local_seed = data.random.range(100, 10000000)

        --GlobalsSetValue("local_seed", tostring(local_seed))

        --local unique_seed = data.random.range(100, 10000000)
        --GlobalsSetValue("unique_seed", tostring(unique_seed))

        if (steam_utils.IsOwner()) then
            local unique_game_id = data.random.range(100, 10000000)
            steam_utils.TrySetLobbyData(lobby, "unique_game_id", tostring(unique_game_id))
        end

        if (not data.spectator_mode and player_entity == nil) then
            gameplay_handler.LoadPlayer(lobby, data)
        end

        if(MP_VERSION > 350)then
            RunWhenPlayerExists(function()
                skin_system.load(lobby, data)
            end)
        end

        gameplay_handler.LoadLobby(lobby, data, true, true)

        if (playermenu ~= nil) then
            playermenu:Destroy()
        end

        playermenu = playerinfo_menu:New()

        -- request ready states
        networking.send.request_ready_states(lobby)
        networking.send.request_skins(lobby)

        
        --message_handler.send.Handshake(lobby)
    end,
    --[[
    spectate = function(lobby, was_in_progress)
        arena_log:print("Spectate called!!!")

        if(was_content_mismatched)then
            -- reopen lobby menu
            in_game = false
            gui_closed = false
            invite_menu_open = false 
            selected_player = nil
            -- show content mismatch popup
            ArenaMode.refresh(lobby)
            return
        end


        delay.reset()
        wait.reset()
        if (data ~= nil) then
            ArenaGameplay.GracefulReset(lobby, data)
        end
        
        if (not was_in_progress) then
            steamutils.RemoveLocalLobbyData(lobby, "player_data")
            steamutils.RemoveLocalLobbyData(lobby, "reroll_count")
        end

        gameplay_handler.ResetEverything(lobby)

        local unique_game_id_server = steam.matchmaking.getLobbyData(lobby, "unique_game_id") or "0"
        local unique_game_id_client = steamutils.GetLocalLobbyData(lobby, "unique_game_id") or "1523523"

        if (unique_game_id_server ~= unique_game_id_client) then
            arena_log:print("Unique game id mismatch, removing player data")
            steamutils.RemoveLocalLobbyData(lobby, "player_data")
            steamutils.RemoveLocalLobbyData(lobby, "reroll_count")
        end

        GameAddFlagRun("player_unloaded")

        local seed = tonumber(steam.matchmaking.getLobbyData(lobby, "seed") or 1)

        SetWorldSeed(seed)

        ArenaMode.refresh(lobby)

        data = data_holder:New()
        data.state = "lobby"
        data.spectator_mode = steamutils.IsSpectator(lobby)
        data:DefinePlayers(lobby)

        --local local_seed = data.random.range(100, 10000000)

        --GlobalsSetValue("local_seed", tostring(local_seed))

        --local unique_seed = data.random.range(100, 10000000)
        --GlobalsSetValue("unique_seed", tostring(unique_seed))

        if (steam_utils.IsOwner()) then
            local unique_game_id = data.random.range(100, 10000000)
            steam_utils.TrySetLobbyData(lobby, "unique_game_id", tostring(unique_game_id))
        end

        gameplay_handler.GetGameData(lobby, data)
        gameplay_handler.LoadLobby(lobby, data, true, true)

        if (playermenu ~= nil) then
            playermenu:Destroy()
        end

        playermenu = playerinfo_menu:New()

    end,
    ]]
    update = function(lobby)

        if(Parallax)then
            Parallax.update()
        end

        if (data == nil) then
            return
        end

        --delay.update()
        wait.update()

        if(steam_utils.IsOwner() and data.last_state ~= data.state)then
            data.last_state = data.state
            if(GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous")then
                steam_utils.TrySetLobbyData(lobby, "arena_state", data.state)
            end
        elseif(not steam_utils.IsOwner())then
            data.last_state = nil
        end

        if(MP_VERSION > 350)then
            skin_system.editor_open = GameHasFlagRun("wardrobe_open") and not GameHasFlagRun("game_paused") and gui_closed
            skin_system.draw(lobby, data)
        end

        --[[
        if(GameGetFrameNum() % 10 == 0)then
            local mortals = EntityGetWithTag("mortal")
            for i = 0, #mortals do
                local mortal = mortals[i]
                EntityAddTag(mortal, "homing_target")
            end
        end
        ]]

        data.spectator_mode = steamutils.IsSpectator(lobby)

        data.using_controller = GameGetIsGamepadConnected()

        if (GameGetFrameNum() % 60 == 0) then
            if (data ~= nil) then
                local unique_game_id = steamutils.GetLobbyData( "unique_game_id") or "0"
                steamutils.SetLocalLobbyData(lobby, "unique_game_id", tostring(unique_game_id))
            end

            local members = steamutils.getLobbyMembers(lobby)
            for k, member in pairs(members) do
                if (member.id ~= steam_utils.getSteamID()) then
                    local name = steamutils.getTranslatedPersonaName(member.id)
                    if (name ~= nil) then
                        lobby_member_names[tostring(member.id)] = name
                    end
                end
            end


            networking.send.handshake(lobby)

            


            --local unique_seed = data.random.range(100, 10000000)
            --GlobalsSetValue("unique_seed", tostring(unique_seed))
        end

        -- no fog allowed!!
        local world_state = GameGetWorldStateEntity()
        local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")

        ComponentSetValue2(world_state_component, "fog", 0)
        ComponentSetValue2(world_state_component, "intro_weather", true)

        --[[local update_seed = steamutils.GetLobbyData( "update_seed")
        if (update_seed == nil) then
            update_seed = "0"
        end

        GlobalsSetValue("update_seed", update_seed)]]

        if (data ~= nil) then

            gameplay_handler.Update(lobby, data)
   

            if (not IsPaused() and not GameHasFlagRun("arena_trailer_mode")) then
                if (playermenu ~= nil) then
                    playermenu:Update(data, lobby)
                end
            end
        end
        
        if(steamutils.IsOwner() and input:WasKeyPressed("f9"))then
            ArenaGameplay.WinnerCheck(lobby, data, true)
        end

        --[[
        if (input:WasKeyPressed("f5")) then
            
            -- global table snapshot
            -- json stringify global table
            local json_string = inspect(data)

            -- write to file
            arena_data_file:print(json_string)

        end

        

        if(input:WasKeyPressed("f10"))then
            -- add 1000 cosmetics currency'
            local currency = ModSettingGet("arena_cosmetics_currency") or 0
            currency = currency + 1000
            ModSettingSet("arena_cosmetics_currency", currency)
        end]]
        --[[if(input:WasKeyPressed("f1"))then
            if(not GameHasFlagRun("arena_trailer_mode"))then

                GameSetCameraFree(true)

                
                GameAddFlagRun("arena_trailer_mode")
            else
                GameRemoveFlagRun("game_paused")
                GameRemoveFlagRun("arena_trailer_mode")

                GameSetCameraFree(false)
            end
            
        end
        

        if(input:WasKeyPressed("f2"))then
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
                trailer_camera_x = x
                trailer_camera_y = y
                EntityLoad("mods/evaisa.arena/files/entities/particles/trailer/arena_logo.xml", x, y)
            else
                local x = 0
                local y = 0
                trailer_camera_x = x
                trailer_camera_y = y
                EntityLoad("mods/evaisa.arena/files/entities/particles/trailer/arena_logo.xml", x, y)
            end

            networking.send.spawn_trailer_effects(lobby)
        end

        if (input:WasKeyPressed("f3")) then
            local particles = EntityGetWithTag("arena_logo")
            for i, v in ipairs(particles)do
                EntityKill(v)
            end
        end]]
     
        --[[
        if(input:WasKeyPressed("f10"))then
            if(steam_utils.IsOwner())then
                GameRemoveFlagRun("DeserializedHolyMountain")
                ArenaGameplay.AddRound(lobby)
                delay.new(5, function()
                    ArenaGameplay.LoadLobby(lobby, data, false)
                    networking.send.load_lobby(lobby)
                end)
            end
        end
        ]]
        --[[elseif(input:WasKeyPressed("f9"))then
            EntityKill(GameGetWorldStateEntity())
        elseif(input:WasKeyPressed("f6"))then
            local player_entity = EntityGetWithTag("player_unit")[1]
            local x, y = EntityGetTransform(player_entity)
            EntityInflictDamage(player_entity, 10000, "DAMAGE_SLICE", "player", "BLOOD_EXPLOSION", 0, 0, GameGetWorldStateEntity(), x, y, 0)
        --elseif (input:WasKeyPressed("f5")) then
            
            -- global table snapshot
            -- json stringify global table
            local json_string = inspect(data)
            -- write to file

            --print(type(json_string))

            --GamePrint(tostring(json_string).."wawa")

        elseif (input:WasKeyPressed("f3")) then
            if(not dev_log or not dev_log.enabled)then
                dev_log = logger.init("arena-dev.log")
                print("Dev log enabled")
                dev_log.enabled = true
                dev_log:print("Dev log enabled")
            else
                dev_log.enabled = false
            end


            
        end]]

        if(GameHasFlagRun("arena_trailer_mode"))then
            GameAddFlagRun("game_paused")
            GameSetCameraFree(false)
            GameSetCameraPos(trailer_camera_x or 0, trailer_camera_y or 0)
        end

        if(GameGetFrameNum() % 60 == 0)then
            scoreboard.apply_data(lobby, data)
        end

        --print("Did something go wrong?")
    end,
    late_update = function(lobby)
        if (data == nil) then
            return
        end

        gameplay_handler.LateUpdate(lobby, data)

        if(GameHasFlagRun("arena_trailer_mode"))then
            GameSetCameraFree(false)
            GameSetCameraPos(trailer_camera_x or 0, trailer_camera_y or 0)
        end
        

    end,
    lobby_update = function(lobby)
        
        if(scoreboard_button_ui == nil)then
            scoreboard_button_ui = GuiCreate()
        end

        GuiStartFrame(scoreboard_button_ui)

        if (not IsPaused() and (data ~= nil or (#scoreboard.data > 0))) then


            local screen_width, screen_height = GuiGetScreenDimensions(scoreboard_button_ui)

            GuiOptionsAdd(scoreboard_button_ui, 6)

            if(GameGetIsGamepadConnected())then
                GuiOptionsAdd(scoreboard_button_ui, 2)
            else
                GuiOptionsRemove(scoreboard_button_ui, 2)
            end

            if (GuiImageButton(scoreboard_button_ui, 21312, screen_width - 60, screen_height - 20, "", "mods/evaisa.arena/files/sprites/ui/scoreboard.png")) then
                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
                if(data ~= nil)then
                    scoreboard.apply_data(lobby, data)
                end
                scoreboard.open = not scoreboard.open
            end

            
            if (bindings:IsJustDown("arena_scoreboard_toggle") or bindings:IsJustDown("arena_scoreboard_toggle_joy")) then
                GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
                if(data ~= nil)then
                    scoreboard.apply_data(lobby, data)
                end
                scoreboard.open = not scoreboard.open
            end
        end


        scoreboard.update(lobby)

    end,
    player_enter = function(lobby, user)

        if(data and data.players[tostring(user)] ~= nil)then
            
            data.players[tostring(user)].entity = nil
            data.players[tostring(user)].alive = false
        end

        if(steamutils.IsOwner())then
            SendLobbyData(lobby)
            
            print("Player joined - Sending lobby data!")
        end
    end,
    leave = function(lobby)
        GameAddFlagRun("player_unloaded")
        if(gameplay_handler == nil)then
            return
        end


        gameplay_handler.ResetEverything(lobby, true)


    end,
    --[[
    message = function(lobby, message, user)
        message_handler.handle(lobby, message, user, data)
    end,
    ]]
    received = function(lobby, event, message, user)
        if (user == steam_utils.getSteamID() or data == nil) then
            return
        end

        if (not data.players[tostring(user)]) then
            data:DefinePlayer(lobby, user)
        end

        if (data ~= nil) then
            if (networking.receive[event]) then
                networking.receive[event](lobby, message, user, data)
            end

        end
        --print("Received event: " .. event)

    end,
    disconnected = function(lobby, user)
        print("round should end!!")

        local k = tostring(user)

        if(data == nil)then
            return
        end

        local v = data.players[k]


        if(v ~= nil)then
            v:Clean(lobby)
            data.players[k] = nil
        end

        -- if we are the last player, unready
        if(not data.spectator_mode)then
            if (steam_utils.getNumLobbyMembers() == 1) then
                GameRemoveFlagRun("lock_ready_state")
                GameAddFlagRun("player_unready")
                GameRemoveFlagRun("ready_check")
                --ArenaGameplay.SetReady(lobby, data, false, true)
            end
        end

        --[[if (steam_utils.IsOwner()) then
            local winner_key = tostring(k) .. "_wins"
            steam_utils.DeleteLobbyData(lobby, winner_key)
        end
        ]]
        lobby_member_names[k] = nil
        if (data.state == "arena" and GlobalsGetValue("arena_gamemode", "ffa") ~= "continuous") then
            if(steam_utils.IsOwner())then
                ArenaGameplay.WinnerCheck(lobby, data)
            end
        end
    end,
    on_projectile_fired = function(lobby, shooter_id, projectile_id, rng, position_x, position_y, target_x, target_y,
                                   send_message, unknown1, multicast_index, unknown3)
        --[[print(tostring(send_message))
        print(tostring(unknown1))
        print(tostring(unknown2))
        print(tostring(unknown3))]]

        --print("Projectile fired")

        if (EntityHasTag(shooter_id, "client")) then
            EntityAddTag(shooter_id, "player_unit")
        end

        if (data ~= nil) then
            gameplay_handler.OnProjectileFired(lobby, data, shooter_id, projectile_id, rng, position_x, position_y,
                target_x, target_y, send_message, unknown1, multicast_index, unknown3)
        end
    end,
    on_projectile_fired_post = function(lobby, shooter_id, projectile_id, rng, position_x, position_y, target_x, target_y,
                                        send_message, unknown1, multicast_index, unknown3)
        if (EntityHasTag(shooter_id, "client")) then
            EntityRemoveTag(shooter_id, "player_unit")
        end

        if (data ~= nil) then
            gameplay_handler.OnProjectileFiredPost(lobby, data, shooter_id, projectile_id, rng, position_x, position_y,
                target_x, target_y, send_message, unknown1, multicast_index, unknown3)
        end
    end
}





table.insert(gamemodes, ArenaMode)
