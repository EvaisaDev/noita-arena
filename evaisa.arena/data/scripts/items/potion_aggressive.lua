dofile_once("data/scripts/lib/utilities.lua")

flask_materials = 
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

dofile("mods/evaisa.arena/files/scripts/utilities/utils.lua")

function init(entity_id)
	local x, y = EntityGetTransform(entity_id)

	dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")
	local seed_x, seed_y = get_new_seed( x, y, true )
	SetRandomSeed(seed_x, seed_y)

	local item = random_from_weighted_table(flask_materials, function(item)
		return GameHasFlagRun("material_blacklist_"..item.material)
	end)
	local potion_material = item.material

	AddMaterialInventoryMaterial(entity_id, potion_material, 1000)
end