arena_list = {
    {
        id = "original",
        name = "Origins",
        description = "The original arena, created during closed beta",
        thumbnail = "mods/evaisa.arena/content/arenas/original/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/original/map.lua",
        pixel_scenes = "mods/evaisa.arena/content/arenas/original/arena_scenes.xml",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/original/biome.xml",
                height_index="1",
                color="ffeba92a"
            }
        },
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    },
    {
        id = "spoop",
        name = "Unholy Temple",
        description = "Arena made by Spoopy",
        thumbnail = "mods/evaisa.arena/content/arenas/spoop/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/spoop/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/spoop/biome.xml",
                height_index="1",
                color="ffa15fb4"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/spoop/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    },
    {
        id = "stadium",
        name = "Stadium",
        description = "Football anyone?",
        thumbnail = "mods/evaisa.arena/content/arenas/stadium/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/stadium/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/stadium/stadium.xml",
                height_index="1",
                color="ff75caeb"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/stadium/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400, -- damage floor, if player falls below this they die.
        time = 0.5, -- world time, optional. default will be day.
    },
}