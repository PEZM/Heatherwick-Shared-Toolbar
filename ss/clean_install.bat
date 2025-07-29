@echo off
echo Cleaning and Installing Heatherwick Studio Toolbar...

REM Get the user's AppData folder
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\packages\8.0

REM Remove old plugin files if they exist
echo Removing old plugin files...
if exist "%APPDATA_PATH%\Heatherwick-Studio-Toolbar" rmdir /S /Q "%APPDATA_PATH%\Heatherwick-Studio-Toolbar"

REM Create the directory if it doesn't exist
if not exist "%APPDATA_PATH%" mkdir "%APPDATA_PATH%"

REM Install using Yak package
echo Installing Yak package...
echo Please install the Yak package manually:
echo 1. Open Rhino 8
echo 2. Go to Tools -> Package Manager
echo 3. Click "Install from file"
echo 4. Select: bin\Debug\heatherwick-studio-toolbar-1.0.1-rh8_0-any.yak

echo.
echo Clean installation complete!
echo.
echo Package will be installed to: %APPDATA_PATH%\Heatherwick-Studio-Toolbar
echo.
echo IMPORTANT: You need to restart Rhino 8 completely for the changes to take effect.
echo The plugin should now load from the correct location and use the correct GUID.
echo.
echo After restarting Rhino:
echo 1. Check Tools -> Options -> Plug-ins
echo 2. Look for "Heatherwick Studio Toolbar" 
echo 3. It should show "Loaded: Yes" and have the correct GUID
echo 4. Try typing 'Heatherwick_ListCommands' in the command line
echo.
pause 