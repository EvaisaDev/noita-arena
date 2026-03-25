EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
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
RegisterSpawnFunction( 0xfff1356a, "spawn_bridge" )
RegisterSpawnFunction( 0xff9656df, "spawn_brewing_stand" )
RegisterSpawnFunction( 0xff4b99a2, "spawn_rocking_chair")
RegisterSpawnFunction( 0xffc4db26, "spawn_bed")
RegisterSpawnFunction( 0xffb635b4, "spawn_chair")
RegisterSpawnFunction( 0xff583d96, "spawn_table")
RegisterSpawnFunction( 0xff7343a2, "spawn_explosive_crate")
RegisterSpawnFunction( 0xff78abc6, "small_crate")
RegisterSpawnFunction( 0xff3a7493, "large_crate")
RegisterSpawnFunction( 0xff7c56b2, "toxic_barrel")
RegisterSpawnFunction( 0xffd43ed4, "barrel_unstable")
RegisterSpawnFunction( 0xff40d169, "spawn_dresser")
RegisterSpawnFunction( 0xff934392, "spawn_chair_2")
RegisterSpawnFunction( 0xff5cc52c, "spawn_chandelier")
RegisterSpawnFunction( 0xff49ab8e, "spawn_wardrobe")
RegisterSpawnFunction( 0xff486177, "spawn_cage" )
RegisterSpawnFunction( 0xff29b01d, "spawn_castle_statue" )
RegisterSpawnFunction( 0xff32702c, "spawn_temple_statue_2" )
RegisterSpawnFunction( 0xff73a06e, "spawn_temple_statue_1" )
RegisterSpawnFunction( 0xffa53cc5, "spawn_worm_deflector" )
RegisterSpawnFunction( 0xff739663, "spawn_vase" )
RegisterSpawnFunction( 0xff6dc8c3, "spawn_potion" )
RegisterSpawnFunction( 0xffceb931, "spawn_random_trapbox" )
RegisterSpawnFunction( 0xff3ac6d6, "spawn_suspended_container" )
RegisterSpawnFunction( 0xff1f5b7b, "physics_box_explosive" )
RegisterSpawnFunction( 0xffc53fd1, "wand_altar" )
RegisterSpawnFunction( 0xffd56be5, "heart" )
RegisterSpawnFunction( 0xff5c37b3, "vault_apparatus_01" )
RegisterSpawnFunction( 0xff533d86, "vault_apparatus_02" )
RegisterSpawnFunction( 0xff3d7b86, "furniture_castle_divan" )
RegisterSpawnFunction( 0xff4d6164, "furniture_castle_wardrobe" )
RegisterSpawnFunction( 0xff95668e, "furniture_castle_chair" )
RegisterSpawnFunction( 0xff3b66b0, "furniture_castle_table" )
RegisterSpawnFunction( 0xff1b3157, "furniture_stool" )
RegisterSpawnFunction( 0xff4bd13f, "suspended_seamine" )
RegisterSpawnFunction( 0xff3691d2, "physics_chain_torch_ghostly" )
RegisterSpawnFunction( 0xffa29d5e, "physics_sandbag" )
RegisterSpawnFunction( 0xff1e6341, "forcefield_generator" )


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
		if(has_tag(v, "magic_liquid") or has_tag(v, "water") or has_tag(v, "liquid_common")) and (not v:match("molten") and not has_tag(v, "hot") and not has_tag(v, "lava") and not has_tag(v, "fire") and not has_tag(v, "fire_strong") and not GameHasFlagRun("material_blacklist_"..v)) then
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
	local colors = {ffa111ba = get_random_liquid(), ffa063c9 = get_random_liquid(), ff9854ff = get_random_liquid(), ff54a7ff = get_random_liquid(), ffb475bd = get_random_liquid()}
	local base = "mods/evaisa.arena/content/arenas/tower/spliced"
	LoadPixelScene( base.."/0.plz", base.."/0_visual.plz", -506, -836, base.."/0_background.png", false, false, colors )
	LoadPixelScene( base.."/1.plz", base.."/1_visual.plz", -629, -608, base.."/1_background.png", false, false, colors )
	LoadPixelScene( base.."/2.plz", base.."/2_visual.plz", -615, -96, base.."/2_background.png", false, false, colors )
	LoadPixelScene( base.."/3.plz", base.."/3_visual.plz", -637, 416, base.."/3_background.png", false, false, colors )
	LoadPixelScene( base.."/4.plz", base.."/4_visual.plz", 354, -608, base.."/4_background.png", false, false, colors )
	LoadPixelScene( base.."/5.plz", base.."/5_visual.plz", -158, -497, base.."/5_background.png", false, false, colors )
	LoadPixelScene( base.."/6.plz", base.."/6_visual.plz", -158, -96, base.."/6_background.png", false, false, colors )
	LoadPixelScene( base.."/7.plz", base.."/7_visual.plz", -158, 416, base.."/7_background.png", false, false, colors )
	LoadPixelScene( base.."/8.plz", base.."/8_visual.plz", 670, -608, base.."/8_background.png", false, false, colors )
	LoadPixelScene( base.."/9.plz", base.."/9_visual.plz", 354, -548, base.."/9_background.png", false, false, colors )
	LoadPixelScene( base.."/10.plz", base.."/10_visual.plz", 354, -96, base.."/10_background.png", false, false, colors )
	LoadPixelScene( base.."/11.plz", base.."/11_visual.plz", 354, 416, base.."/11_background.png", false, false, colors )
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
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics/chain_torch.xml", x, y ), x, y)
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

