local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
item_spawnlist = {
	{
	  id = "potion",
	  ui_name = "$item_potion",
	  ui_description = "",
	  sprite = "data/ui_gfx/items/potion.png",
	  weight = 1,
	  load_entity = "data/entities/items/pickup/potion.xml",
	  offset_y = -2
	}, -- Potion
	{
	  id = "powder_stash",
	  ui_name = "$item_powder_stash_3",
	  ui_description = "$itemdesc_powder_stash_3",
	  sprite = "data/ui_gfx/items/material_pouch.png",
	  weight = 5,
	  load_entity = "data/entities/items/pickup/powder_stash.xml",
	  offset_y = -2
	}, -- Powder Stash
	{
	  id = "greed_die",
	  ui_name = "$item_die",
	  ui_description = "$itemdesc_die",
	  sprite = "data/ui_gfx/items/die.png",
	  weight = 1,
	  load_entity_func = function(data, x, y)
		local ox = data.offset_x or 0
		local oy = data.offset_y or 0
		if GameHasFlagRun("greed_curse") and (GameHasFlagRun("greed_curse_gone") == false) then
		  return EntityLoad("data/entities/items/pickup/physics_greed_die.xml", x + ox, y + oy)
		else
		  return EntityLoad("data/entities/items/pickup/physics_die.xml", x + ox, y + oy)
		end
	  end,
	  offset_y = -12,
	}, 
	{
	  id = "runestone_laser",
	  ui_name = "$item_runestone_laser",
	  ui_description = "$itemdesc_runestone",
	  sprite = "data/ui_gfx/items/runestone_laser.png", 
	  weight = 0.142,
	  load_entity = "data/entities/items/pickup/runestones/runestone_laser.xml",
	  offset_y = -10
	},
	{
		id = "runestone_fireball",
		ui_name = "$item_runestone_fireball",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_fireball.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_fireball.xml",
		offset_y = -10
	},
	{
		id = "runestone_lava",
		ui_name = "$item_runestone_lava",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_lava.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_lava.xml",
		offset_y = -10
	},
	{
		id = "runestone_slow",
		ui_name = "$item_runestone_slow",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_slow.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_slow.xml",
		offset_y = -10
	},
	{
		id = "runestone_null",
		ui_name = "$item_runestone_null",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_null.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_null.xml",
		offset_y = -10
	},
	{
		id = "runestone_disc",
		ui_name = "$item_runestone_disc",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_disc.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_disc.xml",
		offset_y = -10
	},
	{
		id = "runestone_metal",
		ui_name = "$item_runestone_metal",
		ui_description = "$itemdesc_runestone",
		sprite = "data/ui_gfx/items/runestone_metal.png",
		weight = 0.142,
		load_entity = "data/entities/items/pickup/runestones/runestone_metal.xml",
		offset_y = -10
	},
	{
	  id = "egg_purple",
	  ui_name = "$item_egg_purple",
	  ui_description = "$item_description_egg_purple",
	  sprite = "data/ui_gfx/items/egg_purple.png",
	  weight = 1,
	  load_entity = "data/entities/items/pickup/egg_purple.xml",
	  offset_y = -2
	}, -- Purple Egg
	{
	  id = "egg_slime",
	  ui_name = "$item_egg_slime",
	  ui_description = "$item_description_egg_slime",
	  sprite = "data/ui_gfx/items/egg_slime.png",
	  weight = 4,
	  load_entity = "data/entities/items/pickup/egg_slime.xml",
	  offset_y = -2
	}, -- Slime Egg
	{
	  id = "egg_monster",
	  ui_name = "$item_egg",
	  ui_description = "$item_description_egg",
	  sprite = "data/ui_gfx/items/egg.png",
	  weight = 2,
	  load_entity = "data/entities/items/pickup/egg_monster.xml",
	  offset_y = -2
	}, -- Monster Egg
	{
	  id = "brimstone",
	  ui_name = "$item_brimstone",
	  ui_description = "$item_description_brimstone",
	  sprite = "data/ui_gfx/items/brimstone.png",
	  weight = 4,
	  load_entity = "data/entities/items/pickup/brimstone.xml",
	  offset_y = -2
	}, -- Brimstone
	{
	  id = "thunderstone",
	  ui_name = "$item_thunderstone",
	  ui_description = "$item_description_thunderstone",
	  sprite = "data/ui_gfx/items/thunderstone.png",
	  weight = 2,
	  load_entity = "data/entities/items/pickup/thunderstone.xml",
	  offset_y = -2
	}, -- Thunderstone
	{
	  id = "broken_wand",
	  ui_name = "$item_broken_wand",
	  ui_description = "$item_description_broken_wand",
	  sprite = "data/ui_gfx/items/broken_wand.png",
	  weight = 3,
	  load_entity = "data/entities/items/pickup/broken_wand.xml",
	  offset_y = -2
	}, -- Broken Wand
	{
	  id = "gold_orb",
	  ui_name = "$item_gold_orb",
	  ui_description = "$itemdesc_gold_orb",
	  sprite = "data/ui_gfx/items/orb_gold.png",
	  weight = 1,
	  load_entity_func = function(data, x, y)
		local ox = data.offset_x or 0
		local oy = data.offset_y or 0
		if GameHasFlagRun("greed_curse") and (GameHasFlagRun("greed_curse_gone") == false) then
		  return EntityLoad("data/entities/items/pickup/physics_gold_orb_greed.xml", x + ox, y + oy)
		else
		  return EntityLoad("data/entities/items/pickup/physics_gold_orb.xml", x + ox, y + oy)
		end
	  end,
	  offset_y = -2
	}, -- Gold Orb (potentially greed version)
	-- add 10 tablets
	{
        id = "book_1",
		ui_name = "$booktitle00",
		ui_description = "$bookdesc00",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_00.xml",
		offset_y = -5
    },
	{
		id = "book_2",
		ui_name = "$booktitle02",
		ui_description = "$bookdesc02",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_01.xml",
		offset_y = -5
	},
	{
		id = "book_3",
		ui_name = "$booktitle03",
		ui_description = "$bookdesc03",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_02.xml",
		offset_y = -5
	},
	{
		id = "book_4",
		ui_name = "$booktitle04",
		ui_description = "$bookdesc04",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_03.xml",
		offset_y = -5
	},
	{
		id = "book_5",
		ui_name = "$booktitle05",
		ui_description = "$bookdesc05",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_04.xml",
		offset_y = -5
	},
	{
		id = "book_6",
		ui_name = "$booktitle06",
		ui_description = "$bookdesc06",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_05.xml",
		offset_y = -5
	},
	{
		id = "book_7",
		ui_name = "$booktitle07",
		ui_description = "$bookdesc07",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_06.xml",
		offset_y = -5
	},
	{
		id = "book_8",
		ui_name = "$booktitle08",
		ui_description = "$bookdesc08",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_07.xml",
		offset_y = -5
	},
	{
		id = "book_9",
		ui_name = "$booktitle09",
		ui_description = "$bookdesc09",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_08.xml",
		offset_y = -5
	},
	{
		id = "book_10",
		ui_name = "$booktitle10",
		ui_description = "$bookdesc10",
		sprite = "data/ui_gfx/items/emerald_tablet.png",
		weight = 0.1,
		load_entity = "data/entities/items/books/book_09.xml",
		offset_y = -5
	}


}

