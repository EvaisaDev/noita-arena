dofile_once( "mods/evaisa.arena/files/helper.lua" );
dofile_once( "mods/evaisa.arena/files/lib/variables.lua" );

local entity = GetUpdatedEntityID();

local spriteComp = EntityGetFirstComponentIncludingDisabled( entity, "SpriteComponent" );

local x, y = EntityGetTransform( entity );

init_pos = init_pos or {x,y};

local offset_x, offset_y = ComponentGetValue2( spriteComp, "offset_animator_offset" );


local hitbox_comp = EntityGetFirstComponentIncludingDisabled( entity, "HitboxComponent" );

EntityApplyTransform( entity, init_pos[1] + offset_x, init_pos[2] + offset_y );

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



