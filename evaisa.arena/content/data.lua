arena_list = {
    {
        id = "original",
        name = "Origins",
        description = "The original arena, created during closed beta",
        thumbnail = "mods/evaisa.arena/content/arenas/default_thumbnail.png",
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
    
    --[[{
        id = "alias",
        name = "Lethal Lava Land",
        description = "Map made by alias",
        thumbnail = "mods/evaisa.arena/content/arenas/alias_map/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/alias_map/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/alias_map/lava.xml",
                height_index="1",
                color="ffab3e3a"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/alias_map/arena_scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 1000, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 500 -- damage floor, if player falls below this they die.
    },
    {
        id = "underwater",
        name = "Underwater",
        description = "Map made by kaliuresis",
        thumbnail = "mods/evaisa.arena/content/arenas/underwater/underwater_thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/underwater/map.lua",
        custom_biomes = {
            biome_filename="mods/evaisa.arena/content/arenas/underwater/underwater_biome.xml",
            height_index="1",
            color="ff322cab",
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/underwater/arena_scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 1024, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 512 -- damage floor, if player falls below this they die.
    },]]
    {
        id = "spoop",
        name = "Unholy Temple",
        description = "Arena made by Spoopy",
        thumbnail = "mods/evaisa.arena/content/arenas/default_thumbnail.png",
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
        thumbnail = "mods/evaisa.arena/content/arenas/default_thumbnail.png",
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