-- Function to randomly select material from a weighted list with special handlers
function random_from_weighted_table(weighted_table)
	-- Check for any handler that forces selection
	for _, item in ipairs(weighted_table) do
		if item.handler and item.handler() then
			return item.material
		end
	end

	-- Calculate total weight for normal selection
	local total_weight = 0
	for _, item in ipairs(weighted_table) do
		total_weight = total_weight + item.weight
	end

	local random_weight = Random(1, total_weight * 1000000) / 1000000
	for _, item in ipairs(weighted_table) do
		random_weight = random_weight - item.weight
		if random_weight <= 0 then
			return item.material
		end
	end
end


function EntityGetNamedChild( entity_id, name )
    local children = EntityGetAllChildren( entity_id ) or {};
	if children ~= nil then
		for index,child_entity in pairs( children ) do
			local child_entity_name = EntityGetName( child_entity );
			
			if child_entity_name == name then
				return child_entity;
            end
        end
    end
end