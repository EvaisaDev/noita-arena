-- default biome functions that get called if we can't find a a specific biome that works for us
-- The level of action ids that are spawned from the chests
CHEST_LEVEL = 2
dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/biome_scripts.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/biome_modifiers.lua")
dofile( "mods/evaisa.arena/files/scripts/misc/generate_shop_item.lua" )


RegisterSpawnFunction( 0xffffeedd, "init" )
RegisterSpawnFunction( 0xff00AC33, "load_pixel_scene3" )
RegisterSpawnFunction( 0xff00AC64, "load_pixel_scene4" )
RegisterSpawnFunction( 0xff4691c7, "load_puzzle_capsule" )
RegisterSpawnFunction( 0xff3691d7, "load_puzzle_capsule_b" )
RegisterSpawnFunction( 0xff55AF4B, "load_altar" )
RegisterSpawnFunction( 0xff23B9C3, "spawn_altar_torch" ) 
RegisterSpawnFunction( 0xff55AF8C, "spawn_skulls" ) 
RegisterSpawnFunction( 0xffF516E3, "spawn_scavenger_party" )
RegisterSpawnFunction( 0xffFFC84E, "spawn_acid" )
RegisterSpawnFunction( 0xff7285c4, "load_acidtank_right" )
RegisterSpawnFunction( 0xff9472c4, "load_acidtank_left" )
RegisterSpawnFunction( 0xff504600, "spawn_stones" )
RegisterSpawnFunction( 0xffc800ff, "load_pixel_scene_alt" )
RegisterSpawnFunction( 0xff33934c, "spawn_shopitem" )
RegisterSpawnFunction( 0xff80FF5A, "spawn_vines" )
RegisterSpawnFunction( 0xff434040, "spawn_burning_barrel" )
RegisterSpawnFunction( 0xffb4a00a, "spawn_fish" )
RegisterSpawnFunction( 0xffaa42ff, "spawn_electricity_trap" )
RegisterSpawnFunction( 0xff366178, "spawn_buried_eye_teleporter" )
RegisterSpawnFunction( 0xff876543, "spawn_statue_hand" )
RegisterSpawnFunction( 0xff00855c, "spawn_receptacle" )


------------ SMALL ENEMIES ----------------------------------------------------

g_small_enemies =
{
	total_prob = 0,
	-- this is air, so nothing spawns at 0.6
	{
		prob   		= 0.1,
		min_count	= 0,
		max_count	= 0,    
		entity 	= ""
	},
	-- add skullflys after this step
	{
		prob   		= 0.2,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/shotgunner.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/slimeshooter.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 4,    
		entity 	= "data/entities/animals/rat.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/iceskull.xml"
	},
	{
		prob   		= 0.07,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/scavenger_grenade.xml"
	},
	{
		prob   		= 0.07,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/scavenger_smg.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entities 	= {
		"data/entities/animals/scavenger_smg.xml",
		"data/entities/animals/scavenger_grenade.xml"
		}
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/sniper.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank.xml"
	},
	{
		prob   		= 0.01,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank_rocket.xml"
	},
	{
		prob   		= 0.09,
		min_count	= 1,
		max_count	= 1,
		ngpluslevel	= 1,
		entity 	= "data/entities/animals/thundermage.xml"
	},
	{
		prob   		= 0.09,
		min_count	= 1,
		max_count	= 1,
		ngpluslevel	= 2,
		entity 	= "data/entities/animals/thundermage_big.xml"
	},
}


------------ BIG ENEMIES ------------------------------------------------------

