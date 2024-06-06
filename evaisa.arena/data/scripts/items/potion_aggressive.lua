 dofile_once("data/scripts/lib/utilities.lua")

potions = 
{
	{
		material="lava",
		weight=1,
	},
	{
		material="water",
		weight=1,
	},
	{
		material="blood",
		weight=1,
	},
	{
		material="alcohol",
		weight=1,
	},
	{
		material="oil",
		weight=1,
	},
	{
		material="slime",
		weight=1,
	},
	{
		material="acid",
		weight=1,
	},
	{
		material="radioactive_liquid",
		weight=1,
	},
	{
		material="gunpowder_unstable",
		weight=1,
	},
	{
		material="liquid_fire",
		weight=1,
	},
	{
		material="magic_liquid_teleportation",
		weight=1,
	},
	{
		material="magic_liquid_berserk",
		weight=1,
	},
	{
		material="magic_liquid_charm",
		weight=1,
	},
	{
		material="blood_cold",
		weight=1,
	},
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

	AddMaterialInventoryMaterial(entity_id, potion_material, 1000)
end