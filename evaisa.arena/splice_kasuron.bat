@echo off

cd "../../"

REM Run the splice command to generate the tower files and folders
"noita_dev.exe" -splice_pixel_scene "mods/evaisa.arena/content/arenas/kasuron/kasuron.png" -x "-448" -y "-344" -debug 1

REM Copy the generated tower folder into the tower arena directory
xcopy /s /e /y /I "data\biome_impl\spliced\kasuron" "mods\evaisa.arena\content\arenas\kasuron\spliced"

REM Copy the xml
copy /y "data\biome_impl\spliced\kasuron.xml" "mods\evaisa.arena\content\arenas\kasuron\kasuron.xml"

REM Fix paths in the xml
powershell -Command "(Get-Content 'mods\evaisa.arena\content\arenas\kasuron\kasuron.xml') -replace 'data/biome_impl/spliced/kasuron/', 'mods/evaisa.arena/content/arenas/kasuron/spliced/' | Set-Content 'mods\evaisa.arena\content\arenas\kasuron\kasuron.xml'"

pause