dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/director_helpers_design.lua")
dofile_once("data/scripts/biome_scripts.lua")
dofile_once("mods/evaisa.arena/files/scripts/utilities/vegetation_loader.lua")

RegisterSpawnFunction( 0xffff54e3, "spawn_point" )
RegisterSpawnFunction( 0xffdd00ff, "spawn_scene" )
RegisterSpawnFunction( 0xff00d9ff, "spawn_cactus" )
RegisterSpawnFunction( 0xff006aff, "spawn_dry_grass" )
RegisterSpawnFunction( 0xffff9900, "spawn_tree" )
RegisterSpawnFunction( 0xffd9ff00, "spawn_bush")
RegisterSpawnFunction( 0xffa1a2f3, "physics_lantern_small" )
RegisterSpawnFunction( 0xffa1a2a4, "physics_lantern" )
RegisterSpawnFunction( 0xffa1a2b4, "physics_chain_torch" )
RegisterSpawnFunction( 0xffa1a2c4, "torch_stand" )
RegisterSpawnFunction( 0xff36ab6c, "spawn_bone" )

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

local function has_tag(mat, tag)
    local mat_id = CellFactory_GetType(mat)
    local tags = CellFactory_GetTags(mat_id)
    if not tags[1] then return false end
    for i = 1, #tags do
        if tags[i]:match(tag) then
            return true
        end
    end
    return false
end

function get_random_liquid()
	local liquids = CellFactory_GetAllLiquids(false, false)

	local valid_liquids = {}
	for k, v in pairs(liquids)do
		if(has_tag(v, "magic_liquid") or has_tag(v, "water") or has_tag(v, "liquid_common")) and not v:match("molten") and not GameHasFlagRun("material_blacklist_"..v) then
			table.insert(valid_liquids, v)
		end
	end

	if(#valid_liquids == 0)then
		return "water"
	end

	return valid_liquids[Random(1, #valid_liquids)]
end

function spawn_scene( x, y )
	SetRandomSeed(x, y)
	local colors = {ffc13fd8 = get_random_liquid(), ff5e3fd8 = get_random_liquid()}
	x=-450
	y=-350
	LoadPixelScene( "mods/evaisa.arena/content/arenas/remnant/materials_new.png", "mods/evaisa.arena/content/arenas/remnant/visuals_new.png", x, y, "mods/evaisa.arena/content/arenas/remnant/background_new.png", false, false, colors)
end

-- note to do this kinda thing you need to register the vegetation in data.lua
function spawn_cactus( x, y )
	print("spawning cactus at", x, y)
	LoadVegetation("data/vegetation/cactus_0$[2-7].xml", x, y)
end

function spawn_dry_grass( x, y )
	print("spawning dry grass at", x, y)
	LoadVegetation("data/vegetation/drygrass_$[1-4].xml", x, y)
end

function spawn_tree( x, y )
	print("spawning tree at", x, y)
	LoadVegetation("data/vegetation/tree_spruce_"..tostring(Random(1, 4))..".xml", x, y)
end

function spawn_bush( x, y )
	print("spawning bush at", x, y)
	LoadVegetation("data/vegetation/bush_0$[1-9].xml", x, y)
end


function physics_lantern( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/lantern_small.xml", x, y ), x, y)
end

function physics_lantern_small( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/lantern_small.xml", x, y ), x, y)
end

function physics_chain_torch( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/remnant/entities/chain_torch.xml", x, y ), x, y)
end

function torch_stand( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_torch_stand.xml", x, y ), x, y)
end

function spawn_bone( x, y )
	SetRandomSeed(x, y)
	local bones = {
		"data/entities/props/physics_skull_01",
		"data/entities/props/physics_skull_02",
		"data/entities/props/physics_skull_03",
		"data/entities/props/physics_bone_01",
		"data/entities/props/physics_bone_02",
		"data/entities/props/physics_bone_03",
		"data/entities/props/physics_bone_04",
		"data/entities/props/physics_bone_05",
		"data/entities/props/physics_bone_06"
	}

	EntityHelper.NetworkRegister(EntityLoad( bones[Random(1, #bones)]..".xml", x, y ), x, y)
end