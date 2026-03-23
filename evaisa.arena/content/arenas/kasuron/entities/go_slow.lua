-- 1. Get the sun entity
local entity_id = GetUpdatedEntityID()

-- 2. Get the velocity controller
local vel_comp = EntityGetFirstComponent(entity_id, "VelocityComponent") --[[@cast vel_comp number]]

-- 3. Reset it's velocity
ComponentSetValue2(vel_comp, "mVelocity", 0, 0)

-- Save the position:
if GotPos == nil then
    local x, y = EntityGetTransform(entity_id)
    X, Y, GotPos = x, y, true
end
EntitySetTransform(entity_id, X, Y)