local old_fungal_shift = fungal_shift

fungal_shift = function(entity, x, y, debug_no_limits)
    local old_ConvertMaterialEverywhere = ConvertMaterialEverywhere
    local from_materials = ""
    local to_material = "water"
    ConvertMaterialEverywhere = function(from, to)
        local from_name, to_name = CellFactory_GetName(from), CellFactory_GetName(to)
        from_materials = from_materials .. from_name .. ";"
        to_material = to_name
        old_ConvertMaterialEverywhere(from, to)
    end
    old_fungal_shift(entity, x, y, debug_no_limits)
    GlobalsSetValue("arena_fungal_shift_from", from_materials)
    GlobalsSetValue("arena_fungal_shift_to", to_material)
    ConvertMaterialEverywhere = old_ConvertMaterialEverywhere
end