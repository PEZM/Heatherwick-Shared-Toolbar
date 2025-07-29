@echo off
setlocal enabledelayedexpansion

REM ========================================
REM Heatherwick Studio Toolbar Installer
REM ========================================
REM This script installs the Heatherwick Studio Toolbar plugin for Rhino 8
REM Version: 1.0.1
REM ========================================

echo.
echo ========================================
echo Heatherwick Studio Toolbar Installer
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
set APPDATA_PATH=%APPDATA%\McNeel\Rhinoceros\packages\8.0
set PLUGIN_NAME=Heatherwick-Studio-Toolbar
set PLUGIN_DIR=%APPDATA_PATH%\%PLUGIN_NAME%

echo [INFO] Installing to: %PLUGIN_DIR%
echo.

REM Check if source files exist
set SOURCE_DIR=bin\Debug\net7.0
if not exist "%SOURCE_DIR%" (
    echo [ERROR] Source directory not found: %SOURCE_DIR%
    echo [ERROR] Please build the project first (Build Solution in Visual Studio)
    echo.
    pause
    exit /b 1
)

REM Check for required files
set REQUIRED_FILES=Heatherwick Studio Toolbar.rhp,Heatherwick Studio Toolbar.rui,Heatherwick Studio Toolbar.deps.json,Heatherwick Studio Toolbar.runtimeconfig.json,System.Drawing.Common.dll,Microsoft.Win32.SystemEvents.dll

for %%f in (%REQUIRED_FILES%) do (
    if not exist "%SOURCE_DIR%\%%f" (
        echo [ERROR] Required file not found: %%f
        echo [ERROR] Please build the project first (Build Solution in Visual Studio)
        echo.
        pause
        exit /b 1
    )
)

REM Create the plugin directory
echo [INFO] Creating plugin directory...
if not exist "%PLUGIN_DIR%" (
    mkdir "%PLUGIN_DIR%"
    if !errorLevel! neq 0 (
        echo [ERROR] Failed to create directory: %PLUGIN_DIR%
        pause
        exit /b 1
    )
    echo [SUCCESS] Created plugin directory
) else (
    echo [INFO] Plugin directory already exists
)

REM Create runtimes directory
if not exist "%PLUGIN_DIR%\runtimes" (
    mkdir "%PLUGIN_DIR%\runtimes"
    echo [INFO] Created runtimes directory
)

REM Copy main plugin files
echo [INFO] Copying plugin files...
copy "%SOURCE_DIR%\Heatherwick Studio Toolbar.rhp" "%PLUGIN_DIR%\" >nul
if !errorLevel! neq 0 (
    echo [ERROR] Failed to copy plugin file
    pause
    exit /b 1
)

copy "%SOURCE_DIR%\Heatherwick Studio Toolbar.rui" "%PLUGIN_DIR%\" >nul
if !errorLevel! neq 0 (
    echo [ERROR] Failed to copy toolbar file
    pause
    exit /b 1
)

REM Copy dependency files
copy "%SOURCE_DIR%\Heatherwick Studio Toolbar.deps.json" "%PLUGIN_DIR%\" >nul
copy "%SOURCE_DIR%\Heatherwick Studio Toolbar.runtimeconfig.json" "%PLUGIN_DIR%\" >nul
copy "%SOURCE_DIR%\System.Drawing.Common.dll" "%PLUGIN_DIR%\" >nul
copy "%SOURCE_DIR%\Microsoft.Win32.SystemEvents.dll" "%PLUGIN_DIR%\" >nul

REM Copy PDB file for debugging (optional)
if exist "%SOURCE_DIR%\Heatherwick Studio Toolbar.pdb" (
    copy "%SOURCE_DIR%\Heatherwick Studio Toolbar.pdb" "%PLUGIN_DIR%\" >nul
    echo [INFO] Copied debug symbols
)

REM Copy runtimes directory if it exists
if exist "%SOURCE_DIR%\runtimes" (
    xcopy "%SOURCE_DIR%\runtimes" "%PLUGIN_DIR%\runtimes" /E /I /Y >nul
    echo [INFO] Copied runtime dependencies
)

echo [SUCCESS] All files copied successfully
echo.

REM Create manifest file for package management
echo [INFO] Creating package manifest...
(
echo package: Heatherwick-Studio-Toolbar
echo version: 1.0.1
echo description: Shared Toolbar Framework for Heatherwick Studio Plugins
echo authors: Heatherwick Studio
echo repository: https://github.com/heatherwickstudio/rhino-toolbar
echo keywords: [rhino, toolbar, heatherwick]
echo engines: ^>=8.0
echo platforms: [windows]
echo license: MIT
echo icon: EmbeddedResources/plugin-utility.ico
echo files:
echo   - source: Heatherwick Studio Toolbar.rhp
echo   - source: Heatherwick Studio Toolbar.rui
echo   - source: *.dll
echo   - source: *.json
echo   - source: runtimes/**
) > "%PLUGIN_DIR%\manifest.yml"

echo [SUCCESS] Package manifest created
echo.

REM Create registry entries for auto-loading (optional)
echo [INFO] Setting up registry entries...
reg add "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\Heatherwick-Studio-Toolbar" /v "Name" /t REG_SZ /d "Heatherwick-Studio-Toolbar" /f >nul 2>&1
reg add "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\Heatherwick-Studio-Toolbar" /v "Path" /t REG_SZ /d "%PLUGIN_DIR%\Heatherwick Studio Toolbar.rhp" /f >nul 2>&1
reg add "HKCU\Software\McNeel\Rhinoceros\8.0\Plug-ins\Heatherwick-Studio-Toolbar" /v "LoadMode" /t REG_DWORD /d 1 /f >nul 2>&1

echo [SUCCESS] Registry entries created
echo.

REM Verify installation
echo [INFO] Verifying installation...
set VERIFY_FILES=Heatherwick Studio Toolbar.rhp,Heatherwick Studio Toolbar.rui,Heatherwick Studio Toolbar.deps.json,Heatherwick Studio Toolbar.runtimeconfig.json,System.Drawing.Common.dll,Microsoft.Win32.SystemEvents.dll,manifest.yml

for %%f in (%VERIFY_FILES%) do (
    if exist "%PLUGIN_DIR%\%%f" (
        echo [✓] %%f
    ) else (
        echo [✗] %%f - MISSING
        set VERIFY_FAILED=1
    )
)

if defined VERIFY_FAILED (
    echo.
    echo [WARNING] Some files are missing from the installation
) else (
    echo.
    echo [SUCCESS] All files verified successfully
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Plugin installed to: %PLUGIN_DIR%
echo.
echo Next steps:
echo 1. Restart Rhino 8
echo 2. The plugin should load automatically
echo 3. Use 'Heatherwick_ListCommands' to see available commands
echo 4. Use 'Heatherwick_LoadToolbar' for toolbar instructions
echo 5. To add commands to a toolbar:
echo    - Right-click on any toolbar
echo    - Select 'Customize'
echo    - Search for 'Heatherwick'
echo    - Drag commands to your toolbar
echo.
echo For troubleshooting, see the README.md file
echo.
pause 