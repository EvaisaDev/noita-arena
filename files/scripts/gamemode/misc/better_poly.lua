function wake_up_waiting_threads()
    local entity_id = GetUpdatedEntityID()
    local controls = EntityGetFirstComponentIncludingDisabled(entity_id, "ControlsComponent")

    local animal_ai = EntityGetFirstComponentIncludingDisabled(entity_id, "AnimalAIComponent")

    local frame = GameGetFrameNum()

    if not controls or not animal_ai then
        return
    end

    local mButtonDownEat = ComponentGetValue2(controls, "mButtonDownEat")
    if(mButtonDownEat)then
        ComponentSetValue2(animal_ai, "mEatNextFrame", frame)
    end

end