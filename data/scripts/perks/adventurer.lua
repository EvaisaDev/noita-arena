dofile_once("data/scripts/gun/procedural/gun_action_utils.lua")
dofile_once( "data/scripts/game_helpers.lua" )

local entity_id    = GetUpdatedEntityID()
local player_id = EntityGetRootEntity( GetUpdatedEntityID() )
local x, y = EntityGetTransform( player_id )

function init(entity_id)
	print("adventurer init")
	chunks_explored = {}
end

gui = gui or GuiCreate()
GuiStartFrame( gui )

function WorldToScreenPos(gui_input, x, y)
	local ww, wh = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X"), MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")
	local sw, sh = GuiGetScreenDimensions(gui_input)
	local _, _, cam_w, cam_h = GameGetCameraBounds()
	local cx, cy = GameGetCameraPos()
	cx = cx - cam_w / 2
	cy = cy - cam_h / 2
	x, y = x - cx, y - cy
	x, y = x / ww, y / wh
	x, y = x * sw, y * sh
	return x, y
end

function Gui9Piece(gui, id_func, x, y, width, height, alpha, z_index, image_sprite, piece_size, color)
	local r = color and color[1] or 1
	local g = color and color[2] or 1
	local b = color and color[3] or 1
	local a = color and color[4] or 1

	
    -- top left
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x, y, image_sprite, alpha, 1, 1, 0, 1, "tl")
    -- top right
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x + width - piece_size, y, image_sprite, alpha, 1, 1, 0, 1, "tr")
    -- bottom left
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x, y + height - piece_size, image_sprite, alpha, 1, 1, 0, 1, "bl")
    -- bottom right
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x + width - piece_size, y + height - piece_size, image_sprite, alpha, 1, 1, 0, 1, "br")
    -- top
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index) 
    GuiImage(gui, id_func(), x + piece_size, y, image_sprite, alpha, (width - piece_size * 2) / piece_size, 1, 0, 1, "tc")
    -- bottom
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x + piece_size, y + height - piece_size, image_sprite, alpha, (width - piece_size * 2) / piece_size, 1, 0, 1, "bc")
    -- left
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x, y + piece_size, image_sprite, alpha, 1, (height - piece_size * 2) / piece_size, 0, 1, "lc")
    -- right
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x + width - piece_size, y + piece_size, image_sprite, alpha, 1, (height - piece_size * 2) / piece_size, 0, 1, "rc")
    -- center
	GuiColorSetForNextWidget(gui, r, g, b, a)
    GuiZSetForNextWidget(gui, z_index)
    GuiImage(gui, id_func(), x + piece_size, y + piece_size, image_sprite, alpha, (width - piece_size * 2) / piece_size, (height - piece_size * 2) / piece_size, 0, 1, "c")
end

local id = 325136
local function new_id()
	id = id + 1
	return id
end

chunks_explored = chunks_explored or {}

local chunk_size = 512

local cx = math.floor( x / chunk_size )
local cy = math.floor( y / chunk_size )

local key = table.concat( { cx, cy }, "_" )

-- get all 9 neighboring chunks
local neighbors = {
	{ cx - 1, cy - 1 },
	{ cx, cy - 1 },
	{ cx + 1, cy - 1 },
	{ cx - 1, cy },
	{ cx, cy },
	{ cx + 1, cy },
	{ cx - 1, cy + 1 },
	{ cx, cy + 1 },
	{ cx + 1, cy + 1 }
}

for i,v in ipairs(neighbors) do
	local world_x, world_y = WorldToScreenPos(gui, v[1] * chunk_size, v[2] * chunk_size)
	local color = {1, 1, 1, 0.01}
	-- check if chunk is explored
	if not chunks_explored[table.concat( v, "_" )] then
		color = {0.7, 1, 0.7, 0.2}
	end

	local size = chunk_size + (chunk_size / 2) + 1

	Gui9Piece(gui, function() return new_id() end, world_x + 1, world_y, size + 1,size - 4, color[4], 0, "mods/evaisa.arena/files/sprites/ui/9piece_white.xml", 3, color)	
end


local function is_chunk_explored()
	if not chunks_explored[key] then
		return false
	end
	
	return true
end

if ( not is_chunk_explored() ) then
	local heal = 60
	heal = heal / 25
	heal_entity( player_id, heal )
	
	chunks_explored[key] = true

	GamePrint( "$log_adventurer" )
end