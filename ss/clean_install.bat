@echo off
echo Cleaning and Installing Heatherwick Studio Toolbar...

REM Get the user's AppData folder
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\8.0\packages

REM Remove old plugin files if they exist
echo Removing old plugin files...
if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp" del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp"
if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui" del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui"

REM Create the directory if it doesn't exist
if not exist "%APPDATA_PATH%" mkdir "%APPDATA_PATH%"

REM Copy the plugin files
echo Copying plugin files...
copy "bin\Debug\net7.0\Heatherwick Studio Toolbar.rhp" "%APPDATA_PATH%\"
copy "bin\Debug\net7.0\Heatherwick Studio Toolbar.rui" "%APPDATA_PATH%\"

echo.
echo Clean installation complete!
echo.
echo Files installed to: %APPDATA_PATH%
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