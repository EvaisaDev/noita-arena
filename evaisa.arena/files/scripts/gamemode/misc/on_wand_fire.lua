function wand_fired( gun_entity_id )
    --local player_entity_id = EntityGetRootEntity( gun_entity_id )
    --[[local controls_comp = EntityGetFirstComponentIncludingDisabled( player_entity_id, "ControlsComponent" )
    if(controls_comp)then
        local change_item_r = ComponentGetValue2(controls_comp, "mButtonDownChangeItemR")
        local change_item_l = ComponentGetValue2(controls_comp, "mButtonDownChangeItemL")

        -- only allow fire if not switching items
        if(not (change_item_r or change_item_l))then]]
            local fire_count = GlobalsGetValue( "wand_fire_count", "0" )
            fire_count = tonumber( fire_count )
            fire_count = fire_count + 1
            GlobalsSetValue( "wand_fire_count", tostring( fire_count ) )
            GamePrint("fired")
        --[[end
    end]]
end