local entity = {}

GameDestroyInventoryItems = function( entity_who_picked )
    local items = GameGetAllInventoryItems( entity_who_picked )
    for i, item in ipairs(items or {}) do
        EntityRemoveFromParent( item )
        EntityKill( item )
    end
end

entity.ClearGameEffects = function( ent )
    local components = EntityGetComponent(ent, "GameEffectComponent")
    if components ~= nil then
        for i,component in ipairs(components) do
            -- check if the effect is not -1 frames
            local frames = ComponentGetValue2(component, "frames")
            if frames > 0 then
                -- if it is not, set it to 1
                ComponentSetValue2(component, "frames", 1)
            end
        end
    end
    -- do the same for lifetime components
    local components = EntityGetComponent(ent, "LifetimeComponent")
    if components ~= nil then
        for i,component in ipairs(components) do
            -- check if the effect is not -1 frames
            local frames = ComponentGetValue2(component, "lifetime")
            if frames > 0 then
                -- if it is not, set it to 1
                ComponentSetValue2(component, "lifetime", 1)
            end
        end
    end

    -- also loop through children and do the same
    local children = EntityGetAllChildren(ent)
    if children ~= nil then
        for i,child in ipairs(children) do
            entity.ClearGameEffects(child)
        end
    end
end

-- make a item network synced
entity.NetworkRegister = function(item_entity, x, y, id)
    if(item_entity == nil or item_entity == 0)then
        return
    end

    local EntityHelper = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")

    local val = EntityHelper.GetVariable(item_entity, "arena_entity_id")
    if(val ~= nil)then
        return
    end

    EntityHelper.SetVariable(item_entity, "arena_entity_id", id ~= nil and id or tonumber(tostring(x)..tostring(math.abs(y))))

    local lua_comps = EntityGetComponentIncludingDisabled(item_entity, "LuaComponent") or {}
    local has_pickup_script = false
    for i, lua_comp in ipairs(lua_comps) do
        if (ComponentGetValue2(lua_comp, "script_item_picked_up") == "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua") then
            has_pickup_script = true
        end
    end

    if (not has_pickup_script) then
        EntityAddTag(item_entity, "does_physics_update")
        EntityAddComponent(item_entity, "LuaComponent", {
            _tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
            script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/item_pickup.lua",
            script_kick = "mods/evaisa.arena/files/scripts/gamemode/misc/item_kick.lua",
            script_throw_item = "mods/evaisa.arena/files/scripts/gamemode/misc/item_throw.lua",
        })
    end
end

entity.SetVariable = function(ent, name, value)
    --print("entity: "..tostring(ent))
    if(ent == nil or ent == 0 or not EntityGetIsAlive(ent))then
        return
    end
    local variable_storage_comps = EntityGetComponentIncludingDisabled(ent, "VariableStorageComponent")
    local found_and_set = false
    if variable_storage_comps ~= nil then
        for i,variable_storage_comp in ipairs(variable_storage_comps) do
            if ComponentGetValue2(variable_storage_comp, "name") == name then
                found_and_set = true
                if(type(value) == "number")then
                    ComponentSetValue2(variable_storage_comp, "value_int", 0)
                    ComponentSetValue2(variable_storage_comp, "value_float", value)
                elseif(type(value) == "string")then
                    ComponentSetValue2(variable_storage_comp, "value_int", 1)
                    ComponentSetValue2(variable_storage_comp, "value_string", value)
                elseif(type(value) == "boolean")then
                    ComponentSetValue2(variable_storage_comp, "value_int", 2)
                    ComponentSetValue2(variable_storage_comp, "value_bool", value)
                end
                return
            end
        end
    end

    if(not found_and_set)then
        --print("entity: "..tostring(ent).." did not have variable "..name..", creating it")
        local variable_storage_comp = EntityAddComponent(ent, "VariableStorageComponent", {
            name = name,
        })

        if(type(value) == "number")then
            ComponentSetValue2(variable_storage_comp, "value_int", 0)
            ComponentSetValue2(variable_storage_comp, "value_float", value)
        elseif(type(value) == "string")then
            ComponentSetValue2(variable_storage_comp, "value_int", 1)
            ComponentSetValue2(variable_storage_comp, "value_string", value)
        elseif(type(value) == "boolean")then
            ComponentSetValue2(variable_storage_comp, "value_int", 2)
            ComponentSetValue2(variable_storage_comp, "value_bool", value)
        end
    end
