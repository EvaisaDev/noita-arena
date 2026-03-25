@echo off

cd "../../"

REM Run the splice command to generate the tower files and folders
"noita_dev.exe" -splice_pixel_scene "mods/evaisa.arena/content/arenas/lava_bowl/lava_bowl.png" -x "-763" -y "-293" -debug 1

REM Copy the generated tower folder into the tower arena directory
xcopy /s /e /y /I "data\biome_impl\spliced\lava_bowl" "mods\evaisa.arena\content\arenas\lava_bowl\spliced"

REM Copy the xml
copy /y "data\biome_impl\spliced\lava_bowl.xml" "mods\evaisa.arena\content\arenas\lava_bowl\lava_bowl.xml"

REM Fix paths in the xml
powershell -Command "(Get-Content 'mods\evaisa.arena\content\arenas\lava_bowl\lava_bowl.xml') -replace 'data/biome_impl/spliced/lava_bowl/', 'mods/evaisa.arena/content/arenas/lava_bowl/spliced/' | Set-Content 'mods\evaisa.arena\content\arenas\lava_bowl\lava_bowl.xml'"

pause