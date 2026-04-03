local function has_tag(mat, tag)
    local mat_id = CellFactory_GetType(mat)
    local tags = CellFactory_GetTags(mat_id)
    if not tags[1] then return false end
    for i = 1, #tags do
        if tags[i]:match(tag) then
            return true
        end
    end
    return false
end

function get_valid_liquids()
	local liquids = CellFactory_GetAllLiquids(false, false)

	local valid_liquids = {}
	for k, v in pairs(liquids)do
		if(has_tag(v, "magic_liquid") or has_tag(v, "water") or has_tag(v, "liquid_common")) and (not v:match("rat") and not v:match("monster") and not v:match("creepy") and not v:match("molten") and not has_tag(v, "catastrophic") and not has_tag(v, "hot") and not has_tag(v, "lava") and not has_tag(v, "fire") and not has_tag(v, "fire_strong") and (bypass_blacklist or not GameHasFlagRun("material_blacklist_"..v))) then
			table.insert(valid_liquids, v)
		end
	end

	return valid_liquids
end

function get_random_liquid(bypass_blacklist)

	local valid_liquids = get_valid_liquids()

	if(#valid_liquids == 0)then
		return "water"
	end

	return valid_liquids[Random(1, #valid_liquids)]
end

