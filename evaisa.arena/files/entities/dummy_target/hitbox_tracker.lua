dofile_once( "mods/evaisa.arena/files/helper.lua" );
dofile_once( "mods/evaisa.arena/files/lib/variables.lua" );

local entity = GetUpdatedEntityID();

local x, y = EntityGetTransform( entity );

local seed = EntityGetFirstComponentIncludingDisabled( entity, "PositionSeedComponent" )
local cdc = EntityGetFirstComponentIncludingDisabled( entity, "CharacterDataComponent" )

if not (seed and cdc) then return end

if ComponentGetValue2( seed, "pos_x" ) == 0 and ComponentGetValue2( seed, "pos_y" ) == 0 then
    ComponentSetValue2( seed, "pos_x", x )
    ComponentSetValue2( seed, "pos_y", y )
end

local tx = ComponentGetValue2( seed, "pos_x" )
local ty = ComponentGetValue2( seed, "pos_y" )

local vx, vy = ComponentGetValue2( cdc, "mVelocity" )
vx = (vx + (tx - x) / 5) * 0.95
vy = (vy + (ty - y) / 5) * 0.95
ComponentSetValue2( cdc, "mVelocity", vx, vy )

--[[
local default_hitbox = {
    aabb_max_x=3,
    aabb_max_y=7,
    aabb_min_x=-3,
    aabb_min_y=-9,
}

local current_hitbox = {
    aabb_max_x=default_hitbox.aabb_max_x + offset_x,
    aabb_max_y=default_hitbox.aabb_max_y + offset_y,
    aabb_min_x=default_hitbox.aabb_min_x + offset_x,
    aabb_min_y=default_hitbox.aabb_min_y + offset_y,
}

ComponentSetValue2( hitbox_comp, "aabb_max_x", current_hitbox.aabb_max_x );
ComponentSetValue2( hitbox_comp, "aabb_max_y", current_hitbox.aabb_max_y );
ComponentSetValue2( hitbox_comp, "aabb_min_x", current_hitbox.aabb_min_x );
ComponentSetValue2( hitbox_comp, "aabb_min_y", current_hitbox.aabb_min_y );
]]



