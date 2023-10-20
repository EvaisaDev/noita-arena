dofile("mods/evaisa.arena/files/scripts/misc/random_action.lua")

local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")

local a, b, c, d, e, f = GameGetDateAndTimeLocal()

local random_seed = tonumber(GlobalsGetValue("unique_seed", tostring(GameGetFrameNum() + GameGetRealWorldTimeSinceStarted())))

local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
if(GameHasFlagRun("shop_sync"))then
	random_seed = ((tonumber(GlobalsGetValue("world_seed", "0")) or 1) * 214) * rounds
end


local random = rng.new(random_seed)
local index = 0

GetRandomActionWithType = function( x, y, level, type, i)
	local action = RandomActionWithType( level, type, x * 324 + i, y * 436 - (i * 45) ) or "LIGHT_BULLET"
	return action
end

local get_new_seed = function(x, y)
	local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
    local seed = tonumber(GlobalsGetValue("unique_seed", tostring(GameGetFrameNum() + GameGetRealWorldTimeSinceStarted())))
    if(GameHasFlagRun("shop_sync"))then
        seed = ((tonumber(GlobalsGetValue("world_seed", "0")) or 1) * 214) * rounds
    end
	if(x and y)then
		seed = seed + (x * 324) + (y * 436)
	end
    return seed
end

Random = function(a, b)
	if(a == nil and b == nil)then
		return random.next_float()
	elseif(b == nil)then
		return random.range(0, a)
	else
		return random.range(a, b)
	end
end

SetRandomSeed = function(x, y)
	--if(GameHasFlagRun("shop_sync"))then
		local seed = get_new_seed(x, y)
		if(seed ~= random_seed)then
			random = rng.new(seed)
			random_seed = seed
		end
	--end
end

local old_wand_add_random_cards = wand_add_random_cards
function wand_add_random_cards( gun, entity_id, level, cost )

	if(not GameHasFlagRun("shop_no_tiers"))then
		old_wand_add_random_cards( gun, entity_id, level)
		return
	end

	local is_rare = gun["is_rare"]
	local x, y = EntityGetTransform( entity_id )

	-- stuff in the gun
	local good_cards = 5
	if( Random(0,100) < 7 ) then good_cards = Random(20,50) end

	if( is_rare == 1 ) then
		good_cards = good_cards * 2
	end

	if( level == nil ) then level = 1 end
	level = tonumber( level )

	local orig_level = level
	level = level - 1
	local deck_capacity = gun["deck_capacity"]
	local actions_per_round = gun["actions_per_round"]
	local card_count = Random( 1, 3 ) 
	local bullet_card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_PROJECTILE, 0 )
	local card = ""
	local random_bullets = 0 
	local good_card_count = 0

	if( Random(0,100) < 50 and card_count < 3 ) then card_count = card_count + 1 end 
	
	if( Random(0,100) < 10 or is_rare == 1 ) then 
		card_count = card_count + Random( 1, 2 )
	end

	good_cards = Random( 5, 45 )
	card_count = Random( 0.51 * deck_capacity, deck_capacity )
	card_count = clamp( card_count, 1, deck_capacity-1 )

	-- card count is in between 1 and 6

	if( Random(0,100) < (orig_level*10)-5 ) then
		random_bullets = 1
	end

	if( Random( 0, 100 ) < 4 or is_rare == 1 ) then
		local p = Random(0,100) 
		if( p < 77 ) then
			card = GetRandomActionWithType( x, y + cost, level+1, ACTION_TYPE_MODIFIER, 666 )
		--[[
		Arvi (9.12.2020): DRAW_MANY cards were causing oddities as always casts, so testing a different set of always_cast cards
		elseif( p < 94 ) then
			card = GetRandomActionWithType( x, y, level+1, ACTION_TYPE_DRAW_MANY, 666 )
			good_card_count = good_card_count + 1
		]]--
		elseif ( p < 85 ) then
			card = GetRandomActionWithType( x, y + cost, level+1, ACTION_TYPE_MODIFIER, 666 )
			good_card_count = good_card_count + 1
		elseif ( p < 93 ) then
			card = GetRandomActionWithType( x, y + cost, level+1, ACTION_TYPE_STATIC_PROJECTILE, 666 )
		else 
			card = GetRandomActionWithType( x, y + cost, level+1, ACTION_TYPE_PROJECTILE, 666 )
		end
		AddGunActionPermanent( entity_id, card )
	end

	-- --------------- CARDS -------------------------
	-- TODO: tweak the % 
	if( Random( 0, 100 ) < 50 ) then

		-- more structured placement
		-- DRAW_MANY + MOD + BULLET

		-- local bullet_card = GetRandomActionWithType( x, y, level, ACTION_TYPE_PROJECTILE, 0 )
		local extra_level = level
		while( Random( 1, 10 ) == 10 ) do
			extra_level = extra_level + 1
			bullet_card = GetRandomActionWithType( x, y + cost, extra_level, ACTION_TYPE_PROJECTILE, 0 )
		end

		if( card_count < 3 ) then
			if( card_count > 1 and Random( 0, 100 ) < 20 ) then
				card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_MODIFIER, 2 )
				AddGunAction( entity_id, card )
				card_count = card_count - 1
			end

			for i=1,card_count do
				bullet_card = GetRandomActionWithType( x, y + cost, extra_level, ACTION_TYPE_PROJECTILE, i * 4124  )
				AddGunAction( entity_id, bullet_card )
			end
		else
			-- DRAW_MANY + MOD
			if( Random( 0, 100 ) < 40 ) then
				card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_DRAW_MANY, 1 )
				AddGunAction( entity_id, card )
				card_count = card_count - 1
			end

			-- add another DRAW_MANY
			if( card_count > 3 and Random( 0, 100 ) < 40 ) then
				card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_DRAW_MANY, 1 )
				AddGunAction( entity_id, card )
				card_count = card_count - 1
			end

			if( Random( 0, 100 ) < 80 ) then
				card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_MODIFIER, 2 )
				AddGunAction( entity_id, card )
				card_count = card_count - 1
			end


			for i=1,card_count do
				bullet_card = GetRandomActionWithType( x, y + cost, extra_level, ACTION_TYPE_PROJECTILE, i * 352 )
				AddGunAction( entity_id, bullet_card )
			end
		end
	else
		for i=1,card_count do
			if( Random(0,100) < good_cards and card_count > 2 ) then
				-- if actions_per_round == 1 and the first good card, then make sure it's a draw x
				if( good_card_count == 0 and actions_per_round == 1 ) then
					card = GetRandomActionWithType( x, y, level, ACTION_TYPE_DRAW_MANY, i )
					good_card_count = good_card_count + 1
				else
					if( Random(0,100) < 83 ) then
						card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_MODIFIER, i )
					else
						card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_DRAW_MANY, i )
					end
				end
			
				AddGunAction( entity_id, card )
			else
				AddGunAction( entity_id, bullet_card )
				if( random_bullets == 1 ) then
					bullet_card = GetRandomActionWithType( x, y + cost, level, ACTION_TYPE_PROJECTILE, i )
				end
			end
		end
	end
end

function generate_gun( cost, level, force_unshuffle )
	local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )
	SetRandomSeed( x + cost, y )


	local gun = get_gun_data( cost, level, force_unshuffle )
	make_wand_from_gun_data( gun, entity_id, level )
	wand_add_random_cards( gun, entity_id, level, cost )
	
end


