local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

local radius = 100
local effect_entities = {}
local frame_length = -1 -- if not 0 will reapply this effect after this many frames have gone by
local hit_shooter = false

last_frame_triggered_entities = last_frame_triggered_entities or {} -- keep track of the last frame individual entities were hit on

local variable_storage_comps = EntityGetComponent( entity_id, "VariableStorageComponent" )

for k, v in ipairs(variable_storage_comps) do
    local name = ComponentGetValue2( v, "name" )
    if name == "effect" then
        radius = ComponentGetValue2( v, "value_float" )
        local effect_entities_csv = ComponentGetValue2( v, "value_string" )
        -- split the csv string into a table
        for effect_entity in effect_entities_csv:gmatch("[^,]+") do
            table.insert(effect_entities, effect_entity)
        end
        hit_shooter = ComponentGetValue2( v, "value_bool" )
        frame_length = ComponentGetValue2( v, "value_int" )
    end
end

local shooter = nil
local projectile_component = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
if projectile_component ~= nil then
    shooter = ComponentGetValue2(projectile_component, "mWhoShot")
end

local entities = EntityGetInRadiusWithTag( x, y, radius, "hittable" )

for k, v in pairs(entities) do
    local entity_id = v
    if entity_id ~= shooter or hit_shooter then
        if last_frame_triggered_entities[entity_id] == nil or (frame_length ~= -1 and ( GameGetFrameNum() - last_frame_triggered_entities[entity_id] > frame_length )) then
            for k, effect_entity in ipairs(effect_entities) do
                local entity = LoadGameEffectEntityTo(entity_id, effect_entity)
                if(entity ~= 0 and (EntityHasTag(entity_id, "player_unit") or EntityHasTag(entity_id, "client")))then
                    local game_effect_comp = EntityGetFirstComponentIncludingDisabled(entity, "GameEffectComponent")
                    if game_effect_comp ~= nil then
                        local frames = ComponentGetValue2(game_effect_comp, "frames")
                        if frames == -1 or frames == 0 then
                            ComponentSetValue2(game_effect_comp, "frames", frame_length)
                        end
                    end
                end
            end
            last_frame_triggered_entities[entity_id] = GameGetFrameNum()
        end
    end
end




