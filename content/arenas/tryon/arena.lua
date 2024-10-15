dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xff5cb643, "skull" )
RegisterSpawnFunction( 0xff5cb644, "bone1" )
RegisterSpawnFunction( 0xff5cb645, "bone2" )
RegisterSpawnFunction( 0xff982945, "pot" )
RegisterSpawnFunction( 0xff982946, "lamp" )
RegisterSpawnFunction( 0xff982947, "tnt" )
RegisterSpawnFunction( 0xff982948, "tnt2" )
RegisterSpawnFunction( 0xff00dbff, "lasergate" )
RegisterSpawnFunction( 0xff00db86, "forcefield" )
RegisterSpawnFunction( 0xff8ab222, "wire" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function skull( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_skull_01.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (53 + x) ^ y,
		value_int = 0,
	})
end

function bone1( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_bone_01.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (54 + x) ^ y,
		value_int = 0,
	})
end

function bone2( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_bone_02.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (55 + x) ^ y,
		value_int = 0,
	})
end

function pot( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/potion.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (56 + x) ^ y,
		value_int = 0,
	})
end

function lamp( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_tubelamp.xml", x, y )
end

function tnt( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_box_explosive.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (57 + x) ^ y,
		value_int = 0,
	})
end

function tnt2( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_propane_tank.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (58 + x) ^ y,
		value_int = 0,
	})
end

function lasergate( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/lasergate_down.xml", x, y )
end

function forcefield( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/forcefield_generator.xml", x, y )
end

function wire( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/tryon/entities/physics_hanging_wire.xml", x, y )
end