dofile("mods/evaisa.arena/files/scripts/utilities/utils.lua")


dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")

function spawn_from_list( list, x, y, sync )
	local spawnlist

	local seed_x, seed_y = get_new_seed( x, y, sync )
	SetRandomSeed( seed_x, seed_y )

	if ( type( list ) == "string" ) then
		spawnlist = item_spawnlist
	elseif ( type( list ) == "table" ) then
		spawnlist = list
	end
	
	local data = random_from_weighted_table( spawnlist, function(item)
		return GameHasFlagRun("item_blacklist_"..item.id)
	end)

	local rnd = Random( 1, 100000 )

	local ox = data.offset_x or 0
	local oy = data.offset_y or 0

	if ( data.load_entity_func ~= nil ) then
		local item_entity = data.load_entity_func( data, x, y )
		EntityHelper.NetworkRegister(item_entity, x, y, math.floor(rnd + x + y + GameGetFrameNum()))
		return item_entity
	elseif ( data.load_entity_from_list ~= nil ) then
		
		local item_entity = spawn_from_list( data.load_entity_from_list, x, y, sync )
		EntityHelper.NetworkRegister(item_entity, x, y, math.floor(rnd + x + y + GameGetFrameNum()))
		return item_entity
	elseif ( data.load_entity ~= nil ) then
		
		local item_entity = EntityLoad( data.load_entity, x + ox, y + oy )
		EntityHelper.NetworkRegister(item_entity, x, y, math.floor(rnd + x + y + GameGetFrameNum()))
		return item_entity
	end
end