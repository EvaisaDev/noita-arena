local w = 40
local h = 40

BiomeMapSetSize( w, h )

SetRandomSeed( 25325, 32626 )

--[[
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
]]


local biomes = {
	0xFF6EADE1, -- coalmine
	0xFF7B8FE9, -- collapsed mines
	0xFF6EE1BD, -- crypt
	0xFF6EE190, -- excavation site
	0xFFB1E16E, -- fungi cave
	0xFFE1DD6E, -- rainforest
	0xFFE1926E, -- snowey caverns
	0xFFE16E6E, -- hiisi base
	0xFFC94C4C, -- vault
	0xFF566D91, -- frozen vault
	0xFFBB54A5 -- fungi forest
}

local biome = biomes[Random( 1, #biomes )]

for x = 0, w - 1 do
	for y = 0, h - 1 do
		--BiomeMapSetPixel( x, y, 0xFF7B8FE9 )
		if(x > 17 and x < 22 and y > 11 and y < 16)then
			BiomeMapSetPixel( x, y, biome )
		else
        	BiomeMapSetPixel( x, y, 0xFF688384 )
		end
	end
end
