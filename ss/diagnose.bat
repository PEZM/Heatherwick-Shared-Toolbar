@echo off
echo ========================================
echo Heatherwick Studio Toolbar - Diagnostics
echo ========================================
echo.

REM Get the username from environment
set USERNAME=%USERNAME%

REM Define the target directories
set RHINO_PACKAGES_DIR=C:\Users\%USERNAME%\AppData\Roaming\McNeel\Rhinoceros\8.0\packages
set HEATHERWICK_STUDIO_DIR=C:\Users\%USERNAME%\AppData\Roaming\HeatherwickStudio

echo Checking directories...
echo.

echo 1. Rhino Packages Directory:
if exist "%RHINO_PACKAGES_DIR%" (
    echo    [OK] Directory exists: %RHINO_PACKAGES_DIR%
    dir "%RHINO_PACKAGES_DIR%\*.rhp" 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo    [OK] Found .rhp files in directory
    ) else (
        echo    [WARNING] No .rhp files found in directory
    )
) else (
    echo    [ERROR] Directory does not exist: %RHINO_PACKAGES_DIR%
)

echo.

echo 2. Heatherwick Studio Directory:
if exist "%HEATHERWICK_STUDIO_DIR%" (
    echo    [OK] Directory exists: %HEATHERWICK_STUDIO_DIR%
) else (
    echo    [WARNING] Directory does not exist: %HEATHERWICK_STUDIO_DIR%
)

echo.

echo 3. Plugin File Check:
set PLUGIN_FILE=%RHINO_PACKAGES_DIR%\Heatherwick Studio Toolbar.rhp
if exist "%PLUGIN_FILE%" (
    echo    [OK] Plugin file exists: %PLUGIN_FILE%
    for %%A in ("%PLUGIN_FILE%") do (
        echo    File size: %%~zA bytes
        echo    Created: %%~tA
    )
) else (
    echo    [ERROR] Plugin file not found: %PLUGIN_FILE%
)

echo.

echo 4. Build Output Check:
set BUILD_FILE=bin\Release\net7.0\Heatherwick Studio Toolbar.rhp
if exist "%BUILD_FILE%" (
    echo    [OK] Build output exists: %BUILD_FILE%
    for %%A in ("%BUILD_FILE%") do (
        echo    File size: %%~zA bytes
        echo    Created: %%~tA
    )
) else (
    echo    [ERROR] Build output not found: %BUILD_FILE%
)

echo.

echo 5. .NET Version Check:
dotnet --version
if %ERRORLEVEL% EQU 0 (
    echo    [OK] .NET SDK is available
) else (
    echo    [ERROR] .NET SDK not found
)

echo.

echo 6. Rhino Installation Check:
if exist "C:\Program Files\Rhino 8\System\Rhino.exe" (
    echo    [OK] Rhino 8 found in Program Files
) else (
    echo    [WARNING] Rhino 8 not found in Program Files
)

if exist "C:\Program Files\Rhino 8\System\Yak.exe" (
    echo    [OK] Yak executable found
) else (
    echo    [WARNING] Yak executable not found
)

echo.

echo ========================================
echo Diagnostic Complete
echo ========================================
echo.
echo If you see any [ERROR] messages above, those need to be fixed.
echo If you see [WARNING] messages, they might indicate issues.
echo.
echo Next steps:
echo 1. Check Rhino command line for detailed error messages
echo 2. Try building the project again
echo 3. Check Windows Event Viewer for .NET errors
echo 4. Ensure Rhino 8 is up to date
echo.

pause 