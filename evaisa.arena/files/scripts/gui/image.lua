local spng = require("libspng")
local fs = require("fs")

function setPixel(img, x, y, r, g, b, a)
    local index = (y * img.w + x) * 4
    img.data[index] = r
    img.data[index + 1] = g
    img.data[index + 2] = b
    img.data[index + 3] = a
end

function getPixel(img, x, y)
    local index = (y * img.w + x) * 4
    return img.data[index], img.data[index + 1], img.data[index + 2], img.data[index + 3]
end

function getPixel2(img, x, y)
    local index = (y * img.w + x) * 4
    return {img.data[index], img.data[index + 1], img.data[index + 2], img.data[index + 3]}
end


function loadImage(file)
    local gamemode_path = GetModFilePath(ARENA_MOD_ID, ARENA_STEAM_ID)
    debug_log:print("Gamemode path: " .. gamemode_path)

    if(gamemode_path)then
        -- replace mods/evaisa.arena from start of file path with gamemode path
        file = file:gsub("mods/evaisa.arena", gamemode_path)
    end

    debug_log:print("image path: " .. file)

    local f, err = fs.open(file)

    if not f then
        if(exception_log ~= nil)then
            exception_log:print("File not found: " .. file)
        end
        return nil, false
    end

    local img = assert(spng.open{read = f:buffered_read()})
    local bmp = assert(img:load{accept = {rgba8 = true}})
    assert(f:close())
    img:free()
    return bmp, true
end

function loadImageFromString(png_string)
    local img = assert(spng.open(png_string))
    local bmp = assert(img:load{accept = {rgba8 = true}})
    img:free()
    return bmp
end

function saveImage(bmp, file)
    -- get folder path without file
    local folder = file:match("(.*/)")
    local path = ""
    for folder_name in folder:gmatch("([^/]+)")do
        path = path .. folder_name
        fs.mkdir(path, true)
        path = path .. "/"
    end

    
	local f = assert(fs.open(file, 'w'))
	assert(spng.save{
		bitmap = bmp,
		write = function(buf, sz)
			return f:write(buf, sz)
		end,
	})
	assert(f:close())
end

function color_split(abgr_int)
    local r = bit.band(abgr_int, 0x000000FF)
    local g = bit.band(abgr_int, 0x0000FF00)
    local b = bit.band(abgr_int, 0x00FF0000)
    local a = bit.band(abgr_int, 0xFF000000)

    g = bit.rshift(g, 8)
    b = bit.rshift(b, 16)
    a = bit.rshift(a, 24)

    return r,g,b,a
end

function color_merge(r,g,b,a)
    local abgr_int = 0
    abgr_int = bit.bor(abgr_int, r)
    abgr_int = bit.bor(abgr_int, bit.lshift(g, 8))
    abgr_int = bit.bor(abgr_int, bit.lshift(b, 16))
    abgr_int = bit.bor(abgr_int, bit.lshift(a, 24))

    return abgr_int
end

function rgb_to_hex (r, g, b)
    return string.format("%02x%02x%02x", r, g, b)
end

function hex_to_rgb (hex)
    hex = hex:gsub("#","")

    --if string is less than 6 characters, add 0s to the end
    if string.len(hex) < 6 then
        hex = hex .. string.rep("0", 6 - string.len(hex))
    end

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return r, g, b
end
