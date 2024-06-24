function damage_about_to_be_received( damage, x, y, entity_thats_responsible, critical_hit_chance )
    local damage_details = GetDamageDetails()
    local name = EntityGetName(GetUpdatedEntityID())
    if(damage_details.description ~= "damage_fake" and damage_details.description ~= "kill_client")then
        print("Client [".. name.."] is not dead, blocking damage.")
        return 0, 0
    end

    --print("Returning original damage")

    return damage, 0
end


function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
    if message == "damage_fake" then
        local entity_id = GetUpdatedEntityID()
        local name = EntityGetName(entity_id)
        print("Client [".. name.."] is not dead, preventing death.")
        local damageModelComponent = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
        if damageModelComponent ~= nil then
            local health = ComponentGetValue2( damageModelComponent, "hp" )
            if health - damage <= 0 then
                ComponentSetValue2( damageModelComponent, "hp", damage + 0.04 )
            end
        end
    end
end