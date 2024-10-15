dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xff5cb954, "spawn_bed" )
RegisterSpawnFunction( 0xff51b547, "spawn_chair" )
RegisterSpawnFunction( 0xff648f60, "spawn_table" )
RegisterSpawnFunction( 0xff29b01d, "spawn_castle_statue" )
RegisterSpawnFunction( 0xff32702c, "spawn_temple_statue_2" )
RegisterSpawnFunction( 0xff73a06e, "spawn_temple_statue_1" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function spawn_bed( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/bed.xml", x, y - 6 )
end

function spawn_chair( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/chair.xml", x, y - 6 )
end

function spawn_table( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/table.xml", x, y )
end

function spawn_castle_statue( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/castle_statue.xml", x, y )
end

function spawn_temple_statue_1( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/temple_statue_01.xml", x, y )
end

function spawn_temple_statue_2( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/temple_statue_02.xml", x, y )
end