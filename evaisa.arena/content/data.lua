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
            --LoadBackgroundSprite(steam_utils.getUserAvatar(steam_utils.getSteamID()), 0, 0)

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
            --LoadBackgroundSprite(steam_utils.getUserAvatar(steam_utils.getSteamID()), 0, 0)

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
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/vault_frozen.xml",
                height_index="1",
                color="FF566D91"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/biomes/allbiomes/fungiforest.xml",
                height_index="1",
                color="FFBB54A5"
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
--[[
{
    id = "static_tile_test",
    name = "Static Tile Test",
    description = "!!!",
    credits = "Evaisa",
    thumbnail = "mods/evaisa.arena/content/arenas/spoop/thumbnail.png",
    frame = "mods/evaisa.arena/content/arenas/frame.png",
    biome_map = "mods/evaisa.arena/content/arenas/test_static_tile/map.lua",
    custom_biomes = {
        {
            biome_filename="mods/evaisa.arena/content/arenas/test_static_tile/empty.xml",
            height_index="1",
            color="ff92b4cb"
        },
        {
            biome_filename="mods/evaisa.arena/content/arenas/test_static_tile/biome_mimics.xml",
            height_index="0",
            color="ff9b7dec"
        }
    },
    spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
        {x = 0, y = 0}
    },
    zone_size = 1150, -- size of damage zone, should be max distance from 0, 0 players can travel
    zone_floor = 600, -- damage floor, if player falls below this they die.
    update = function(self, lobby, data) -- Ran every frame while in the arena.
        local world_state = GameGetWorldStateEntity()
        local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
        
        ComponentSetValue2(world_state_component, "time", 0)
        ComponentSetValue2(world_state_component, "time_dt", 0)
    end,
},]]
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
    {
        id = "mimicstemple",
        name = "$arena_maps_mimicstemple_name",
        description = "$arena_maps_mimicstemple_description",
        credits = "Ydrec, Nolla Games",
        thumbnail = "mods/evaisa.arena/content/arenas/mimic_temple/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/mimic_temple/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/mimic_temple/empty.xml",
                height_index="1",
                color="ff92b4cb"
            },
            {
                biome_filename="mods/evaisa.arena/content/arenas/mimic_temple/biome_mimics.xml",
                height_index="0",
                color="ff9b7dec"
            }
        },
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 850, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 600, -- damage floor, if player falls below this they die.
        update = function(self, lobby, data) -- Ran every frame while in the arena.
            local world_state = GameGetWorldStateEntity()
            local world_state_component = EntityGetFirstComponentIncludingDisabled(world_state, "WorldStateComponent")
            
            ComponentSetValue2(world_state_component, "time", 0)
            ComponentSetValue2(world_state_component, "time_dt", 0)
        end,
    },
    {
        id = "foundry",
        name = "$arena_maps_foundry_name",
        description = "$arena_maps_foundry_description",
        credits = "Lord",
        thumbnail = "mods/evaisa.arena/content/arenas/foundry/thumbnail.png",
        frame = "mods/evaisa.arena/content/arenas/frame.png",
        biome_map = "mods/evaisa.arena/content/arenas/foundry/map.lua",
        custom_biomes = {
            {
                biome_filename="mods/evaisa.arena/content/arenas/foundry/foundry.xml",
                height_index="1",
                color="ff31f31a"
            }
        },
        pixel_scenes = "mods/evaisa.arena/content/arenas/foundry/scenes.xml",
        spawn_points = { -- optional, can also use spawn pixels, 0,0 is there as a backup in case spawn pixels fail somehow.
            {x = 0, y = 0}
        },
        zone_size = 600, -- size of damage zone, should be max distance from 0, 0 players can travel
        zone_floor = 400 -- damage floor, if player falls below this they die.
    }
}

