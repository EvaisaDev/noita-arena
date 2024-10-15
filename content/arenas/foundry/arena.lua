EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xffa1a2a3, "drain_pipe" )
RegisterSpawnFunction( 0xff4cacab, "forge_item_check" )
RegisterSpawnFunction( 0xffa1a2b3, "suspended_container" )
RegisterSpawnFunction( 0xffa1a2d3, "suspended_chain" )
RegisterSpawnFunction( 0xffa1a2e3, "suspended_cage" )
RegisterSpawnFunction( 0xffa1a2f3, "physics_lantern_small" )
RegisterSpawnFunction( 0xffa1a2a4, "physics_lantern" )
RegisterSpawnFunction( 0xffa1a2b4, "physics_minecart" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function drain_pipe( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/drain_pipe.xml", x, y )
end

function forge_item_check( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/forge_item_check.xml", x, y )
end

function suspended_container( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/suspended_container.xml", x, y ), x, y)
end

function suspended_chain( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/suspended_chain.xml", x, y ), x, y)
end

function suspended_cage( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/suspended_cage.xml", x, y ), x, y)
end

function physics_lantern( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/physics_lantern.xml", x, y ), x, y)
end

function physics_lantern_small( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/physics_lantern_small.xml", x, y ), x, y)
end

function physics_minecart( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/foundry/entities/physics_minecart.xml", x, y ), x, y)
end