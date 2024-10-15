dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform( entity_id )
pos_x = pos_x - 5

local stones = {
	"data/entities/props/physics_stone_01.xml",
	"data/entities/props/physics_stone_02.xml",
	"data/entities/props/physics_stone_03.xml",
	"data/entities/props/physics_stone_03.xml",
	"data/entities/props/physics_stone_04.xml",
	"data/entities/props/physics_stone_04.xml",
}

local props = {
	"data/entities/props/physics_stone_01.xml",
	"data/entities/props/physics_stone_02.xml",
	"data/entities/props/physics_stone_03.xml",
	"data/entities/props/physics_stone_04.xml",
}

local count = ProceduralRandomi(pos_x, pos_y, 2, 7)

for i=1,count do
	local obj
	local r = ProceduralRandomf(i + pos_x, pos_y + 4)
	if r > 0.9 then
		obj = props[ProceduralRandomi(pos_x - 4, pos_y + i, 1, #props)]
	else
		obj = stones[ProceduralRandomi(pos_x - 4, pos_y + i, 1, #stones)]
	end
	
	local entity = EntityLoad(obj, pos_x + r * 8, pos_y)

	EntityAddComponent2(entity, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
		script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
		script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
		script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
	})

	EntityAddComponent2(entity, "VariableStorageComponent", {
		name = "arena_entity_id",
		value_float = (554 + pos_x) ^ pos_y,
		value_int = 0,
	})
	
	pos_y = pos_y - 5
end
