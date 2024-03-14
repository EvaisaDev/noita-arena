entity = GetUpdatedEntityID()
interactComp = EntityGetFirstComponentIncludingDisabled(entity, "InteractableComponent", "wardrobe")


local players = EntityGetWithTag("player_unit")
if(players == nil)then
    return
end
local player = players[1]

local max_distance = 50
local x, y = EntityGetTransform(entity)
local px, py = EntityGetTransform(player)

if(math.abs(x - px) > max_distance or math.abs(y - py) > max_distance)then
    GameRemoveFlagRun("wardrobe_open")
    GameRemoveFlagRun("chat_bind_disabled")
end

if(GameHasFlagRun("wardrobe_open"))then
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_closed"))
else
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_open"))
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )

    if(GameHasFlagRun("wardrobe_open"))then
        if(GameHasFlagRun("no_wardrobe_close"))then
            return
        end
        GameRemoveFlagRun("chat_bind_disabled")
        GameRemoveFlagRun("wardrobe_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_closed"))
    else
        GameAddFlagRun("chat_bind_disabled")
        GameAddFlagRun("wardrobe_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_open"))
    end

    --GamePrint("Not implemented yet :(")
    --print("Not implemented yet :(")
end