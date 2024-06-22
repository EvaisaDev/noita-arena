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
}

cosmetics = {
    {
        id = "dunce_hat",
        name = "$arena_cosmetics_dunce_hat_name",
        description = "$arena_cosmetics_dunce_hat_description",
        icon = "mods/evaisa.arena/content/cosmetics/dunce_hat/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "dunce",
        sprite_offset = {x = 2, y = 5},
        sprite = "mods/evaisa.arena/content/cosmetics/dunce_hat/hat.png",
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
        name = "Gold Dust",
        description = "I LOVE SHINIES!!",
        icon = "mods/evaisa.arena/content/cosmetics/gold_dust/icon.png",
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
            local ent = EntityLoad("mods/evaisa.arena/content/cosmetics/gold_dust/gold_dust.xml")
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
        id = "shrek_mask",
        name = "Ogre Mask",
        description = "Unique cosmetic for Xytio.",
        icon = "mods/evaisa.arena/content/cosmetics/shrek/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "mask",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        sprite_offset = {x = 1, y = 1},
        sprite = "mods/evaisa.arena/content/cosmetics/shrek/shrek_mask.png",
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
        name = "Tanksy Hat",
        description = "Unique cosmetic for Tanksy.",
        icon = "mods/evaisa.arena/content/cosmetics/tanksy/icon.png",
        credits = "Evaisa",
        sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/tanksy/player_hat.xml",
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
        name = "Propeller Hat",
        description = "A propeller hat.",
        icon = "mods/evaisa.arena/content/cosmetics/propeller/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 3, y = 7},
        sprite = "mods/evaisa.arena/content/cosmetics/propeller/hat.xml",
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
        id = "fish_hat",
        name = "Joel",
        description = "[Unlocked by killing 15 players while wet]",
        icon = "mods/evaisa.arena/content/cosmetics/fish/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 4, y = 9},
        sprite = "mods/evaisa.arena/content/cosmetics/fish/hat2.xml",
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

                                GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock")), GameTextGetTranslatedOrNot(self.name))
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
        name = "Joel x2",
        description = "Unique cosmetic for Dexter.",
        icon = "mods/evaisa.arena/content/cosmetics/fish/iconx2.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 0, y = 9},
        --sprite = "mods/evaisa.arena/content/cosmetics/fish/hat2.xml",
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
                image_file="mods/evaisa.arena/content/cosmetics/fish/hat2.xml", 
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
                image_file="mods/evaisa.arena/content/cosmetics/fish/hat2.xml", 
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
        id = "fish_hat_2",
        name = "Suureväkäs",
        description = "[Unlocked by killing 30 players while wet]",
        icon = "mods/evaisa.arena/content/cosmetics/fish2/icon.png",
        credits = "Evaisa",
        --sprite_sheet_overlay = "mods/evaisa.arena/content/cosmetics/dunce_hat/sprite_sheet_overlay.png",
        type = "hat",
        sprite_offset = {x = 4, y = 9},
        sprite = "mods/evaisa.arena/content/cosmetics/fish2/fish_02.xml",
        sprite_animation = "walk",
        can_be_unlocked = true,
        can_be_purchased = true,
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

                                GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock")), GameTextGetTranslatedOrNot(self.name))
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
        name = "Party Hat",
        description = "It is your birthday today.",
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
        name = "Bowler Hat",
        description = "A bowler hat.",
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
    -- construction
    {
        id = "construction_hat",
        name = "Hard Hat",
        description = "Earthquakes are guaranteed.",
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
    -- crown
    {
        id = "crown_hat",
        name = "Crown",
        description = "[Unlocked by getting 10 wins]",
        icon = "mods/evaisa.arena/content/cosmetics/icons/crown.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 2, y = 2},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/crown.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            local unlock_flag = "cosmetic_unlocked_"..self.id
            if(not HasFlagPersistent(unlock_flag))then
                local wins = tonumber(ModSettingGet("ARENA_COSMETIC_CROWN_COUNTER")) or 0
                wins = wins + 1
                if(wins >= 10)then
                    AddFlagPersistent(unlock_flag)
                    ModSettingRemove("ARENA_COSMETIC_CROWN_COUNTER")

                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock")), GameTextGetTranslatedOrNot(self.name))
                end

                ModSettingSet("ARENA_COSMETIC_CROWN_COUNTER", wins)
            end
        end,
    },
    -- detective
    {
        id = "detective_hat",
        name = "Detective Hat",
        description = "What crime are we solving today?",
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
    -- ears
    {
        id = "ears_hat",
        name = "Fluffy Ears",
        description = "woahg they're so fluffy",
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
    -- elk_boss
    {
        id = "elk_boss_hat",
        name = "Tapion vasalli",
        description = "[Unlocked by getting a 5 winstreak.]",
        icon = "mods/evaisa.arena/content/cosmetics/icons/elk_boss.png",
        credits = "Evaisa",
        type = "hat",
        sprite_offset = {x = 5, y = 8},
        sprite = "mods/evaisa.arena/content/cosmetics/sprites/elk_boss.png",
        can_be_unlocked = true,
        can_be_purchased = false,
        unlocked_default = false,
        price = 0,
        on_win = function(self, lobby, data, entity, wins, winstreak) -- runs when player wins a round
            -- unlocks on a 5 winstreak
            if(winstreak >= 5)then
                local unlock_flag = "cosmetic_unlocked_"..self.id
                if(not HasFlagPersistent(unlock_flag))then
                    AddFlagPersistent(unlock_flag)
                    GamePrintImportant("$arena_cosmetic_unlock", string.format(GameTextGetTranslatedOrNot("$arena_cosmetic_hidden_unlock")), GameTextGetTranslatedOrNot(self.name))
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
        name = "Antlers",
        description = "A pair of magestic antlers.",
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
        name = "Flat Cap",
        description = "A flat cap.",
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
    -- grenade
    {
        id = "grenade_hat",
        name = "Kranuhiisi Mask",
        description = "Wear the flesh of your enemies!",
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
        name = "Parantajahiisi Mask",
        description = "Medic!",
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
        name = "Leprechaun Hat",
        description = "Where did I hide the gold again?",
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
        name = "Plumber Hat",
        description = "Legally distinct italian plumber hat.",
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
    -- pylon
    {
        id = "pylon_hat",
        name = "Pylon",
        description = "I drank the blood of some people, but the people were on drugs, and now I'm a wizaerd!",
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
        name = "Sheriff Hat",
        description = "Yeehaw!",
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
    -- sombrero
    {
        id = "sombrero_hat",
        name = "Sombrero",
        description = "Shades you from the hot sun.",
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
    -- straw hat
    {
        id = "straw_hat",
        name = "Straw Hat",
        description = "A hat made from straw, often used by farmers.",
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
        name = "Tiara",
        description = "A fancy tiara.",
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
        name = "Toimari Mask",
        description = "You the boss now.",
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
        id = "tophat_hat",
        name = "Top Hat",
        description = "A fancy top hat.",
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
    -- welder
    {
        id = "welder_hat",
        name = "Welding Mask",
        description = "Safety first.",
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
        name = "Wizard Hat",
        description = "Improves your magic by 0%",
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
        name = "Golden Amulet",
        description = "[Unlocked by vanilla requirements]",
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
        name = "Amulet of Yendor",
        description = "[Unlocked by vanilla requirements]",
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
        name = "Crown",
        description = "[Unlocked by vanilla requirements]",
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