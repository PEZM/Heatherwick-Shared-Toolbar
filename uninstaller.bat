@echo off
setlocal enabledelayedexpansion

REM ========================================
REM Heatherwick Studio Toolbar Uninstaller
REM ========================================
REM This script completely removes the Heatherwick Studio Toolbar plugin
REM Version: 1.0.0
REM ========================================

echo.
echo ========================================
echo Heatherwick Studio Toolbar Uninstaller
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges
) else (
    echo [WARNING] Not running as administrator - some operations may fail
    echo.
)

REM Get the user's AppData folder
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\8.0\packages
set PLUGIN_NAME=HeatherwickStudioToolbar
set PLUGIN_DIR=%APPDATA_PATH%\%PLUGIN_NAME%

echo [INFO] Plugin location: %PLUGIN_DIR%
echo.

REM Check if plugin is installed
if not exist "%PLUGIN_DIR%" (
    echo [INFO] Plugin directory not found - nothing to uninstall
    echo.
    pause
    exit /b 0
)

REM Confirm uninstallation
echo [WARNING] This will completely remove the Heatherwick Studio Toolbar plugin.
echo [WARNING] All plugin files and settings will be deleted.
echo.
set /p CONFIRM="Are you sure you want to continue? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo [INFO] Uninstallation cancelled
    echo.
    pause
    exit /b 0
)

echo.
echo [INFO] Starting uninstallation...
echo.

REM Stop any running Rhino processes (optional)
echo [INFO] Checking for running Rhino processes...
tasklist /FI "IMAGENAME eq Rhino.exe" 2>NUL | find /I /N "Rhino.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] Rhino is currently running
    echo [WARNING] Please close Rhino before continuing
    set /p CONTINUE="Continue anyway? (y/N): "
    if /i not "%CONTINUE%"=="y" (
        echo [INFO] Uninstallation cancelled
        echo.
        pause
        exit /b 0
    )
)

REM Remove registry entries
echo [INFO] Removing registry entries...
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\HeatherwickStudioToolbar" /f >nul 2>&1
if !errorLevel! equ 0 (
    echo [SUCCESS] Registry entries removed
) else (
    echo [INFO] No registry entries found to remove
)

REM Remove toolbar from Rhino's toolbar list
echo [INFO] Cleaning up toolbar references...
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Toolbars" /v "HeatherwickStudioToolbar" /f >nul 2>&1

REM Remove from Rhino's plugin list
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins" /v "HeatherwickStudioToolbar" /f >nul 2>&1

REM Remove plugin files
echo [INFO] Removing plugin files...
if exist "%PLUGIN_DIR%" (
    REM List files before deletion
    echo [INFO] Files to be removed:
    dir "%PLUGIN_DIR%" /B 2>nul
    
    REM Remove all files and subdirectories
    rmdir /S /Q "%PLUGIN_DIR%"
    if !errorLevel! equ 0 (
        echo [SUCCESS] Plugin directory and all files removed
    ) else (
        echo [ERROR] Failed to remove plugin directory
        echo [INFO] You may need to manually delete: %PLUGIN_DIR%
    )
) else (
    echo [INFO] Plugin directory not found
)

REM Clean up any orphaned files in the packages directory
echo [INFO] Checking for orphaned files...
if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp" (
    del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rhp" >nul 2>&1
    echo [INFO] Removed orphaned .rhp file
)

if exist "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui" (
    del "%APPDATA_PATH%\Heatherwick Studio Toolbar.rui" >nul 2>&1
    echo [INFO] Removed orphaned .rui file
)

REM Clean up Heatherwick Studio data directory (if empty)
set HEATHERWICK_DATA=%APPDATA%\HeatherwickStudio
if exist "%HEATHERWICK_DATA%" (
    dir "%HEATHERWICK_DATA%" /B >nul 2>&1
    if !errorLevel! neq 0 (
        echo [INFO] Heatherwick Studio data directory is empty
        rmdir "%HEATHERWICK_DATA%" >nul 2>&1
        echo [INFO] Removed empty Heatherwick Studio data directory
    )
)

REM Clean up temporary files
echo [INFO] Cleaning up temporary files...
if exist "%TEMP%\HeatherwickStudio*" (
    rmdir /S /Q "%TEMP%\HeatherwickStudio*" >nul 2>&1
    echo [INFO] Removed temporary files
)

REM Verify uninstallation
echo.
echo [INFO] Verifying uninstallation...
if not exist "%PLUGIN_DIR%" (
    echo [✓] Plugin directory removed
) else (
    echo [✗] Plugin directory still exists: %PLUGIN_DIR%
    set VERIFY_FAILED=1
)

reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\HeatherwickStudioToolbar" >nul 2>&1
if !errorLevel! neq 0 (
    echo [✓] Registry entries removed
) else (
    echo [✗] Registry entries still exist
    set VERIFY_FAILED=1
)

if not defined VERIFY_FAILED (
    echo.
    echo [SUCCESS] Uninstallation verification passed
) else (
    echo.
    echo [WARNING] Some components may not have been fully removed
    echo [INFO] You may need to manually clean up remaining files
)

echo.
echo ========================================
echo Uninstallation Complete!
echo ========================================
echo.
echo The Heatherwick Studio Toolbar plugin has been removed.
echo.
echo Next steps:
echo 1. Restart Rhino 8 to ensure all changes take effect
echo 2. The plugin will no longer load automatically
echo 3. Any custom toolbars using this plugin will need to be reconfigured
echo.
echo If you need to reinstall the plugin, run the installer.bat script.
echo.
pause 