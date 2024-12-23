local helpers = dofile("mods/evaisa.mp/files/scripts/helpers.lua")

local function serialize_damage_details(tbl)
    --[[
        tbl.ragdoll_fx,
        tbl.damage_types,
        tbl.knockback_force,
        tbl.impulse[1],
        tbl.impulse[2],
        tbl.world_pos[1],
        tbl.world_pos[2],
        tbl.smash_explosion and 1 or 0,
        tbl.explosion_x or 0,
        tbl.explosion_y or 0
    ]]
    return string.format("%d,%d,%f,%f,%f,%f,%f,%f,%d,%f,%f,%s", tbl.ragdoll_fx, tbl.damage_types, tbl.knockback_force, tbl.blood_multiplier, tbl.impulse[1], tbl.impulse[2], tbl.world_pos[1], tbl.world_pos[2], tbl.smash_explosion and 1 or 0, tbl.explosion_x or 0, tbl.explosion_y or 0, tbl.attacker or "")
end

dofile("mods/evaisa.arena/files/scripts/gamemode/misc/perks/teleportitis.lua")

last_teleportitis_trigger = last_teleportitis_trigger or 0

function damage_about_to_be_received( damage, x, y, entity_thats_responsible, critical_hit_chance )
    local entity_id = GetUpdatedEntityID()

    
    local damage_details = GetDamageDetails()

    damage_details.attacker = EntityGetName(entity_thats_responsible) or ""

    local projectile = damage_details.projectile_thats_responsible

    local skip_block = false

    local special_projectile_handlers = {
        ["data/entities/projectiles/deck/swapper.xml"] = function()
            damage = 0
            skip_block = true
            CrossCall("Swap", entity_thats_responsible)
        end
    }

    if(projectile ~= nil)then
        for i, v in ipairs(EntityGetComponent(projectile, "VariableStorageComponent") or {})do
            local name = ComponentGetValue2(v, "name")
            local value_string = ComponentGetValue2(v, "value_string")
            if(name == "projectile_file")then
                local handler = special_projectile_handlers[value_string]
                if(handler)then
                    handler()
                end
            end
        end
    end

    if(GameHasFlagRun( "teleportitis" ))then
        if(GameGetFrameNum() - last_teleportitis_trigger > 60)then
            damage = damage * 0.8
            trigger(entity_id)
            last_teleportitis_trigger = GameGetFrameNum()
        end
    end


    if(GameHasFlagRun("smash_mode"))then
        --[[local damage_details = GetDamageDetails()

        local impulse_x = damage_details.impulse[1]
        local impulse_y = damage_details.impulse[2]
        ]]

        --if(not(impulse_x == 0 and impulse_y == 0))then
        local knockback = tonumber(GlobalsGetValue("smash_knockback", "1"))
        GlobalsSetValue("smash_knockback", tostring(math.min(knockback * 1.25, 100000)))
        if(entity_thats_responsible ~= GameGetWorldStateEntity())then
            return 0.0001, 0
        end
        --end
    end


    local damage_cap_percentage = tonumber(GlobalsGetValue("damage_cap", "0.25") or 0.25)

    local damageModelComponent = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
    if damageModelComponent ~= nil and entity_thats_responsible ~= GameGetWorldStateEntity() then
        local max_hp = ComponentGetValue2( damageModelComponent, "max_hp" )
        local damage_cap = max_hp * damage_cap_percentage
        if damage > damage_cap then
            damage = damage_cap
        end
    end

    GameAddFlagRun("prepared_damage")
    GameRemoveFlagRun("finished_damage")

    if(skip_block)then
        GameAddFlagRun("finished_damage")
    end


   

    GlobalsSetValue("last_damage_details", tostring(serialize_damage_details(damage_details)))



    --critical_hit_chance = 50

    return damage, critical_hit_chance
end


