entity = GetUpdatedEntityID()
interactComp = EntityGetFirstComponentIncludingDisabled(entity, "InteractableComponent", "wardrobe")


if(GameHasFlagRun("wardrobe_open"))then
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_open"))
else
    ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_closed"))
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )

    if(GameHasFlagRun("wardrobe_open"))then
        GameRemoveFlagRun("wardrobe_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_open"))
    else
        GameAddFlagRun("wardrobe_open")
        ComponentSetValue2(interactComp, "ui_text", GameTextGetTranslatedOrNot("$arena_wardrobe_interact_closed"))
    end

    GamePrint("Not implemented yet :(")
    print("Not implemented yet :(")
end