dofile_once("data/scripts/lib/utilities.lua")

HamisMode = {
    explode = function(entity_id, x, y, stacks)
        local pos_x, pos_y = EntityGetTransform( entity_id )

        local eid = shoot_projectile( entity_id, "mods/evaisa.arena/files/entities/misc/explosion.xml", pos_x, pos_y, 0, 0 )
        
        local herd_id = -1
        edit_component( entity_id, "GenomeDataComponent", function(comp,vars)
            herd_id = ComponentGetValue2( comp, "herd_id" )
        end)
        
        edit_component( eid, "ProjectileComponent", function(comp,vars)
            ComponentSetValue2( comp, "mWhoShot", entity_id )
            ComponentSetValue2( comp, "mShooterHerdId", herd_id )
            
            ComponentObjectSetValue( comp, "config_explosion", "dont_damage_this", entity_id )

            local explosion_damage = math.floor(0.04 * (1 + ( 0.2 * stacks )))
            local explosion_radius = math.floor(30 * (1 + ( 0.2 * stacks )))

            ComponentObjectSetValue2( comp, "config_explosion", "damage", explosion_damage )
            ComponentObjectSetValue2( comp, "config_explosion", "explosion_radius", explosion_radius )
        end)
    end
} 