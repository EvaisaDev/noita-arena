local me = GetUpdatedEntityID()
EntityRemoveComponent(me, GetUpdatedComponentID())
local var = EntityGetFirstComponent(me, "VariableStorageComponent", "graham_dummy_state")
local sprites = EntityGetComponentIncludingDisabled(me, "SpriteComponent", "grahamsdummy_damage") or {}
local sprite = sprites[2]
if (not var) or (not sprite) then return end
ComponentSetValue2(var, "value_float", 0)
ComponentSetValue2(sprite, "offset_x", 2.5)
ComponentSetValue2(sprite, "text", "0")
EntityRefreshSprite(me, sprite)
