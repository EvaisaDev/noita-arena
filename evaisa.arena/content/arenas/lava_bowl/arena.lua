dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")
dofile_once("mods/evaisa.arena/files/scripts/utilities/vegetation_loader.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xffff9900, "spawn_tree" )
RegisterSpawnFunction( 0xffd9ff00, "spawn_bush")
RegisterSpawnFunction( 0xffa1a2f3, "physics_lantern_small" )
RegisterSpawnFunction( 0xffa1a2a4, "physics_lantern" )
RegisterSpawnFunction( 0xffa1a2b4, "physics_chain_torch" )
RegisterSpawnFunction( 0xffe8af44, "lava_removal" )
RegisterSpawnFunction( 0xffc5603b, "lava_removal_big" )
RegisterSpawnFunction( 0xffbd8b2d, "lava_removal_bigger" )
RegisterSpawnFunction( 0xff3bcbb8, "lava_removal_400" )
-- 450
RegisterSpawnFunction( 0xff3bcb62, "lava_removal_450" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function spawn_tree( x, y )
	print("spawning tree at", x, y)
	LoadVegetation("data/vegetation/tree_spruce_"..tostring(Random(1, 4))..".xml", x, y)
end

function spawn_bush( x, y )
	print("spawning bush at", x, y)
	LoadVegetation("data/vegetation/bush_0$[1-9].xml", x, y)
end

function physics_chain_torch( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/chain_torch.xml", x, y ), x, y)
end

function physics_lantern( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/lantern_small.xml", x, y ), x, y)
end

function physics_lantern_small( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/lantern_small.xml", x, y ), x, y)
end


function lava_removal( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/lava_bowl/entities/lava_annihilation_spell.xml", x, y )
end

function lava_removal_big( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/lava_bowl/entities/lava_annihilation_spell_big.xml", x, y )
end

function lava_removal_bigger( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/lava_bowl/entities/lava_annihilation_spell_bigger.xml", x, y )
end

function lava_removal_400( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/lava_bowl/entities/lava_annihilation_spell_400.xml", x, y )
end

function lava_removal_450( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/lava_bowl/entities/lava_annihilation_spell_450.xml", x, y )
end