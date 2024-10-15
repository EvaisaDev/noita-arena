dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xffcb63d6, "light_small" )
RegisterSpawnFunction( 0xffa686aa, "light_right" )
RegisterSpawnFunction( 0xffe494ed, "light_left" )
RegisterSpawnFunction( 0xff97449f, "light_center" )
RegisterSpawnFunction( 0xff4e7d94, "spawn_ball")

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function light_small( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/stadium/entities/spotlight_entity.xml", x + 0.5, y - 2 )
end

function light_right( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/stadium/entities/spotlight_entity2.xml", x + 1, y - 2 )
	local x, y = EntityGetTransform( entity )
	EntitySetTransform( entity, x, y, 0.7853 )
end

function light_left( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/stadium/entities/spotlight_entity2.xml", x - 1, y - 2 )
	local x, y = EntityGetTransform( entity )
	EntitySetTransform( entity, x, y, -0.7853 )
end

function light_center( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/stadium/entities/spotlight_entity2.xml", x, y - 16 )
end

function spawn_ball( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/stadium/entities/ball.xml", x, y )
end