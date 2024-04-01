local entity = dofile("mods/evaisa.arena/files/scripts/gamemode/helpers/entity.lua")
local EZWand = dofile("mods/evaisa.arena/files/scripts/utilities/EZWand.lua")
dofile_once("data/scripts/perks/perk_list.lua")

local player_helper = {}

player_helper.Get = function()
    local player = EntityGetWithTag("player_unit")

    if (player == nil) then
        return
    end

    --[[
    if(#player > 1)then
        print("Found more than one player, issue??")
        -- print all the player entities
        for k, v in pairs(player)do
            print("Player "..k..": "..tostring(v))
        end
        -- kill first player
        EntityKill(player[1])
    end
    ]]
    --[[
    if(player[1] ~= last_player_entity)then
        print("Player changed from "..tostring(last_player_entity).." to "..tostring(player[1]))
    end

    last_player_entity = player[1]
    ]]
    return player[1]
end

player_helper.Clean = function(clear_inventory)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    if (clear_inventory) then
        GameDestroyInventoryItems(player)
    end
    entity.ClearGameEffects(player)
end

player_helper.Lock = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if (controls ~= nil) then
        ComponentSetValue2(controls, "enabled", false)
    end

    GameAddFlagRun("player_locked")
    GameRemoveFlagRun("player_is_unlocked")
    arena_log:print("Player locked")

    local characterDataComponent = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
    if (characterDataComponent ~= nil) then
        EntitySetComponentIsEnabled(player, characterDataComponent, false)
    end
    local platformShooterPlayerComponent = EntityGetFirstComponentIncludingDisabled(player,
        "PlatformShooterPlayerComponent")
    if (platformShooterPlayerComponent ~= nil) then
        EntitySetComponentIsEnabled(player, platformShooterPlayerComponent, false)
    end
end

player_helper.Unlock = function(data)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    GameSetCameraFree(false)
    data.arena_spectator = false
    local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if (controls ~= nil) then
        ComponentSetValue2(controls, "enabled", true)
    end

    arena_log:print("Player unlocked")

    if (not GameHasFlagRun("game_paused")) then
        if (player) then
            np.RegisterPlayerEntityId(player)
            local inventory_gui = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")
            local controls_component = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")

            EntitySetComponentIsEnabled(player, inventory_gui, true)
            np.EnableInventoryGuiUpdate(true)
            np.EnablePlayerItemPickUpper(true)
            ComponentSetValue2(controls_component, "enabled", true)
        end
    end

    GameRemoveFlagRun("player_locked")
    GameAddFlagRun("player_is_unlocked")
    local characterDataComponent = EntityGetFirstComponentIncludingDisabled(player, "CharacterDataComponent")
    if (characterDataComponent ~= nil) then
        EntitySetComponentIsEnabled(player, characterDataComponent, true)
    end
    local platformShooterPlayerComponent = EntityGetFirstComponentIncludingDisabled(player,
        "PlatformShooterPlayerComponent")
    if (platformShooterPlayerComponent ~= nil) then
        EntitySetComponentIsEnabled(player, platformShooterPlayerComponent, true)
    end
end

player_helper.Move = function(x, y)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    --EntitySetTransform(player, x, y)
    EntityApplyTransform(player, x, y)
end

player_helper.GiveGold = function(amount)
    local player = player_helper.Get()
    if (player == nil) then
        arena_log:print("Player not found!")
        return
    end
    local wallet_component = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
    local money = ComponentGetValue2(wallet_component, "money")
    local add_amount = amount
    ComponentSetValue2(wallet_component, "money", money + add_amount)
    arena_log:print("Gave " .. add_amount .. " gold to player.")
end

player_helper.GetGold = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local wallet_component = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
    local money = ComponentGetValue2(wallet_component, "money")
    return money
end

player_helper.GiveStartingGear = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local x, y = EntityGetTransform(player)
    local wand = EntityLoad("data/entities/items/starting_wand_rng.xml", x, y)
    arena_log:print("Starting gear granted to player entity: " .. tostring(player))
    GamePickUpInventoryItem(player, wand, false)
    local wand2 = EntityLoad("data/entities/items/starting_bomb_wand_rng.xml", x, y)
    GamePickUpInventoryItem(player, wand2, false)
    local potion = EntityLoad("data/entities/items/pickup/potion_starting.xml", x, y)
    GamePickUpInventoryItem(player, potion, false)
end

player_helper.Immortal = function(immortal)
    if (immortal) then
        GameAddFlagRun("Immortal")
    else
        GameRemoveFlagRun("Immortal")
    end
end

player_helper.GetWandData = function(fresh)
    fresh = fresh or false

    --[[
    local wand = EZWand.GetHeldWand()
    if(wand == nil)then
        return nil
    end
    local wandData = wand:Serialize()
    return wandData
    ]]
    local wands = EZWand.GetAllWands()
    if (wands == nil or #wands == 0) then
        return nil
    end


end

local function entity_is_wand(entity_id)
	local ability_component = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
    if ability_component == nil then return false end
	return ComponentGetValue2(ability_component, "use_gun_script") == true
end

player_helper.GetItemData = function(fresh)
    fresh = fresh or false

    --[[
    local wand = EZWand.GetHeldWand()
    if(wand == nil)then
        return nil
    end
    local wandData = wand:Serialize()
    return wandData
    ]]
    
    return nil
end

player_helper.GetInventoryItems = function(inventory_name)
    local player = player_helper.Get()
    if(not player)then
        return {}
    end
    local inventory = nil 

    local player_child_entities = EntityGetAllChildren( player )
    if ( player_child_entities ~= nil ) then
        for i,child_entity in ipairs( player_child_entities ) do
            local child_entity_name = EntityGetName( child_entity )
            
            if ( child_entity_name == inventory_name ) then
                inventory = child_entity
            end
    
        end
    end

    if(inventory == nil)then
        return {}
    end

    local items = {}
    for i, v in ipairs(EntityGetAllChildren(inventory) or {}) do
        local item_component = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
        if(item_component)then
            table.insert(items, v)
        end
    end
    return items
end

set_next_frame = set_next_frame or nil

player_helper.SetWandData = function(wand_data)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end

    if (wand_data ~= nil) then
        local active_item_entity = nil

        for k, wandInfo in ipairs(wand_data) do
            local x, y = EntityGetTransform(player)

            local wand = EZWand(wandInfo.data, x, y)
            if (wand == nil) then
                return
            end

            wand:PickUp(player)

            local itemComp = EntityGetFirstComponentIncludingDisabled(wand.entity_id, "ItemComponent")
            if (itemComp ~= nil) then
                ComponentSetValue2(itemComp, "inventory_slot", wandInfo.slot_x, wandInfo.slot_y)
            end

            --print("Deserialized wand #"..tostring(k).." - Active? "..tostring(wandInfo.active))

            if (wandInfo.active) then
                active_item_entity = wand.entity_id
            end

            GlobalsSetValue(tostring(wand.entity_id) .. "_wand", tostring(wandInfo.id))
        end

        if (active_item_entity ~= nil) then
            arena_log:print("Selected item was: " .. tostring(active_item_entity))

            game_funcs.SetActiveHeldEntity(player, active_item_entity, false, false)

            --[[
            local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")

            ComponentSetValue2(inventory2Comp, "mActiveItem", active_item_entity)
            ComponentSetValue2(inventory2Comp, "mActualActiveItem", active_item_entity)
            ComponentSetValue2(inventory2Comp, "mInitialized", false)
            ComponentSetValue2(inventory2Comp, "mForceRefresh", true)
            ]]
        end
    end
end

local pickup_item = function(entity, item)
    local item_component = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
    if item_component then
      ComponentSetValue2(item_component, "has_been_picked_by_player", true)
    end
    --GamePickUpInventoryItem(entity, self.entity_id, false)
    local entity_children = EntityGetAllChildren(entity) or {}
    -- 
    for key, child in pairs( entity_children ) do
      if EntityGetName( child ) == "inventory_quick" then
        EntityAddChild( child, item)
      end
    end
  
    EntitySetComponentsWithTagEnabled( item, "enabled_in_world", false )
    EntitySetComponentsWithTagEnabled( item, "enabled_in_hand", false )
    EntitySetComponentsWithTagEnabled( item, "enabled_in_inventory", true )
  
    local wand_children = EntityGetAllChildren(item) or {}
  
    for k, v in ipairs(wand_children)do
      EntitySetComponentsWithTagEnabled( item, "enabled_in_world", false )
    end  
end



player_helper.SetItemData = function(item_data)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end

    if (item_data ~= nil) then
        local active_item_entity = nil

        for k, itemInfo in ipairs(item_data) do
            local x, y = EntityGetTransform(player)
            local item_entity = nil

            local item = nil
            if(itemInfo.is_wand)then
                item = EZWand(itemInfo.data, x, y, true)
                
            else
                item = EntityCreateNew()
                np.DeserializeEntity(item, itemInfo.data, x, y)

            end

            if (item == nil) then
                return
            end

            if(itemInfo.is_wand)then
                item:PickUp(player)
                local itemComp = EntityGetFirstComponentIncludingDisabled(item.entity_id, "ItemComponent")
                if (itemComp ~= nil) then
                    ComponentSetValue2(itemComp, "inventory_slot", itemInfo.slot_x, itemInfo.slot_y)
                end
                item_entity = item.entity_id
                if (itemInfo.active) then
                    active_item_entity = item.entity_id
                end
            else
                pickup_item(player, item)
                local itemComp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
                if (itemComp ~= nil) then
                    ComponentSetValue2(itemComp, "inventory_slot", itemInfo.slot_x, itemInfo.slot_y)
                end
                item_entity = item
                if (itemInfo.active) then
                    active_item_entity = item
                end
            end

            --wand:PickUp(player)



            --print("Deserialized wand #"..tostring(k).." - Active? "..tostring(wandInfo.active))

            entity.SetVariable(item_entity, "arena_entity_id", itemInfo.id)

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

            --GlobalsSetValue(tostring(active_item_entity).."_item", tostring(itemInfo.id))
        end

        if (active_item_entity ~= nil) then
            arena_log:print("Selected item was: " .. tostring(active_item_entity))

            game_funcs.SetActiveHeldEntity(player, active_item_entity, false, false)

            --[[
            local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")

            ComponentSetValue2(inventory2Comp, "mActiveItem", active_item_entity)
            ComponentSetValue2(inventory2Comp, "mActualActiveItem", active_item_entity)
            ComponentSetValue2(inventory2Comp, "mInitialized", false)
            ComponentSetValue2(inventory2Comp, "mForceRefresh", true)
            ]]
        end
    end
end

player_helper.GetWandString = function()
    local wands = EZWand.GetAllWands()
    if (wands == nil or #wands == 0) then
        return nil
    end
    local wandDataString = ""
    for k, v in pairs(wands) do
        wandDataString = wandDataString .. v:Serialize()
    end
    return wandDataString
end

player_helper.GetControlsComponent = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if (controls == nil) then
        return
    end
    return controls
end

player_helper.DidKick = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local controls = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if (controls == nil) then
        return
    end
    local mButtonDownKick = ComponentGetValue2(controls, "mButtonDownKick")
    return mButtonDownKick
end

player_helper.GetActiveHeldItem = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end

end

player_helper.GetAnimationData = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local spriteComp = EntityGetFirstComponent(player, "SpriteComponent", "character")
    if (spriteComp == nil) then
        return
    end
    local rectAnim = ComponentGetValue2(spriteComp, "rect_animation")
    return rectAnim
end

player_helper.GetAimData = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local controlsComp = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    if (controlsComp == nil) then
        return
    end
    local x, y = ComponentGetValue2(controlsComp, "mAimingVector")

    return x and { x = x, y = y } or nil
end

player_helper.Hide = function(hide)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local spriteComps = EntityGetComponentIncludingDisabled(player, "SpriteComponent", "character")
    if (hide) then
        for k, v in pairs(spriteComps) do
            ComponentSetValue2(v, "visible", false)
        end
        -- hide cape
    else
        for k, v in pairs(spriteComps) do
            ComponentSetValue2(v, "visible", true)
        end
    end
end

player_helper.GetHealthInfo = function()
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local health = 100
    local maxHealth = 100
    local healthComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    if (healthComponent ~= nil) then
        health = ComponentGetValue2(healthComponent, "hp")
        maxHealth = ComponentGetValue2(healthComponent, "max_hp")
    end
    return health, maxHealth
end


player_helper.GetSpells = function()
    local player = player_helper.Get()
    if (player == nil) then
        return {}
    end

    local spells = {}
    --ItemActionComponent
    local items = GameGetAllInventoryItems(player) or {}
    for k, v in pairs(items) do
        local itemComp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
        if (itemComp ~= nil) then
            local itemActionComp = EntityGetFirstComponentIncludingDisabled(v, "ItemActionComponent")
            if (itemActionComp ~= nil) then
                local action = ComponentGetValue2(itemActionComp, "action_id")
                table.insert(spells, action)
            end
        end
    end

    return spells
end

player_helper.SetSpells = function(spells)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    if (spells == nil) then
        return
    end

    local x, y = EntityGetTransform(player)

    for k, v in ipairs(spells) do
        local action = CreateItemActionEntity(v, x, y)
        GamePickUpInventoryItem(player, action, false)
    end
end

player_helper.GetPerks = function()
    local perk_info = {}
    for i, perk_data in ipairs(perk_list) do
        local perk_id = perk_data.id
        local flag_name = get_perk_picked_flag_name(perk_id)

        local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))


        if GameHasFlagRun(flag_name) and (pickup_count > 0) then
            table.insert(perk_info, { id = perk_id, count = pickup_count })
        end
    end

    return perk_info
end

player_helper.GivePerk = function(perk_id, amount, skip_count)
    -- fetch perk info ---------------------------------------------------

    local entity_who_picked = player_helper.Get()

    if (entity_who_picked == nil) then
        return
    end

    local pos_x, pos_y

    pos_x, pos_y = EntityGetTransform(entity_who_picked)

    local perk_data = get_perk_with_id(perk_list, perk_id)
    if perk_data == nil then
        return
    end

    local flag_name = get_perk_picked_flag_name(perk_id)

    -- update how many times the perk has been picked up this run -----------------
    if not skip_count then
        local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))
        pickup_count = pickup_count + 1
        if(perk_log)then
            perk_log:print(perk_id .. " picked up " .. pickup_count .. " times")
        end
        GlobalsSetValue(flag_name .. "_PICKUP_COUNT", tostring(pickup_count))
    end

    -- load perk for entity_who_picked -----------------------------------
    local add_progress_flags = not GameHasFlagRun("no_progress_flags_perk")
    --[[
    if add_progress_flags then
        local flag_name_persistent = string.lower(flag_name)
        if (not HasFlagPersistent(flag_name_persistent)) then
            GameAddFlagRun("new_" .. flag_name_persistent)
        end
        AddFlagPersistent(flag_name_persistent)
    end
    ]]
    GameAddFlagRun(flag_name)

    local no_remove = perk_data.do_not_remove or false

    local fake_perk_ent = EntityCreateNew()
    EntitySetTransform(fake_perk_ent, pos_x, pos_y)

    if (not perk_data.one_off_effect and ((not perk_data.do_not_reapply) or not skip_count)) then
        if(perk_data.do_not_reapply)then
            print("reapplying: " .. perk_id)
        end
        -- add a game effect or two
        if perk_data.game_effect ~= nil then
            local game_effect_comp, game_effect_entity = GetGameEffectLoadTo(entity_who_picked, perk_data.game_effect,
                true)
            if game_effect_comp ~= nil then
                ComponentSetValue(game_effect_comp, "frames", "-1")

                if (no_remove == false) then
                    ComponentAddTag(game_effect_comp, "perk_component")
                    EntityAddTag(game_effect_entity, "perk_entity")
                end
            end
        end

        if perk_data.game_effect2 ~= nil then
            local game_effect_comp, game_effect_entity = GetGameEffectLoadTo(entity_who_picked, perk_data.game_effect2,
                true)
            if game_effect_comp ~= nil then
                ComponentSetValue(game_effect_comp, "frames", "-1")

                if (no_remove == false) then
                    ComponentAddTag(game_effect_comp, "perk_component")
                    EntityAddTag(game_effect_entity, "perk_entity")
                end
            end
        end

        -- particle effect only applied once
        if perk_data.particle_effect ~= nil and (amount <= 1) then
            local particle_id = EntityLoad("data/entities/particles/perks/" .. perk_data.particle_effect .. ".xml")

            if (no_remove == false) then
                EntityAddTag(particle_id, "perk_entity")
            end

            EntityAddChild(entity_who_picked, particle_id)
        end

        -- certain other perks may be marked as picked-up
        if perk_data.remove_other_perks ~= nil then
            for i, v in ipairs(perk_data.remove_other_perks) do
                local f = get_perk_picked_flag_name(v)
                GameAddFlagRun(f)
            end
        end


        if (perk_data.func ~= nil and not perk_data.skip_functions_on_load) then
            perk_data.func(fake_perk_ent, entity_who_picked, perk_id, amount)
        end
    end

    perk_name = GameTextGetTranslatedOrNot(perk_data.ui_name)
    perk_desc = GameTextGetTranslatedOrNot(perk_data.ui_description)

    -- add ui icon etc
    local entity_ui = EntityCreateNew("")
    EntityAddComponent(entity_ui, "UIIconComponent",
        {
            name = perk_data.ui_name,
            description = perk_data.ui_description,
            icon_sprite_file = perk_data.ui_icon
        })

    if (no_remove == false) then
        EntityAddTag(entity_ui, "perk_entity")
    end

    EntityAddChild(entity_who_picked, entity_ui)



    EntityKill(fake_perk_ent)

    --GamePrint( "Picked up perk: " .. perk_data.name )
