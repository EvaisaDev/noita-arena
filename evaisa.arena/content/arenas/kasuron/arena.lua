dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xffeef615, "sun" )
RegisterSpawnFunction( 0xffb45331, "wheel" )
RegisterSpawnFunction( 0xffb423e8, "TP1" )
RegisterSpawnFunction( 0xffb423e9, "TP2" )
RegisterSpawnFunction( 0xffb42310, "TP3" )
RegisterSpawnFunction( 0xffb42323, "TP4" )
RegisterSpawnFunction( 0xffb42345, "TP5" )
RegisterSpawnFunction( 0xffb42123, "TP6" )
RegisterSpawnFunction( 0xffb42308, "CAGE" )
RegisterSpawnFunction( 0xff1f5b7b, "Prop1" )
RegisterSpawnFunction( 0xffa0b572, "Prop2" )
RegisterSpawnFunction( 0xfff5b537, "SKATE" )
RegisterSpawnFunction( 0xffeb1813, "laser" )
RegisterSpawnFunction( 0xff06ec25, "radio" )
RegisterSpawnFunction( 0xffa83717, "box" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

function sun( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/sunbaby.xml", x, y )
end

function wheel( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/physics_wheel.xml", x, y )
end

function TP1( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleport.xml", x, y )
end

function TP2( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleportgold.xml", x, y )
end

function TP3( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleportout.xml", x, y )
end

function TP4( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleportright.xml", x, y )
end

function TP5( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleportleft.xml", x, y )
end

function TP6( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/teleportup.xml", x, y )
end

function Prop1( x, y )
	EntityLoad( "data/entities/props/vault_apparatus_01.xml", x, y )
end

function laser( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/kasuron/entities/lasergate.xml", x, y )
end

function box( x, y )
	local entity = EntityLoad( "data/entities/props/physics_barrel_water.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (59 + x) ^ y,
		value_int = 0,
	})
end

function radio( x, y )
	local entity = EntityLoad( "data/entities/props/physics_barrel_radioactive.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (60 + x) ^ y,
		value_int = 0,
	})
end

function SKATE( x, y )
	local entity = EntityLoad( "data/entities/props/physics_skateboard.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (61 + x) ^ y,
		value_int = 0,
	})
end

function Prop2( x, y )
	local entity = EntityLoad( "data/entities/props/furniture_locker.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (62 + x) ^ y,
		value_int = 0,
	})
end

function CAGE( x, y )
	local entity = EntityLoad( "data/entities/props/suspended_cage.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (63 + x) ^ y,
		value_int = 0,
	})
end

