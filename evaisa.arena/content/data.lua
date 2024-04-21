local function moveClouds(bank)
    local world_state = EntityGetFirstComponent( GameGetWorldStateEntity(), "WorldStateComponent" )
    local wind_speed = ComponentGetValue2( world_state, "wind_speed" )
    local time_dt = ComponentGetValue2( world_state, "time_dt" )
  
    if bank.state.cloundx1 ~= nil then
      bank.state.cloundx1 = bank.state.cloundx1 - wind_speed * 0.000017 * time_dt
      local clound1 = bank:getLayerById("clound1")
      clound1.offset_x = bank.state.cloundx1
    end
  
    if bank.state.cloundx2 ~= nil then
      bank.state.cloundx2 = bank.state.cloundx2 - wind_speed * 0.0000255 * time_dt
      local clound2 = bank:getLayerById("clound2")
      clound2.offset_x = bank.state.cloundx2
    end
end

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
        parallax_textures = {
            "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_01.png",
            "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_02.png",
            "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_02.png",
            "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_layer_01.png",
            "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_layer_02.png",
            "mods/evaisa.arena/files/scripts/parallax/tex/sky_colors_day.png",
        }, -- insert parallax textures into here, you will not be able to use custom parallax textures without this, note parallax works across all arenas so no need to reregister.
        parallax_layers = 7, -- total parallax layers, used to figure out the max layers needed. Note: going past 8 will cause the shaders to fail o intel Xe graphics cards.
        init = function(self) -- called when the gamemode is loaded, this is before even entering a lobby, can be used for doing pre-init stuff.

        end,
        load = function(self, lobby, data) -- called when the arena is loaded, can be used for setting up the arena.
            --LoadBackgroundSprite(steam_utils.getUserAvatar(steam.user.getSteamID()), 0, 0)

            -- custom parallax stuff!!
            if(Parallax)then
                local mountains = Parallax.getBankTemplate() -- initializing a custom parallax background.
                mountains.id = "original"
                mountains.layers = {
                    {id = "clound1", path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_01.png",
                        offset_y = 0.3894, depth = 0.94, sky_blend = 1.0, sky_index = Parallax.SKY_DEFAULT.CLOUDS_1
                    },
                    {id = "mountain02", path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_02.png",
                        offset_y = 0.3894,  depth = 0.9245, sky_blend = 1.0, sky_index = Parallax.SKY_DEFAULT.MOUNTAIN_2,
                    },
                    {id = "clound2", path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_02.png",
                        offset_y = 0.3894, depth = 0.9, sky_blend = 1.0, sky_index = Parallax.SKY_DEFAULT.CLOUDS_2
                    },
                    {id = "mountainLayer2", path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_layer_02.png",
                        offset_y = 0.37569,  depth = 0.87918, sky_blend = 1.0, sky_index = Parallax.SKY_DEFAULT.MOUNTAIN_1_BACK
                    },
                    {id = "mountainLayer1", path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_mountains_layer_01.png",
                        offset_y = 0.37569,  depth = 0.87918, sky_blend = 1.0, sky_index = Parallax.SKY_DEFAULT.MOUNTAIN_1_HIGHLIGHT
                    },
                }
                mountains.sky.path = "mods/evaisa.arena/files/scripts/parallax/tex/sky_colors_day.png"

                mountains.state = { 
                    cloundx1 = 0,
                    cloundx2 = 0,
                }
                mountains.update = moveClouds

                Parallax.push(mountains, 30)
            end
        end,
        unload = function(self, lobby, data) -- called when the arena is unloaded.

        end,
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 1)
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
        zone_floor = 400, -- damage floor, if player falls below this they die.
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
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
        parallax_layers = 7, -- total parallax layers, used to figure out the max layers needed. Note: going past 8 will cause the shaders to fail o intel Xe graphics cards.
        parallax_textures = {
            "mods/evaisa.arena/content/arenas/stadium/parallax/ocean1t.png",
            "mods/evaisa.arena/content/arenas/stadium/parallax/ocean2t.png",
            "mods/evaisa.arena/content/arenas/stadium/parallax/ocean3t.png",
            "mods/evaisa.arena/content/arenas/stadium/parallax/ocean4.png",
            "mods/evaisa.arena/content/arenas/stadium/parallax/ocean5.png",
            "mods/evaisa.arena/content/arenas/stadium/parallax/sky_colors.png",
        }, -- insert parallax textures into here, you will not be able to use custom parallax textures without this, note parallax works across all arenas so no need to reregister.
        load = function(self, lobby, data) -- called when the arena is loaded, can be used for setting up the arena.
            --LoadBackgroundSprite(steam_utils.getUserAvatar(steam.user.getSteamID()), 0, 0)

            -- custom parallax stuff!!
            if(Parallax)then
                local ocean = Parallax.getBankTemplate() -- initializing a custom parallax background.
                ocean.id = "original"
                ocean.layers = {
                    {
                        id = "clound1", 
                        path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_01.png",
                        offset_y = 0.4894, 
                        depth = 0.81, 
                        sky_blend = 0.9, 
                        sky_index = Parallax.SKY_DEFAULT.CLOUDS_1
                    },
                    {
                        id = "clound2", 
                        path = "mods/evaisa.arena/files/scripts/parallax/tex/demo/parallax_clounds_02.png",
                        offset_y = 0.4894, 
                        depth = 0.802, 
                        sky_blend = 0.9, 
                        sky_index = Parallax.SKY_DEFAULT.CLOUDS_2
                    },
                    {
                        id = "ocean1", 
                        path = "mods/evaisa.arena/content/arenas/stadium/parallax/ocean1t.png",
                        offset_y = 0.18,  
                        depth = 0.8, 
                        sky_blend = 0.93, 
                        sky_index = 8,
                    },
                    {
                        id = "ocean2", 
                        path = "mods/evaisa.arena/content/arenas/stadium/parallax/ocean2t.png",
                        offset_y = 0.2,  
                        depth = 0.78, 
                        sky_blend = 0.93, 
                        sky_index = 8,
                    },
                    {
                        id = "ocean3", 
                        path = "mods/evaisa.arena/content/arenas/stadium/parallax/ocean3t.png",
                        offset_y = 0.2,  
                        depth = 0.76, 
                        sky_blend = 0.93, 
                        sky_index = 8,
                    },
                    {
                        id = "ocean4", 
                        path = "mods/evaisa.arena/content/arenas/stadium/parallax/ocean4.png",
                        offset_y = 0.2,  
                        depth = 0.74, 
                        sky_blend = 0.93, 
                        sky_index = 8,
                    },
                    {
                        id = "ocean5", 
                        path = "mods/evaisa.arena/content/arenas/stadium/parallax/ocean5.png",
                        offset_y = 0.2,  
                        depth = 0.72, 
                        sky_blend = 0.93, 
                        sky_index = 8,
                    }
                }
                ocean.sky.path = "mods/evaisa.arena/content/arenas/stadium/parallax/sky_colors.png"

                ocean.state = { 
                    cloundx1 = 0,
                    cloundx2 = 0,
                    wavex1 = 0,
                    wavex2 = 0,
                    wavex3 = 0,
                    wavex4 = 0,
                    wavex5 = 0,
                    time = 0,
                }

                local function moveWaves(bank)
                    local world_state = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
                    local wind_speed = ComponentGetValue2(world_state, "wind_speed")
                    local time_dt = ComponentGetValue2(world_state, "time_dt")

                    bank.state.time = bank.state.time + time_dt

                    if bank.state.wavex1 ~= nil then
                        -- move in sine wave left and right
                        local wave_speed = 0.001 -- adjust the wave speed as needed
                        local wave_amplitude = 0.1 -- adjust the wave amplitude as needed

                        bank.state.wavex1 = math.sin(bank.state.time * wave_speed) * wave_amplitude
                        bank.state.wavex2 = math.sin(bank.state.time * wave_speed + 1) * wave_amplitude
                        bank.state.wavex3 = math.sin(bank.state.time * wave_speed + 2) * wave_amplitude
                        bank.state.wavex4 = math.sin(bank.state.time * wave_speed + 3) * wave_amplitude
                        bank.state.wavex5 = math.sin(bank.state.time * wave_speed + 4) * wave_amplitude

                        local ocean1 = bank:getLayerById("ocean1")
                        ocean1.offset_x = bank.state.wavex1
                        local ocean2 = bank:getLayerById("ocean2")
                        ocean2.offset_x = bank.state.wavex2
                        local ocean3 = bank:getLayerById("ocean3")
                        ocean3.offset_x = bank.state.wavex3
                        local ocean4 = bank:getLayerById("ocean4")
                        ocean4.offset_x = bank.state.wavex4
                        local ocean5 = bank:getLayerById("ocean5")
                        ocean5.offset_x = bank.state.wavex5
                    end
                end

                ocean.update = function(bank) 
                    moveClouds(bank)

                    moveWaves(bank)

                end

                Parallax.push(ocean, 30)
            end
        end,
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0.5)
            ComponentSetValue2(world_state_component, "time_dt", 1)
        end,
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
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
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
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
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
        zone_floor = 400, -- damage floor, if player falls below this they die.
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
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
        zone_floor = 400, -- damage floor, if player falls below this they die.
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
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