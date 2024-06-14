local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

local reapply_fix_list = {
    EXTRA_PERK = true,
    PERKS_LOTTERY = true,
    EXTRA_SHOP_ITEM = true,
    HEARTS_MORE_EXTRA_HP = true,
}

local remove_list = {
    PEACE_WITH_GODS = true,
    ATTRACT_ITEMS = true,
    --ABILITY_ACTIONS_MATERIALIZED = true, -- works now
    NO_WAND_EDITING = true,
    --MEGA_BEAM_STONE = true,
    GOLD_IS_FOREVER = true,
    EXPLODING_GOLD = true,
	EXTRA_MONEY_TRICK_KILL = true,
    TRICK_BLOOD_MONEY = true,
    EXPLODING_CORPSES = true,
    INVISIBILITY = true,
    GLOBAL_GORE = true,
    REMOVE_FOG_OF_WAR = true,
    --VAMPIRISM = true,
    WORM_ATTRACTOR = true,
    RADAR_ENEMY = true,
    FOOD_CLOCK = true,
    IRON_STOMACH = true,
    WAND_RADAR = true,
    ITEM_RADAR = true,
    MOON_RADAR = true,
    MAP = true,
    REVENGE_RATS = true,
    --ATTACK_FOOT = true, -- fixed
    --LEGGY_FEET = true, -- fixed
    PLAGUE_RATS = true,  
    VOMIT_RATS = true,
    MOLD = true,
    WORM_SMALLER_HOLES = true,
    HOMUNCULUS = true,
    --LUKKI_MINION = true,
    GENOME_MORE_HATRED = true,
    GENOME_MORE_LOVE = true,
    --ANGRY_GHOST = true,
    --HUNGRY_GHOST = true,
    DEATH_GHOST = true,
}

local allow_on_clients = {
    PERSONAL_LASER = true,
    HOVER_BOOST = true,
    FASTER_LEVITATION = true,
    STRONG_KICK = true,
    TELEKINESIS = true,
    EXTRA_HP = false,
    CORDYCEPS = true,
    RISKY_CRITICAL = true,
    FUNGAL_DISEASE = true,
    PROJECTILE_REPULSION_SECTOR = true,
    PROJECTILE_EATER_SECTOR = true,
    LOW_RECOIL = true,
    NO_MORE_KNOCKBACK = true,
    MANA_FROM_KILLS = true,
    ANGRY_LEVITATION = true,
    LASER_AIM = true,
	LEGGY_FEET = true,
	ATTACK_FOOT = true,
	LUKKI_MINION = true,
}   

local skip_function_list = {
    GAMBLE = true,
}

