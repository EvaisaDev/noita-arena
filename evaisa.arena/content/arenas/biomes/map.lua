local w = 40
local h = 40

BiomeMapSetSize( w, h )

SetRandomSeed( 25325, 32626 )


local biomes = {
	0xFF6EADE1,
	0xFF7B8FE9,
	0xFF6EE1BD,
	0xFF6EE190,
	0xFFB1E16E,
	--0xFFE1DD6E,
	0xFFE1926E,
	0xFFE16E6E,
	0xFFC94C4C,
	0xFF566D91,
	0xFFBB54A5
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
