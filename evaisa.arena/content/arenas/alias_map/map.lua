local w = 100
local h = 100

BiomeMapSetSize( w, h )


for x = 0, w - 1 do
	for y = 0, h - 1 do
        BiomeMapSetPixel( x, y, 0xffab3e3a )
	end
end
