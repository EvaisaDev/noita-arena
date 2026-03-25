local maps = {
    {
        id = "Kasuron",
        name = "Kasuron",
        description = "Don't stare for too long",
        thumbnail = "mods/evaisa.arena/content/arenas/kasuron/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/kasuron/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/kasuron/Biome.xml",
                height_index="1",
                color="FFD89228"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/kasuron/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 1000, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    }
}

for k, v in ipairs(maps)do
    table.insert(arena_list, v)
end