g_big_enemies =
{
	total_prob = 0,
	-- this is air, so nothing spawns at 0.6
	{
		prob   		= 0.3,
		min_count	= 0,
		max_count	= 0,    
		entity 	= ""
	},
	-- add skullflys after this step
	{
		prob   		= 0.15,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/thundermage.xml"
	},
	{
		prob   		= 0.08,
		min_count	= 1,
		max_count	= 1,
		ngpluslevel	= 1,
		entity 	= "data/entities/animals/thundermage_big.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/worm_big.xml"
	},
	{
		prob   		= 0.01,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/worm.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 3,    
		entity 	= "data/entities/animals/worm_tiny.xml"
	},
	{
		prob   		= 0.4,
		min_count	= 1,
		max_count	= 3,    
		entity 	= "data/entities/animals/iceskull.xml"
	},
	{
		prob   		= 0.2,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/giant.xml"
	},
	{
		prob   		= 0.04,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/icemage.xml"
	},
	{
		prob   		= 0.2,
		min_count	= 1,
		max_count	= 1,    
		entities 	= {
			{
				min_count	= 1,
				max_count 	= 1,
				entity = "data/entities/animals/sniper.xml",
			},
			{
				min_count	= 0,
				max_count 	= 2,
				entity = "data/entities/animals/shotgunner.xml",
			},
		}
	},
	{
		prob   		= 0.2,
		min_count	= 2,
		max_count	= 3,    
		entity 	= "data/entities/animals/scavenger_grenade.xml"
	},
	{
		prob   		= 0.2,
		min_count	= 2,
		max_count	= 3,    
		entity 	= "data/entities/animals/scavenger_smg.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 2,    
		entities 	= {
			{
				min_count	= 1,
				max_count 	= 2,
				entity = "data/entities/animals/scavenger_smg.xml",
			},
			{
				min_count	= 1,
				max_count 	= 2,
				entity = "data/entities/animals/scavenger_grenade.xml",
			},
		}
	},
	{
		prob   		= 0.02,
		min_count	= 1,
		max_count	= 1,
		ngpluslevel = 1,
		entities 	= {
			{
				min_count	= 1,
				max_count 	= 1,
				entity = "data/entities/animals/scavenger_smg.xml",
			},
			{
				min_count	= 1,
				max_count 	= 2,
				entity = "data/entities/animals/scavenger_grenade.xml",
			},
			{
				min_count	= 0,
				max_count 	= 1,
				entity = "data/entities/animals/coward.xml",
			},
		}
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank.xml"
	},
	{
		prob   		= 0.03,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank_rocket.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entities 	= {
			{
				min_count	= 1,
				max_count 	= 3,
				entity = "data/entities/animals/scavenger_smg.xml",
			},
			{
				min_count	= 1,
				max_count 	= 3,
				entity = "data/entities/animals/scavenger_grenade.xml",
			},
			"data/entities/animals/scavenger_leader.xml",
		}
	},
	{
		prob   		= 0.01,
		min_count	= 1,
		max_count	= 1,    
		entity 		= "data/entities/animals/monk.xml"
	},
	{
		prob   		= 0.01,
		min_count	= 1,
		max_count	= 1,    
		entity 		= "data/entities/animals/wizard_neutral.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/thunderskull.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 2,
		max_count	= 4,    
		entity 	= "data/entities/animals/scavenger_glue.xml",
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/drone_shield.xml",
		ngpluslevel = 2,
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/buildings/hpcrystal.xml",
		ngpluslevel = 1,
	},
	{
		prob   		= 0.01,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/easter/sniper.xml",
		spawn_check = function() 
			local year, month, day = GameGetDateAndTimeLocal()
			
			if ( month == 8 ) and ( day == 24 ) then
				return true
			else
				return false 
			end
		end,
	},
}


---------- UNIQUE ENCOUNTERS ---------------

g_scavenger_party =
{
	total_prob = 0,
	-- 
	{
		prob   		= 1,
		min_count	= 1,
		max_count	= 1,    
		entities 	= {
			{
				min_count	= 1,
				max_count 	= 3,
				entity = "data/entities/animals/scavenger_smg.xml",
			},
			{
				min_count	= 1,
				max_count 	= 3,
				entity = "data/entities/animals/scavenger_grenade.xml",
			},
			{
				min_count	= 0,
				max_count 	= 1,
				entity = "data/entities/animals/coward.xml",
			},
			"data/entities/animals/scavenger_leader.xml",
		}
	},
}


