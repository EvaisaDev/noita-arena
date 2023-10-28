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

cosmetics = {
    {
        id = "dunce_hat",
        name = "Dunce Hat",
        description = "A hat for those who couldn't hurry up",
        icon = "mods/evaisa.arena/content/cosmetics/dunce_hat/icon.png",
        credits = "Evaisa",
        --sprite_sheet = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet.png",
        type = "hat",
        hat_offset = {x = 0, y = 4},
        hat_sprite = "mods/evaisa.arena/content/cosmetics/dunce_hat/hat.png",
        --unlock_flag = "cosmetic_unlocked_dunce_hat",
        can_be_unlocked = false,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            return false
        end,
        try_force_enable = function(lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            do return true end
            if(GameHasFlagRun("dunce"))then
                local ready_count = ArenaGameplay.ReadyAmount(data, lobby)
                local total_count = ArenaGameplay.TotalPlayers(lobby)
                if((total_count > 1 and ready_count == (total_count - 1) and not GameHasFlagRun("ready_check")) or GameHasFlagRun("was_last_ready"))then
                    return true
                end
            end
            return false
        end,
        on_update = function(lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "test",
        name = "Test",
        description = "Test",
        icon = "mods/evaisa.arena/content/cosmetics/test/icon.png",
        credits = "Evaisa",
        type = "outfit",
        outfit = {
            lower_body = {
            },
            upper_body = {
                {
                    filename = "data/ragdolls/alchemist/torso.png",
                    scale = 1,
                    z_index = 0.599,
                    y = -3,
                    rot = 0,
                    alpha = 1,
                    flip = 1,
                    h = 19,
                    w = 18,
                    x = -4,
                },
            },
            arm = {
            },
            head = {
                {
                    filename = "data/ragdolls/alchemist/head.png",
                    scale = 1,
                    z_index = 0.598,
                    y = -3,
                    rot = 0,
                    alpha = 1,
                    flip = 1,
                    h = 19,
                    w = 18,
                    x = -5,
                },
            },
        },
    }
}

cosmetic_types = {
    hat = {
        max_stack = 1, -- how many items of this type can be worn at the same time.
    },
    outfit = {
        max_stack = 1, -- how many items of this type can be worn at the same time.
    },
}