@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Heatherwick Studio Toolbar Uninstaller v2.0
echo ========================================

REM Configuration
set "PLUGIN_NAME=Heatherwick-Studio-Toolbar"
set "APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\packages\8.0"
set "CURRENT_GUID=12345678-1234-1234-1234-123456789abc"
set "OLD_GUID=3856c5bd-1cf1-4bf3-9322-3111c1b2907c"
set "BUILD_OUTPUT_PATH=%USERPROFILE%\OneDrive - Heatherwick Studio\Ge-CoDe - Internal\AppDev\Heatherwick Studio Toolbar\bin\Debug\net7.0"

echo [INFO] Plugin name: %PLUGIN_NAME%
echo [INFO] Plugin location: %APPDATA_PATH%\%PLUGIN_NAME%
echo [INFO] Current GUID: %CURRENT_GUID%
echo [INFO] Old GUID: %OLD_GUID%
echo [INFO] Build output path: %BUILD_OUTPUT_PATH%
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Not running as administrator - some operations may fail
    echo [INFO] Consider running as administrator for complete cleanup
    echo.
)

echo [WARNING] This will completely remove the Heatherwick Studio Toolbar plugin.
echo [WARNING] All plugin files, settings, and registry entries will be deleted.
echo.

set /p confirm="Are you sure you want to continue? (y/N): "
if /i not "%confirm%"=="y" (
    echo [INFO] Operation cancelled by user
    pause
    exit /b 0
)

echo.
echo [INFO] Starting comprehensive uninstallation...

REM Step 1: Check for running Rhino processes
echo [INFO] Checking for running Rhino processes...
tasklist /FI "IMAGENAME eq Rhino.exe" 2>NUL | find /I /N "Rhino.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] Rhino is currently running. Please close Rhino and try again.
    echo [INFO] This ensures all registry entries are properly released.
    pause
    exit /b 1
) else (
    echo [INFO] No running Rhino processes found.
)

REM Step 2: Remove registry entries by GUID
echo.
echo [INFO] Removing registry entries by GUID...

REM Remove current GUID
echo [INFO] Removing registry entries for current GUID: %CURRENT_GUID%
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%CURRENT_GUID%" /f 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Removed registry entries for current GUID
) else (
    echo [INFO] No registry entries found for current GUID
)

REM Remove old GUID
echo [INFO] Removing registry entries for old GUID: %OLD_GUID%
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%OLD_GUID%" /f 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Removed registry entries for old GUID
) else (
    echo [INFO] No registry entries found for old GUID
)

REM Step 3: Search and remove any registry entries containing "Heatherwick"
echo.
echo [INFO] Searching for any other Heatherwick-related registry entries...
set "found_entries=0"
for /f "tokens=*" %%i in ('reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins" /s 2^>nul ^| findstr /i "heatherwick"') do (
    set /a found_entries+=1
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
if %found_entries% equ 0 (
    echo [INFO] No additional Heatherwick-related registry entries found
)

REM Step 4: Search and remove entries pointing to build output directory
echo.
echo [INFO] Searching for entries pointing to build output directory...
set "found_build_entries=0"
for /f "tokens=*" %%i in ('reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins" /s 2^>nul ^| findstr /i "Heatherwick Studio Toolbar\\bin\\Debug"') do (
    set /a found_build_entries+=1
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
if %found_build_entries% equ 0 (
    echo [INFO] No build output registry entries found
)

REM Step 5: Clean up toolbar references
echo.
echo [INFO] Cleaning up toolbar references...
reg delete "HKCU\Software\McNeel\Rhinoceros\8.0\Toolbars" /v "Heatherwick Studio Toolbar" /f 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Removed toolbar reference
) else (
    echo [INFO] No toolbar reference found
)

REM Step 6: Remove plugin files
echo.
echo [INFO] Removing plugin files...

REM Remove from Yak installation directory
if exist "%APPDATA_PATH%\%PLUGIN_NAME%" (
    echo [INFO] Removing plugin directory: %APPDATA_PATH%\%PLUGIN_NAME%
    rmdir /s /q "%APPDATA_PATH%\%PLUGIN_NAME%" 2>nul
    if !errorlevel! equ 0 (
        echo [SUCCESS] Plugin directory removed
    ) else (
        echo [WARNING] Failed to remove plugin directory
    )
) else (
    echo [INFO] Plugin directory not found: %APPDATA_PATH%\%PLUGIN_NAME%
)

REM Remove from build output (if it exists and is different from current location)
if exist "%BUILD_OUTPUT_PATH%" (
    echo [INFO] Checking build output directory: %BUILD_OUTPUT_PATH%
    if not "%BUILD_OUTPUT_PATH%"=="%CD%\bin\Debug\net7.0" (
        echo [INFO] Removing build output directory
        rmdir /s /q "%BUILD_OUTPUT_PATH%" 2>nul
        if !errorlevel! equ 0 (
            echo [SUCCESS] Build output directory removed
        ) else (
            echo [WARNING] Failed to remove build output directory
        )
    ) else (
        echo [INFO] Skipping current build output directory
    )
)

REM Step 7: Clean up temporary files
echo.
echo [INFO] Cleaning up temporary files...
del /q "%TEMP%\Heatherwick*" 2>nul
if !errorlevel! equ 0 (
    echo [SUCCESS] Temporary files cleaned
) else (
    echo [INFO] No temporary files found
)

REM Step 8: Verify uninstallation
echo.
echo [INFO] Verifying uninstallation...

set "verification_passed=0"
set "verification_failed=0"

REM Check if plugin directory still exists
if exist "%APPDATA_PATH%\%PLUGIN_NAME%" (
    echo [❌] Plugin directory still exists
    set /a verification_failed+=1
) else (
    echo [✅] Plugin directory removed
    set /a verification_passed+=1
)

REM Check if registry entries still exist
reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%CURRENT_GUID%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [❌] Registry entries still exist (current GUID)
    set /a verification_failed+=1
) else (
    echo [✅] Registry entries removed (current GUID)
    set /a verification_passed+=1
)

reg query "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\%OLD_GUID%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [❌] Registry entries still exist (old GUID)
    set /a verification_failed+=1
) else (
    echo [✅] Registry entries removed (old GUID)
    set /a verification_passed+=1
)

REM Final summary
echo.
echo ========================================
echo Uninstallation Complete
echo ========================================
echo.
echo [INFO] Verification results:
echo [INFO] - Passed: %verification_passed%
echo [INFO] - Failed: %verification_failed%
echo.

if %verification_failed% gtr 0 (
    echo [WARNING] Some components may not have been fully removed
    echo [INFO] You may need to manually clean up remaining files
    echo [INFO] Consider running as administrator for complete cleanup
) else (
    echo [SUCCESS] All components successfully removed!
)

echo.
echo Next steps:
echo 1. Restart Rhino 8 to ensure all changes take effect
echo 2. The plugin will no longer load automatically
echo 3. Any custom toolbars using this plugin will need to be reconfigured
echo.
echo If you need to reinstall the plugin, use the Yak package installer.
echo.

pause 