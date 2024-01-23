dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xff50db46, "spawn_lamp" )
RegisterSpawnFunction( 0xffFF50FF, "spawn_hanger" )
RegisterSpawnFunction( 0xff0050FF, "spawn_wheel" )
RegisterSpawnFunction( 0xff0150FF, "spawn_wheel_small" )
RegisterSpawnFunction( 0xff0250FF, "spawn_wheel_tiny" )

function spawn_point( x, y )

	print("spawning point")

	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end


function spawn_lamp(x, y)

	local lamp = EntityLoad("data/entities/props/physics/lantern_small.xml", x, y)

	EntityAddComponent2(lamp, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(lamp, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (53 + x) ^ y,
		value_int = 0,
	})
end

function spawn_wheel(x, y)
	local entity = EntityLoad( "data/entities/props/physics_wheel.xml", x, y )

	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (554 + x) ^ y,
		value_int = 0,
	})
end

function spawn_wheel_small(x, y)
	local entity = EntityLoad( "data/entities/props/physics_wheel_small.xml", x, y )

	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (123 + x) ^ y,
		value_int = 0,
	})
end

function spawn_wheel_tiny(x, y)
	local entity = EntityLoad( "data/entities/props/physics_wheel_tiny.xml", x, y )

	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (5321 + x) ^ y,
		value_int = 0,
	})
end

function spawn_hanger(x, y)
	--[[
	local entity = EntityLoad( "data/entities/props/physics_bucket.xml", x, y )

	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (324 + x) ^ y,
		value_int = 0,
	})
	]]
end