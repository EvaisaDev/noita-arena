dofile_once("data/scripts/lib/utilities.lua")
dofile( "data/scripts/gun/gun_actions.lua" )
dofile("mods/evaisa.arena/files/scripts/misc/random_action.lua")

function generate_shop_item( x, y, cheap_item, biomeid_, is_stealable )
	
	local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
	local seed_x, seed_y = (x * 3256) + rounds * 765 + (GameGetFrameNum() / 30), (y * 5326) + rounds * 123 + (GameGetFrameNum() / 20)
	if(GameHasFlagRun("shop_sync"))then
        seed_x, seed_y = (x * 3256) + rounds * 765, (y * 5326) + rounds * 123
	end
	SetRandomSeed( seed_x, seed_y )


	local biomes =
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 2,
		[8] = 2,
		[9] = 2,
		[10] = 2,
		[11] = 2,
		[12] = 2,
		[13] = 3,
		[14] = 3,
		[15] = 3,
		[16] = 3,
		[17] = 4,
		[18] = 4,
		[19] = 4,
		[20] = 4,
		[21] = 5,
		[22] = 5,
		[23] = 5,
		[24] = 5,
		[25] = 6,
		[26] = 6,
		[27] = 6,
		[28] = 6,
		[29] = 6,
		[30] = 6,
		[31] = 6,
		[32] = 6,
		[33] = 6,
	}
	
	if (biomeid_ ~= nil) then
		biomeid = biomeid_
	end

	if( is_stealable == nil ) then
		is_stealable = false
	end

	local item = ""
	local cardcost = 0

	-- Note( Petri ): Testing how much squaring the biomeid for prices affects things
	local level = biomeid

	
	if(level > 10)then
		level = 10
	end
	

	item = RandomAction(level, x, y)--GetRandomAction( x + math.random(-10000, 10000), y + math.random(-10000, 10000), level, 0 )

	if item == nil then
		return
	end

	biomeid = biomeid * biomeid

	cardcost = 0

	for i,thisitem in ipairs( actions ) do
		if ( string.lower( thisitem.id ) == string.lower( item ) ) then
			price = math.max(math.floor( ( (thisitem.price * 0.30) + (70 * biomeid) ) / 10 ) * 10, 10)
			cardcost = price
			
			if ( thisitem.spawn_requires_flag ~= nil ) then
				local flag = thisitem.spawn_requires_flag
				
				if ( HasFlagPersistent( flag ) == false ) then
					print( "Trying to spawn " .. tostring( thisitem.id ) .. " even though flag " .. tostring( flag ) .. " not set!!" )
				end
			end
		end
	end
	
	if( cheap_item ) then
		cardcost = 0.5 * cardcost
	end
	

	local eid = CreateItemActionEntity( item, x, y )

	if( cheap_item ) then
		EntityLoad( "data/entities/misc/sale_indicator.xml", x, y )
	end

	-- local x, y = EntityGetTransform( entity_id )
	-- SetRandomSeed( x, y )
	
	local offsetx = 6

	local shop_price_multiplier = tonumber(GlobalsGetValue("shop_price_multiplier", "1"))

	cardcost = math.floor( cardcost * shop_price_multiplier )

	local text = tostring(cardcost)
	local textwidth = 0
	
	for i=1,#text do
		local l = string.sub( text, i, i )
		
		if ( l ~= "1" ) then
			textwidth = textwidth + 6
		else
			textwidth = textwidth + 3
		end
	end
	


	offsetx = textwidth * 0.5 - 0.5
	if( GlobalsGetValue("no_shop_cost") == "false")then
			
		EntityAddComponent( eid, "SpriteComponent", { 
			_tags="shop_cost,enabled_in_world",
			image_file="data/fonts/font_pixel_white.xml", 
			is_text_sprite="1", 
			offset_x=tostring(offsetx), 
			offset_y="25", 
			update_transform="1" ,
			update_transform_rotation="0",
			text=tostring(cardcost),
			z_index="-1",
		} )	

		local stealable_value = "0"
		if( is_stealable ) then 
			stealable_value = "1"
		end
		

		EntityAddComponent( eid, "ItemCostComponent", { 
			_tags="shop_cost,enabled_in_world", 
			cost=cardcost,
			stealable="0"
		} )
	end
		
	EntityAddComponent( eid, "LuaComponent", { 
		script_item_picked_up="data/scripts/items/shop_effect.lua",
		} )
	-- shop_item_pickup2.lua

	-- display uses remaining, if any
	--  NOTE(Olli): removed this because it didn't work with low resolution rendering
	--[[edit_component( eid, "ItemComponent", function(comp,vars)
		local uses_remaining = tonumber( ComponentGetValue(comp, "uses_remaining" ) )
		if uses_remaining > -1 then
			EntityAddComponent( eid, "SpriteComponent", { 
				_tags="shop_cost,enabled_in_world",
				image_file="data/fonts/font_pixel_white.xml", 
				is_text_sprite="1", 
				offset_x="16", 
				offset_y="32", 
				has_special_scale="1",
				special_scale_x="0.5",
				special_scale_y="0.5",
				update_transform="1" ,
				update_transform_rotation="0",
				text=tostring(uses_remaining),
				} )
		end
	end)]]--
	return eid
end

------------ generate shop wand -----------------------------------------------

