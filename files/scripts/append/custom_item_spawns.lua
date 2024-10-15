local function register_item(weight, entity, offset) -- use this to register an item in spawn table

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