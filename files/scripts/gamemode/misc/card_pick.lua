entity = GetUpdatedEntityID()
interactComp = EntityGetFirstComponentIncludingDisabled(entity, "InteractableComponent")


local players = EntityGetWithTag("player_unit")
if(players == nil)then
    return
end
local player = players[1]

if(player == nil)then
    return
end

local max_distance = 30
local x, y = EntityGetTransform(entity)
local px, py = EntityGetTransform(player)

if(math.abs(x - px) > max_distance or math.abs(y - py) > max_distance)then

    if(GameHasFlagRun("card_menu_open"))then
        GameAddFlagRun("update_card_menu_state")
        GameRemoveFlagRun("card_menu_open")
        GameRemoveFlagRun("chat_bind_disabled")
    end


    
end

if(GameHasFlagRun("card_menu_open"))then
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick_2"))
else
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick"))
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )

    if(GameHasFlagRun("card_menu_open"))then
        GameRemoveFlagRun("chat_bind_disabled")
        GameRemoveFlagRun("card_menu_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick_2"))
        GameAddFlagRun("update_card_menu_state")
    else
        GameAddFlagRun("chat_bind_disabled")
        GameAddFlagRun("card_menu_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick"))
        GameAddFlagRun("update_card_menu_state")
    end

end