end

player_helper.SetPerks = function(perks, skip_count)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    if (perks == nil) then
        return
    end

    for k, v in ipairs(perks) do
        local perk_id = v.id
        local pickup_count = v.count

        for i = 1, pickup_count do
            --entity.GivePerk(player, perk_id, i)
            player_helper.GivePerk(perk_id, i, skip_count)
        end
    end
end

player_helper.GiveHealth = function(amount)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local healthComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    if (healthComponent ~= nil) then
        local health = ComponentGetValue2(healthComponent, "hp")

        health = health + amount
        ComponentSetValue2(healthComponent, "hp", health)
    end
end

player_helper.GiveMaxHealth = function(amount)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    local healthComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    if (healthComponent ~= nil) then
        local max_hp = ComponentGetValue2(healthComponent, "max_hp")
        local max_hp_cap = ComponentGetValue2(healthComponent, "max_hp_cap")
        local hp = ComponentGetValue2(healthComponent, "hp")

        max_hp = max_hp + amount

        if (max_hp_cap > 0) then
            max_hp_cap = math.max(max_hp, max_hp_cap)
        end

        -- if( hp > max_hp ) then hp = max_hp end
        ComponentSetValue2(healthComponent, "max_hp_cap", max_hp_cap)
        ComponentSetValue2(healthComponent, "max_hp", max_hp)
        ComponentSetValue2(healthComponent, "hp", max_hp)
    end
