@echo off
echo Installing Heatherwick Studio Toolbar...

REM Get the user's AppData folder
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\8.0\packages

REM Create the directory if it doesn't exist
if not exist "%APPDATA_PATH%" mkdir "%APPDATA_PATH%"

REM Copy the plugin files
echo Copying plugin files...
copy "bin\Debug\net7.0\Heatherwick Studio Toolbar.rhp" "%APPDATA_PATH%\"
copy "bin\Debug\net7.0\Heatherwick Studio Toolbar.rui" "%APPDATA_PATH%\"

echo.
echo Installation complete!
echo.
echo To use the toolbar:
echo 1. Restart Rhino 8
echo 2. The plugin should load automatically
echo 3. Use 'Heatherwick_ListCommands' to see available commands
echo 4. To add commands to a toolbar:
echo    - Right-click on any toolbar
echo    - Select 'Customize'
echo    - Search for 'Heatherwick'
echo    - Drag commands to your toolbar
echo.
pause 