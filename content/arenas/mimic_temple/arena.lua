-- default biome functions that get called if we can't find a a specific biome that works for us
-- The level of action ids that are spawned from the chests
CHEST_LEVEL = 1
dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/biome_scripts.lua")

RegisterSpawnFunction( 0xff805000, "spawn_cloud_trap" )
RegisterSpawnFunction( 0xff397780, "load_floor_rubble" )
RegisterSpawnFunction( 0xff00ffa0, "load_floor_rubble_l" )
RegisterSpawnFunction( 0xff1ca7ff, "load_floor_rubble_r" )
-- RegisterSpawnFunction( 0xffffeed1, "spawn_puzzle_watchtower" )
-- RegisterSpawnFunction( 0xffffeeda, "spawn_puzzle_barren" )
RegisterSpawnFunction( 0xffffeedb, "spawn_puzzle_potion_mimics" )
-- RegisterSpawnFunction( 0xffffeedc, "spawn_puzzle_darkness" )

RegisterSpawnFunction( 0xffffeede, "spawn_potion_mimic_empty" )
RegisterSpawnFunction( 0xffffeedf, "spawn_potion_mimic" )
RegisterSpawnFunction( 0xffffeed0, "spawn_fish_many" )
RegisterSpawnFunction( 0xffffeed2, "spawn_boss_phase2_marker" )
RegisterSpawnFunction( 0xffffeed3, "spawn_book_barren" )
RegisterSpawnFunction( 0xffffeed4, "spawn_potion_beer" )
RegisterSpawnFunction( 0xffffeed5, "spawn_potion_milk" )
RegisterSpawnFunction( 0xffffeed6, "spawn_scorpion" )
RegisterSpawnFunction( 0xffffaaaa, "spawn_sign_left" )
RegisterSpawnFunction( 0xffffaadd, "spawn_sign_right" )
RegisterSpawnFunction( 0xffff54e3, "spawn_point" )

--------------------------------------------------

local BG_Z = 0

------------ small -------------------------------

g_lamp =
{
	total_prob = 0,
	{
		prob   		= 1.0,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/props/physics/chain_torch_ghostly.xml"
	},
}