local rewrites = {
	ADVENTURER = {
		-- shooting unedited wands gives back HP
		id = "ADVENTURER",
		ui_name = "$perk_adventurer",
		ui_description = "$perkdesc_adventurer",
		ui_icon = "data/ui_gfx/perk_icons/adventurer.png",
		perk_icon = "data/items_gfx/perks/adventurer.png",
		stackable = STACKABLE_NO,
		func = function( entity_perk_item, entity_who_picked, item_name )
			print("Adventurer perk picked")
			EntityAddComponent2( entity_who_picked, "LuaComponent", 
			{
				_tags = "perk_component",
				script_source_file = "data/scripts/perks/adventurer.lua",
				execute_every_n_frame = 1,
				execute_on_added = true,
				call_init_function = true,
			} )
			
		end,
	},
	-- Fixed issue where health was reset on load
	GLASS_CANNON = {
		id = "GLASS_CANNON",
		ui_name = "$perk_glass_cannon",
		ui_description = "$arena_perk_glass_cannon_alt",
		ui_icon = "data/ui_gfx/perk_icons/glass_cannon.png",
		perk_icon = "data/items_gfx/perks/glass_cannon.png",
		game_effect = "DAMAGE_MULTIPLIER",
		stackable = STACKABLE_YES,
		stackable_is_rare = true,
		stackable_maximum = 2,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
		skip_functions_on_load = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local damagemodels = EntityGetComponent( entity_who_picked, "DamageModelComponent" )
			if( damagemodels ~= nil ) then
				for i,damagemodel in ipairs(damagemodels) do
					local hp = tonumber( ComponentGetValue( damagemodel, "hp" ) )
					local max_hp = 50 / 25
					
					--ComponentSetValue( damagemodel, "hp", math.min( hp, max_hp ) )
					ComponentSetValue( damagemodel, "max_hp", max_hp )
					ComponentSetValue( damagemodel, "max_hp_cap", max_hp )
					ComponentSetValue( damagemodel, "hp", max_hp )
				end
			end
		end,
	},
	-- Fixed issue where vampirism health is reapplied on load
	VAMPIRISM = {
		id = "VAMPIRISM",
		ui_name = "$perk_vampirism",
		ui_description = "$perkdesc_vampirism",
		ui_icon = "data/ui_gfx/perk_icons/vampirism.png",
		perk_icon = "data/items_gfx/perks/vampirism.png",
		game_effect = "HEALING_BLOOD",
		game_effect2 = "PROTECTION_FOOD_POISONING",
		stackable = STACKABLE_NO,
		skip_functions_on_load = true,
		func = function( entity_perk_item, entity_who_picked, item_name )

			local damagemodels = EntityGetComponent( entity_who_picked, "DamageModelComponent" )
			if( damagemodels ~= nil ) then
				for i,damagemodel in ipairs(damagemodels) do
					local hp = tonumber( ComponentGetValue( damagemodel, "hp" ) )
					local max_hp = tonumber( ComponentGetValue( damagemodel, "max_hp" ) ) * 0.75

					max_hp = math.ceil( max_hp * 25 ) / 25
					
					ComponentSetValue( damagemodel, "hp", math.min( hp, max_hp ) )
					ComponentSetValue( damagemodel, "max_hp", max_hp )
				end
			end
		end,
	},
	UNLIMITED_SPELLS = {
		id = "UNLIMITED_SPELLS",
		ui_name = "$perk_unlimited_spells",
		ui_description = "$perkdesc_unlimited_spells",
		ui_icon = "data/ui_gfx/perk_icons/unlimited_spells.png",
		perk_icon = "data/items_gfx/perks/unlimited_spells.png",
		stackable = false,
        func = function( entity_perk_item, entity_who_picked, item_name )
            GameAddFlagRun( "arena_unlimited_spells" )
        end,
	},
	LUKKI_MINION = {
		id = "LUKKI_MINION",
		ui_name = "$perk_lukki_minion",
		ui_description = "$perkdesc_lukki_minion",
		ui_icon = "data/ui_gfx/perk_icons/lukki_minion.png",
		perk_icon = "data/items_gfx/perks/lukki_minion.png",
		stackable = false,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "mods/evaisa.arena/files/entities/perks/lukki_minion.xml", x, y )
			EntityAddTag( child_id, "perk_entity" )
			
			EntityAddComponent( child_id, "VariableStorageComponent", 
			{
				name = "owner_id",
				value_int = tostring( entity_who_picked ),
			} )

		end,
		func_remove = function( entity_who_picked )
		end,
	},
	MEGA_BEAM_STONE = {
		id = "MEGA_BEAM_STONE",
		ui_name = "$arena_perk_mega_beam_stone",
		ui_description = "$perkdesc_mega_beam_stone",
		ui_icon = "data/ui_gfx/perk_icons/mega_beam_stone.png",
		perk_icon = "data/items_gfx/perks/mega_beam_stone.png",
		stackable = STACKABLE_YES,
		usable_by_enemies = false,
		run_on_clients = false,
		func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
			local entities = GameGetAllInventoryItems( entity_who_picked ) or {}
			local count = 0

			pickup_count = pickup_count or 1

			for _,entity in ipairs(entities) do
				local name = EntityGetName( entity )
				-- check if name contains the word "beamstone"
				if string.find(name, "beamstone") then
					count = count + 1
				end
			end

			--print("beamstone count: "..tostring(count).."/"..tostring(pickup_count))

			if(count >= pickup_count)then
				return
			end

			--print("spawning beamstone")
			
			local x,y = EntityGetTransform( entity_who_picked )
			EntityHelper.NetworkRegister(EntityLoad( "mods/evaisa.arena/files/entities/perks/beamstone.xml", x, y-10 ), x, y, math.floor(GameGetFrameNum() + x * y % 10000000))
			
			EntityLoad( "data/entities/particles/poof_white_appear.xml", x, y-10 )
		end,
	},
	TELEPORTITIS = 	{
		id = "TELEPORTITIS",
		ui_name = "$perk_teleportitis",
		ui_description = "$perkdesc_teleportitis", -- TODO "and gain a shield for a short duration."
		ui_icon = "data/ui_gfx/perk_icons/teleportitis.png",
		perk_icon = "data/items_gfx/perks/teleportitis.png",
		stackable = STACKABLE_NO,
		usable_by_enemies = false,
		run_on_clients = false,
		func = function( entity_perk_item, entity_who_picked, item_name )
			GameAddFlagRun( "teleportitis" )
		end,
	},
    SHIELD = {
		id = "SHIELD",
		ui_name = "$perk_shield",
		ui_description = "$perkdesc_shield",
		ui_icon = "data/ui_gfx/perk_icons/shield.png",
		perk_icon = "data/items_gfx/perks/shield.png",
		stackable = STACKABLE_YES,
		stackable_how_often_reappears = 10,
		stackable_maximum = 5,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local x,y = EntityGetTransform( entity_who_picked )
			local name = EntityGetName( entity_who_picked )
			local child_id = EntityLoad( "data/entities/misc/perks/shield.xml", x, y )
			
			local shield_num = EntityHelper.GetVariable(entity_who_picked, "shield_count") or 0
			local shield_radius = 10 + shield_num * 2.5
			local charge_speed = math.max( 0.22 - shield_num * 0.05, 0.02 )
			shield_num = shield_num + 1

			EntityHelper.SetVariable(entity_who_picked, "shield_count", shield_num)
			
			local comps = EntityGetComponent( child_id, "EnergyShieldComponent" )
			if( comps ~= nil ) then
				for i,comp in ipairs( comps ) do
					ComponentSetValue2( comp, "radius", shield_radius )
					ComponentSetValue2( comp, "recharge_speed", charge_speed )
				end
			end
			
			comps = EntityGetComponent( child_id, "ParticleEmitterComponent" )
			if( comps ~= nil ) then
				for i,comp in ipairs( comps ) do
					local minradius,maxradius = ComponentGetValue2( comp, "area_circle_radius" )
					
					if ( minradius ~= nil ) and ( maxradius ~= nil ) then
						if ( minradius == 0 ) then
							ComponentSetValue2( comp, "area_circle_radius", 0, shield_radius )
						elseif ( minradius == 10 ) then
							ComponentSetValue2( comp, "area_circle_radius", shield_radius, shield_radius )
						end
					end
				end
			end
			
			EntityAddTag( child_id, "perk_entity" )
			EntityAddChild( entity_who_picked, child_id )
		end,
		func_enemy = function( entity_perk_item, entity_who_picked )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "data/entities/misc/perks/shield.xml", x, y )
			EntityAddChild( entity_who_picked, child_id )
		end,
	},
	ATTACK_FOOT = 	{
		id = "ATTACK_FOOT",
		ui_name = "$perk_attack_foot",
		ui_description = "$perkdesc_attack_foot",
		ui_icon = "data/ui_gfx/perk_icons/attack_foot.png",
		perk_icon = "data/items_gfx/perks/attack_foot.png",
		stackable = STACKABLE_YES,
		stackable_maximum = 3,
		max_in_perk_pool = 2,
		stackable_is_rare = true,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = 0
			local is_stacking = EntityHasTag( entity_who_picked, "attack_foot_climber")

			local limb_count = 4
			if is_stacking then limb_count = 2 end
			for i=1,limb_count do
				child_id = EntityLoad( "data/entities/misc/perks/attack_foot/limb_walker.xml", x, y )
				EntityAddTag( child_id, "perk_entity" )
				EntityAddChild( entity_who_picked, child_id )
			end
			
			child_id = EntityLoad( "mods/evaisa.arena/files/entities/perks/limb_attacker.xml", x, y )
			EntityAddTag( child_id, "perk_entity" )
			EntityAddChild( entity_who_picked, child_id )
			
			if not is_stacking then
				-- enable climbing
				child_id = EntityLoad( "data/entities/misc/perks/attack_foot/limb_climb.xml", x, y )
				EntityAddTag( child_id, "perk_entity" )
				EntityAddChild( entity_who_picked, child_id )
				EntityAddTag( entity_who_picked, "attack_foot_climber" )
			else
				-- add length to limbs
				for _,v in ipairs(EntityGetAllChildren(entity_who_picked)) do
					if EntityHasTag(v, "attack_foot_walker") then
						component_readwrite(EntityGetFirstComponent(v, "IKLimbComponent"), { length = 50 }, function(comp)
							comp.length = comp.length * 1.5
						end)
					end
				end
			end
			
			local platformingcomponents = EntityGetComponent( entity_who_picked, "CharacterPlatformingComponent" )
			if( platformingcomponents ~= nil ) then
				for i,component in ipairs(platformingcomponents) do
					local run_speed = tonumber( ComponentGetMetaCustom( component, "run_velocity" ) ) * 1.25
					local vel_x = math.abs( tonumber( ComponentGetMetaCustom( component, "velocity_max_x" ) ) ) * 1.25
					
					local vel_x_min = 0 - vel_x
					local vel_x_max = vel_x
					
					ComponentSetMetaCustom( component, "run_velocity", run_speed )
					ComponentSetMetaCustom( component, "velocity_min_x", vel_x_min )
					ComponentSetMetaCustom( component, "velocity_max_x", vel_x_max )
				end
			end
			
			--[[perk_pickup_event("LUKKI")
			
			if ( pickup_count <= 2 ) then
				add_lukkiness_level(entity_who_picked)
			end]]
		end,
		func_remove = function( entity_who_picked )
			local platformingcomponents = EntityGetComponent( entity_who_picked, "CharacterPlatformingComponent" )
			if( platformingcomponents ~= nil ) then
				for i,component in ipairs(platformingcomponents) do
					ComponentSetMetaCustom( component, "run_velocity", 154 )
					ComponentSetMetaCustom( component, "velocity_min_x", -57 )
					ComponentSetMetaCustom( component, "velocity_max_x", 57 )
					ComponentSetValue2( component, "pixel_gravity", 350 )
				end
			end
		end,
	},
	LEGGY_FEET = {
		id = "LEGGY_FEET",
		ui_name = "$perk_leggy_feet",
		ui_description = "$perkdesc_leggy_feet",
		ui_icon = "data/ui_gfx/perk_icons/leggy_feet.png",
		perk_icon = "data/items_gfx/perks/leggy_feet.png",
		stackable = STACKABLE_YES, -- Arvi: these variables don't really make sense for this perk but putting them in anyway
		stackable_is_rare = true,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = 0
			local is_stacking = EntityHasTag( entity_who_picked, "attack_foot_climber")
			local limb_count = 2
			if is_stacking then limb_count = 1 end
			
			for i=1,limb_count do
				child_id = EntityLoad( "data/entities/misc/perks/attack_leggy/leggy_limb_left.xml", x, y )
				EntityAddTag( child_id, "perk_entity" )
				EntityAddChild( entity_who_picked, child_id )
			end
			for i=1,limb_count do
				child_id = EntityLoad( "data/entities/misc/perks/attack_leggy/leggy_limb_right.xml", x, y )
				EntityAddTag( child_id, "perk_entity" )
				EntityAddChild( entity_who_picked, child_id )
			end
			
			child_id = EntityLoad( "mods/evaisa.arena/files/entities/perks/leggy_limb_attacker.xml", x, y )
			EntityAddTag( child_id, "perk_entity" )
			EntityAddChild( entity_who_picked, child_id )

			if not is_stacking then
				child_id = EntityLoad( "data/entities/misc/perks/attack_foot/limb_climb.xml", x, y )
				EntityAddTag( child_id, "perk_entity" )
				EntityAddChild( entity_who_picked, child_id )
				EntityAddTag( entity_who_picked, "attack_foot_climber" )
			else
				-- add length to limbs
				for _,v in ipairs(EntityGetAllChildren(entity_who_picked)) do
					if EntityHasTag(v, "leggy_foot_walker") then
						component_readwrite(EntityGetFirstComponent(v, "IKLimbComponent"), { length = 50 }, function(comp)
							comp.length = comp.length * 1.5
						end)
					end
				end
			end
			
			local platformingcomponents = EntityGetComponent( entity_who_picked, "CharacterPlatformingComponent" )
			if( platformingcomponents ~= nil ) then
				for i,component in ipairs(platformingcomponents) do
					local run_speed = tonumber( ComponentGetMetaCustom( component, "run_velocity" ) ) * 1.25
					local vel_x = math.abs( tonumber( ComponentGetMetaCustom( component, "velocity_max_x" ) ) ) * 1.25
					
					local vel_x_min = 0 - vel_x
					local vel_x_max = vel_x
					
					ComponentSetMetaCustom( component, "run_velocity", run_speed )
					ComponentSetMetaCustom( component, "velocity_min_x", vel_x_min )
					ComponentSetMetaCustom( component, "velocity_max_x", vel_x_max )
				end
			end
			
		end,
		func_remove = function( entity_who_picked )
			local platformingcomponents = EntityGetComponent( entity_who_picked, "CharacterPlatformingComponent" )
			if( platformingcomponents ~= nil ) then
				for i,component in ipairs(platformingcomponents) do
					ComponentSetMetaCustom( component, "run_velocity", 154 )
					ComponentSetMetaCustom( component, "velocity_min_x", -57 )
					ComponentSetMetaCustom( component, "velocity_max_x", 57 )
					-- NOTE apparently this isn't needed, since the LEGGY works differently from the LUKKI
					-- ComponentSetValue2( component, "pixel_gravity", 350 )
				end
			end
		end,
	},
    EXTRA_MONEY = {
		id = "EXTRA_MONEY",
		ui_name = "$perk_extra_money",
		ui_description = "$arena_perk_extra_money_description",
		ui_icon = "data/ui_gfx/perk_icons/extra_money.png",
		perk_icon = "data/items_gfx/perks/extra_money.png",
		stackable = true,
        skip_functions_on_load = true,
        game_effect = "EXTRA_MONEY",
        func = function( entity_perk_item, entity_who_picked, item_name )
            local extra_gold_count = tonumber( GlobalsGetValue( "EXTRA_MONEY_COUNT", "0" ) )
            extra_gold_count = extra_gold_count + 1
            GlobalsSetValue( "EXTRA_MONEY_COUNT", tostring( extra_gold_count ) )
        end
	},
    SAVING_GRACE = {
		id = "SAVING_GRACE",
		ui_name = "$perk_saving_grace",
		ui_description = "$perkdesc_saving_grace",
		ui_icon = "data/ui_gfx/perk_icons/saving_grace.png",
		perk_icon = "data/items_gfx/perks/saving_grace.png",
		stackable = STACKABLE_NO,
		func = function( entity_perk_item, entity_who_picked, item_name )
			GameAddFlagRun( "saving_grace" )
		end,
	},
    LEVITATION_TRAIL = {
		id = "LEVITATION_TRAIL",
		ui_name = "$perk_levitation_trail",
		ui_description = "$perkdesc_levitation_trail",
		ui_icon = "data/ui_gfx/perk_icons/levitation_trail.png",
		perk_icon = "data/items_gfx/perks/levitation_trail.png",
		stackable = STACKABLE_YES,
		stackable_is_rare = true,
		max_in_perk_pool = 2,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			EntityAddComponent( entity_who_picked, "LuaComponent", 
			{
				_tags="perk_component",
				script_source_file="mods/evaisa.arena/files/scripts/misc/levitation_trail.lua",
				execute_every_n_frame="3"
			} )
		end,
	},
    RESPAWN = {
		id = "RESPAWN",
		ui_name = "$perk_respawn",
		ui_description = "$perkdesc_respawn",
		ui_icon = "data/ui_gfx/perk_icons/respawn.png",
		perk_icon = "data/items_gfx/perks/respawn.png",
        --game_effect = "RESPAWN",
        skip_functions_on_load = true,
		stackable = STACKABLE_YES,
		stackable_is_rare = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
            local respawn_count = tonumber( GlobalsGetValue( "RESPAWN_COUNT", "0" ) )
            respawn_count = respawn_count + 1

			GamePrint("Respawn count set to "..tostring(respawn_count)..".")
			print("Respawn count set to "..tostring(respawn_count)..".")

            GlobalsSetValue( "RESPAWN_COUNT", tostring( respawn_count ) )
		end,
	},
	CONTACT_DAMAGE = {
		id = "CONTACT_DAMAGE",
		ui_name = "$perk_contact_damage",
		ui_description = "$perkdesc_contact_damage",
		ui_icon = "data/ui_gfx/perk_icons/contact_damage.png",
		perk_icon = "data/items_gfx/perks/contact_damage.png",
		stackable = STACKABLE_NO,
		usable_by_enemies = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "mods/evaisa.arena/files/entities/perks/contact_damage.xml", x, y )
			EntityAddTag( child_id, "perk_entity" )
			EntityAddChild( entity_who_picked, child_id )
		end,
		func_enemy = function( entity_perk_item, entity_who_picked )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "mods/evaisa.arena/files/entities/perks/contact_damage.xml", x, y )
			EntityAddChild( entity_who_picked, child_id )
		end,
		--[[func_client = function( entity_perk_item, entity_who_picked, item_name, amount )
			local x,y = EntityGetTransform( entity_who_picked )
			local child_id = EntityLoad( "data/entities/misc/perks/contact_damage_enemy.xml", x, y )
			EntityAddChild( entity_who_picked, child_id )
		end,]]
	},
	ALWAYS_CAST = {
		id = "ALWAYS_CAST",
		ui_name = "$perk_always_cast",
		ui_description = "$perkdesc_always_cast",
		ui_icon = "data/ui_gfx/perk_icons/always_cast.png",
		perk_icon = "data/items_gfx/perks/always_cast.png",
		stackable = STACKABLE_YES,
		one_off_effect = true,
		func = function( entity_perk_item, entity_who_picked, item_name )
			local x,y = EntityGetTransform( entity_perk_item )
			local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0

			local seed_x, seed_y = get_new_seed( x + rounds, y + rounds, GameHasFlagRun("perk_sync") )
			SetRandomSeed( seed_x, seed_y )
			
			dofile("mods/evaisa.arena/files/scripts/misc/random_action.lua")

			

			GetRandomActionWithType = function( x, y, level, type, i)
				--print("Custom get action called!")
				return RandomActionWithType( level, type ) or "LIGHT_BULLET"
			end

			local good_cards = {}
			local good_cards_init = { "DAMAGE", "CRITICAL_HIT", "HOMING", "SPEED", "ACID_TRAIL", "SINEWAVE" }
			
			for k, v in ipairs(good_cards_init)do
				if(not GameHasFlagRun("spell_blacklist_"..v))then
					table.insert(good_cards, v)
				end
			end

			-- "FREEZE", "MATTER_EATER", "ELECTRIC_CHARGE"
			local x, y = EntityGetTransform( entity_perk_item )
			SetRandomSeed( x, y )
			
			local r = Random( 1, 100 )
			local level = 6

			local card = good_cards[ Random( 1, #good_cards ) ] or RandomAction(level)

			if( r <= 50 ) then
				local p = Random(1,100)

				if( p <= 86 ) then
					card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_MODIFIER, 666 )
				elseif( p <= 93 ) then
					card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_STATIC_PROJECTILE, 666 )
				elseif ( p < 100 ) then
					card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_PROJECTILE, 666 )
				else
					card = GetRandomActionWithType( x + Random(-1000, 1000), y + Random(-1000, 1000), level, ACTION_TYPE_UTILITY, 666 )
				end
			end

			local wand = find_the_wand_held( entity_who_picked )
			
			if ( wand ~= NULL_ENTITY ) then
				local comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
				
				if ( comp ~= nil ) then
					local deck_capacity = ComponentObjectGetValue( comp, "gun_config", "deck_capacity" )
					local deck_capacity2 = EntityGetWandCapacity( wand )
					
					local always_casts = deck_capacity - deck_capacity2
					
					if ( always_casts < 4 ) then
						AddGunActionPermanent( wand, card )
					else
						GamePrintImportant( "$log_always_cast_failed", "$logdesc_always_cast_failed" )
					end
				end
			end
		end,
	}
}

-- loop backwards through perk_list so we can remove entries
for i=#perk_list,1,-1 do
    local perk = perk_list[i]
    if remove_list[perk.id] then
        table.remove(perk_list, i)
    else
        if rewrites[perk.id] then
            perk_list[i] = rewrites[perk.id]
        end
        
        if reapply_fix_list[perk.id] then
            perk_list[i].do_not_reapply = true
        end

        if allow_on_clients[perk.id] then
            perk_list[i].run_on_clients = true
        elseif allow_on_clients[perk.id] ~= nil and allow_on_clients[perk.id] == false then
            perk_list[i].run_on_clients = false
            perk_list[i].usable_by_enemies = false
        end

        if skip_function_list[perk.id] then
            perk_list[i].skip_functions_on_load = true
        end
    end
end