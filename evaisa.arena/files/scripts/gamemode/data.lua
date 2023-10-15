local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")
local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")
local playerinfo = dofile("mods/evaisa.arena/files/scripts/gamemode/playerinfo.lua")
local data = {}

function data:New()
    local o = {
        players = {},
        tweens = {},
        projectile_seeds = {},
        ready_counter = nil,
        countdown = nil,
        upgrade_system = nil,
        ----- spectator mode -----
        spectator_gui_entity = nil,
        spectator_gui = nil,
        spectator_text_gui = nil,
        arena_spectator = false,
        selected_player = nil,
        selected_player_name = nil,
        spectator_mode = false,
        spectator_quick_switch_trigger = 0,
        spectator_lobby_loaded = false,

        lobby_spectated_player = nil,
        controlled_physics_entities = {},

        big_font = font_helper.NewFont("mods/evaisa.arena/files/font/Daydream_128.xml"),
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
            self.players[tostring(user)] = playerinfo:New(user)
            local ready = steam.matchmaking.getLobbyData(lobby, tostring(user).."_ready")
            if(ready ~= nil and ready ~= "")then
                self.players[tostring(user)].ready = ready == "true"
            end
        end,
        DefinePlayers = function(self, lobby)
            local members = steamutils.getLobbyMembers(lobby)
            for k, member in pairs(members)do
                if(member.id ~= steam.user.getSteamID())then
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