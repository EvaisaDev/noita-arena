dofile("data/scripts/status_effects/status_list.lua")

local unique_status_effects = {}
local unique_status_effect_added = {}
for k,v in pairs(status_effects)do
  if(v.id ~= nil and not unique_status_effect_added[v.id])then
    unique_status_effect_added[v.id] = true
    table.insert(unique_status_effects, v.id)
  end
end

--[[
SetStainPercentage = function( entity_id, effect_id )
  EntityRemoveStainStatusEffect( entity_id, effect_id, 0 )
  EntityAddRandomStains( entity_id, 
end
]]

GetStainPercentage = function( entity_id, effect_id )
  local status_effect_data_component = EntityGetFirstComponentIncludingDisabled( entity_id, "StatusEffectDataComponent" )
  if(status_effect_data_component == nil)then
    return 0
  end
  local stain_effects = ComponentGetValue2(status_effect_data_component, "stain_effects")
  if(stain_effects == nil)then
    return 0
  end
  for k,v in pairs(stain_effects) do
    local index = k - 1
    if(index > 0)then
      local effect = unique_status_effects[index]
      if(effect == effect_id)then
        return v
      end
    end
  end
  return 0
end

GetIngestionPercentage = function( entity_id, effect_id )
  local status_effect_data_component = EntityGetFirstComponentIncludingDisabled( entity_id, "StatusEffectDataComponent" )
  if(status_effect_data_component == nil)then
    return 0
  end
  local ingestion_effects = ComponentGetValue2(status_effect_data_component, "ingestion_effects")
  if(ingestion_effects == nil)then
    return 0
  end
  for k,v in pairs(ingestion_effects) do
    local index = k - 1
    if(index > 0)then
      local effect = unique_status_effects[index]
      if(effect == effect_id)then
        return v
      end
    end
  end
  return 0
end

GetActiveStatusEffects = function( entity_id, combined )
  local active_effects = {
    stain = {},
    ingestion = {}
  }

  if(combined)then
    active_effects = {}
  end

  local status_effect_data_component = EntityGetFirstComponentIncludingDisabled( entity_id, "StatusEffectDataComponent" )
  if(status_effect_data_component == nil)then
    return active_effects
  end

  local damage_model_component = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )

  local ingestion_effects = ComponentGetValue2(status_effect_data_component, "ingestion_effects") or {}
  local stain_effects = ComponentGetValue2(status_effect_data_component, "stain_effects") or {}


  for k,v in pairs(ingestion_effects) do
    local index = k - 1
    if(index > 0)then
      local effect = unique_status_effects[index]
      if(v > 0.15)then
        --table.insert(active_effects.ingestion, effect)
        if combined then
          active_effects[effect] = v
        elseif(not combined)then
          active_effects.ingestion[effect] = v
        end
      end
    end
  end

  for k,v in pairs(stain_effects) do
    local index = k - 1
    if(index > 0)then
      local effect = unique_status_effects[index]
      --print(effect .. ": " .. tostring(v))
      if(v > 0.15)then
        --table.insert(active_effects.stain, effect)
        if(combined and (active_effects[effect] == nil or v > active_effects[effect]))then
          active_effects[effect] = v
        elseif(not combined)then
          active_effects.stain[effect] = v
        end
      end
    end
  end

  if(damage_model_component)then
    local is_on_fire = ComponentGetValue2(damage_model_component, "mIsOnFire")
    local fire_frames_left = ComponentGetValue2(damage_model_component, "mFireFramesLeft") or 0
    local fire_duration_frames = ComponentGetValue2(damage_model_component, "mFireDurationFrames") or 720
    local fire_value = fire_frames_left / fire_duration_frames
    if(is_on_fire == true)then
      --[[print("fire_value: " .. tostring(fire_value))
      print("on_fire: " .. tostring(is_on_fire))]]
      if(combined)then
        active_effects["ON_FIRE"] = fire_value
      else
        active_effects.stain["ON_FIRE"] = fire_value
      end
    end
  end

  return active_effects
end

GetStatusElement = function( id, value )
  local last_index_threshold = -100
  local elem = nil

  for k,v in pairs(status_effects)do
    local threshold = v.min_threshold_normalized or 0
    if(v.id == id)then
      if(threshold > last_index_threshold and value >= threshold)then
        last_index_threshold = threshold
        elem = v
        --print(v.id)
        if(v.id == "ON_FIRE")then
          v.effect_entity = "mods/evaisa.arena/files/entities/misc/on_fire.xml"
        end
      end
    end
  end
  return elem
end