function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
    local entity_id = GetUpdatedEntityID()
    local x, y = EntityGetTransform(entity_id)
    local damage_details = GetDamageDetails()

    --print(json.stringify(damage_details))

    --[[
        {
            ragdoll_fx = 1 
            damage_types = 16 -- bitflag
            knockback_force = 0    
            impulse = {0, 0},
            world_pos = {216.21, 12.583},
        }
    ]]

    damage_details.attacker = EntityGetName(entity_thats_responsible) or ""

    --print(tostring(entity_thats_responsible))

    if(GameHasFlagRun("smash_mode") and entity_thats_responsible ~= GameGetWorldStateEntity() and entity_thats_responsible ~= nil)then

        local impulse_x = damage_details.impulse[1]
        local impulse_y = damage_details.impulse[2]

        if(projectile_thats_responsible)then
            -- calculate projectile velocity
            local velocity_comp = EntityGetFirstComponentIncludingDisabled(projectile_thats_responsible, "VelocityComponent")
            if(velocity_comp ~= nil)then
                local vel_x, vel_y = ComponentGetValue2(velocity_comp, "mVelocity")
                -- normalize
                local len = math.sqrt(vel_x * vel_x + vel_y * vel_y)
                impulse_x = vel_x / len
                impulse_y = vel_y / len
            end
        else
            -- get aim angle of responsible entity
            local controls_comp = EntityGetFirstComponentIncludingDisabled(entity_thats_responsible, "ControlsComponent")

            if(controls_comp)then
                local aim_x, aim_y = ComponentGetValue2(controls_comp, "mAimingVector")
                -- normalize
                local len = math.sqrt(aim_x * aim_x + aim_y * aim_y)
                impulse_x = aim_x / len
                impulse_y = aim_y / len
            else
                local ex, ey = EntityGetTransform(entity_thats_responsible)
                local dx = x - ex
                local dy = y - ey
                local len = math.sqrt(dx * dx + dy * dy)
                impulse_x = dx / len
                impulse_y = dy / len
            end
        
        end


        if(not(impulse_x == 0 and impulse_y == 0))then
            local character_data_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "CharacterDataComponent")

            local smash_knockback = tonumber(GlobalsGetValue("smash_knockback", "1"))
            

            if(smash_knockback > 10000)then
                EntityLoad("mods/evaisa.arena/files/entities/misc/smash_explosion.xml", x, y)
                damage_details.smash_explosion = true
                damage_details.explosion_x = x
                damage_details.explosion_y = y
            end

            LoadGameEffectEntityTo( entity_id, "mods/evaisa.arena/files/entities/misc/smash_knockback.xml")

            --print("SMASH KNOCKBACK: " .. tostring(smash_knockback))
            --print("IMPULSE: " .. tostring(impulse_x) .. ", " .. tostring(impulse_y))
            ComponentSetValue2(character_data_comp, "is_on_ground", true)
 
            local controls_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ControlsComponent")

            if(controls_comp ~= nil)then
                ComponentSetValue2(controls_comp, "mJumpVelocity", impulse_x * smash_knockback, impulse_y * smash_knockback)
            end
            ComponentSetValue2(character_data_comp, "mVelocity", impulse_x * smash_knockback, impulse_y * smash_knockback)

        end
    end


    --print(json.stringify(damage_details))
    -- check if would kill
    GameAddFlagRun("took_damage")
    GameAddFlagRun("finished_damage")
    GameRemoveFlagRun("prepared_damage")
    GlobalsSetValue("last_damage_details", tostring(serialize_damage_details(damage_details)))
    
    local invincibility_frames = 0

    local damageModelComponent = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
    if damageModelComponent ~= nil then
        if(GameHasFlagRun("Immortal"))then
            if(damage > 0)then
                local hp = ComponentGetValue2( damageModelComponent, "hp" )
                local max_hp = ComponentGetValue2( damageModelComponent, "max_hp" )

                print("Immortal: " .. tostring(hp) .. " / " .. tostring(max_hp))
                print("Updating hp to: " .. tostring(math.min(math.max(hp + damage, 0.04), max_hp + damage)))
                print("Damage: " .. tostring(damage))


                ComponentSetValue2( damageModelComponent, "hp", math.min(math.max(hp + damage, 0.04), max_hp + damage) )
            end
        else
            if(is_fatal)then
                local died = true
                local respawn_count = tonumber( GlobalsGetValue( "RESPAWN_COUNT", "0" ) )

                if(GameHasFlagRun( "saving_grace" ))then
                    local hp = ComponentGetValue2( damageModelComponent, "hp" )
                    if(math.floor(hp * 25) > 1)then
                        ComponentSetValue2( damageModelComponent, "hp", damage + 0.04 )

                        --ComponentSetValue2( damageModelComponent, "invincibility_frames", 60 )
                        local effect = GetGameEffectLoadTo( entity_id, "PROTECTION_ALL", true)

                        ComponentSetValue2( effect, "frames", 60 )

                        invincibility_frames = 60
                        
                        print("$log_gamefx_savinggrace")
                        GamePrint("$log_gamefx_savinggrace")

                        died = false
                    end
                end

                if(respawn_count > 0 and died)then
                    local extra_respawn_count = tonumber(GlobalsGetValue("EXTRA_RESPAWN_COUNT", "0"))
                    respawn_count = respawn_count - 1

                    extra_respawn_count = extra_respawn_count + 1

                    GlobalsSetValue( "RESPAWN_COUNT", tostring(respawn_count) )
                    GlobalsSetValue( "EXTRA_RESPAWN_COUNT", tostring(extra_respawn_count) )

                    print("$logdesc_gamefx_respawn")
                    GamePrint("$logdesc_gamefx_respawn")

                    GamePrintImportant("$log_gamefx_respawn", "$logdesc_gamefx_respawn")

                    --ComponentSetValue2( damageModelComponent, "invincibility_frames", 30 )
                    
                    local effect = GetGameEffectLoadTo( entity_id, "PROTECTION_ALL", true)

                    ComponentSetValue2( effect, "frames", 30 )

                    invincibility_frames = 30

                    ComponentSetValue2( damageModelComponent, "hp", damage + 4 )

                    died = false
                end

                if(died)then
                    GameAddFlagRun("player_died")
                    if(entity_thats_responsible ~= nil)then
                        GlobalsSetValue("killer", EntityGetName(entity_thats_responsible) or "")
                    end
                end
            end
        end
    end

    GlobalsSetValue("invincibility_frames", tostring(invincibility_frames))
end