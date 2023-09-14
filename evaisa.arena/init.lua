local genomes = dofile("mods/evaisa.arena/files/scripts/utilities/genomes.lua")

genomes:start()
genomes:add("pvp", 0, 0, 0, {})
genomes:add("pvp_client", 0, 0, 0, {})
genomes:finish()

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
    if(ModIsEnabled("evaisa.mp"))then
        ------ TRANSLATIONS -------
    
        dofile("mods/evaisa.mp/lib/translations.lua")
    
        register_localizations("mods/evaisa.arena/translations.csv", 2)
    
        ---------------------------
    end
end

function OnModPostInit()
    if(ModIsEnabled("evaisa.mp"))then
        ModLuaFileAppend("mods/evaisa.mp/data/gamemodes.lua", "mods/evaisa.arena/files/scripts/gamemode/main.lua")
    end
end

function OnWorldPreUpdate()
    if(not ModIsEnabled("evaisa.mp"))then
        GamePrint(GameTextGetTranslatedOrNot("$arena_noita_online_missing"))
    end
end


function OnMagicNumbersAndWorldSeedInitialized()
    GameAddFlagRun("no_progress_flags_perk")
    GameAddFlagRun("no_progress_flags_action")
    GameAddFlagRun("no_progress_flags_animal")
    --print("Init content: \n"..ModTextFileGetContent("data/scripts/init.lua"))
    --print("Biome mod content: \n"..ModTextFileGetContent("data/scripts/biome_modifiers.lua"))
end

function OnPlayerSpawned(player)
    EntityKill(player)
end