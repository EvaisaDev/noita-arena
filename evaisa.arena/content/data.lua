arena_list = {
    {
        id = "original",
        name = "$arena_maps_original_name",
        description = "$arena_maps_original_description",
        credits = "Evaisa",
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
        zone_floor = 400, -- damage floor, if player falls below this they die.
        init = function(self) -- called when the gamemode is loaded, this is before even entering a lobby, can be used for storing variables.
        end,
        load = function(self, lobby, data) -- called when the arena is loaded, can be used for setting up the arena.
            --LoadBackgroundSprite(steam_utils.getUserAvatar(steam.user.getSteamID()), 0, 0)
        end,
        unload = function(self, lobby, data) -- called when the arena is unloaded.

        end,
        update = function(self, lobby, data) -- Ran every frame while in the arena.

        end,
    },
    {
        id = "spoop",
        name = "$arena_maps_temple_name",
        description = "$arena_maps_temple_description",
        credits = "SpoopyBoi",
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
        name = "$arena_maps_stadium_name",
        description = "$arena_maps_stadium_description",
        credits = "Evaisa",
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
    {
        id = "coalpit",
        name = "$arena_maps_coalpit_name",
        description = "$arena_maps_coalpit_description",
        credits = "Autumnis",
        thumbnail = "mods/evaisa.arena/content/arenas/coalpit/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/coalpit/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/coalpit/coalpit.xml",
                height_index="1",
                color="ff35f34a"
            },
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/coalpit/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400, -- damage floor, if player falls below this they die.
    },
    {
        id = "biomes",
        name = "$arena_maps_biomes_name",
        description = "$arena_maps_biomes_description",
        credits = "Evaisa",
        thumbnail = "mods/evaisa.arena/content/arenas/biomes/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/biomes/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/walls.xml",
                height_index="1",
                color="FF688384"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/coalmine_alt.xml",
                height_index="1",
                color="FF7B8FE9"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/coalmine.xml",
                height_index="1",
                color="FF6EADE1"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/crypt.xml",
                height_index="1",
                color="FF6EE1BD"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/excavationsite.xml",
                height_index="1",
                color="FF6EE190"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/fungicave.xml",
                height_index="1",
                color="FFB1E16E"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/rainforest.xml",
                height_index="1",
                color="FFE1DD6E"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/snowcave.xml",
                height_index="1",
                color="FFE1926E"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/snowcastle.xml",
                height_index="1",
                color="FFE16E6E"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/vault.xml",
                height_index="1",
                color="FFC94C4C"
            },
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/biomes/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400, -- damage floor, if player falls below this they die.
    },
    {
        id = "bureon",
        name = "$arena_maps_bureon_name",
        description = "$arena_maps_bureon_description",
        credits = "burr/weturtle",
        thumbnail = "mods/evaisa.arena/content/arenas/bureon/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/bureon/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/bureon/Biome.xml",
                height_index="1",
                color="FFD828DE"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/bureon/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    },
    {
        id = "tryon",
        name = "$arena_maps_tryon_name",
        description = "$arena_maps_tryon_description",
        credits = "burr/weturtle",
        thumbnail = "mods/evaisa.arena/content/arenas/tryon/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/tryon/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/tryon/Biome.xml",
                height_index="1",
                color="FFD828D1"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/tryon/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    },
}

cosmetics = {
    {
        id = "dunce_hat",
        name = "$arena_cosmetics_dunce_hat_name",
        description = "$arena_cosmetics_dunce_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/dunce_hat/icon.png",
        credits = "Evaisa",
        --sprite_sheet = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet.png",
        type = "hat",
        hat_offset = {x = 2, y = 5},
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
    }
}

cosmetic_types = {
    hat = {
        max_stack = 1, -- how many items of this type can be worn at the same time.
    }
}