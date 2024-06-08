local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

local area_damage_component = EntityGetFirstComponentIncludingDisabled(entity_id, "AreaDamageComponent")
local projectile_component = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")

if (area_damage_component == nil)then
    return
end

-- update rate
local update_every_n_frame = ComponentGetValue2(area_damage_component, "update_every_n_frame")

-- projectile component stuff
local never_hit_player = false
local collide_with_shooter_frames = 0
local hit_shooter = false

-- track frames
frames = frames or 0

EntitySetComponentIsEnabled(entity_id, area_damage_component, false)

if(projectile_component ~= nil)then
    local shooter = ComponentGetValue2(projectile_component, "mWhoShot")
    if(shooter ~= 0)then
        entity_responsible = shooter
    end
    hit_shooter = ComponentGetValue2(projectile_component, "friendly_fire") and frames > collide_with_shooter_frames or collide_with_shooter_frames == -1
    never_hit_player = ComponentGetValue2(projectile_component, "never_hit_player")
    collide_with_shooter_frames = ComponentGetValue2(projectile_component, "collide_with_shooter_frames")
end


-- implementation
if (frames % update_every_n_frame == 0)then
    local circle_radius = ComponentGetValue2(area_damage_component, "circle_radius")
    local damage_per_frame = ComponentGetValue2(area_damage_component, "damage_per_frame")
    local entity_responsible = ComponentGetValue2(area_damage_component, "entity_responsible")
    local death_cause = ComponentGetValue2(area_damage_component, "death_cause")
    local entities_with_tag = ComponentGetValue2(area_damage_component, "entities_with_tag")
    local aabb_min_x, aabb_min_y = ComponentGetValue2(area_damage_component, "aabb_min")
    local aabb_max_x, aabb_max_y = ComponentGetValue2(area_damage_component, "aabb_max")
    local damage_type = ComponentGetValue2(area_damage_component, "damage_type")
    if circle_radius > 0 then
        local entities = EntityGetInRadiusWithTag(x, y, circle_radius, entities_with_tag)
        for k, v in pairs(entities) do
            local entity = v
            if (entity ~= entity_responsible or hit_shooter) and not (never_hit_player and EntityHasTag(entity, "player_unit")) then
                EntityInflictDamage(entity, damage_per_frame, damage_type, death_cause, "NORMAL", 0, 0, entity_responsible, x, y)
            end
        end
    else
        local entities = EntityGetWithTag(entities_with_tag)
        for k, v in pairs(entities) do
            local entity = v
            local ex, ey = EntityGetTransform(entity)
            if ex >= aabb_min_x and ex <= aabb_max_x and ey >= aabb_min_y and ey <= aabb_max_y then
                if (entity ~= entity_responsible or hit_shooter) and not (never_hit_player and EntityHasTag(entity, "player_unit")) then
                    EntityInflictDamage(entity, damage_per_frame, damage_type, death_cause, "NORMAL", 0, 0, entity_responsible, x, y)
                end
            end
        end
    end
end


frames = frames + 1