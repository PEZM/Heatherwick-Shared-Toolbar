@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Heatherwick Studio Toolbar - Force Registry Cleanup
echo ========================================

echo [INFO] This script will force remove ALL registry entries related to Heatherwick Studio Toolbar
echo [WARNING] This is a destructive operation - use with caution!
echo.

set /p confirm="Are you sure you want to continue? (y/N): "
if /i not "%confirm%"=="y" (
    echo [INFO] Operation cancelled by user
    pause
    exit /b 0
)

echo.
echo [INFO] Starting force registry cleanup...

REM Remove by current GUID
echo [INFO] Removing registry entries for current GUID...
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\12345678-1234-1234-1234-123456789abc" /f 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Removed registry entries for current GUID
) else (
    echo [INFO] No registry entries found for current GUID
)

REM Remove by old GUID
echo [INFO] Removing registry entries for old GUID...
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\3856c5bd-1cf1-4bf3-9322-3111c1b2907c" /f 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Removed registry entries for old GUID
) else (
    echo [INFO] No registry entries found for old GUID
)

REM Search and remove any entries containing "Heatherwick" in the name
echo [INFO] Searching for any other Heatherwick-related registry entries...
for /f "tokens=*" %%i in ('reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins" /s ^| findstr /i "heatherwick"') do (
    echo [INFO] Found: %%i
    for /f "tokens=2 delims=\" %%j in ("%%i") do (
        echo [INFO] Attempting to remove: %%j
        reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%%j" /f 2>nul
        if !errorlevel! equ 0 (
            echo [SUCCESS] Removed: %%j
        ) else (
            echo [WARNING] Failed to remove: %%j
        )
    )
)

REM Search and remove any entries pointing to our build output directory
echo [INFO] Searching for entries pointing to build output directory...
for /f "tokens=*" %%i in ('reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins" /s ^| findstr /i "Heatherwick Studio Toolbar\\bin\\Debug"') do (
    echo [INFO] Found build output reference: %%i
    for /f "tokens=2 delims=\" %%j in ("%%i") do (
        echo [INFO] Attempting to remove: %%j
        reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%%j" /f 2>nul
        if !errorlevel! equ 0 (
            echo [SUCCESS] Removed: %%j
        ) else (
            echo [WARNING] Failed to remove: %%j
        )
    )
)

echo.
echo [INFO] Force registry cleanup complete!
echo [INFO] Please restart Rhino to ensure all changes take effect.
echo.
pause 