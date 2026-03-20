local me = GetUpdatedEntityID()
local x, y = EntityGetTransform(me)
local state = EntityGetFirstComponentIncludingDisabled(me, "VariableStorageComponent", "graham_dummy_state")
local soac = EntityGetFirstComponentIncludingDisabled(me, "SpriteOffsetAnimatorComponent")
local hitbox = EntityGetFirstComponentIncludingDisabled(me, "HitboxComponent")
local sprite = EntityGetFirstComponentIncludingDisabled(me, "SpriteComponent")
local seed = EntityGetFirstComponentIncludingDisabled(me, "PositionSeedComponent")
local cdc = EntityGetFirstComponentIncludingDisabled(me, "CharacterDataComponent")
if not (state and hitbox and soac and sprite and seed and cdc) then return end

local tx, ty = ComponentGetValue2(seed, "pos_x"), ComponentGetValue2(seed, "pos_y")
local vx, vy = ComponentGetValue2(cdc, "mVelocity")
vx = (vx + (tx - x) / 5) * 0.95
vy = (vy + (ty - y) / 5) * 0.95
ComponentSetValue2(cdc, "mVelocity", vx, vy)
local child = EntityGetAllChildren(me, "dummy_pin") or {}
if #child > 0 then
    EntitySetTransform(child[1], tx, ty)
end
EntitySetTransform(me, tx, ty)
