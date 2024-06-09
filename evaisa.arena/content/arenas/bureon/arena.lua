EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xff73a06e, "heart" )
RegisterSpawnFunction( 0xff32702c, "music3" )
RegisterSpawnFunction( 0xff29b01d, "wand3" )
RegisterSpawnFunction( 0xff5cb954, "music2" )
RegisterSpawnFunction( 0xff5cb643, "skull" )
RegisterSpawnFunction( 0xff5cb644, "bone1" )
RegisterSpawnFunction( 0xff5cb645, "bone2" )
RegisterSpawnFunction( 0xff982945, "orb" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function heart( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/heart.xml", x, y ), x, y)
end

function music3( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/music_machine_03.xml", x, y ), x, y)
end

function wand3( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/wand_unshuffle_03.xml", x, y ), x, y)
	
end

function music2( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/music_machine_02.xml", x, y ), x, y)
end

function skull( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_skull_01.xml", x, y ), x, y)
end

function bone1( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/physics_bone_01.xml", x, y ), x, y)
end

function bone2( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/physics_bone_02.xml", x, y ), x, y)
end

function orb( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/items/pickup/potion.xml", x, y ), x, y)
end