@echo off

cd "../../"

REM Run the splice command to generate the tower files and folders
"noita_dev.exe" -splice_pixel_scene mods/evaisa.arena/content/arenas/tower/tower.png -x "-670" -y "-1120" -debug 1

REM Copy the generated tower folder into the tower arena directory
xcopy /s /e /y /I "data\biome_impl\spliced\tower" "mods\evaisa.arena\content\arenas\tower\spliced"

pause