g_unique_enemy =
{
	total_prob = 0,
	-- this is air, so nothing spawns at 0.6
	{
		prob   		= 0.0,
		min_count	= 0,
		max_count	= 0,    
		entity 	= ""
	},
	-- add skullflys after this step
	{
		prob   		= 1.0,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank_rocket.xml"
	},
	{
		prob   		= 0.001,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/tank_super.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/wizard_tele.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/wizard_dark.xml"
	},
	{
		prob   		= 0.07,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/wizard_swapper.xml"
	},
	{
		prob   		= 0.1,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/necromancer.xml"
	},
}

g_unique_enemy2 =
{
	total_prob = 0,
	-- this is air, so nothing spawns at 0.6
	{
		prob   		= 0.0,
		min_count	= 0,
		max_count	= 0,    
		entity 	= ""
	},
	-- add skullflys after this step
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/scavenger_grenade.xml"
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 2,    
		entity 	= "data/entities/animals/scavenger_smg.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/animals/sniper.xml"
	}
}

------------ ITEMS ------------------------------------------------------------

g_items =
{
	total_prob = 0,
	-- this is air, so nothing spawns at 0.6
	{
		prob   		= 0,
		min_count	= 0,
		max_count	= 0,    
		entity 	= ""
	},
	-- add skullflys after this step
	{
		prob   		= 5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/items/wand_level_02.xml"
	},
	-- debug tests
	{
		prob   		= 5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/items/wand_level_02_better.xml"
	},
	{
		prob   		= 5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/items/wand_unshuffle_02.xml"
	},
}

g_pixel_scene_01 =
{
	total_prob = 0,
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/verticalobservatory.png",
		visual_file		= "data/biome_impl/snowcave/verticalobservatory_visual.png",
		background_file	= "data/biome_impl/snowcave/verticalobservatory_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/verticalobservatory2.png",
		visual_file		= "data/biome_impl/snowcave/verticalobservatory2_visual.png",
		background_file	= "data/biome_impl/snowcave/verticalobservatory2_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icebridge2.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/pipe.png",
		visual_file		= "data/biome_impl/snowcave/pipe_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.25,
		material_file 	= "data/biome_impl/snowcave/receptacle_water.png",
		visual_file		= "",
		background_file	= "data/biome_impl/snowcave/receptacle_water_background.png",
		is_unique		= 0
	},
}

g_pixel_scene_01_alt =
{
	total_prob = 0,
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/verticalobservatory_alt.png",
		visual_file		= "data/biome_impl/snowcave/verticalobservatory_visual.png",
		background_file	= "data/biome_impl/snowcave/verticalobservatory_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/verticalobservatory2_alt.png",
		visual_file		= "data/biome_impl/snowcave/verticalobservatory2_visual.png",
		background_file	= "data/biome_impl/snowcave/verticalobservatory2_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icebridge2_alt.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/pipe_alt.png",
		visual_file		= "data/biome_impl/snowcave/pipe_visual.png",
		background_file	= "",
		is_unique		= 0
	},
}