end

player_helper.GetInventoryInfo = function()
    local inventory = {}
    local player = player_helper.Get()
    if (player == nil) then
        return inventory
    end

    local inventory_items = GameGetAllInventoryItems(player) or {}

    for k, v in ipairs(inventory_items) do
        local item = {
            slot_x = 0,
            slot_y = 0,
            inventory_name = "",
            is_wand = false,
            id = v
        }
        local itemComp = EntityGetFirstComponentIncludingDisabled(v, "ItemComponent")
        if (itemComp ~= nil) then
            local slot_x, slot_y = ComponentGetValue2(itemComp, "inventory_slot")
            item.slot_x = slot_x
            item.slot_y = slot_y
        else
            goto continue
        end

        local inv = EntityGetParent(v)
        local root = EntityGetRootEntity(v)

        if(root ~= v)then
            local inventory_name = EntityGetName(inv)
            item.inventory_name = inventory_name
            item.is_wand = entity_is_wand(v)

            table.insert(inventory, item)
        end

        ::continue::
    end

    return inventory
end

player_helper.DidInventoryChange = function(old_inventory_info, new_inventory_info)
    if (old_inventory_info == nil or new_inventory_info == nil) then
        return true
    end

    if (#old_inventory_info ~= #new_inventory_info) then
        return true
    end

    -- loop through both inventories, and compare the items with the same ids
    -- if an item with the same id is not in both tables, return true
    -- then check if the items are the same or not

    for k, v in ipairs(old_inventory_info) do
        local found = false
        for k2, v2 in ipairs(new_inventory_info) do
            if (v.id == v2.id) then
                found = true
                if (v.slot_x ~= v2.slot_x or v.slot_y ~= v2.slot_y or v.inventory_name ~= v2.inventory_name) then
                    return true
                end
            end
        end
        if (not found) then
            return true
        end
    end

    -- we also need to check the other way around, if there is an item in the new inventory that is not in the old one
    for k, v in ipairs(new_inventory_info) do
        local found = false
        for k2, v2 in ipairs(old_inventory_info) do
            if (v.id == v2.id) then
                found = true
            end
        end
        if (not found) then
            return true
        end
    end

    return false
end

player_helper.Serialize = function(dont_stringify)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end

    --GamePrint("Serializing player...")
    --print("Serializing player...")

    local data = {
        health = 100,
        max_health = 100,
        --item_data = player_helper.GetItemData(),
        --spells = player_helper.GetSpells(),
        perks = player_helper.GetPerks(),
        gold = player_helper.GetGold(),
    }
    local healthComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    if (healthComponent ~= nil) then
        data.health = ComponentGetValue2(healthComponent, "hp")
        data.max_health = ComponentGetValue2(healthComponent, "max_hp")
    end

    local compare_data = {
        health = data.health,
        max_health = data.max_health,
        --item_data = player_helper.GetItemData(true),
        --spells = data.spells,
        perks = data.perks,
        gold = data.gold,
    }

    local data_out = dont_stringify and data or bitser.dumps(data)

    local compare_string = bitser.dumps(compare_data)

    return data_out, compare_string
end


player_helper.Deserialize = function(data, skip_perk_count, lobby, lobby_data)
    local player = player_helper.Get()
    if (player == nil) then
        return
    end
    if (data == nil) then
        return
    end

    data = type(data) == "string" and bitser.loads(data) or data

    -- kill items
    for k, v in pairs(GameGetAllInventoryItems(player) or {}) do
        GameKillInventoryItem(player, v)
        EntityKill(v)
    end

    --[[if (data.item_data ~= nil) then
        player_helper.SetItemData(data.item_data)
    end
    if (data.spells ~= nil) then
        player_helper.SetSpells(data.spells)
    end]]
    if (data.perks ~= nil) then
        player_helper.SetPerks(data.perks, skip_perk_count)
    end
    if (data.gold ~= nil) then
        player_helper.GiveGold(data.gold)
    end
    if (data.health ~= nil and data.max_health ~= nil) then
        local healthComponent = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
        if (healthComponent ~= nil) then
            ComponentSetValue2(healthComponent, "hp", data.health)
            ComponentSetValue2(healthComponent, "max_hp", data.max_health)
        end
    end

    if(skin_system and lobby)then
        skin_system.apply_skin_to_entity(lobby, player, nil, lobby_data)
    end
end

return player_helper
