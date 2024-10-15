local ready_counter = {}

function ready_counter.create( text, callback, finish_callback )
    local gui_ready_counter = GuiCreate()
    GuiOptionsAdd(gui_ready_counter, 2)
    GuiOptionsAdd(gui_ready_counter, 6)

    local self = {
        text = text,
        callback = callback,
        offset_x = 9,
        offset_y = 28,
        destroyed = false,
        update = function(self, lobby, data)
            if(self.destroyed)then
                return nil
            end

            GuiStartFrame(gui_ready_counter)

            local players_ready, players = self.callback()

            if players_ready == players then
                return true
            end
            

            local width, height = GuiGetTextDimensions(gui_ready_counter, GameTextGetTranslatedOrNot(self.text) .. " " .. tostring(players_ready) .. " / " .. tostring(players), 1)
            local screen_width, screen_height = GuiGetScreenDimensions(gui_ready_counter)

            local x = screen_width - self.offset_x - width
            local y = screen_height - self.offset_y - height

            if(ModSettingGet("evaisa.arena.ready_count_left"))then
                x = self.offset_x
                y = screen_height - self.offset_x - height
            end


            GuiBeginAutoBox(gui_ready_counter)
            GuiZSetForNextWidget(gui_ready_counter, 1000)
            GuiText(gui_ready_counter, x, y, GameTextGetTranslatedOrNot(self.text) .. " " .. tostring(players_ready) .. " / " .. tostring(players))
            GuiZSetForNextWidget(gui_ready_counter, 1001)
            GuiEndAutoBoxNinePiece(gui_ready_counter, 4)
            local _, _, _, ready_x, ready_y, ready_w, ready_h = GuiGetPreviousWidgetInfo(gui_ready_counter)

            if(not data.spectator_mode)then
                local text_w, text_h = GuiGetTextDimensions(gui_ready_counter, GameTextGetTranslatedOrNot(self.text) .. " " .. tostring(players_ready) .. " / " .. tostring(players), 1)

                -- if ready
                -- arena_ready_button_not_ready
                -- arena_ready_button_ready
                local ready = data.client.ready
                local ready_button_hovered = data.client.ready_button_hovered

                local ready_9piece = "mods/evaisa.arena/files/sprites/ui/button_9piece.png"
                local button_scale = ready_button_hovered and 1.05 or 1
                
                GuiBeginAutoBox(gui_ready_counter)
                GuiZSetForNextWidget(gui_ready_counter, 1000)
                
                -- Calculate button dimensions with scaling
                local button_w, button_h = GuiGetImageDimensions(gui_ready_counter, "mods/evaisa.arena/files/sprites/ui/ready_check_1.png", button_scale)
                
                -- Determine button X position based on setting
                local is_left_aligned = ModSettingGet("evaisa.arena.ready_count_left")
                local ready_button_x = is_left_aligned and ready_x or (ready_x + ready_w - button_w)
                
                local ready_button_y = ready_y - ready_h - 2
                
                
                -- Get button text and dimensions 
                local button_text = ready and GameTextGetTranslatedOrNot("$arena_ready_button_ready") or GameTextGetTranslatedOrNot("$arena_ready_button_not_ready")
                local button_text_w, button_text_h = GuiGetTextDimensions(gui_ready_counter, button_text, button_scale)

                ready_button_x = ready_button_x + 1
                
                if(not is_left_aligned)then
                    ready_button_x = ready_button_x - (button_text_w) - 4
                end

                local original_text_w, original_text_h = button_text_w / button_scale, button_text_h / button_scale
                local original_button_w, original_button_h = button_w / button_scale, button_h / button_scale 

                local total_width = original_text_w + original_button_w + 4
                local total_height = math.max(original_text_h, original_button_h)
                local scaled_width = total_width * button_scale
                local scaled_height = total_height * button_scale

                if(is_left_aligned)then
                    -- offset button so it is centered
                    ready_button_x = ready_button_x - (scaled_width - total_width) / 2
                else
                    ready_button_x = ready_button_x + (scaled_width - total_width) / 2
                end
                
                ready_button_y = ready_button_y - (scaled_height - total_height) / 2
            



                local button_text_x = ready_button_x + button_w + 2
                local button_text_y = ready_button_y + (button_h - button_text_h) / 2
                
                GuiText(gui_ready_counter, button_text_x, button_text_y, button_text, button_scale)

                if(ready)then
                    GuiImage(gui_ready_counter,214, ready_button_x, ready_button_y, "mods/evaisa.arena/files/sprites/ui/ready_check_2.png", 1, button_scale, button_scale, 0)
                else
                    GuiImage(gui_ready_counter,214, ready_button_x, ready_button_y, "mods/evaisa.arena/files/sprites/ui/ready_check_1.png", 1, button_scale, button_scale, 0)
                end


                GuiZSetForNextWidget(gui_ready_counter, 1001)
                GuiEndAutoBoxNinePiece(gui_ready_counter, 1, 0, 0, false, 0, ready_9piece, ready_9piece)

                local clicked, right_clicked, hovered, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui_ready_counter)
                if(clicked)then
                    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
        
                    if(GameHasFlagRun("lock_ready_state"))then
                        return
                    end
                    
                    if(GameHasFlagRun("ready_check"))then
                        --ChatPrint(GameTextGetTranslatedOrNot("$arena_self_unready"))
                        GameAddFlagRun("player_unready")
                        GameRemoveFlagRun("ready_check")
                        GameRemoveFlagRun("player_ready")
                    else
                        --ChatPrint(GameTextGetTranslatedOrNot("$arena_self_ready"))
                        GameAddFlagRun("player_ready")
                        GameAddFlagRun("ready_check")
                        GameRemoveFlagRun("player_unready")
                    end
                end
                if(hovered)then
                    if(not data.client.ready_button_hovered)then
                        GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_select", 0, 0)
                    end

                    local cursor_x, cursor_y = input:GetUIMousePos(gui_ready_counter)



                    GuiImage(gui_ready_counter, 2412, cursor_x - 16, cursor_y - 16, "mods/evaisa.arena/files/sprites/ui/no_avatar.png", 0, 1, 1)
                    

                    data.client.ready_button_hovered = true
                else
                    data.client.ready_button_hovered = false
                end


     
            end

            return false
        end,
        apply_offset = function(self, x, y)
            self.offset_x = x
            self.offset_y = y
        end,
        cleanup = function(self)
            self.destroyed = true
            GuiDestroy(gui_ready_counter)
        end
    }

    return self
end

return ready_counter