g_pixel_scene_02 =
{
	total_prob = 0,
	{
		prob   			= 0.4,
		material_file 	= "data/biome_impl/snowcave/crater.png",
		visual_file		= "data/biome_impl/snowcave/crater_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/horizontalobservatory.png",
		visual_file		= "data/biome_impl/snowcave/horizontalobservatory_visual.png",
		background_file	= "data/biome_impl/snowcave/horizontalobservatory_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/horizontalobservatory2.png",
		visual_file		= "data/biome_impl/snowcave/horizontalobservatory2_visual.png",
		background_file	= "data/biome_impl/snowcave/horizontalobservatory2_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.3,
		material_file 	= "data/biome_impl/snowcave/horizontalobservatory3.png",
		visual_file		= "data/biome_impl/snowcave/horizontalobservatory3_visual.png",
		background_file	= "data/biome_impl/snowcave/horizontalobservatory3_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.4,
		material_file 	= "data/biome_impl/snowcave/icebridge.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.4,
		material_file 	= "data/biome_impl/snowcave/snowcastle.png",
		visual_file		= "data/biome_impl/snowcave/snowcastle_visual.png",
		background_file	= "data/biome_impl/snowcave/snowcastle_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0,
		material_file 	= "data/biome_impl/snowcave/symbolroom.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icepillar.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.5,
		material_file 	= "data/biome_impl/snowcave/shop.png",
		visual_file		= "data/biome_impl/snowcave/shop_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/camp.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
}

g_pixel_scene_03 =
{
	total_prob = 0,
	{
		prob   			= 0.9,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/tinyobservatory.png",
		visual_file		= "data/biome_impl/snowcave/tinyobservatory_visual.png",
		background_file	= "data/biome_impl/snowcave/tinyobservatory_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/tinyobservatory2.png",
		visual_file		= "data/biome_impl/snowcave/tinyobservatory2_visual.png",
		background_file	= "data/biome_impl/snowcave/tinyobservatory2_background.png",
		is_unique		= 0
	},
	{
		prob   			= 0.2,
		material_file 	= "data/biome_impl/snowcave/buried_eye.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
}

g_acidtank_right =
{
	total_prob = 0,
	{
		prob   			= 1.7,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.2,
		material_file 	= "data/biome_impl/acidtank_2.png",
		visual_file		= "data/biome_impl/acidtank_2_visual.png",
		background_file	= "data/biome_impl/acidtank_2_background.png",
		is_unique		= 0
	},
}

g_acidtank_left =
{
	total_prob = 0,
	{
		prob   			= 1.7,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.2,
		material_file 	= "data/biome_impl/acidtank.png",
		visual_file		= "data/biome_impl/acidtank_visual.png",
		background_file	= "data/biome_impl/acidtank_background.png",
		is_unique		= 0
	},
}

g_pixel_scene_04 =
{
	total_prob = 0,
	{
		prob   			= 0.5,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icicles.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icicles2.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icicles3.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/snowcave/icicles4.png",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
}

g_puzzle_capsule =
{
	total_prob = 0,
	{
		prob   			= 9.0,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/snowcave/puzzle_capsule.png",
		visual_file		= "data/biome_impl/snowcave/puzzle_capsule_visual.png",
		background_file	= "data/biome_impl/snowcave/puzzle_capsule_background.png",
		is_unique		= 0
	},
}

g_puzzle_capsule_b =
{
	total_prob = 0,
	{
		prob   			= 9.0,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/snowcave/puzzle_capsule_b.png",
		visual_file		= "data/biome_impl/snowcave/puzzle_capsule_b_visual.png",
		background_file	= "data/biome_impl/snowcave/puzzle_capsule_b_background.png",
		is_unique		= 0
	},
}

g_lamp =
{
	total_prob = 0,
	-- add skullflys after this step
	{
		prob   		= 0.4,
		min_count	= 1,
		max_count	= 1,    
		entity 	= ""
	},
	{
		prob   		= 0.7,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/props/physics_lantern_small.xml"
	},
}

g_props =
{
	total_prob = 0,
	{
		prob   		= 0.15,
		min_count	= 0,
		max_count	= 0,
		offset_y 	= 0,    
		entity 	= ""
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_box_explosive.xml"
	},
	{
		prob   		= 0.2,
		min_count	= 1,
		max_count	= 1,
		offset_y 	= 0,    
		entity 	= "data/entities/props/physics_propane_tank.xml"
	},
	{
		prob   		= 0.3,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_barrel_oil.xml"
	},
	{
		prob   		= 0.05,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_trap_electricity_enabled.xml"
	},
	
}

g_skulls =
{
	total_prob = 0,
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_skull_01.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_skull_02.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_skull_03.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_01.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_02.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_03.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_04.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_05.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_bone_06.xml"
	},
}

g_stones =
{
	total_prob = 0,
	{
		prob   		= 2,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/stonepile.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_stone_01.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_stone_02.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_stone_03.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= "data/entities/props/physics_stone_04.xml"
	},
	{
		prob   		= 4,
		min_count	= 1,
		max_count	= 1,    
		offset_y 	= 0,
		entity 	= ""
	},
}

g_ghostlamp =
{
	total_prob = 0,
	-- add skullflys after this step
	{
		prob   		= 1.0,
		min_count	= 1,
		max_count	= 1,    
		offset_y	= 10,
		entity 	= "data/entities/props/physics_chain_torch_ghostly.xml"
	},
}

g_candles =
{
	total_prob = 0,
	{
		prob   		= 0.33,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_candle_1.xml"
	},
	{
		prob   		= 0.33,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_candle_2.xml"
	},
	{
		prob   		= 0.33,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_candle_3.xml"
	},
}

g_vines =
{
	total_prob = 0,
	{
		prob   		= 0.4,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/verlet_chains/cords/verlet_cord.xml"
	},
	{
		prob   		= 0.3,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/verlet_chains/cords/verlet_cord_long.xml"
	},
	{
		prob   		= 1.5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= ""
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/verlet_chains/cords/verlet_cord_short.xml"
	},
	{
		prob   		= 0.5,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/verlet_chains/cords/verlet_cord_shorter.xml"
	},
}

g_fish =
{
	total_prob = 0,
	-- add skullflys after this step
	{
		prob   		= 1.0,
		min_count	= 3,
		max_count	= 4,    
		entity 	= "data/entities/animals/fish_large.xml"
	},
	{
		prob   		= 5.0,
		min_count	= 1,
		max_count	= 1,    
		entity 	= ""
	},
}

function safe( x, y )
	local result = true
	
	if ( x >= 125 ) and ( x <= 249 ) and ( y >= 3070 ) and ( y <= 3187 ) then
		result = false
	end
	
	return result
end

-- actual functions that get called from the wang generator

function init(x, y, w, h)
	-- figure out positions for 8 statues within the biome
	-- and spawn them if a position is within the bounds of this function call
	-- NOTE: only 3 statues need to be destroyed to complete sequence
	for i=1,8 do
		local biome_x_min = -2350
		local biome_x_max = 2350
		local biome_y_min = 3140
		local biome_y_max = 4500

		local pos_x = ProceduralRandomi(109,i*53,biome_x_min,biome_x_max)
		local pos_y = ProceduralRandomi(111,i*2.9,biome_y_min,biome_y_max)

		if pos_x >= x and pos_x <= x+w
		and pos_y >= y and pos_y <= y+h then
			-- spawn
			--print("spawned statue " .. i .. " at " .. pos_x .. ", " .. pos_y)
			LoadPixelScene( "data/biome_impl/snowcave/statue_hand.png", "", pos_x-22, pos_y-22, "", true )
		end	
	end
end

function spawn_small_enemies(x, y)
	local spawn_points = EntityGetInRadiusWithTag( x, y, 150, "spawn_point" )
	local distance = math.sqrt(x*x + y*y)
	if(distance < 600 and #spawn_points == 0)then
		EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
	end
end

function spawn_big_enemies(x, y)
	local spawn_points = EntityGetInRadiusWithTag( x, y, 150, "spawn_point" )
	local distance = math.sqrt(x*x + y*y)
	if(distance < 600 and #spawn_points == 0)then
		EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
	end
end

function spawn_unique_enemy(x, y)

end

function spawn_unique_enemy2(x, y)

end

function spawn_scavenger_party(x,y)

end

function spawn_items(x, y)
	local r = ProceduralRandom( x-11.631, y+10.2257 )
	
	if (r < 0.45) then
		LoadPixelScene( "data/biome_impl/wand_altar.png", "data/biome_impl/wand_altar_visual.png", x-15, y-17, "", true )
	end
end

function spawn_lamp(x, y)
	if safe( x, y ) then
		spawn(g_lamp,x+5,y+10,0,0)
	end
end

function spawn_props(x, y)
	if safe( x, y ) then
		local r = ProceduralRandom( x-11.231, y+10.2157 )
		
		if (r < 0.9) then
			spawn(g_props,x,y-3,0,0)
		else
			LoadPixelScene( "data/biome_impl/snowperson.png", "data/biome_impl/snowperson_visual.png", x-12, y-38, "", true )
		end
	end
end

function spawn_skulls(x, y)
	spawn(g_skulls,x,y,0,0)
end

function spawn_stones(x, y)
	spawn(g_stones,x,y,0,0)
end

function load_pixel_scene( x, y )
	load_random_pixel_scene( g_pixel_scene_01, x, y )
end

function load_pixel_scene_alt( x, y )
	load_random_pixel_scene( g_pixel_scene_01_alt, x, y )
end

function load_pixel_scene2( x, y )
	load_random_pixel_scene( g_pixel_scene_02, x, y )
end

function load_pixel_scene3( x, y )
	load_random_pixel_scene( g_pixel_scene_03, x, y )
end

function load_pixel_scene4( x, y )
	load_random_pixel_scene( g_pixel_scene_04, x, y )
end

function load_puzzle_capsule( x, y )
	--print("puzzle capsule spawned at " .. x .. ", " .. y)
	load_random_pixel_scene( g_puzzle_capsule, x, y )
end

function load_puzzle_capsule_b( x, y )
	--print("puzzle capsule spawned at " .. x .. ", " .. y)
	load_random_pixel_scene( g_puzzle_capsule_b, x-50, y-230 )
end

function spawn_altar_torch(x, y)
	EntityLoad( "data/entities/props/altar_torch.xml", x-7, y-36 )
end

function spawn_acid(x, y)
	if safe( x, y ) then
		EntityLoad( "data/entities/props/dripping_acid_gas.xml", x, y )
	end
end

function load_altar( x, y )
	LoadPixelScene( "data/biome_impl/altar.png", "data/biome_impl/altar_visual.png", x-92, y-96, "", true )
	EntityLoad( "data/entities/buildings/altar.xml", x, y-32 )
end

function load_acidtank_right( x, y )
	if safe( x, y ) then
		load_random_pixel_scene( g_acidtank_right, x-12, y-12 )
	end
end

function load_acidtank_left( x, y )
	if safe( x, y ) then
		load_random_pixel_scene( g_acidtank_left, x-252, y-12 )
	end
end

function spawn_shopitem( x, y )
	generate_shop_item( x, y, false, 3 )
end

function spawn_vines(x, y)
	spawn(g_vines,x+5,y+5)
end

function spawn_electricity_trap(x, y)
	EntityLoad("data/entities/props/physics_trap_electricity_enabled.xml", x, y)
end

function spawn_burning_barrel(x, y)
	if safe( x, y ) then
		EntityLoad( "data/entities/props/physics_barrel_burning.xml", x, y )
	end
end

function spawn_fish(x, y)
	spawn(g_fish,x,y)
end

function spawn_buried_eye_teleporter(x, y)
	EntityLoad("data/entities/buildings/teleport_snowcave_buried_eye.xml", x, y)
end

function spawn_statue_hand(x, y)
	EntityLoad("data/entities/buildings/statue_hand_1.xml", x, y)
end

function spawn_receptacle( x, y )
	EntityLoad( "data/entities/buildings/receptacle_water.xml", x, y )
end
