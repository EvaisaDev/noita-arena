local e = GetUpdatedEntityID()
EntityApplyTransform(e, EntityGetTransform(e))

local function update_children(entity)
    local children = EntityGetAllChildren(entity)
    if children == nil then return end
    for _, child in ipairs(children) do
        EntityApplyTransform(child, EntityGetTransform(child))
        update_children(child)
    end
end

update_children( e )