cosmetics = {
    {
        id = "dunce_hat",
        name = "$arena_cosmetics_dunce_hat_name",
        description = "$arena_cosmetics_dunce_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "dunce",
        sprite_offset = {x = 2, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/hat.png",
        can_be_unlocked = false,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            if(GameHasFlagRun("dunce"))then
                local ready_count = ArenaGameplay.ReadyAmount(data, lobby)
                local total_count = ArenaGameplay.TotalPlayers(lobby)

                if((total_count > 1 and ready_count == (total_count - 1) and not GameHasFlagRun("ready_check")) or GameHasFlagRun("was_last_ready"))then
                    return true
                end
            end
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "gold_dust",
        name = "$arena_cosmetics_gold_dust_name",
        description = "$arena_cosmetics_gold_dust_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/gold_dust.png",
        credits = "Evaisa",
        type = "particles",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 3000,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            --[[local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198032563991"]]
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked

            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/particles/gold_dust.xml")
            EntityAddChild(entity, ent)

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == "gold_dust")then
                    EntityKill(child)
                end
            end
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "blue_fire",
        name = "$arena_cosmetics_blue_fire_name",
        description = "$arena_cosmetics_blue_fire_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/blue_fire.png",
        credits = "Evaisa",
        type = "particles",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2500,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            --[[local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198032563991"]]
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked

            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/particles/blue_fire.xml")
            EntityAddChild(entity, ent)

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == "fire_head")then
                    EntityKill(child)
                end
            end
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "trans_glitter",
        name = "$arena_cosmetics_trans_glitter_name",
        description = "$arena_cosmetics_trans_glitter_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/trans_glitter.png",
        credits = "Evaisa",
        type = "particles",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2500,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            --[[local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198032563991"]]
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked

            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/particles/trans_glitter.xml")
            EntityAddChild(entity, ent)

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == "trans_glitter")then
                    EntityKill(child)
                end
            end
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "haunted",
        name = "$arena_cosmetics_haunted_name",
        description = "$arena_cosmetics_haunted_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/haunted.png",
        credits = "Evaisa",
        type = "particles",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 3000,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            --[[local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198032563991"]]
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked

            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/particles/haunted.xml")
            EntityAddChild(entity, ent)

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == "haunted")then
                    EntityKill(child)
                end
            end
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "shrek_mask",
        name = "$arena_cosmetics_ogre_mask_name",
        description = "$arena_cosmetics_ogre_mask_description ",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/shrek/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "mask",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        sprite_offset = {x = 1, y = 1},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/shrek/shrek_mask.png",
        sprite_z = 0.41,
        price = 10,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561197991801655"
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "tanksy_hat",
        name = "$arena_cosmetics_tanksy_hat_name",
        description = "$arena_cosmetics_tanksy_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/overlay/tanksy/icon.png",
        credits = "Evaisa",
        sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/overlay/tanksy/player_hat.xml",
        type = "hat",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561197995188444"
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "propeller_hat",
        name = "$arena_cosmetics_propeller_hat_name",
        description = "$arena_cosmetics_propeller_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/propeller/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 3, y = 7},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/propeller/hat.xml",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "alias_mask",
        name = "$arena_cosmetics_alias_mask_name",
        description = "$arena_cosmetics_alias_mask_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/alias.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "mask",
        sprite_offset = {x = 10, y = 0},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/alias/sus.xml",
        sprite_scale = {x = 0.1, y = 0.1},
        sprite_only_inherit_position = true,
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198014921778"
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
            -- get entity with id
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == self.id)then
                    -- update scale
                    local x, y, r, s, s2 = EntityGetTransform(entity)
                    local mask_x, mask_y, mask_r = EntityGetTransform(child)

                    EntitySetTransform(child, mask_x, mask_y, mask_r, s * self.sprite_scale.x, s2 * self.sprite_scale.y)

                end
            end
        end,
    },
    {
        id = "fish_hat",
        name = "$arena_cosmetics_fish_hat_name",
        description = "$arena_cosmetics_fish_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/fish/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 4, y = 9},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/fish/hat2.xml",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_kill_func = true, -- Run kill func even when not worn
        always_run_win_func = false, -- Run Win func even when not worn
        price = 0,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
            --[[self.rotation = self.rotation or 0
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == self.id)then
                    print("found fish")
                    -- simulate rotating the fish by changing the width of the sprite
                    self.rotation = self.rotation + 0.05
                    local width = math.sin(self.rotation)
                    local x, y, r = EntityGetTransform(entity)
                    EntitySetTransform(child, x, y, r, width, 1)
                    
                end
            end]]
        end,
        on_kill = function(self, lobby, data, entity, killed_entity) -- runs when player kills another player
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local children = EntityGetAllChildren(entity)
                for k, v in ipairs(children or {}) do
                    -- if has GameEffectComponent
                    local game_effect_comp = EntityGetFirstComponentIncludingDisabled(v, "GameEffectComponent")
                    if(game_effect_comp ~= nil)then
                        -- check if has wet effect
                        local effect = ComponentGetValue2(game_effect_comp, "effect")
                        if(effect == "WET")then
                            -- check if has killed 15 players
                            local kills = tonumber(ModSettingGet("ARENA_COSMETIC_JOEL_COUNTER")) or 0
                        
                            kills = kills + 1
                            if(kills >= 15)then
                                AddFlagPersistent(unlock_flag)
                                ModSettingRemove("ARENA_COSMETIC_JOEL_COUNTER")

                                GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                            end

                            ModSettingSet("ARENA_COSMETIC_JOEL_COUNTER", kills)
                        end

                    end
                end
            end

        end,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
            
        end,
    },
    {
        id = "dexter_joel",
        name = "$arena_cosmetics_dexter_joel_name",
        description = "$arena_cosmetics_dexter_joel_description",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/fish/iconx2.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 0, y = 9},
        --sprite = "mods/evaisa.arena/content/cosmetics/sprites/fish/hat2.xml",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_kill_func = true, -- Run kill func even when not worn
        always_run_win_func = false, -- Run Win func even when not worn
        price = 0,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            local steam_id = steam_utils.getSteamID()
            
            local id = tostring(steam_id)

            return id == "76561198032563991"
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local cosmetic = self

            local offset_x, offset_y = 0, 0
            if(cosmetic.sprite_offset)then
                offset_x = cosmetic.sprite_offset.x or 0
                offset_y = cosmetic.sprite_offset.y or 0
            end

            -- joel 1
            local hat_entity = EntityCreateNew(cosmetic.id)
            local hotspot = "hat"
            if(cosmetic.hotspot)then
                hotspot = cosmetic.hotspot
            end
            EntityAddChild(entity, hat_entity)
            EntityAddComponent2(hat_entity, "SpriteComponent", {
                _tags="character",
                alpha=1, 
                image_file="mods/evaisa.arena/content/cosmetics/sprites/fish/hat2.xml", 
                next_rect_animation=cosmetic.sprite_animation or "", 
                offset_x=offset_x, 
                offset_y=offset_y, 
                rect_animation=cosmetic.sprite_animation or "",
                z_index=0.4,
            })
            EntityAddComponent2(hat_entity, "SpriteAnimatorComponent")
            --[[EntityAddComponent2(hat_entity, "InheritTransformComponent", {
                parent_hotspot_tag=hotspot,
                only_position=true
            })]]

            -- joel 2
            local hat_entity2 = EntityCreateNew(cosmetic.id)
            local hotspot2 = "hat"
            if(cosmetic.hotspot)then
                hotspot2 = cosmetic.hotspot
            end
            EntityAddChild(entity, hat_entity2)
            EntityAddComponent2(hat_entity2, "SpriteComponent", {
                _tags="character",
                alpha=1, 
                image_file="mods/evaisa.arena/content/cosmetics/sprites/fish/hat2.xml", 
                next_rect_animation=cosmetic.sprite_animation or "", 
                offset_x=offset_x+9, 
                offset_y=offset_y, 
                rect_animation=cosmetic.sprite_animation or "",
                z_index=0.4,
            })
            EntityAddComponent2(hat_entity2, "SpriteAnimatorComponent")
            --[[EntityAddComponent2(hat_entity2, "InheritTransformComponent", {
                parent_hotspot_tag=hotspot2,
                only_position=true
            })]]

            -- invert scale w on second joel
            local x, y, r = EntityGetTransform(hat_entity2)
            EntitySetTransform(hat_entity2, x, y, r, -1, 1)
    
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == self.id)then
                    EntityKill(child)
                end
            end
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
            local joels = {}
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == self.id)then
                    table.insert(joels, child)
                end
            end

            local x, y = EntityGetHotspot(entity, "hat", true, true)
            for k, v in ipairs(joels) do
                local offset = 0
                if(k == 2)then
                    offset = 9
                end
                EntitySetTransform(v, x + offset - 9, y, 0)
            end
        end,
    },
    {
        id = "fish_hat_red",
        name = "$arena_cosmetics_fish_hat_2_name",
        description = "$arena_cosmetics_fish_hat_2_description",
        icon = "mods/evaisa.arena/content/cosmetics/sprites/fish2/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/sprites/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 4, y = 9},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/fish2/fish_02.xml",
        sprite_animation = "walk",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_kill_func = true, -- Run kill func even when not worn
        always_run_win_func = false, -- Run Win func even when not worn
        price = 0,
        try_unlock = function(self, lobby, data) -- runs every frame, if true, unlock flag is added
            return false
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
            --[[self.rotation = self.rotation or 0
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == self.id)then
                    print("found fish")
                    -- simulate rotating the fish by changing the width of the sprite
                    self.rotation = self.rotation + 0.05
                    local width = math.sin(self.rotation)
                    local x, y, r = EntityGetTransform(entity)
                    EntitySetTransform(child, x, y, r, width, 1)
                    
                end
            end]]
        end,
        on_kill = function(self, lobby, data, entity, killed_entity) -- runs when player kills another player
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local children = EntityGetAllChildren(entity)
                for k, v in ipairs(children or {}) do
                    -- if has GameEffectComponent
                    local game_effect_comp = EntityGetFirstComponentIncludingDisabled(v, "GameEffectComponent")
                    if(game_effect_comp ~= nil)then
                        -- check if has wet effect
                        local effect = ComponentGetValue2(game_effect_comp, "effect")
                        if(effect == "WET")then
                            -- check if has killed 15 players
                            local kills = tonumber(ModSettingGet("ARENA_COSMETIC_JOEL_COUNTER2")) or 0
                        
                            kills = kills + 1
                            if(kills >= 30)then
                                AddFlagPersistent(unlock_flag)
                                ModSettingRemove("ARENA_COSMETIC_JOEL_COUNTER2")

                                GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                            end

                            ModSettingSet("ARENA_COSMETIC_JOEL_COUNTER2", kills)
                        end

                    end
                end
            end

        end,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
            
        end,
    },
    -- bithday
    {
        id = "birthday_hat",
        name = "$arena_cosmetics_birthday_hat_name",
        description = "$arena_cosmetics_birthday_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/birthday.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/birthday.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
    },
    -- bowler
    {
        id = "bowler_hat",
        name = "$arena_cosmetics_bowler_hat_name",
        description = "$arena_cosmetics_bowler_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/bowler.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/bowler.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- bowler_brown
    {
        id = "bowler_hat_brown",
        name = "$arena_cosmetics_bowler_hat_brown_name",
        description = "$arena_cosmetics_bowler_hat_brown_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/bowler_brown.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/bowler_brown.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- bowler_green
    {
        id = "bowler_hat_green",
        name = "$arena_cosmetics_bowler_hat_green_name",
        description = "$arena_cosmetics_bowler_hat_green_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/bowler_green.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/bowler_green.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- bowler_pink
    {
        id = "bowler_hat_pink",
        name = "$arena_cosmetics_bowler_hat_pink_name",
        description = "$arena_cosmetics_bowler_hat_pink_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/bowler_pink.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/bowler_pink.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- bowler_red
    {
        id = "bowler_hat_red",
        name = "$arena_cosmetics_bowler_hat_red_name",
        description = "$arena_cosmetics_bowler_hat_red_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/bowler_red.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/bowler_red.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- construction
    {
        id = "construction_hat",
        name = "$arena_cosmetics_construction_hat_name",
        description = "$arena_cosmetics_construction_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/construction.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/construction.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
    },
    -- construction_blue
    {
        id = "construction_hat_blue",
        name = "$arena_cosmetics_construction_hat_blue_name",
        description = "$arena_cosmetics_construction_hat_blue_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/construction_blue.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/construction_blue.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
    },
    -- construction_white
    {
        id = "construction_hat_white",
        name = "$arena_cosmetics_construction_hat_white_name",
        description = "$arena_cosmetics_construction_hat_white_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/construction_white.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/construction_white.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
    },
    -- crown
    {
        id = "crown_hat",
        name = "$arena_cosmetics_crown_hat_name",
        description = "$arena_cosmetics_crown_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/crown.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_win_func = true,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local wins = tonumber(ModSettingGet("ARENA_COSMETIC_CROWN_COUNTER")) or 0
                wins = wins + 1
                if(wins >= 10)then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                end

                ModSettingSet("ARENA_COSMETIC_CROWN_COUNTER", wins)
            end
        end,
    },
    -- crown tier 2
    {
        id = "crown_hat_2",
        name = "$arena_cosmetics_crown_hat_2_name",
        description = "$arena_cosmetics_crown_hat_2_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown_tier2.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/crown_tier2.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_win_func = true,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                print("win")
                local wins = tonumber(ModSettingGet("ARENA_COSMETIC_CROWN_COUNTER")) or 0
                wins = wins + 1
                if(wins >= 20)then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                end

                ModSettingSet("ARENA_COSMETIC_CROWN_COUNTER", wins)
            end
        end,
    },
    -- crown tier 3
    {
        id = "crown_hat_3",
        name = "$arena_cosmetics_crown_hat_3_name",
        description = "$arena_cosmetics_crown_hat_3_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown_tier3.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/crown_tier3.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_win_func = true,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local wins = tonumber(ModSettingGet("ARENA_COSMETIC_CROWN_COUNTER")) or 0
                wins = wins + 1
                if(wins >= 30)then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                end

                ModSettingSet("ARENA_COSMETIC_CROWN_COUNTER", wins)
            end
        end,
    },
    -- crown tier 4
    {
        id = "crown_hat_4",
        name = "$arena_cosmetics_crown_hat_4_name",
        description = "$arena_cosmetics_crown_hat_4_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown_tier4.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 6},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/crown_tier4.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_win_func = true,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local wins = tonumber(ModSettingGet("ARENA_COSMETIC_CROWN_COUNTER")) or 0
                wins = wins + 1
                if(wins >= 40)then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                end

                ModSettingSet("ARENA_COSMETIC_CROWN_COUNTER", wins)
            end
        end,
    },
    -- detective
    {
        id = "detective_hat",
        name = "$arena_cosmetics_detective_hat_name",
        description = "$arena_cosmetics_detective_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/detective.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/detective.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- detective_black
    {
        id = "detective_hat_black",
        name = "$arena_cosmetics_detective_hat_black_name",
        description = "$arena_cosmetics_detective_hat_black_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/detective_black.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/detective_black.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- detective_green
    {
        id = "detective_hat_green",
        name = "$arena_cosmetics_detective_hat_green_name",
        description = "$arena_cosmetics_detective_hat_green_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/detective_green.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/detective_green.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 300,
    },
    -- ears
    {
        id = "ears_hat",
        name = "$arena_cosmetics_ears_hat_name",
        description = "$arena_cosmetics_ears_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/ears.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 1, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/ears.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 200,
    },
    -- ears_black
    {
        id = "ears_hat_black",
        name = "$arena_cosmetics_ears_hat_black_name",
        description = "$arena_cosmetics_ears_hat_black_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/ears_black.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 1, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/ears_black.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 200,
    },
    -- ears_blue
    {
        id = "ears_hat_blue",
        name = "$arena_cosmetics_ears_hat_blue_name",
        description = "$arena_cosmetics_ears_hat_blue_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/ears_blue.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 1, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/ears_blue.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 200,
    },
    -- ears_brown
    {
        id = "ears_hat_brown",
        name = "$arena_cosmetics_ears_hat_brown_name",
        description = "$arena_cosmetics_ears_hat_brown_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/ears_brown.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 1, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/ears_brown.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 200,
    },
    -- ears_pink
    {
        id = "ears_hat_pink",
        name = "$arena_cosmetics_ears_hat_pink_name",
        description = "$arena_cosmetics_ears_hat_pink_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/ears_pink.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 1, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/ears_pink.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 200,
    },
    -- elk_boss
    {
        id = "elk_boss_hat",
        name = "$arena_cosmetics_elk_boss_hat_name",
        description = "$arena_cosmetics_elk_boss_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/elk_boss.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 5, y = 8},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/elk_boss.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        always_run_win_func = true,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            -- unlocks on a 5 winstreak
            if(winstreak >= 5)then
                local unlock_flag = "cosmetic_unlocked_"..self.id
                if(not HasFlagPersistent(unlock_flag))then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock"), GameTextGetTranslatedOrNot(self.name)))
                end
            end
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/particles/elk_boss.xml")
            EntityAddChild(entity, ent)

        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
            local children = EntityGetAllChildren(entity)
            for _, child in ipairs(children or {}) do
                if(EntityGetName(child) == "deer_sparkles")then
                    EntityKill(child)
                end
            end
        end,
    },
    -- elk
    {
        id = "elk_hat",
        name = "$arena_cosmetics_elk_hat_name",
        description = "$arena_cosmetics_elk_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/elk.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 5, y = 8},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/elk.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- flatcap
    {
        id = "flatcap_hat",
        name = "$arena_cosmetics_flatcap_hat_name",
        description = "$arena_cosmetics_flatcap_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/flatcap.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/flatcap.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 250,
    },
    -- flatcap_black
    {
        id = "flatcap_hat_black",
        name = "$arena_cosmetics_flatcap_hat_black_name",
        description = "$arena_cosmetics_flatcap_hat_black_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/flatcap_black.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/flatcap_black.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 250,
    },
    -- flatcap_blue
    {
        id = "flatcap_hat_blue",
        name = "$arena_cosmetics_flatcap_hat_blue_name",
        description = "$arena_cosmetics_flatcap_hat_blue_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/flatcap_blue.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/flatcap_blue.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 250,
    },
    -- flatcap_grey
    {
        id = "flatcap_hat_grey",
        name = "$arena_cosmetics_flatcap_hat_grey_name",
        description = "$arena_cosmetics_flatcap_hat_grey_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/flatcap_grey.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/flatcap_grey.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 250,
    },
    -- grenade
    {
        id = "grenade_hat",
        name = "$arena_cosmetics_grenade_hat_name",
        description = "$arena_cosmetics_grenade_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/grenade.png",
        credits = "Evaisa",
        type = "mask",
        sprite_offset = {x = 1, y = 1},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/grenade.png",
        sprite_z = 0.41,
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- healer
    {
        id = "healer_hat",
        name = "$arena_cosmetics_healer_hat_name",
        description = "$arena_cosmetics_healer_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/healer.png",
        credits = "Evaisa",
        type = "mask",
        sprite_offset = {x = 1, y = 1},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/healer.png",
        sprite_z = 0.41,
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 500,
    },
    -- leprechaun
    {
        id = "leprechaun_hat",
        name = "$arena_cosmetics_leprechaun_hat_name",
        description = "$arena_cosmetics_leprechaun_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/leprechaun.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 9},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/leprechaun.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 500,
    },
    -- plumber
    {
        id = "plumber_hat",
        name = "$arena_cosmetics_plumber_hat_name",
        description = "$arena_cosmetics_plumber_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/plumber.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/plumber.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- plumber_green
    {
        id = "plumber_hat_green",
        name = "$arena_cosmetics_plumber_hat_green_name",
        description = "$arena_cosmetics_plumber_hat_green_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/plumber_green.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/plumber_green.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- plumber_purple
    {
        id = "plumber_hat_purple",
        name = "$arena_cosmetics_plumber_hat_purple_name",
        description = "$arena_cosmetics_plumber_hat_purple_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/plumber_purple.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/plumber_purple.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- plumber_yellow
    {
        id = "plumber_hat_yellow",
        name = "$arena_cosmetics_plumber_hat_yellow_name",
        description = "$arena_cosmetics_plumber_hat_yellow_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/plumber_yellow.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/plumber_yellow.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 400,
    },
    -- pylon
    {
        id = "pylon_hat",
        name = "$arena_cosmetics_pylon_hat_name",
        description = "$arena_cosmetics_pylon_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/pylon.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/pylon.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 600,
    },
    -- sheriff
    {
        id = "sheriff_hat",
        name = "$arena_cosmetics_sheriff_hat_name",
        description = "$arena_cosmetics_sheriff_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/sheriff.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 4, y = 7},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/sheriff.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 600,
    },
    -- sheriff_black
    {
        id = "sheriff_hat_black",
        name = "$arena_cosmetics_sheriff_hat_black_name",
        description = "$arena_cosmetics_sheriff_hat_black_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/sheriff_black.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 4, y = 7},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/sheriff_black.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 600,
    },
    -- sombrero
    {
        id = "sombrero_hat",
        name = "$arena_cosmetics_sombrero_hat_name",
        description = "$arena_cosmetics_sombrero_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/sombrero.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 4, y = 5 },
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/sombrero.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 600,
    },
    -- sombrero_alt
    {
        id = "sombrero_hat_alt",
        name = "$arena_cosmetics_sombrero_hat_alt_name",
        description = "$arena_cosmetics_sombrero_hat_alt_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/sombrero_alt.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 4, y = 5 },
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/sombrero_alt.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 600,
    },
    -- straw hat
    {
        id = "straw_hat",
        name = "$arena_cosmetics_straw_hat_name",
        description = "$arena_cosmetics_straw_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/strawhat.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/strawhat.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 150,
    },
    -- tiara
    {
        id = "tiara_hat",
        name = "$arena_cosmetics_tiara_hat_name",
        description = "$arena_cosmetics_tiara_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tiara.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 3},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tiara.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 1500,
    },
    -- toimari
    {
        id = "toimari_hat",
        name = "$arena_cosmetics_toimari_hat_name",
        description = "$arena_cosmetics_toimari_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/toimari.png",
        credits = "Evaisa",
        type = "mask",
        sprite_offset = {x = 6, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/toimari.png",
        sprite_z = 0.41,
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2500,
    },
    -- tophat
    {
        id = "tophat",
        name = "$arena_cosmetics_tophat_name",
        description = "$arena_cosmetics_tophat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- tophat_blue_band
    {
        id = "tophat_blue_band",
        name = "$arena_cosmetics_tophat_blue_band_name",
        description = "$arena_cosmetics_tophat_blue_band_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat_blue_band.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat_blue_band.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- tophat_green_band
    {
        id = "tophat_green_band",
        name = "$arena_cosmetics_tophat_green_band_name",
        description = "$arena_cosmetics_tophat_green_band_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat_green_band.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat_green_band.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- tophat_purple_band
    {
        id = "tophat_purple_band",
        name = "$arena_cosmetics_tophat_purple_band_name",
        description = "$arena_cosmetics_tophat_purple_band_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat_purple_band.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat_purple_band.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- tophat_brown
    {
        id = "tophat_brown",
        name = "$arena_cosmetics_tophat_brown_name",
        description = "$arena_cosmetics_tophat_brown_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat_brown.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat_brown.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- tophat_purple
    {
        id = "tophat_purple",
        name = "$arena_cosmetics_tophat_purple_name",
        description = "$arena_cosmetics_tophat_purple_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/tophat_purple.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 4},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/tophat_purple.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 2000,
    },
    -- welder
    {
        id = "welder_hat",
        name = "$arena_cosmetics_welder_hat_name",
        description = "$arena_cosmetics_welder_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/welder.png",
        credits = "Evaisa",
        type = "mask",
        sprite_offset = {x = 1, y = 0},
        sprite_z = 0.41,
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/welder.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 500,
    },
    -- wizard
    {
        id = "wizard_hat",
        name = "$arena_cosmetics_wizard_hat_name",
        description = "$arena_cosmetics_wizard_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/wizard.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 3, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/wizard.png",
        can_be_unlocked = true,
        can_be_purchased = true,
        unlocked_default = false,
        price = 1000,
    },
    -- amulet
    {
        id = "amulet",
        name = "$arena_cosmetics_amulet_name",
        description = "$arena_cosmetics_amulet_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/amulet.png",
        credits = "Evaisa",
        sprite_sheet_overlay = "data/enemies_gfx/player_amulet.xml",
        overlay_z = 0.59,
        type = "amulet",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            return HasFlagPersistent( "secret_amulet" )
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "amulet_gem",
        name = "$arena_cosmetics_amulet_gem_name",
        description = "$arena_cosmetics_amulet_gem_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/amulet_gem.png",
        credits = "Evaisa",
        sprite_sheet_overlay = "data/enemies_gfx/player_amulet_gem.xml",
        overlay_z = 0.58,
        type = "amulet",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            return HasFlagPersistent( "secret_amulet_gem" )
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
    {
        id = "crown_secret",
        name = "$arena_cosmetics_crown_secret_name",
        description = "$arena_cosmetics_crown_secret_description",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown_secret.png",
        credits = "Evaisa",
        sprite_sheet_overlay = "data/enemies_gfx/player_hat2.xml",
        overlay_z = 0.58,
        type = "hat",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        try_unlock = function(lobby, data) -- runs every frame, if true, unlock flag is added
            return HasFlagPersistent( "secret_hat" )
        end,
        try_force_enable = function(self, lobby, data) -- if this condition is true, the cosmetic will be enabled even if it's not unlocked
            return false
        end,
        on_update = function(self, lobby, data, entity) -- runs every frame while hat is worn
        end,
        on_load = function(self, lobby, data, entity) -- runs when cosmetic is loaded, can be used to load entities etc.
        end,
        on_unload = function(self, lobby, data, entity) -- runs when cosmetic is unloaded, can be used to unload entities etc.
        end,
        on_arena_unlocked = function(self, lobby, data, entity) -- runs when player is unlocked in arena.
        end,
    },
}

cosmetic_types = {
    dunce = {
        max_stack = 1,
    },
    hat = {
        max_stack = 1,
    },
    particles = {
        max_stack = 3,
    },
    mask = {
        max_stack = 1,
    },
    amulet = {
        max_stack = 2,
    }
}