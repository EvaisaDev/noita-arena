@echo off

cd "../../"

REM Run the first command to generate the temple files and folders
"noita_dev.exe" -splice_pixel_scene mods/evaisa.arena/files/biome/pixelscenes/holymountain/temple.png -x "-222" -y "-133" -debug 1

REM Run the second command to generate the temple_itemshop files and folders
"noita_dev.exe" -splice_pixel_scene mods/evaisa.arena/files/biome/pixelscenes/holymountain/temple_itemshop.png -x "-222" -y "-133" -debug 1

REM Copy the generated temple folder and temple.xml file
xcopy /s /e /y /I "data\biome_impl\spliced\temple" "mods\evaisa.arena\files\biome\pixelscenes\temple"
xcopy /s /e /y /I "data\biome_impl\spliced\temple.xml" "mods\evaisa.arena\files\biome\pixelscenes"

REM Replace paths in the temple.xml file
powershell -Command "(Get-Content 'mods/evaisa.arena/files/biome/pixelscenes/temple.xml') -replace 'data/biome_impl/spliced', 'mods/evaisa.arena/files/biome/pixelscenes' | Set-Content 'mods/evaisa.arena/files/biome/pixelscenes/temple.xml'"

REM Copy the generated temple_itemshop folder and temple_itemshop.xml file
xcopy /s /e /y /I "data\biome_impl\spliced\temple_itemshop" "mods\evaisa.arena\files\biome\pixelscenes\temple_itemshop"
xcopy /s /e /y /I "data\biome_impl\spliced\temple_itemshop.xml" "mods\evaisa.arena\files\biome\pixelscenes"

REM Replace paths in the temple_itemshop.xml file
powershell -Command "(Get-Content 'mods/evaisa.arena/files/biome/pixelscenes/temple_itemshop.xml') -replace 'data/biome_impl/spliced', 'mods/evaisa.arena/files/biome/pixelscenes' | Set-Content 'mods/evaisa.arena/files/biome/pixelscenes/temple_itemshop.xml'"

pause