end

entity.GetVariable = function(ent, name)
    local variable_storage_comps = EntityGetComponentIncludingDisabled(ent, "VariableStorageComponent")
    if variable_storage_comps ~= nil then
        for i,variable_storage_comp in ipairs(variable_storage_comps) do
            if ComponentGetValue2(variable_storage_comp, "name") == name then
                local value_type = ComponentGetValue2(variable_storage_comp, "value_int")
                if(value_type == 0)then
                    return ComponentGetValue2(variable_storage_comp, "value_float")
                elseif(value_type == 1)then
                    return ComponentGetValue2(variable_storage_comp, "value_string")
                elseif(value_type == 2)then
                    return ComponentGetValue2(variable_storage_comp, "value_bool")
                end
            end
        end
    end
    return nil
end

local function pickup_tag_fix(item)
    EntitySetComponentsWithTagEnabled( item, "enabled_in_world", false )
    EntitySetComponentsWithTagEnabled( item, "enabled_in_hand", false )
    EntitySetComponentsWithTagEnabled( item, "enabled_in_inventory", true )

    -- get all children
    local children = EntityGetAllChildren(item)

    -- loop through children
    if children ~= nil then
        for i,child in ipairs(children) do
            pickup_tag_fix(child)
        end
    end
end

entity.PickItem = function(ent, item, inventory)
    local item_component = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
    local preferred_inv = "QUICK"
    if item_component then
      ComponentSetValue2(item_component, "has_been_picked_by_player", true)
      preferred_inv = ComponentGetValue2(item_component, "preferred_inventory")
      ComponentSetValue2(item_component, "mFramePickedUp", GameGetFrameNum())
      -- play_spinning_animation
      ComponentSetValue2(item_component, "play_spinning_animation", true)
      ComponentSetValue2(item_component, "play_hover_animation", false)
    end
    if inventory ~= nil then
      preferred_inv = inventory
    end

    local entity_children = EntityGetAllChildren(ent) or {}

    for key, child in pairs( entity_children ) do
      if EntityGetName( child ) == "inventory_"..string.lower(preferred_inv) then
        EntityAddChild( child, item)
      end
    end
  
    pickup_tag_fix(item)


    local sprite_particle_emitter_comp = EntityGetFirstComponentIncludingDisabled(item, "SpriteParticleEmitterComponent")
    if sprite_particle_emitter_comp ~= nil then
        EntitySetComponentIsEnabled(item, sprite_particle_emitter_comp, false)
    end
  

    --print("Adding Item ("..item..") to Inventory ("..preferred_inv..") of Entity ("..ent..")")
    --print("Item ("..item..") attached as child to Entity ("..EntityGetParent(item)..") of Root Entity ("..EntityGetRootEntity(item)..")")
end