function spawn_bridge( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/tower/entities/bridge_spawner.xml", x, y )
end

function spawn_brewing_stand( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_brewing_stand.xml", x, y ), x, y)
end

function spawn_rocking_chair( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_rocking_chair.xml", x, y ), x, y)
end

function spawn_bed( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_bed.xml", x, y ), x, y)
end

function spawn_chair( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_wood_chair.xml", x, y ), x, y)
end

function spawn_table( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_wood_table.xml", x, y ), x, y)
end

function spawn_explosive_crate( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_crate.xml", x, y ), x, y)
end

function small_crate( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_box_harmless.xml", x, y ), x, y)
end

function large_crate( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_box_harmless_small.xml", x, y ), x, y)
end

function toxic_barrel( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_barrel_radioactive.xml", x, y ), x, y)
end

function barrel_unstable( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_barrel_oil.xml", x, y ), x, y)
end

function spawn_dresser( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_dresser.xml", x, y ), x, y)
end

function spawn_chair_2( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_chair_2.xml", x, y ), x, y)
end

function spawn_chandelier( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_chandelier.xml", x, y ), x, y)
end

function spawn_wardrobe( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_wardrobe.xml", x, y ), x, y)
end

function spawn_cage( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/suspended_cage.xml", x, y ), x, y)
end


function spawn_castle_statue( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/castle_statue.xml", x, y )
end

function spawn_temple_statue_1( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/temple_statue_01.xml", x, y )
end

function spawn_temple_statue_2( x, y )
	EntityLoad( "mods/evaisa.arena/content/arenas/spoop/entities/temple_statue_02.xml", x, y )
end

function spawn_worm_deflector( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/buildings/physics_worm_deflector.xml", x, y ), x, y)
end

function spawn_vase( x, y )
	SetRandomSeed(x, y)

	local vases = {
		"data/entities/props/physics_vase.xml",
		"data/entities/props/physics_vase_longleg.xml"
	}

	EntityHelper.NetworkRegister(EntityLoad( vases[Random(1, #vases)], x, y ), x, y)
end

function spawn_potion( x, y )
	SetRandomSeed(x, y)

	EntityHelper.NetworkRegister(EntityLoad( "data/entities/items/pickup/potion.xml", x, y ), x, y)
end

function spawn_random_trapbox( x, y )
	SetRandomSeed(x, y)

	local trapboxes = {
		"data/entities/props/physics/trap_laser.xml",
		"data/entities/props/physics_trap_circle_acid.xml",
		"data/entities/props/physics_trap_electricity.xml",
		"data/entities/props/physics_trap_ignite.xml",
		"data/entities/props/physics_trap_circle_acid.xml"
	}

	EntityHelper.NetworkRegister(EntityLoad( trapboxes[Random(1, #trapboxes)], x, y ), x, y)
end

function spawn_suspended_container( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/suspended_container.xml", x, y ), x, y)
end

function physics_box_explosive( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_box_explosive.xml", x, y ), x, y)
end

function wand_altar( x, y )
	LoadPixelScene( "data/biome_impl/wand_altar.png", "data/biome_impl/wand_altar_visual.png", x-10, y-17, "", true )

	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/wand_unshuffle_03.xml", x - 1, y - 12 ), x - 1, y - 12)
end

function heart( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/content/arenas/bureon/entities/heart.xml", x, y ), x, y)
end

function vault_apparatus_01( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/vault_apparatus_01.xml", x, y ), x, y)
end

function vault_apparatus_02( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/vault_apparatus_02.xml", x, y ), x, y)
end

function furniture_castle_divan( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_castle_divan.xml", x, y ), x, y)
end

function furniture_castle_wardrobe( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_castle_wardrobe.xml", x, y ), x, y)
end

function furniture_castle_chair( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_castle_chair.xml", x, y ), x, y)
end

function furniture_castle_table( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_castle_table.xml", x, y ), x, y)
end

function furniture_stool( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/furniture_stool.xml", x, y ), x, y)
end

function suspended_seamine( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/suspended_seamine.xml", x, y ), x, y)
end

function physics_chain_torch_ghostly( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_chain_torch_ghostly.xml", x, y ), x, y)
end

function physics_sandbag( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/physics_sandbag.xml", x, y ), x, y)
end

function forcefield_generator( x, y )
	EntityHelper.NetworkRegister(EntityLoad( "data/entities/props/forcefield_generator.xml", x, y ), x, y)
end