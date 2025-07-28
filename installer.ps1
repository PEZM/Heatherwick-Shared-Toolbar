#Requires -Version 5.1

<#
.SYNOPSIS
    Heatherwick Studio Toolbar Plugin Installer
    
.DESCRIPTION
    This script installs the Heatherwick Studio Toolbar plugin for Rhino 8.
    It handles all necessary files, dependencies, and registry entries.
    
.PARAMETER Force
    Skip confirmation prompts and install automatically
    
.PARAMETER LogFile
    Path to log file for installation details
    
.EXAMPLE
    .\installer.ps1
    .\installer.ps1 -Force
    .\installer.ps1 -LogFile "C:\temp\install.log"
#>

param(
    [switch]$Force,
    [string]$LogFile
)

# ========================================
# Heatherwick Studio Toolbar Installer
# ========================================
# Version: 1.0.0
# ========================================

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    
    if ($LogFile) {
        Add-Content -Path $LogFile -Value $logMessage
    }
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-RhinoRunning {
    $rhinoProcesses = Get-Process -Name "Rhino" -ErrorAction SilentlyContinue
    return $rhinoProcesses.Count -gt 0
}

function Install-Plugin {
    Write-Log "Starting Heatherwick Studio Toolbar installation..."
    
    # Check administrator privileges
    if (Test-Administrator) {
        Write-Log "Running with administrator privileges" "SUCCESS"
    } else {
        Write-Log "Not running as administrator - some operations may fail" "WARNING"
    }
    
    # Check if Rhino is running
    if (Test-RhinoRunning) {
        Write-Log "Rhino is currently running" "WARNING"
        if (-not $Force) {
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                Write-Log "Installation cancelled by user"
                return $false
            }
        }
    }
    
    # Define paths
    $appDataPath = "$env:APPDATA\McNeel\Rhinoceros\8.0\packages"
    $pluginName = "HeatherwickStudioToolbar"
    $pluginDir = Join-Path $appDataPath $pluginName
    $sourceDir = "bin\Debug\net7.0"
    
    Write-Log "Installing to: $pluginDir"
    
    # Check source directory
    if (-not (Test-Path $sourceDir)) {
        Write-Log "Source directory not found: $sourceDir" "ERROR"
        Write-Log "Please build the project first (Build Solution in Visual Studio)" "ERROR"
        return $false
    }
    
    # Check required files
    $requiredFiles = @(
        "Heatherwick Studio Toolbar.rhp",
        "Heatherwick Studio Toolbar.rui",
        "Heatherwick Studio Toolbar.deps.json",
        "Heatherwick Studio Toolbar.runtimeconfig.json",
        "System.Drawing.Common.dll",
        "Microsoft.Win32.SystemEvents.dll"
    )
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $sourceDir $file
        if (-not (Test-Path $filePath)) {
            Write-Log "Required file not found: $file" "ERROR"
            Write-Log "Please build the project first (Build Solution in Visual Studio)" "ERROR"
            return $false
        }
    }
    
    try {
        # Create plugin directory
        Write-Log "Creating plugin directory..."
        if (-not (Test-Path $pluginDir)) {
            New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
            Write-Log "Created plugin directory" "SUCCESS"
        } else {
            Write-Log "Plugin directory already exists"
        }
        
        # Create runtimes directory
        $runtimesDir = Join-Path $pluginDir "runtimes"
        if (-not (Test-Path $runtimesDir)) {
            New-Item -ItemType Directory -Path $runtimesDir -Force | Out-Null
            Write-Log "Created runtimes directory"
        }
        
        # Copy main plugin files
        Write-Log "Copying plugin files..."
        $mainFiles = @(
            "Heatherwick Studio Toolbar.rhp",
            "Heatherwick Studio Toolbar.rui",
            "Heatherwick Studio Toolbar.deps.json",
            "Heatherwick Studio Toolbar.runtimeconfig.json",
            "System.Drawing.Common.dll",
            "Microsoft.Win32.SystemEvents.dll"
        )
        
        foreach ($file in $mainFiles) {
            $sourceFile = Join-Path $sourceDir $file
            $destFile = Join-Path $pluginDir $file
            Copy-Item -Path $sourceFile -Destination $destFile -Force
        }
        
        # Copy PDB file for debugging (optional)
        $pdbFile = Join-Path $sourceDir "Heatherwick Studio Toolbar.pdb"
        if (Test-Path $pdbFile) {
            Copy-Item -Path $pdbFile -Destination $pluginDir -Force
            Write-Log "Copied debug symbols"
        }
        
        # Copy runtimes directory if it exists
        $sourceRuntimes = Join-Path $sourceDir "runtimes"
        if (Test-Path $sourceRuntimes) {
            Copy-Item -Path "$sourceRuntimes\*" -Destination $runtimesDir -Recurse -Force
            Write-Log "Copied runtime dependencies"
        }
        
        Write-Log "All files copied successfully" "SUCCESS"
        
        # Create manifest file
        Write-Log "Creating package manifest..."
        $manifestContent = @"
package: HeatherwickStudioToolbar
version: 1.0.0
description: Shared Toolbar Framework for Heatherwick Studio Plugins
authors: Heatherwick Studio
repository: https://github.com/heatherwickstudio/rhino-toolbar
keywords: [rhino, toolbar, heatherwick]
engines: >=8.0
platforms: [windows]
license: MIT
icon: EmbeddedResources/plugin-utility.ico
files:
  - source: Heatherwick Studio Toolbar.rhp
  - source: Heatherwick Studio Toolbar.rui
  - source: *.dll
  - source: *.json
  - source: runtimes/**
"@
        
        $manifestPath = Join-Path $pluginDir "manifest.yml"
        Set-Content -Path $manifestPath -Value $manifestContent
        Write-Log "Package manifest created" "SUCCESS"
        
        # Create registry entries
        Write-Log "Setting up registry entries..."
        $registryPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Plug-ins\$pluginName"
        
        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $registryPath -Name "Name" -Value "HeatherwickStudioToolbar" -Type String
        Set-ItemProperty -Path $registryPath -Name "Path" -Value (Join-Path $pluginDir "Heatherwick Studio Toolbar.rhp") -Type String
        Set-ItemProperty -Path $registryPath -Name "LoadMode" -Value 1 -Type DWord
        
        Write-Log "Registry entries created" "SUCCESS"
        
        # Verify installation
        Write-Log "Verifying installation..."
        $verifyFiles = @(
            "Heatherwick Studio Toolbar.rhp",
            "Heatherwick Studio Toolbar.rui",
            "Heatherwick Studio Toolbar.deps.json",
            "Heatherwick Studio Toolbar.runtimeconfig.json",
            "System.Drawing.Common.dll",
            "Microsoft.Win32.SystemEvents.dll",
            "manifest.yml"
        )
        
        $verificationFailed = $false
        foreach ($file in $verifyFiles) {
            $filePath = Join-Path $pluginDir $file
            if (Test-Path $filePath) {
                Write-Log "✓ $file" "SUCCESS"
            } else {
                Write-Log "✗ $file - MISSING" "ERROR"
                $verificationFailed = $true
            }
        }
        
        if ($verificationFailed) {
            Write-Log "Some files are missing from the installation" "WARNING"
        } else {
            Write-Log "All files verified successfully" "SUCCESS"
        }
        
        return $true
        
    } catch {
        Write-Log "Installation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Heatherwick Studio Toolbar Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $Force) {
        Write-Host "This will install the Heatherwick Studio Toolbar plugin for Rhino 8."
        Write-Host "The plugin will be installed to your Rhino packages directory."
        Write-Host ""
        $confirm = Read-Host "Continue with installation? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Log "Installation cancelled by user"
            exit 0
        }
        Write-Host ""
    }
    
    $success = Install-Plugin
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    if ($success) {
        Write-Host "Installation Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Plugin installed to: $env:APPDATA\McNeel\Rhinoceros\8.0\packages\HeatherwickStudioToolbar" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor White
        Write-Host "1. Restart Rhino 8" -ForegroundColor White
        Write-Host "2. The plugin should load automatically" -ForegroundColor White
        Write-Host "3. Use 'Heatherwick_ListCommands' to see available commands" -ForegroundColor White
        Write-Host "4. Use 'Heatherwick_LoadToolbar' for toolbar instructions" -ForegroundColor White
        Write-Host "5. To add commands to a toolbar:" -ForegroundColor White
        Write-Host "   - Right-click on any toolbar" -ForegroundColor White
        Write-Host "   - Select 'Customize'" -ForegroundColor White
        Write-Host "   - Search for 'Heatherwick'" -ForegroundColor White
        Write-Host "   - Drag commands to your toolbar" -ForegroundColor White
        Write-Host ""
        Write-Host "For troubleshooting, see the README.md file" -ForegroundColor White
    } else {
        Write-Host "Installation Failed!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check the error messages above and try again." -ForegroundColor Red
        Write-Host "Make sure the project is built before running the installer." -ForegroundColor Red
    }
    
} catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
} finally {
    if (-not $Force) {
        Write-Host ""
        Read-Host "Press Enter to continue"
    }
} 