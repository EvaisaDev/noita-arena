dofile_once("data/scripts/lib/utilities.lua")

-- NOTE (Petri): 
-- There is a mods/nightmare potion.lua which overwrites this one.

flask_materials = 
{
	-- Standard Materials (75% chance)
	{ material = "lava", weight = 7.5 }, -- 75 / 11 = 6.81 rounded to 7.5
	{ material = "water", weight = 7.5 },
	{ material = "blood", weight = 7.5 },
	{ material = "alcohol", weight = 7.5 },
	{ material = "oil", weight = 7.5 },
	{ material = "slime", weight = 7.5 },
	{ material = "acid", weight = 7.5 },
	{ material = "radioactive_liquid", weight = 7.5 },
	{ material = "gunpowder_unstable", weight = 7.5 },
	{ material = "liquid_fire", weight = 7.5 },
	{ material = "blood_cold", weight = 7.5 },

	-- Magic Materials (25% chance)
	{ material = "magic_liquid_unstable_teleportation", weight = 2.5 }, -- 25 / 13 = 1.92 rounded to 2.5
	{ material = "magic_liquid_polymorph", weight = 2.5 },
	{ material = "magic_liquid_random_polymorph", weight = 2.5 },
	{ material = "magic_liquid_berserk", weight = 2.5 },
	{ material = "magic_liquid_invisibility", weight = 2.5 },
	{ material = "material_confusion", weight = 2.5 },
	{ material = "magic_liquid_movement_faster", weight = 2.5 },
	{ material = "magic_liquid_faster_levitation", weight = 2.5 },
	{ material = "magic_liquid_worm_attractor", weight = 2.5 },
	{ material = "magic_liquid_protection_all", weight = 2.5 },
	{ material = "magic_liquid_mana_regeneration", weight = 2.5 },
	{ material = "magic_liquid_hp_regeneration", weight = 0.0375 },  -- 0.05 / 100000 * 75 = 0.0375
	{ material = "purifying_powder", weight = 0.01875 }, -- 0.05 / 100000 * 75 = 0.01875
	{ material = "magic_liquid_weakness", weight = 0.0375 },  -- 0.05 / 100000 * 75 = 0.0375
	{ material="magic_liquid_charm", weight=2.5, handler=function()
		local year, month, day = GameGetDateAndTimeLocal()
		return (month == 2 and day == 14 and Random(0, 100) <= 8)
	end},
	{ material="sima", weight=0, handler=function()
		local year, month, day = GameGetDateAndTimeLocal()
		if ((month == 5 and day == 1) or (month == 4 and day == 30)) and (Random(0, 100) <= 20) then
			return true
		end
		return false
	end},
	{ material="juhannussima", weight=0, handler=function()
		local year, month, day, temp1, temp2, temp3, jussi = GameGetDateAndTimeLocal()
		if jussi and (Random(0, 100) <= 9) then
			return true
		end
		return false
	end}
}

dofile("mods/evaisa.arena/files/scripts/utilities/utils.lua")

function init(entity_id)
	local x, y = EntityGetTransform(entity_id)

	dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")
	local seed_x, seed_y = get_new_seed( x, y, GameHasFlagRun("sync_item_generation") )

	--print("potion_seed", tostring(seed_x), tostring(seed_y))

	SetRandomSeed(seed_x, seed_y)

	local item = random_from_weighted_table(flask_materials, function(item)
		return GameHasFlagRun("material_blacklist_"..item.material)
	end)
	local potion_material = item.material

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