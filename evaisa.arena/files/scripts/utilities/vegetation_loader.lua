local function expand_string(str)
  local prefix, range, suffix = str:match("(.-)%$%[([%d%-]+)%](.*)")
  if not prefix or not range or not suffix then
      return {str}
  end

  local result = {}
  local start, stop = range:match("([^%-]+)%-([^%-]+)")
  if not start or not stop then
      return {str}
  end

  start, stop = tonumber(start), tonumber(stop)
  for i = start, stop do
      table.insert(result, string.format("%s%01d%s", prefix, i, suffix))
  end

  return result
end

function RegisterVegetation(path, offset_x, offset_y, material)

  	if(not created_vegetation[path])then
		local entity_paths = {}
		local paths = expand_string(path)
		for _, p in ipairs(paths)do
			local str = [[
<Entity 
  name="unknown" 
  tags="vegetation,pixelsprite" >
  
  <PixelSpriteComponent 
    _enabled="1" 
    image_file="]]..p..[[" 
    anchor_x="]]..offset_x..[[" 
    anchor_y="]]..offset_y..[["
    clean_overlapping_pixels="0"
	material="]]..material..[["
  >
  </PixelSpriteComponent>

  <SimplePhysicsComponent 
    can_go_up="0"
    >
  </SimplePhysicsComponent >
  
  <VelocityComponent />
  
</Entity>
			]]

			local entity_path = p:gsub("%.png", ".xml")
				:gsub("%.jpg", ".xml")
				:gsub("%.jpeg", ".xml")
			-- this is not available here you are so silly
			ModTextFileSetContent(entity_path, str)
			print("registered vegetation", entity_path, "for path", p)
			table.insert(entity_paths, entity_path)
		end

		created_vegetation[path] = entity_paths
		
	end

end

created_vegetation = created_vegetation or {}
function LoadVegetation(path, x, y)

	if(not created_vegetation[path])then
		local paths = expand_string(path)
		local entity_paths = {}
		for _, p in ipairs(paths)do
			local exists = ModDoesFileExist(p)
			if(exists)then
				table.insert(entity_paths, p)
			end
		end
		if(#entity_paths == 0)then
			print("no vegetation found for path", path)
			return
		end
		created_vegetation[path] = entity_paths
	end

	-- load random entity from the created ones
	local paths = created_vegetation[path]

	local entity_path = paths[Random(1, #paths)]

	EntityLoad(entity_path, x, y)

	
end