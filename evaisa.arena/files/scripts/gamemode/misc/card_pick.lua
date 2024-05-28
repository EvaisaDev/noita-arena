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
    GameRemoveFlagRun("card_menu_open")
    print("too far!!")
    GameRemoveFlagRun("chat_bind_disabled")
end

if(GameHasFlagRun("card_menu_open"))then
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick"))
else
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick_2"))
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )

    if(GameHasFlagRun("card_menu_open"))then
        GameRemoveFlagRun("chat_bind_disabled")
        GameRemoveFlagRun("card_menu_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick"))
    else
        GameAddFlagRun("chat_bind_disabled")
        GameAddFlagRun("card_menu_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_card_pick_2"))
    end

    --GamePrint("Not implemented yet :(")
    --print("Not implemented yet :(")
end