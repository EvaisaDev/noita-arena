local steamutils = dofile_once("mods/evaisa.mp/lib/steamutils.lua")

local playerinfo = {}

function playerinfo:New(lobby, user)
    local obj = {
        entity = nil,
        held_item = nil,
        hp_bar = nil,
        health = 4,
        max_health = 4,
        ready = false,
        alive = false,
        loaded = false,
        projectile_rng_stack = {},
        target = nil,
        can_fire = false,
        --[[last_position_x = nil,
        last_position_y = nil,]]
        status_effect_entities = {},
        status_effect_comps = {},
        previous_positions = {},
        cosmetics = {},
        ping = 0,
        delay_frames = 0,
        wins = nil,
        winstreak = nil,
        id = user,
        perks = {},
        skin_data = nil,
        controls = {
            kick = false,
            fire = false,
            fire2 = false,
            leftClick = false,
            rightClick = false,
        }
    }

    local state = steam.matchmaking.getLobbyMemberData(lobby, user, "state")
    if(state)then
        obj.state = state
    end

    obj.Death = function(self, damage_details)
        if(self.entity ~= nil and EntityGetIsAlive(self.entity))then

            local items = GameGetAllInventoryItems( self.entity ) or {}

            for i,item in ipairs(items) do
                EntityRemoveFromParent(item)
                EntityKill(item)
            end

            local damage_model_comp = EntityGetFirstComponentIncludingDisabled(self.entity, "DamageModelComponent")
            if(damage_model_comp ~= nil)then
                ComponentSetValue2(damage_model_comp, "hp", 0.04)
                ComponentSetValue2(damage_model_comp, "ui_report_damage", false)
            end

            --[[
                typedef struct H {
                    int ragdoll_fx;
                    int damage_types;
                    float knockback_force;
                    float impulse_x;
                    float impulse_y;
                    float world_pos_x;
                    float world_pos_y;
                    float explosion_x;
                    float explosion_y;
                    bool smash_explosion;
                } DamageDetails;
            ]]

            if(damage_details.ragdoll_fx ~= nil)then
                local damage_types = mp_helpers.GetDamageTypes(damage_details.damage_types)
                local ragdoll_fx = mp_helpers.GetRagdollFX(damage_details.ragdoll_fx)

                -- split the damage into as many parts as there are damage types
                local damage_per_type = 69420 / #damage_types

                for i, damage_type in ipairs(damage_types) do
                    print("Damage type: "..damage_type)
                    if(damage_type == "DAMAGE_ICE")then
                        damage_type = "DAMAGE_PROJECTILE"
                    end
                    EntityInflictDamage(self.entity, damage_per_type, damage_type, "damage_fake",
                    ragdoll_fx, damage_details.impulse_x, damage_details.impulse_y, GameGetWorldStateEntity(), damage_details.world_pos_x, damage_details.world_pos_y, damage_details.knockback_force)
                end
            else
                EntityInflictDamage(self.entity, 69420, "DAMAGE_MATERIAL", "", "NORMAL", 0, 0, GameGetWorldStateEntity())
            end
        end
            
        self.last_velocity = nil
        self.entity = nil
        self.held_item = nil
        if(self.hp_bar)then
            self.hp_bar:destroy()
            self.hp_bar = nil
        end
        self.ready = false
        self.alive = false
        --[[self.last_position_x = nil
        self.last_position_y = nil]]
        self.previous_positions = {}
    end
    obj.Clean = function(self, lobby)
        if(self.entity ~= nil and EntityGetIsAlive(self.entity))then
            EntityKill(self.entity)
        end
        if(self.held_item ~= nil and EntityGetIsAlive(self.held_item))then
            EntityKill(self.held_item)
        end
        self.entity = nil
        self.held_item = nil
        self.cosmetics = {}
        self.last_velocity = nil
        if(self.hp_bar)then
            self.hp_bar:destroy()
            self.hp_bar = nil
        end
        self.ready = false
        self.alive = false
        --[[self.last_position_x = nil
        self.last_position_y = nil]]
        self.previous_positions = {}
        self.last_inventory_string = nil
        self.wins = nil
        self.winstreak = nil
        
        --[[if(steam_utils.IsOwner())then
            steam_utils.TrySetLobbyData(lobby, tostring(self.id).."_loaded", "false")
            steam_utils.TrySetLobbyData(lobby, tostring(self.id).."_ready", "false")
        end]]
    end
    obj.Destroy = function(self)
        if(self.entity ~= nil and EntityGetIsAlive(self.entity))then
            EntityKill(self.entity)
        end
        if(self.held_item ~= nil and EntityGetIsAlive(self.held_item))then
            EntityKill(self.held_item)
        end
        self.entity = nil
        self.held_item = nil
        if(self.hp_bar)then
            self.hp_bar:destroy()
            self.hp_bar = nil
        end
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

return playerinfo