dofile_once("data/scripts/lib/utilities.lua")

materials = 
{
	{ material = "mud", weight = 6.5 },
	{ material = "water_swamp", weight = 6.5 },
	{ material = "water_salt", weight = 6.5 },
	{ material = "swamp", weight = 6.5 },
	{ material = "snow", weight = 6.5 },
	{ material = "water", weight = 32.5 },  -- 65 * 0.5 = 32.5 
	{ material = "blood", weight = 15 },
	{ material = "acid", weight = 2.4 },
	{ material = "magic_liquid_polymorph", weight = 2.4 },
	{ material = "magic_liquid_random_polymorph", weight = 2.4 },
	{ material = "magic_liquid_berserk", weight = 2.4 },
	{ material = "magic_liquid_charm", weight = 2.4 },
	{ material = "magic_liquid_movement_faster", weight = 2.4 },
	{ material = "urine", weight = 0.000666 },
	{ material = "gold", weight = 0.000079 },
	{ material = "slime", weight = 0.4996275 },  -- (0.999255 * 0.5) = 0.4996275
	{ material = "gunpowder_unstable", weight = 0.4996275 },  -- (0.999255 * 0.5) = 0.4996275
	{ material="sima", weight=0, handler=function()
		local year, month, day = GameGetDateAndTimeLocal()
		if ((month == 5 and day == 1) or (month == 4 and day == 30)) and (Random(0, 100) <= 20) then
			return true
		end
		return false
	end},
}


-- Function to randomly select material from a weighted list with special handlers
function random_from_weighted_table(weighted_table)
	-- Check for any handler that forces selection
	for _, item in ipairs(weighted_table) do
		if item.handler and item.handler() then
			return item.material
		end
	end

	-- Calculate total weight for normal selection
	local total_weight = 0
	for _, item in ipairs(weighted_table) do
		total_weight = total_weight + item.weight
	end

	local random_weight = Random(1, total_weight * 1000000) / 1000000
	for _, item in ipairs(weighted_table) do
		random_weight = random_weight - item.weight
		if random_weight <= 0 then
			return item.material
		end
	end
end

function init(entity_id)
	local x, y = EntityGetTransform(entity_id)

	dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")
	local seed_x, seed_y = get_new_seed( x, y, true )
	SetRandomSeed(seed_x, seed_y)

	local potion_material = random_from_weighted_table(materials)

	local total_capacity = tonumber(GlobalsGetValue("EXTRA_POTION_CAPACITY_LEVEL", "1000")) or 1000
	if total_capacity > 1000 then
		local comp = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")

		if comp ~= nil then
			ComponentSetValue(comp, "barrel_size", total_capacity)
		end

		EntityAddTag(entity_id, "extra_potion_capacity")
	end

	local components = EntityGetComponent(entity_id, "VariableStorageComponent")

	if components ~= nil then
		for key, comp_id in pairs(components) do
			local var_name = ComponentGetValue(comp_id, "name")
			if var_name == "potion_material" then
				potion_material = ComponentGetValue(comp_id, "value_string")
			end
		end
	end

	AddMaterialInventoryMaterial(entity_id, potion_material, total_capacity)
end