function generate_shop_wand( x, y, cheap_item, biomeid_ )
	local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
	local seed_x, seed_y = (x * 3256) + rounds * 765 + (GameGetFrameNum() / 30), (y * 5326) + rounds * 123 + (GameGetFrameNum() / 20)
	if(GameHasFlagRun("shop_sync"))then
        seed_x, seed_y = (x * 3256) + rounds * 765, (y * 5326) + rounds * 123
	end
	SetRandomSeed( seed_x, seed_y )

	local biomes =
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 1,
		[5] = 1,
		[6] = 1,
		[7] = 2,
		[8] = 2,
		[9] = 2,
		[10] = 2,
		[11] = 2,
		[12] = 2,
		[13] = 3,
		[14] = 3,
		[15] = 3,
		[16] = 3,
		[17] = 4,
		[18] = 4,
		[19] = 4,
		[20] = 4,
		[21] = 5,
		[22] = 5,
		[23] = 5,
		[24] = 5,
		[25] = 6,
		[26] = 6,
		[27] = 6,
		[28] = 6,
		[29] = 6,
		[30] = 6,
		[31] = 6,
		[32] = 6,
		[33] = 6,
	}


	local biomepixel = math.floor(y / 512)
	local biomeid = biomes[biomepixel] or 0
	
	if (biomes[biomepixel] == nil) then
		print("Unable to find biomeid for chunk at depth " .. tostring(biomepixel))
	end
	if (biomeid_ ~= nil) then
		biomeid = biomeid_
	end

	if(biomeid >= 10)then
		biomeid = 10
	else
		if( biomeid < 1 ) then biomeid = 1 end
		if( biomeid > 6 ) then biomeid = 6 end
	end

	local item = "data/entities/items/"

	local r = Random(0,100)
	if( r <= 50 ) then 
		if(biomeid < 10)then
			item = item .. "wand_level_0"
		else
			item = item .. "wand_level_"
		end
	else
		if(biomeid < 10)then
			item = item .. "wand_unshuffle_0"
		else
			item = item .. "wand_unshuffle_"
		end
	end

	item = item .. tostring(biomeid) .. ".xml"

	
	-- Note( Petri ): Testing how much squaring the biomeid for prices affects things
	biomeid = (0.5 * biomeid) + ( 0.5 * biomeid * biomeid )
	local wandcost = ( 50 + biomeid * 210 ) + ( Random( -15, 15 ) * 10 )

	if( cheap_item ) then
		wandcost = 0.5 * wandcost
	end

	if( cheap_item ) then
		EntityLoad( "data/entities/misc/sale_indicator.xml", x, y )
	end
	
	local offsetx = 6

	local shop_price_multiplier = tonumber(GlobalsGetValue("shop_price_multiplier", "1"))

	wandcost = math.floor( wandcost * shop_price_multiplier )

	local text = tostring(wandcost)
	local textwidth = 0
	
	for i=1,#text do
		local l = string.sub( text, i, i )
		
		if ( l ~= "1" ) then
			textwidth = textwidth + 6
		else
			textwidth = textwidth + 3
		end
	end


	
	offsetx = textwidth * 0.5 - 0.5

	-- local x, y = EntityGetTransform( entity_id )
	-- SetRandomSeed( x, y )
	local eid = EntityLoad( item, x, y)
	if( GlobalsGetValue("no_shop_cost") == "false")then
		EntityAddComponent( eid, "SpriteComponent", { 
			_tags="shop_cost,enabled_in_world",
			image_file="data/fonts/font_pixel_white.xml", 
			is_text_sprite="1", 
			offset_x=tostring(offsetx), 
			offset_y="25", 
			update_transform="1" ,
			update_transform_rotation="0",
			text=tostring(wandcost),
			z_index="-1"
		} )


		EntityAddComponent( eid, "ItemCostComponent", { 
			_tags="shop_cost,enabled_in_world", 
			cost=wandcost,
			stealable="0"
		} )
	end
		
	EntityAddComponent( eid, "LuaComponent", { 
		script_item_picked_up="data/scripts/items/shop_effect.lua"
		} )

	EntitySetTransform( eid, x, y )
	EntityApplyTransform( eid, x, y )

	return eid
end



function generate_shop_potion( x, y, biome_id )
	dofile("data/scripts/item_spawnlists.lua")

	local offsetx = 6

	local eid = spawn_from_list("potion_spawnlist", x, y)

	--if(eid == nil)then return end
	
	if(biome_id >= 10)then
		biome_id = 10
	else
		if( biome_id < 1 ) then biome_id = 1 end
		if( biome_id > 6 ) then biome_id = 6 end
	end

	local itemcost = math.max(math.floor( ( (Random(150, 400) * 0.30) + (70 * biome_id) ) / 10 ) * 10, 10)

	--itemcost = math.floor( itemcost * 0.7 )

	local shop_price_multiplier = tonumber(GlobalsGetValue("shop_price_multiplier", "1"))

	itemcost = math.floor( itemcost * shop_price_multiplier )

	

	local text = tostring(itemcost)
	local textwidth = 0
	
	for i=1,#text do
		local l = string.sub( text, i, i )
		
		if ( l ~= "1" ) then
			textwidth = textwidth + 6
		else
			textwidth = textwidth + 3
		end
	end

	offsetx = textwidth * 0.5 - 0.5

	if( GlobalsGetValue("no_shop_cost") == "false")then
		EntityAddComponent( eid, "SpriteComponent", { 
			_tags="shop_cost,enabled_in_world",
			image_file="data/fonts/font_pixel_white.xml", 
			is_text_sprite="1", 
			offset_x=tostring(offsetx), 
			offset_y="25", 
			update_transform="1" ,
			update_transform_rotation="0",
			text=tostring(itemcost),
			z_index="-1"
		} )


		EntityAddComponent( eid, "ItemCostComponent", { 
			_tags="shop_cost,enabled_in_world", 
			cost=itemcost,
			stealable="0"
		} )
	end
		
	EntityAddComponent( eid, "LuaComponent", { 
		script_item_picked_up="data/scripts/items/shop_effect.lua"
		} )

end