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
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/heart.xml", x, y )
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

function music3( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/music_machine_03.xml", x, y )
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

function wand3( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/wand_unshuffle_03.xml", x, y )
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

function music2( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/music_machine_02.xml", x, y )
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

function skull( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/physics_skull_01.xml", x, y )
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

function bone1( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/physics_bone_01.xml", x, y )
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

function bone2( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/physics_bone_02.xml", x, y )
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

function orb( x, y )
	local entity = EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/potion.xml", x, y )
	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (51 + x) ^ y,
		value_int = 0,
	})
end