function damage_about_to_be_received( damage, x, y, entity_thats_responsible, critical_hit_chance )

    local damage_details = GetDamageDetails()

    local projectile = damage_details.projectile_thats_responsible

    --[[if(projectile ~= nil and EntityHasTag(projectile, "requires_handshake"))then
        CrossCall("ProjectileHit", projectile, false)
    end]]


    local is_dummy = nil
    if(entity_thats_responsible ~= 0 and EntityGetName(entity_thats_responsible) == "dummy_damage")then
        is_dummy = true
    end
    if(not is_dummy and entity_thats_responsible ~= GameGetWorldStateEntity())then
        return 0, 0
    end

    print("Returning original damage")

    return damage, 0
end


function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
    --[[local entity_id = GetUpdatedEntityID()
    local is_dummy = nil
    if(entity_thats_responsible ~= 0 and EntityGetName(entity_thats_responsible) == "dummy_damage")then
        is_dummy = true
    end
    if(is_dummy)then]]
        print("Damage received: "..tostring(damage))
        local damageModelComponent = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
        if damageModelComponent ~= nil then
            local health = ComponentGetValue2( damageModelComponent, "hp" )
            if health then
                ComponentSetValue2( damageModelComponent, "hp", health + damage )
            end
        end
    --end
end