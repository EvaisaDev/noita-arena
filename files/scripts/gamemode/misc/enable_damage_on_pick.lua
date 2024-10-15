dofile( "data/scripts/game_helpers.lua" )

function item_pickup( entity_item, entity_who_picked, name )
	local x, y = EntityGetTransform( entity_item )

    local damage_model_comp = EntityGetFirstComponent( entity_item, "DamageModelComponent" )
    if( damage_model_comp ~= nil ) then
        EntitySetComponentIsEnabled( entity_item, damage_model_comp, true )
    end

    local physics_body_collision_component = EntityGetFirstComponentIncludingDisabled( entity_item, "PhysicsBodyCollisionDamageComponent" )
    if( physics_body_collision_component ~= nil ) then
        EntitySetComponentIsEnabled( entity_item, physics_body_collision_component, true )
    end
end
 