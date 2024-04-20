local genomes = dofile("mods/evaisa.arena/files/scripts/utilities/genomes.lua")

genomes:start()
genomes:add("pvp", 0, 0, 0, {})
genomes:add("pvp_client", 0, 0, 0, {})
genomes:finish()

popup = dofile("mods/evaisa.arena/lib/popup.lua")


--[[
local post_final = ModTextFileGetContent("data/shaders/post_final.frag")

post_final = string.gsub(post_final, "const bool ENABLE_LIGHTING	    		= 1>0;", "const bool ENABLE_LIGHTING	    		= 1<0;")

ModTextFileSetContent("data/shaders/post_final.frag", post_final)
]]

ModMaterialsFileAdd("mods/evaisa.arena/files/materials.xml")
ModMagicNumbersFileAdd("mods/evaisa.arena/files/magic.xml")
ModLuaFileAppend("data/scripts/gun/procedural/gun_procedural.lua", "mods/evaisa.arena/files/scripts/append/gun_procedural.lua")
ModLuaFileAppend("data/scripts/gun/gun.lua", "mods/evaisa.arena/files/scripts/append/gun.lua")
ModLuaFileAppend("data/scripts/perks/perk_list.lua", "mods/evaisa.arena/files/scripts/append/perk_fix.lua")
ModLuaFileAppend("data/scripts/perks/perk.lua", "mods/evaisa.arena/files/scripts/append/perk.lua")
ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/evaisa.arena/files/scripts/append/action_fix.lua")
ModLuaFileAppend("data/scripts/magic/fungal_shift.lua", "mods/evaisa.arena/files/scripts/append/fungal_shift.lua")
ModLuaFileAppend("data/scripts/item_spawnlists.lua", "mods/evaisa.arena/files/scripts/append/custom_item_spawns.lua")
ModLuaFileAppend("data/scripts/perks/perk_reroll.lua", "mods/evaisa.arena/files/scripts/append/perk_reroll.lua")

--[[
parse_overrides = function(overrides, path)
    path = path or ""

    for k, v in pairs(overrides)do
        if(type(v) == "table")then
            parse_overrides(v, path .. "/" .. k)
        elseif(type(v) == "string")then
            local data_path = path .. "/" .. v

            print("Overriding: " .. data_path)

            local content = ModTextFileGetContent("mods/evaisa.arena/data_override"..data_path)
            if(content ~= nil)then
                print("Setting content of (".."data"..data_path..") to \n"..content)

                ModTextFileSetContent("data"..data_path, content)

            end
        end
    end
end

local overrides = dofile_once("mods/evaisa.arena/data_override/override_list.lua")
parse_overrides(overrides)]]

function OnModPreInit()

    ------ TRANSLATIONS -------

    dofile("mods/evaisa.arena/lib/translations.lua")

    register_localizations("mods/evaisa.arena/translations.csv", 2)

    ---------------------------

end

function OnModPostInit()
    if(ModIsEnabled("evaisa.mp"))then
        ModLuaFileAppend("mods/evaisa.mp/data/gamemodes.lua", "mods/evaisa.arena/files/scripts/gamemode/main.lua")
    end
end

function IsPaused()
	return GameHasFlagRun("game_paused_arena")
end

function OnPausedChanged(paused, is_wand_pickup)
	if (paused) then
		GameAddFlagRun("game_paused_arena")
		--GamePrint("paused")
	else
		GameRemoveFlagRun("game_paused_arena")
		--GamePrint("unpaused")
	end
end

local warning_shown_mp = false
local warning_shown_save = false
local ready = false

function OnWorldPreUpdate()
    if(not ready)then
       --print("not ready")
        return
    end

    --print("world pre update")

	if (not IsPaused()) then
		popup.update()
	end

    if(not ModIsEnabled("evaisa.mp") and not warning_shown_mp)then
        warning_shown_mp = true
        print("showing mp warning")
        popup.create("mp_warning", "$arena_mp_missing_warning", {
            "$arena_mp_missing_warning_description",
            "$arena_mp_missing_warning_description_2",
        }, {
        }, -6000)
    end

    if(GameHasFlagRun("mp_blocked_load") and not warning_shown_save)then
        warning_shown_save = true
        print("showing save warning")
        popup.create("save_warning", "$arena_save_warning", {
            "$arena_save_warning_description",
            "$arena_save_warning_description_2",
        }, {
        }, -6000)
    end
end


function OnMagicNumbersAndWorldSeedInitialized()

    
    GameAddFlagRun("no_progress_flags_perk")
    GameAddFlagRun("no_progress_flags_action")
    GameAddFlagRun("no_progress_flags_animal")

    dofile("mods/evaisa.arena/content/data.lua")
    local nxml = dofile("mods/evaisa.arena/lib/nxml.lua")
    
    --print("wharrrrr???")

    local biome_list = nxml.parse(ModTextFileGetContent("data/biome/_biomes_all.xml"))
    for k, v in pairs(arena_list)do
        if(v.custom_biomes ~= nil)then
            for k2, v2 in ipairs(v.custom_biomes)do
                --print("[evaisa.arena] Adding biome: "..v2.biome_filename)
                biome_list:add_child(nxml.parse([[<Biome biome_filename="]]..v2.biome_filename..[[" height_index="]]..v2.height_index..[[" color="]]..v2.color..[["/>]]))
            end
        end
    end

    --print(tostring(biome_list))

    ModTextFileSetContent("data/biome/_biomes_all.xml", tostring(biome_list))


    


    --print("Init content: \n"..ModTextFileGetContent("data/scripts/init.lua"))
    --print("Biome mod content: \n"..ModTextFileGetContent("data/scripts/biome_modifiers.lua"))
end

function OnPlayerSpawned(player)

    print("Player spawned??")

    EntityKill(player)

    GameRemoveFlagRun("game_paused_arena")

    ready = true
    if(GameHasFlagRun("loaded_from_save"))then
        GameAddFlagRun("mp_blocked_load")
        return
    end


    GameAddFlagRun("loaded_from_save")

end