entity.GivePerk = function( entity_who_picked, perk_id, amount )
    -- fetch perk info ---------------------------------------------------

    if(entity_who_picked == nil or entity_who_picked == 0 or not EntityGetIsAlive(entity_who_picked))then
        return
    end

    local pos_x, pos_y

    pos_x, pos_y = EntityGetTransform( entity_who_picked )

    local perk_data = get_perk_with_id( perk_list, perk_id )
    if perk_data == nil then
        return
    end

    if (not (perk_data.run_on_clients or perk_data.usable_by_enemies)) then
        return
    end


    local no_remove = perk_data.do_not_remove or false

    -- add a game effect or two
    if perk_data.game_effect ~= nil then
        local game_effect_comp,game_effect_entity = GetGameEffectLoadTo( entity_who_picked, perk_data.game_effect, true )
        if game_effect_comp ~= nil then
            ComponentSetValue( game_effect_comp, "frames", "-1" )
            
            if ( no_remove == false ) then
                ComponentAddTag( game_effect_comp, "perk_component" )
                EntityAddTag( game_effect_entity, "perk_entity" )
            end
        end
    end

    if perk_data.game_effect2 ~= nil then
        local game_effect_comp,game_effect_entity = GetGameEffectLoadTo( entity_who_picked, perk_data.game_effect2, true )
        if game_effect_comp ~= nil then
            ComponentSetValue( game_effect_comp, "frames", "-1" )
            
            if ( no_remove == false ) then
                ComponentAddTag( game_effect_comp, "perk_component" )
                EntityAddTag( game_effect_entity, "perk_entity" )
            end
        end
    end

    -- particle effect only applied once
    if perk_data.particle_effect ~= nil and ( amount <= 1 ) then
        local particle_id = EntityLoad( "data/entities/particles/perks/" .. perk_data.particle_effect .. ".xml" )
        
        if ( no_remove == false ) then
            EntityAddTag( particle_id, "perk_entity" )
        end
        
        EntityAddChild( entity_who_picked, particle_id )
    end

    local fake_perk_ent = EntityCreateNew()
    EntitySetTransform( fake_perk_ent, pos_x, pos_y )

    if perk_data.func_client ~= nil then
        perk_data.func_client( fake_perk_ent, entity_who_picked, perk_id, amount, true )
    elseif perk_data.func ~= nil then
        perk_data.func( fake_perk_ent, entity_who_picked, perk_id, amount, true )
    end

    EntityKill( fake_perk_ent )

    --GamePrint( "Picked up perk: " .. perk_data.name )
end

entity.BlockFiring = function(ent, do_block)
    local now = GameGetFrameNum();
    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(ent, "Inventory2Component")
    if(inventory2Comp ~= nil)then
        --[[
        local held_wand = ComponentGetValue2(inventory2Comp, "mActiveItem")
        if held_wand ~= 0 then
            local ability = EntityGetFirstComponentIncludingDisabled( held_wand, "AbilityComponent" );
            if ability then
                if(do_block)then
                    ComponentSetValue2( ability, "mReloadFramesLeft", 2 );
                    ComponentSetValue2( ability, "mNextFrameUsable", now + 2 );
                    ComponentSetValue2( ability, "mReloadNextFrameUsable", now + 2 );

                else
                    ComponentSetValue2( ability, "mReloadFramesLeft", 0 );
                    ComponentSetValue2( ability, "mNextFrameUsable", now );
                    ComponentSetValue2( ability, "mReloadNextFrameUsable", now );
                end
            end
        end]]
        local items = GameGetAllInventoryItems(ent)
        for i, item in ipairs(items or {}) do
            local ability = EntityGetFirstComponentIncludingDisabled( item, "AbilityComponent" );
            if ability then
                if(do_block)then
                    --ComponentSetValue2( ability, "mReloadFramesLeft", 2000000 );
                    ComponentSetValue2( ability, "mNextFrameUsable", now + 2000000 );
                    ComponentSetValue2( ability, "mReloadNextFrameUsable", now + 2000000 );

                else
                    --ComponentSetValue2( ability, "mReloadFramesLeft", 0 );
                    ComponentSetValue2( ability, "mNextFrameUsable", now );
                    ComponentSetValue2( ability, "mReloadNextFrameUsable", now );
                end
            end
        end
    end
end

entity.GetHeldItem = function(ent)
    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(ent, "Inventory2Component")
    if(inventory2Comp ~= nil)then
        local held_wand = ComponentGetValue2(inventory2Comp, "mActiveItem")
        if held_wand ~= 0 then
            return held_wand
        end
    end
    return nil
end


return entity