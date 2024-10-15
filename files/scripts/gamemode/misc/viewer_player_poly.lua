-- dexter polymorph thingy.

local function unit_vec(x, y)
    local length = math.sqrt(x * x + y * y)
    return x / length, y / length
end

function wake_up_waiting_threads()
    local entity_id = GetUpdatedEntityID()
    local controls = EntityGetFirstComponentIncludingDisabled(entity_id, "ControlsComponent")

    if(controls)then
        ComponentSetValue2(controls, "enabled", false)
    end

    local animal_ai = EntityGetFirstComponentIncludingDisabled(entity_id, "AnimalAIComponent")

    local frame = GameGetFrameNum()

    if not controls or not animal_ai
    or not ComponentGetValue2(controls, "polymorph_hax")
    or not ComponentGetValue2(controls, "mButtonDownFire")
    or ComponentGetValue2(controls, "mButtonFrameFire") ~= frame
    or ComponentGetValue2(controls, "polymorph_next_attack_frame") > frame
    then
        return
    end

    local attack_ranged_entity_file = ComponentGetValue2(animal_ai, "attack_ranged_entity_file")
    local frames_between_attack = ComponentGetValue2(animal_ai, "attack_ranged_frames_between")
    local offset_x = ComponentGetValue2(animal_ai, "attack_ranged_offset_x")
    local offset_y = ComponentGetValue2(animal_ai, "attack_ranged_offset_y")

    local x, y, _, scale_x, scale_y = EntityGetTransform(entity_id)

    for _, ai_attack in ipairs(EntityGetComponent(entity_id, "AIAttackComponent") or {}) do
        SetRandomSeed(x + 0.11231 + frame, y + 0.2341)
        if Random(100) <= ComponentGetValue2(ai_attack, "use_probability") then
            attack_ranged_entity_file = ComponentGetValue2(ai_attack, "attack_ranged_entity_file")

            frames_between_attack = ComponentGetValue2(ai_attack, "frames_between")
        
            offset_x = ComponentGetValue2(ai_attack, "attack_ranged_offset_x")
            offset_y = ComponentGetValue2(ai_attack, "attack_ranged_offset_y")
        end
    end

    offset_x = offset_x * scale_x
    offset_y = offset_y * scale_y

    -- TODO: Entity rotation

    local shoot_x = x + offset_x
    local shoot_y = y + offset_y

    local aimvec_x, aimvec_y = unit_vec(ComponentGetValue2(controls, "mAimingVector"))
    local target_x = shoot_x + aimvec_x * 2
    local target_y = shoot_y + aimvec_y * 2

    if attack_ranged_entity_file == "data/entities/projectiles/acidshot.xml"
    and EntityGetFilename(entity_id) ~= "data/entities/animals/acidshooter.xml"
    then
        return
    end

    if attack_ranged_entity_file == "" or attack_ranged_entity_file == "data/entities/projectiles/spear.xml" then
        return
    end

    ComponentSetValue2(controls, "polymorph_next_attack_frame", frame + frames_between_attack)

    local projectile = EntityLoad(attack_ranged_entity_file, shoot_x, shoot_y)
    if projectile then
        GameShootProjectile(entity_id,
            shoot_x, shoot_y,
            target_x, target_y,
            projectile,
            true
        )
    end
end