local w = 40
local h = 40

BiomeMapSetSize( w, h )


for x = 0, w - 1 do
	for y = 0, h - 1 do
		--BiomeMapSetPixel( x, y, 0xFF7B8FE9 )
		if(x > 17 and x < 22 and y > 11 and y < 16)then
			BiomeMapSetPixel( x, y, 0xFF7B8FE9 )
		else
        	BiomeMapSetPixel( x, y, 0xFF688384 )
		end
	end
end
