local function register_item(listname, weight, entity, offset) -- use this to register an item in spawn table
    if ( type( listname ) == "string" ) then
        local newmin = spawnlists[listname].rnd_max + 1
        local newmax = newmin + weight
        local tbl = {
            value_min = newmin,
            value_max = newmax,
            offset_y = offset,
            load_entity = entity
        }
        table.insert(spawnlists[listname].spawns, tbl)
        spawnlists[listname].rnd_max = newmax
    elseif ( type( listname ) == "table" ) then
        local newmin = listname.rnd_max + 1
        local newmax = newmin + weight
        local tbl = {
            value_min = newmin,
            value_max = newmax,
            offset_y = offset,
            load_entity = entity
        }
        table.insert(listname.spawns, tbl)
        listname.rnd_max = newmax
    end
end


local items = {
    {
        weight = 1,
        entity = "data/entities/items/books/book_10.xml",
        offset = -5
    }
}


for i = 0, 9 do
    register_item("potion_spawnlist", 2, "data/entities/items/books/book_0"..tostring(i)..".xml", -5)
end


for i, v in ipairs(items) do
    register_item("potion_spawnlist", v.weight, v.entity, v.offset)
end