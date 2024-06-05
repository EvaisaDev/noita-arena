local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
local rng = dofile("mods/evaisa.arena/lib/rng.lua")
local playerinfo = dofile("mods/evaisa.arena/files/scripts/gamemode/playerinfo.lua")
local data = {}

function data:New()
    local o = {
        frame_spawned = GameGetFrameNum(),
        players = {},
        tweens = {},
        projectile_seeds = {},
        ready_counter = nil,
        countdown = nil,
        upgrade_system = nil,
        ----- spectator mode -----
        target_dummy_player = nil,
        spectator_gui_entity = nil,
        spectator_gui = nil,
        spectator_text_gui = nil,
        arena_spectator = false,
        selected_player = nil,
        spectator_mode = false,
        spectator_quick_switch_trigger = 0,
        spectator_lobby_loaded = false,
        controlled_physics_entities = {},
        cosmetics = {},

        spectator_fonts = {
            ["English"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["русский"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Português (Brasil)"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Español"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Deutsch"] = {
                size = 1,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Francais"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Italiano"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["Polska"] = {
                size = 1,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_huge.xml"
            },
            ["简体中文"] = {
                size = 1,
                smooth = true,
                font = "data/fonts/generated/notosans_zhcn_48.bin",
            },
            ["日本語"] = {
                size = 1,
                smooth = true,
                font = "data/fonts/generated/notosans_jp_48.bin",
            },
            ["한국어"] = {
                size = 1,
                smooth = true,
                font = "data/fonts/generated/notosans_ko_48.bin",
            },
            unknown = {
                size = 1,
                smooth = true,
                font = "data/fonts/font_pixel_huge.xml",
            },
        },
        username_fonts = {
            ["English"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["русский"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Português (Brasil)"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Español"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Deutsch"] = {
                size = 0.7,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Francais"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Italiano"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["Polska"] = {
                size = 0.7,
                smooth = false,
                upper = true,
                font = "data/fonts/font_pixel_white.xml"
            },
            ["简体中文"] = {
                size = 0.7,
                smooth = true,
                font = "data/fonts/generated/notosans_zhcn_48.bin",
            },
            ["日本語"] = {
                size = 0.7,
                smooth = true,
                font = "data/fonts/generated/notosans_jp_48.bin",
            },
            ["한국어"] = {
                size = 0.7,
                smooth = true,
                font = "data/fonts/generated/notosans_ko_48.bin",
            },
            unknown = {
                size = 0.7,
                smooth = true,
                font = "data/fonts/font_pixel_white.xml",
            },
        },
        client = {
            ready = false,
            alive = true,
            inventory_was_open = false,
            previous_wand = nil,
            previous_anim = nil,
            previous_perk_string = nil,
            previous_wand_stats = {
                mana = nil, 
                mCastDelayStartFrame = nil, 
                mReloadFramesLeft = nil, 
                mReloadNextFrameUsable = nil, 
                mNextChargeFrame = nil, 
            },
            previous_vel_x = nil,
            previous_vel_y = nil,
            previous_pos_x = nil,
            previous_pos_y = nil,
            --projectile_seeds = {},
            --projectile_homing = {},
            previous_selected_item = nil,
            serialized_player = nil,
            first_spawn_gold = 0,
            spread_index = 1,
            projectiles_fired = 0,
            projectile_rng_stack = {},
            hp = 100,
            max_hp = 100,
            perks = {},
            last_inventory = {},
        },
        state = "lobby",
        preparing = false,
        players_loaded = false,
        deaths = 0,
        spawn_point = {x = 0, y = 0},
        zone_size = nil,
        current_arena = nil,
        ready_for_zone = false,
        rejoined = false,
        random = rng.new((os.time() + GameGetFrameNum() + os.clock()) / 2),
        DefinePlayer = function(self, lobby, user)
            if(steamutils.IsSpectator(lobby, user))then
                return
            end
            self.players[tostring(user)] = playerinfo:New(lobby, user)
            local ready = steamutils.GetLobbyData( tostring(user).."_ready")
            if(ready ~= nil and ready ~= "")then
                self.players[tostring(user)].ready = ready == "true"
            end
        end,
        DefinePlayers = function(self, lobby)
            local members = steamutils.getLobbyMembers(lobby)
            for k, member in pairs(members)do
                if(member.id ~= steam_utils.getSteamID())then
                    self:DefinePlayer(lobby, member.id)
                end
            end
        end,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

return data