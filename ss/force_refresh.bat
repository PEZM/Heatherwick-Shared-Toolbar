@echo off
echo Force Refreshing Heatherwick Studio Toolbar Plugin...

REM Remove old plugin registration completely
echo Removing old plugin registration...
reg delete "HKEY_CURRENT_USER\Software\McNeel\Rhinoceros\8.0\Plug-Ins\3856c5bd-1cf1-4bf3-9322-3111c1b2907c" /f 2>nul
reg delete "HKEY_CURRENT_USER\Software\McNeel\Rhinoceros\8.0\Plug-Ins\12345678-1234-1234-1234-123456789ABC" /f 2>nul

REM Clear Rhino's plugin cache
echo Clearing Rhino plugin cache...
reg delete "HKEY_CURRENT_USER\Software\McNeel\Rhinoceros\8.0\Plug-Ins\Cache" /f 2>nul

REM Remove any old plugin files from packages directory
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\8.0\packages
if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp" del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp"
if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui" del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui"

echo.
echo Force refresh complete!
echo.
echo IMPORTANT: You must completely restart Rhino 8 for changes to take effect.
echo The plugin should now load with the correct GUID and all commands.
echo.
echo After restarting Rhino:
echo 1. Check Tools -> Options -> Plug-ins
echo 2. Look for "Heatherwick Studio Toolbar"
echo 3. Should show GUID: 12345678-1234-1234-1234-123456789ABC
echo 4. Should show all 4 commands including Heatherwick_LoadToolbar
echo.
pause 