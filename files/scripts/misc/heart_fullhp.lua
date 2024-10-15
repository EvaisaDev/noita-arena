dofile( "data/scripts/game_helpers.lua" )

function give_health(entity_who_picked, x, y)

	local max_hp = 0
	local healing = 0
	
	if(x == nil)then
		x, y = EntityGetTransform( entity_who_picked )
	end

	local scaling_type = GlobalsGetValue("health_scaling_type", "mult")
	local flat_amount = tonumber(GlobalsGetValue("health_scaling_flat_amount", "50"))
	local multiplier = tonumber(GlobalsGetValue("health_scaling_mult_amount", "2"))


	print("HP Scaling type: " .. scaling_type)
	print("HP Flat amount: " .. flat_amount)
	print("HP Multiplier: " .. multiplier)

	local hp_gained = 0

	local damagemodels = EntityGetComponent( entity_who_picked, "DamageModelComponent" )
	if( damagemodels ~= nil ) then
		for i,damagemodel in ipairs(damagemodels) do
			max_hp = tonumber( ComponentGetValue( damagemodel, "max_hp" ) )
			local max_hp_cap = tonumber( ComponentGetValue( damagemodel, "max_hp_cap" ) )
			local hp = tonumber( ComponentGetValue( damagemodel, "hp" ) )
			
			local old_max_hp = max_hp
			print("Old max hp: " .. old_max_hp)
			if(scaling_type == "flat")then
				max_hp = max_hp + (flat_amount / 25)
			elseif(scaling_type == "mult")then
				max_hp = max_hp * multiplier
			end
			print("New max hp: " .. max_hp)

			hp_gained = max_hp - old_max_hp
			print("HP gained: " .. hp_gained)
			
			
			if ( max_hp_cap > 0 ) then
				max_hp_cap = math.max( max_hp, max_hp_cap )
			end
			
			healing = max_hp - hp
			
			-- if( hp > max_hp ) then hp = max_hp end
			ComponentSetValue( damagemodel, "max_hp_cap", max_hp_cap)
			ComponentSetValue( damagemodel, "max_hp", max_hp)
			ComponentSetValue( damagemodel, "hp", max_hp)
		end
	end

	EntityLoad("data/entities/particles/image_emitters/heart_fullhp_effect.xml", x, y-12)
	EntityLoad("data/entities/particles/heart_out.xml", x, y-8)
	GamePrintImportant( "$log_heart_fullhp_temple", GameTextGet( "$logdesc_heart_fullhp_temple", tostring(math.floor(hp_gained * 25)), tostring(math.floor(max_hp * 25)), tostring(math.floor(healing * 25)) ) )
	--GameTriggerMusicEvent( "music/temple/enter", true, x, y )

    GameAddFlagRun("picked_health")
	-- remove the item from the game
end

function item_pickup( entity_item, entity_who_picked, name )
	local x, y = EntityGetTransform( entity_item )


	give_health(entity_who_picked, x, y)


	EntityKill( entity_item )
end
