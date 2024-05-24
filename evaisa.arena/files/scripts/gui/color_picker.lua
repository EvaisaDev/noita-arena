dofile("mods/evaisa.arena/files/scripts/gui/image.lua")

local color_picker = {}

color_picker.new = function()
    local self = {
        gui = GuiCreate(),
        bar_index = 0,
        old_bar_index = -1,
        dragging_bar = false,
        dragging_picker = false,
        picker_x = 0,
        picker_y = 0,
        picked_color = color_merge(255, 0, 0, 255),
        current_hex = "FF0000",
        current_red = 255,
        current_green = 0,
        current_blue = 0,
    }

    local id = 21523
    local new_id = function()
        id = id + 1
        return id
    end

    
    local color_picker_images = {}
    local color_picker_ids = {}

    local color_picker_img = loadImage("mods/evaisa.arena/files/gfx/skins/color_picker.png")

    self.picker_x = color_picker_img.w - 1

    local color_bar_img = loadImage("mods/evaisa.arena/files/gfx/skins/color_bar.png")

    for i = 0, color_bar_img.h - 1 do
        local new_image_path = "mods/evaisa.arena/files/gfx/skins/pickers/color_picker" .. tostring(i) .. ".png"
        local new_image = loadImage(new_image_path)

        table.insert(color_picker_images, new_image_path)
        table.insert(color_picker_ids, new_image)
    end

    local picked_color_img = loadImage("mods/evaisa.arena/files/gfx/skins/picked_color.png")

    self.calculateBarIndexAndPickerPosition = function()
        -- calculate what bar index and picker position to use based on current color
        local r, g, b, a = color_split(self.picked_color)
        local closest_index = 0
        local closest_distance = 1000000
        for i, color_picker in ipairs(color_picker_ids)do
            for y = 0, color_picker.h - 1 do
                for x = 0, color_picker.w - 1 do
                    local pixel = getPixel(color_picker, x, y)
                    local distance = math.abs(r - pixel[1]) + math.abs(g - pixel[2]) + math.abs(b - pixel[3])
                    if(distance < closest_distance)then
                        closest_distance = distance
                        closest_index = i
                        self.picker_x = x
                        self.picker_y = y
                    end
                end
            end
        end
        self.bar_index = closest_index - 1

    end

    self.clean = function()
        if(self.gui ~= nil)then
            GuiDestroy(self.gui)
            self.gui = nil
        end
    end

    self.draw = function(x, y)
        id = 21523
        if(self.gui == nil)then
            self.gui = GuiCreate()
        end
        GuiStartFrame(self.gui)
        local container_x, container_y = x, y
        
        local current_color_picker = color_picker_ids[self.bar_index + 1]

        GuiZSetForNextWidget(self.gui, -3900)
        GuiBeginScrollContainer(self.gui, 214521 + (GameGetFrameNum() % 2), x, y, 68, 86, false, 1, 1)

        x = 0
        y = 0
        
        GuiZSetForNextWidget(self.gui, -4000)
        local r, g, b, a = color_split(self.picked_color)
        GuiColorSetForNextWidget(self.gui, r / 255, g / 255, b / 255, a / 255)
        GuiImage(self.gui, new_id(), x, y, "mods/evaisa.arena/files/gfx/skins/picked_color.png", 1, 1, 1)

        y = y + picked_color_img.h + 2

        GuiZSetForNextWidget(self.gui, -4000)
        GuiImage(self.gui, new_id(), x, y, color_picker_images[self.bar_index + 1], 1, 1, 1)

        local _, _, _, picker_x, picker_y = GuiGetPreviousWidgetInfo(self.gui)

        x = x + current_color_picker.w + 2

        GuiZSetForNextWidget(self.gui, -4000)
        GuiImage(self.gui, new_id(), x, y, "mods/evaisa.arena/files/gfx/skins/color_bar.png", 1, 1, 1)
        local _, _, _, bar_x, bar_y = GuiGetPreviousWidgetInfo(self.gui)

        local mouse_x, mouse_y = input:GetUIMousePos(self.gui)

        if(InputIsMouseButtonDown( 1 ))then
            -- get relative mouse position to color picker
            local bar_relative_x = mouse_x - bar_x
            local bar_relative_y = math.floor(mouse_y - bar_y)

            local picker_relative_x = math.floor(mouse_x - picker_x)
            local picker_relative_y = math.floor(mouse_y - picker_y)

            if(not self.dragging_picker and (self.dragging_bar or (bar_relative_x < color_bar_img.w and bar_relative_y < color_bar_img.h and bar_relative_x >= 0 and bar_relative_y >= 0)))then
                bar_relative_y = math.max(0, math.min(color_bar_img.h - 1, bar_relative_y))
                self.bar_index = bar_relative_y
                self.dragging_bar = true

                --local color = ModImageGetPixel(color_picker_ids[self.bar_index + 1], self.picker_x, self.picker_y)
                local pixel = getPixel(current_color_picker, self.picker_x, self.picker_y)
                local color = color_merge(pixel[1], pixel[2], pixel[3], pixel[4])
                self.picked_color = color
                self.current_hex = rgb_to_hex(pixel[1], pixel[2], pixel[3])
                self.current_red = pixel[1]
                self.current_green = pixel[2]
                self.current_blue = pixel[3]
            elseif(self.dragging_picker or (picker_relative_x < color_picker_img.w and picker_relative_y < color_picker_img.h and picker_relative_x >= 0 and picker_relative_y >= 0))then
                self.picker_x = math.max(0, math.min(color_picker_img.w - 1, picker_relative_x))
                self.picker_y = math.max(0, math.min(color_picker_img.h - 1, picker_relative_y))
                
                --local color = ModImageGetPixel(color_picker_ids[self.bar_index + 1], self.picker_x, self.picker_y)
                local pixel = getPixel(current_color_picker, self.picker_x, self.picker_y)
                local color = color_merge(pixel[1], pixel[2], pixel[3], pixel[4])
                self.picked_color = color
                self.current_hex = rgb_to_hex(pixel[1], pixel[2], pixel[3])
                self.current_red = pixel[1]
                self.current_green = pixel[2]
                self.current_blue = pixel[3]
                self.dragging_picker = true
            end
        else
            self.dragging_bar = false
            self.dragging_picker = false
        end

        -- draw bar cursor at relative bar y

        local bar_cursor_x = (bar_x - container_x - 1)
        local bar_cursor_y = (bar_y - container_y - 1) + self.bar_index

        GuiZSetForNextWidget(self.gui, -4001)
        GuiImage(self.gui, new_id(), bar_cursor_x, bar_cursor_y, "mods/evaisa.arena/files/gfx/skins/color_bar_cursor.png", 1, 1, 1)
        
        local picker_cursor_x = (picker_x - container_x - 1) + self.picker_x
        local picker_cursor_y = (picker_y - container_y - 1) + self.picker_y

        GuiZSetForNextWidget(self.gui, -4001)
        GuiImage(self.gui, new_id(), picker_cursor_x - 4, picker_cursor_y - 4, "mods/evaisa.arena/files/gfx/skins/color_picker_cursor.png", 1, 1, 1)

        GuiEndScrollContainer(self.gui)

        GuiZSetForNextWidget(self.gui, -3900)


        GuiBeginScrollContainer(self.gui, 325235 + (GameGetFrameNum() % 2), container_x, container_y + 94, 68, 60, false, 1, 1)
        
        local scroll_x = 0
        local scroll_y = 0
        GuiLayoutBeginVertical(self.gui, scroll_x, scroll_y)
        GuiLayoutBeginHorizontal(self.gui, scroll_x, scroll_y)
        GuiZSetForNextWidget(self.gui, -3910)
        GuiText(self.gui, 0, 0, "Hex")
        GuiZSetForNextWidget(self.gui, -3910)
        local new_hex = GuiTextInput(self.gui, new_id(), 0, 0, self.current_hex, 44, 6, "1234567890abcdefABCDEF")
        if(new_hex ~= self.current_hex)then
            self.current_hex = new_hex
            self.current_red, self.current_green, self.current_blue = hex_to_rgb(self.current_hex)
            self.picked_color = color_merge(self.current_red, self.current_green, self.current_blue, 255)
            self.calculateBarIndexAndPickerPosition()
        end

        GuiLayoutEnd(self.gui)
        GuiLayoutBeginHorizontal(self.gui, scroll_x, scroll_y)
        GuiZSetForNextWidget(self.gui, -3910)
        GuiText(self.gui, 0, 0, "R")
        GuiZSetForNextWidget(self.gui, -3910)
        local new_red = GuiTextInput(self.gui, new_id(), 0, 0, tostring(self.current_red), 52, 3, "1234567890")
        -- cap between 0 and 255
        new_red = tostring(math.max(0, math.min(255, tonumber(new_red) or 0)))
        if(new_red ~= tostring(self.current_red))then
            self.current_red = tonumber(new_red)
            self.picked_color = color_merge(self.current_red, self.current_green, self.current_blue, 255)
            self.current_hex = rgb_to_hex(self.current_red, self.current_green, self.current_blue)
            self.calculateBarIndexAndPickerPosition()
        end

        GuiLayoutEnd(self.gui)

        GuiLayoutBeginHorizontal(self.gui, scroll_x, scroll_y)
        GuiZSetForNextWidget(self.gui, -3910)
        GuiText(self.gui, 0, 0, "G")
        GuiZSetForNextWidget(self.gui, -3910)
        local new_green = GuiTextInput(self.gui, new_id(), 0, 0, tostring(self.current_green), 52, 3, "1234567890")
        new_green = tostring(math.max(0, math.min(255, tonumber(new_green) or 0)))
        if(new_green ~= tostring(self.current_green))then
            self.current_green = tonumber(new_green)
            self.picked_color = color_merge(self.current_red, self.current_green, self.current_blue, 255)
            self.current_hex = rgb_to_hex(self.current_red, self.current_green, self.current_blue)
            self.calculateBarIndexAndPickerPosition()
        end

        GuiLayoutEnd(self.gui)

        GuiLayoutBeginHorizontal(self.gui, scroll_x, scroll_y)
        GuiZSetForNextWidget(self.gui, -3910)
        GuiText(self.gui, 0, 0, "B")
        GuiZSetForNextWidget(self.gui, -3910)
        local new_blue = GuiTextInput(self.gui, new_id(), 0, 0, tostring(self.current_blue), 52, 3, "1234567890")
        new_blue = tostring(math.max(0, math.min(255, tonumber(new_blue) or 0)))
        if(new_blue ~= tostring(self.current_blue))then
            self.current_blue = tonumber(new_blue)
            self.picked_color = color_merge(self.current_red, self.current_green, self.current_blue, 255)
            self.current_hex = rgb_to_hex(self.current_red, self.current_green, self.current_blue)
            self.calculateBarIndexAndPickerPosition()
        end

        GuiLayoutEnd(self.gui)

        GuiLayoutEnd(self.gui)

        GuiEndScrollContainer(self.gui)

    end
    
    return self
end

return color_picker