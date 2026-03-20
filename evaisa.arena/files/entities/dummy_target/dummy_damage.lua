local function len(txt, clock)
    local length = 0
    for i = 1, string.len(txt) do
        if string.sub(txt, i, i) == "." then length = length + 2
        else length = length + 5 end
    end
    if clock then
        return -0.5 * length - 2.5
    else
        return length * 0.5
    end
end

local function rnd(num)
    return tostring(math.floor(num * 250 + 0.5) / 10)
end

function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
    if damage <= 0 then return end
    local me = GetUpdatedEntityID()
    local sprites = EntityGetComponentIncludingDisabled(me, "SpriteComponent", "grahamsdummy_damage") or {}
    local var = EntityGetFirstComponentIncludingDisabled(me, "VariableStorageComponent", "graham_dummy_state")
    local dmg = EntityGetFirstComponentIncludingDisabled(me, "DamageModelComponent")
    if #sprites < 4 or (not var) or (not dmg) then return end
    local text = rnd(damage)
    ComponentSetValue2(sprites[1], "text", text)
    ComponentSetValue2(sprites[1], "offset_x", len(text))
    ComponentSetValue2(sprites[1], "image_file", "mods/grahamsdummy/files/fonts/damage.xml")
    EntityRefreshSprite(me, sprites[1])

    local dps = EntityGetFirstComponent(me, "LuaComponent", "dps_damage_reset")
    if not dps then
        dps = EntityAddComponent2(me, "LuaComponent", {
            _tags="dps_damage_reset",
            script_source_file="mods/evaisa.arena/files/entities/dummy_target/dummy_reset.lua",
            execute_every_n_frame=60,
        })
        ComponentSetValue2(sprites[4], "rect_animation", "go")
        EntityRefreshSprite(me, sprites[4])
    end
    local old = ComponentGetValue2(var, "value_float") + damage
    ComponentSetValue2(var, "value_float", old)
    text = rnd(old)
    ComponentSetValue2(sprites[2], "text", text)
    ComponentSetValue2(sprites[2], "offset_x", len(text))
    ComponentSetValue2(sprites[4], "offset_x", len(text, true))
    EntityRefreshSprite(me, sprites[2])

    local total = ComponentGetValue2(dmg, "falling_damage_damage_max") + damage
    ComponentSetValue2(dmg, "falling_damage_damage_max", total)
    text = rnd(total)
    ComponentSetValue2(sprites[3], "text", text)
    ComponentSetValue2(sprites[3], "offset_x", len(text))
    EntityRefreshSprite(me, sprites[3])

    ComponentSetValue2(dmg, "hp", ComponentGetValue2(dmg, "max_hp"))
end

function interacting(entity_who_interacted, entity_interacted, interactable_name)
    local me = GetUpdatedEntityID()
    local sprites = EntityGetComponentIncludingDisabled(me, "SpriteComponent", "grahamsdummy_damage") or {}
    local dmg = EntityGetFirstComponentIncludingDisabled(me, "DamageModelComponent")
    if #sprites < 4 or (not dmg) then return end
    local text = "0"
    ComponentSetValue2(sprites[1], "text", text)
    ComponentSetValue2(sprites[1], "offset_x", len(text))
    ComponentSetValue2(sprites[1], "image_file", "mods/grahamsdummy/files/fonts/damage.xml")
    EntityRefreshSprite(me, sprites[1])

    ComponentSetValue2(dmg, "falling_damage_damage_max", 0)
    ComponentSetValue2(sprites[3], "text", text)
    ComponentSetValue2(sprites[3], "offset_x", len(text))
    EntityRefreshSprite(me, sprites[3])
end
