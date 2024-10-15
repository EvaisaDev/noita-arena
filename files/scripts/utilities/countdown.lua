local countdown = {}

function countdown.create( table_images, frames_between_images, finish_callback, update_callback )
    local gui_countdown = GuiCreate()
    
    GuiOptionsAdd(gui_countdown, 2)
    GuiOptionsAdd(gui_countdown, 6)

    local self = {
        frame = 0,
        frames_between_images = frames_between_images,
        image_index = 1,
        table_images = table_images,
        finish_callback = finish_callback,
        update_callback = update_callback,
        update = function(self)
            local gui_id = 125918
            local new_id = function()
                gui_id = gui_id + 1
                return gui_id
            end

            GuiStartFrame(gui_countdown)

            self.frame = self.frame + 1
            if self.frame > self.frames_between_images then
                self.frame = 0
                self.image_index = self.image_index + 1
                if self.image_index > #self.table_images then
                    self.finish_callback()
                    GuiDestroy(gui_countdown)
                    return true
                end
            end

            if(self.update_callback)then
                self.update_callback(self.frame, self.image_index)
            end


            --print("image_index: " .. self.image_index)
            local image = self.table_images[self.image_index]


            if(image == nil)then
                print("image is nil")
                return false
            end
            local width, height = GuiGetImageDimensions(gui_countdown, image, 1)
            local screen_width, screen_height = GuiGetScreenDimensions(gui_countdown)

            local x = (screen_width - width) / 2
            local y = (screen_height - height) / 2
            GuiZSetForNextWidget(gui_countdown, 1000)
            GuiImage(gui_countdown, new_id(), x, y, image, 1, 1, 1, 0)

            return false
        end,
        cleanup = function(self)
            GuiDestroy(gui_countdown)
        end
    }

    return self
end

return countdown