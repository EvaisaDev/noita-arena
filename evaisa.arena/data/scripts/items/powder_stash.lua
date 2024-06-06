 dofile_once("data/scripts/lib/utilities.lua")

-- NOTE( Petri ): 
-- There is a mods/nightmare potion.lua which overwrites this one.

local materials = {
	-- Standard Materials (75% chance)
	{ material = "sand", weight = 7.5 },
	{ material = "soil", weight = 7.5 },
	{ material = "snow", weight = 7.5 },
	{ material = "salt", weight = 7.5 },
	{ material = "coal", weight = 7.5 },
	{ material = "gunpowder", weight = 7.5 },
	{ material = "fungisoil", weight = 7.5 },
  
	-- Magic Materials (25% chance)
	{ material = "copper", weight = 2.5 },
	{ material = "silver", weight = 2.5 },
	{ material = "gold", weight = 2.5 },
	{ material = "brass", weight = 2.5 },
	{ material = "bone", weight = 2.5 },
	{ material = "purifying_powder", weight = 2.5 },
	{ material = "fungi", weight = 2.5 }
}

dofile("mods/evaisa.arena/files/scripts/utilities/utils.lua")

function init(entity_id)
	local x, y = EntityGetTransform(entity_id)

	dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")
	local seed_x, seed_y = get_new_seed( x, y, GameHasFlagRun("shop_sync") )
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