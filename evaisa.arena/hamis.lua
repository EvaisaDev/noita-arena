hamis_visible = hamis_visible or false
visible_frames = visible_frames or 0
local fully_visible_frame = 120
pressed_frame = pressed_frame or nil




if(not HasFlagPersistent("super_secret_hamis_mode"))then

    if(menu_status == status.main_menu and not gui_closed)then
        if(not hamis_visible)then
            SetRandomSeed(GameGetFrameNum() + 325135, GameGetFrameNum() % 1000 * 241)
            local rand = Random(0, 100)
            
            if(GameGetFrameNum() % 600 == 0)then
                print("rand: "..rand)
                if(rand >= 80)then
                    hamis_visible = true
                end
            end
        else
            hamis_gui = hamis_gui or GuiCreate()
            GuiStartFrame(hamis_gui)

            local screen_width, screen_height = GuiGetScreenDimensions(hamis_gui)

            local hamis_image = "data/enemies_gfx/longleg.xml"

            local w, h = 12, 19

            local animation = "stand"

            -- slide in from the left, in the bottom left of the screen
            if(visible_frames < fully_visible_frame)then
                visible_frames = visible_frames + 1
                animation = "walk"
            end

            if(pressed_frame ~= nil)then
                animation = "pet"
                if(GameGetFrameNum() - pressed_frame > 50)then
                    hamis_visible = false
                    visible_frames = 0
                    pressed_frame = nil
                    AddFlagPersistent("super_secret_hamis_mode")
                    GamePrint("Super Secret Hämis Mode Unlocked!")
                    
                    np.MagicNumbersSetValue("UI_IMPORTANT_MESSAGE_POS_Y", "80")

                    delay.new(30, function()
                        np.MagicNumbersSetValue("UI_IMPORTANT_MESSAGE_POS_Y", "65")
                    end)

                    GamePrintImportant("SUPER SECRET HÄMIS MODE UNLOCKED!")

               
                end
            end


            local x = -w + ((visible_frames / fully_visible_frame) * (w * 2))
            local y = screen_height - h

            GuiOptionsAddForNextWidget(hamis_gui, 7)
            GuiOptionsAddForNextWidget(hamis_gui, 3)

            GuiImage(hamis_gui, 123, x, y, hamis_image, 1, 2, 2, 0, 2, animation)

            -- calculate hover area for the hamis
            local mouse_x, mouse_y = input:GetUIMousePos(hamis_gui)

            local hover_x = x - w
            local hover_y = y - h
            local hover_w = w * 2
            local hover_h = h * 2

            if(mouse_x > hover_x and mouse_x < hover_x + hover_w and mouse_y > hover_y and mouse_y < hover_y + hover_h)then
                print("hovering over hamis")
                if(input:WasMousePressed(1))then
                    pressed_frame = GameGetFrameNum()
                end
            end

        end
    end
end