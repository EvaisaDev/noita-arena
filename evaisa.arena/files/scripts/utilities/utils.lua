-- Function to randomly select material from a weighted list with special handlers
function random_from_weighted_table(weighted_table, filter_func)

	if not filter_func then
		filter_func = function(item) return false end
	end

	-- Check for any handler that forces selection
	for _, item in ipairs(weighted_table) do
		if not filter_func(item) and item.handler and item.handler() then
			return item
		end
	end

	-- Calculate total weight for normal selection
	local total_weight = 0
	for _, item in ipairs(weighted_table) do
		if( not filter_func(item) )then
			total_weight = total_weight + item.weight
		end
	end

	local random_weight = Random(1, total_weight * 1000000) / 1000000
	for _, item in ipairs(weighted_table) do
		if( not filter_func(item) )then
			random_weight = random_weight - item.weight
			if random_weight <= 0 then
				return item
			end
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

function MergeTables(...)
	local tables = {...}
	local result = {}
	for _,t in ipairs(tables) do
		-- deep table merge
		for k,v in pairs(t) do
			if type(v) == "table" then
				if type(result[k] or false) == "table" then
					result[k] = MergeTables(result[k] or {}, v)
				else
					result[k] = v
				end
			else
				result[k] = v
			end
		end
	end
	return result
end

function GetPlayers()
	return MergeTables(EntityGetWithTag("player_unit") or {}, EntityGetWithTag("polymorphed_player") or {}) or {}
end