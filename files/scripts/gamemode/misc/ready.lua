entity = GetUpdatedEntityID()
readyComp = EntityGetFirstComponentIncludingDisabled(entity, "InteractableComponent", "ready")


if(GameHasFlagRun("ready_check"))then
    ComponentSetValue2(readyComp, "ui_text", GameTextGetTranslatedOrNot("$arena_holymountain_unready"))
else
    ComponentSetValue2(readyComp, "ui_text", GameTextGetTranslatedOrNot("$arena_holymountain_ready"))
end

function interacting( entity_who_interacted, entity_interacted, interactable_name )
    readyComp = EntityGetFirstComponentIncludingDisabled(entity, "InteractableComponent", "ready")
    
    if(GameHasFlagRun("lock_ready_state"))then
        return
    end
    
    if(GameHasFlagRun("ready_check"))then
        GameAddFlagRun("player_unready")
        GameRemoveFlagRun("ready_check")
        GameRemoveFlagRun("player_ready")
        ComponentSetValue2(readyComp, "ui_text", GameTextGetTranslatedOrNot("$arena_holymountain_unready"))
    else
        GameAddFlagRun("player_ready")
        GameAddFlagRun("ready_check")
        GameRemoveFlagRun("player_unready")
        ComponentSetValue2(readyComp, "ui_text", GameTextGetTranslatedOrNot("$arena_holymountain_ready"))
    end
end