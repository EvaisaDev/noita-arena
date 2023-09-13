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
    EntitySetTransform(player, x, y)
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

    local player = player_helper.Get()
    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")
    local wandData = {}
    for k, v in pairs(wands) do
        local wand_entity = v.entity_id
        local item_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "ItemComponent")
        local slot_x, slot_y = ComponentGetValue2(item_comp, "inventory_slot")

        GlobalsSetValue(tostring(wand_entity) .. "_wand", tostring(k))

        table.insert(wandData,
            {
                data = v:Serialize(not fresh, not fresh),
                id = k,
                slot_x = slot_x,
                slot_y = slot_y,
                active = (mActiveItem == wand_entity)
            })
    end
    return wandData
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
    local inventory2Comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
    local mActiveItem = ComponentGetValue2(inventory2Comp, "mActiveItem")
    return mActiveItem
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

    --[[if add_progress_flags then
        local flag_name_persistent = string.lower(flag_name)
        if (not HasFlagPersistent(flag_name_persistent)) then
            GameAddFlagRun("new_" .. flag_name_persistent)
        end
        AddFlagPersistent(flag_name_persistent)
    end]]
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
        wand_data = player_helper.GetWandData(),
        spells = player_helper.GetSpells(),
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
        wand_data = player_helper.GetWandData(true),
        spells = data.spells,
        perks = data.perks,
        gold = data.gold,
    }

    local data_out = dont_stringify and data or bitser.dumps(data)

    local compare_string = bitser.dumps(compare_data)

    return data_out, compare_string
end


player_helper.Deserialize = function(data, skip_perk_count)
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

    if (data.wand_data ~= nil) then
        player_helper.SetWandData(data.wand_data)
    end
    if (data.spells ~= nil) then
        player_helper.SetSpells(data.spells)
    end
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
end

return player_helper