g_ghostlamp =
{
	total_prob = 0,
	{
		prob   		= 1.0,
		min_count	= 1,
		max_count	= 1,    
		entity 	= "data/entities/props/physics/chain_torch_ghostly.xml"
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

g_props =
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
	{
		prob   		= 5.4,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_01.xml",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_02.xml",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_03.xml",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_04.xml",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_05.xml",
	},
	{
		prob   		= 0.6,
		min_count	= 1,
		max_count	= 1, 
		entity 	= "data/entities/props/physics_bone_06.xml",
	},
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
}

g_cloud_trap =
{
}

g_floor_rubble =
{
	total_prob = 0,
	{
		prob   			= 15.0,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_03.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_03_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.05,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_l_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_l_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.05,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_l_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_l_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.05,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_r_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_r_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.05,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_r_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_r_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
}

g_floor_rubble_l =
{
	total_prob = 0,
	{
		prob   			= 2.0,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_l_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_l_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_l_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_l_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_03.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_03_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
}

g_floor_rubble_r =
{
	total_prob = 0,
	{
		prob   			= 2.0,
		material_file 	= "",
		visual_file		= "",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_r_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_r_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_r_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_r_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
		{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 1.0,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_small_03.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_small_03_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_01.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_01_visual.png",
		background_file	= "",
		is_unique		= 0
	},
	{
		prob   			= 0.5,
		material_file 	= "data/biome_impl/wandcave/floor_rubble_dynamic_02.png",
		visual_file		= "data/biome_impl/wandcave/floor_rubble_dynamic_02_visual.png",
		background_file	= "",
		is_unique		= 0
	},
}

function spawn_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spawn_point.xml", x, y )
end

-- 

function spawn_ok( x, y )
	return x < 16000 and x > -16000
end

function spawn_items( pos_x, pos_y )
	local r = ProceduralRandom( pos_x, pos_y )
	-- 20% is air, nothing happens
	if( r < 0.47 ) then return end
	r = ProceduralRandom( pos_x-11.431, pos_y+10.5257 )
	
	if( r < 0.725 ) then
	else
		LoadPixelScene( "data/biome_impl/wand_altar.png", "data/biome_impl/wand_altar_visual.png", pos_x-10, pos_y-17, "", true )
		return
	end
end

-- actual functions that get called from the wang generator

function spawn_boss_phase2_marker(x, y)
	if not spawn_ok(x,y) then return end

	EntityLoad( "data/entities/animals/boss_sky/boss_sky_phase2_marker.xml", x+7, y )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/boss_phase2_bg.png", x+2, y-10, BG_Z )
end

function spawn_potion_mimic_empty(x, y)
	if not spawn_ok(x,y) then return end

	local entity = EntityLoad( "data/entities/animals/mimic_potion.xml", x, y )
	RemoveMaterialInventoryMaterial( entity )
	EntityAddTag( entity, "mimic_potion_sky" )

	local var = EntityGetFirstComponent( entity, "VariableStorageComponent", "potion_mimic_awoken" )
	if var ~= nil then
		ComponentSetValue2( var, "value_bool", false )
	end
end

function spawn_potion_mimic(x, y)
	if not spawn_ok(x,y) then return end

	EntityLoad( "data/entities/items/pickup/potion_mimic.xml", x, y )
end

function spawn_puzzle_watchtower(x, y)
	EntityLoad( "data/biome_impl/static_tile/watchtower_music_trigger.xml", x+40, y+20 )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/watchtower_hint_bg.png", x, y, BG_Z )
end

function spawn_puzzle_darkness(x, y)
	if not spawn_ok(x,y) then return end

	EntityLoad( "data/biome_impl/static_tile/puzzle_logic_darkness.xml", x, y )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/darkness_hint_bg.png", x-120, y-4, BG_Z )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/darkness_hint_bg_2.png", x-18, y+40, BG_Z )
end

function spawn_puzzle_potion_mimics(x, y)
	if not spawn_ok(x,y) then return end

	--EntityLoad( "data/biome_impl/static_tile/puzzle_logic_potion_mimics.xml", x, y )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/potion_mimics_hint_bg.png", x-22, y-22, BG_Z )
end

function spawn_puzzle_barren(x, y)
	if not spawn_ok(x,y) then return end

	EntityLoad( "data/biome_impl/static_tile/puzzle_logic_barren.xml", x, y )
	LoadBackgroundSprite( "data/biome_impl/static_tile/temples-assets/barren_hint_bg.png", x-15, y-30, BG_Z )
end

function spawn_sign_left(x, y)
	LoadPixelScene( "data/biome_impl/static_tile/temples-assets/sign_left.png", "data/biome_impl/static_tile/temples-assets/sign_left_visual.png", x-10, y-15, "", false, false, {}, 50 )
end					

function spawn_sign_right(x, y)
	LoadPixelScene( "data/biome_impl/static_tile/temples-assets/sign_right.png", "data/biome_impl/static_tile/temples-assets/sign_right_visual.png", x-10, y-15, "", false, false, {}, 50 )
end					

function spawn_fish_many(x, y)
	for i=1,10 do
		local yp = y + 80 + i*10
		local r = ProceduralRandom( x, y ) - 0.5
		EntityLoad( "data/entities/animals/fish.xml", x + r * 20, y + 80 + i*10 )
	end
end		

function spawn_book_barren(x, y)
	EntityLoad( "data/entities/items/books/book_barren.xml", x, y-5 )
end		

function spawn_potion_beer(x, y)
	EntityLoad( "data/entities/items/pickup/potion_beer.xml", x, y-5 )
end		

function spawn_potion_milk(x, y)
	EntityLoad( "data/entities/items/pickup/potion_milk.xml", x, y-5 )
end		

function spawn_scorpion(x, y)
	EntityLoad( "data/entities/animals/scorpion_watchtower.xml", x, y )
end		


function spawn_small_enemies(x, y) end

function spawn_big_enemies(x, y) end

function spawn_lamp(x, y)
	spawn(g_lamp,x,y,0,0)
end

function spawn_props(x, y)
	spawn(g_props,x,y-3,0,0)
end

function spawn_cloud_trap(x, y)
	spawn(g_cloud_trap,x-5,y-10)
end

function load_floor_rubble( x, y )
	load_random_pixel_scene( g_floor_rubble, x-10, y-15 )
end

function load_floor_rubble_l( x, y )
	load_random_pixel_scene( g_floor_rubble_l, x-10, y-15 )
end

function load_floor_rubble_r( x, y )
	load_random_pixel_scene( g_floor_rubble_r, x-18, y-17 )
end

function spawn_props2( x, y ) end
function spawn_props3( x, y ) end
function load_pixel_scene( x, y ) end
function load_pixel_scene2( x, y ) end
function spawn_unique_enemy( x, y ) end
function spawn_unique_enemy2( x, y ) end
function spawn_unique_enemy3( x, y ) end
function spawn_ghostlamp( x, y ) end
function spawn_candles( x, y ) end
function spawn_potions( x, y ) end
function spawn_wands( x, y ) end