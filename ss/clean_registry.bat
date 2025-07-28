@echo off
echo Cleaning Rhino Plugin Registry...

REM Remove the old plugin registration
reg delete "HKEY_CURRENT_USER\Software\McNeel\Rhinoceros\8.0\Plug-Ins\3856c5bd-1cf1-4bf3-9322-3111c1b2907c" /f 2>nul

echo.
echo Registry cleanup complete!
echo.
echo The old plugin registration has been removed.
echo Now run clean_install.bat to install the new version.
echo.
pause 