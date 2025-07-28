#Requires -Version 5.1

<#
.SYNOPSIS
    Heatherwick Studio Toolbar Plugin Uninstaller
    
.DESCRIPTION
    This script completely removes the Heatherwick Studio Toolbar plugin from Rhino 8.
    It handles all files, directories, and registry entries.
    
.PARAMETER Force
    Skip confirmation prompts and uninstall automatically
    
.PARAMETER LogFile
    Path to log file for uninstallation details
    
.EXAMPLE
    .\uninstaller.ps1
    .\uninstaller.ps1 -Force
    .\uninstaller.ps1 -LogFile "C:\temp\uninstall.log"
#>

param(
    [switch]$Force,
    [string]$LogFile
)

# ========================================
# Heatherwick Studio Toolbar Uninstaller
# ========================================
# Version: 1.0.0
# ========================================

# Set error action preference
$ErrorActionPreference = "Continue"

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

function Uninstall-Plugin {
    Write-Log "Starting Heatherwick Studio Toolbar uninstallation..."
    
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
            $continue = Read-Host "Please close Rhino before continuing. Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                Write-Log "Uninstallation cancelled by user"
                return $false
            }
        }
    }
    
    # Define paths
    $appDataPath = "$env:APPDATA\McNeel\Rhinoceros\8.0\packages"
    $pluginName = "HeatherwickStudioToolbar"
    $pluginDir = Join-Path $appDataPath $pluginName
    
    Write-Log "Plugin location: $pluginDir"
    
    # Check if plugin is installed
    if (-not (Test-Path $pluginDir)) {
        Write-Log "Plugin directory not found - nothing to uninstall" "INFO"
        return $true
    }
    
    try {
        # Remove registry entries
        Write-Log "Removing registry entries..."
        $registryPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Plug-ins\$pluginName"
        
        if (Test-Path $registryPath) {
            Remove-Item -Path $registryPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Registry entries removed" "SUCCESS"
        } else {
            Write-Log "No registry entries found to remove" "INFO"
        }
        
        # Remove toolbar references from Rhino's toolbar list
        Write-Log "Cleaning up toolbar references..."
        $toolbarPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Toolbars"
        if (Test-Path $toolbarPath) {
            Remove-ItemProperty -Path $toolbarPath -Name $pluginName -ErrorAction SilentlyContinue
        }
        
        # Remove from Rhino's plugin list
        $pluginsPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Plug-ins"
        if (Test-Path $pluginsPath) {
            Remove-ItemProperty -Path $pluginsPath -Name $pluginName -ErrorAction SilentlyContinue
        }
        
        # Remove plugin files
        Write-Log "Removing plugin files..."
        if (Test-Path $pluginDir) {
            # List files before deletion
            Write-Log "Files to be removed:"
            Get-ChildItem -Path $pluginDir -Recurse | ForEach-Object {
                Write-Log "  $($_.FullName.Replace($pluginDir, '').TrimStart('\'))"
            }
            
            # Remove all files and subdirectories
            Remove-Item -Path $pluginDir -Recurse -Force
            if (-not (Test-Path $pluginDir)) {
                Write-Log "Plugin directory and all files removed" "SUCCESS"
            } else {
                Write-Log "Failed to remove plugin directory completely" "ERROR"
                Write-Log "You may need to manually delete: $pluginDir" "WARNING"
            }
        } else {
            Write-Log "Plugin directory not found" "INFO"
        }
        
        # Clean up any orphaned files in the packages directory
        Write-Log "Checking for orphaned files..."
        $orphanedFiles = @(
            (Join-Path $appDataPath "Heatherwick Studio Toolbar.rhp"),
            (Join-Path $appDataPath "Heatherwick Studio Toolbar.rui")
        )
        
        foreach ($file in $orphanedFiles) {
            if (Test-Path $file) {
                Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
                Write-Log "Removed orphaned file: $($file.Split('\')[-1])" "INFO"
            }
        }
        
        # Clean up Heatherwick Studio data directory (if empty)
        $heatherwickData = "$env:APPDATA\HeatherwickStudio"
        if (Test-Path $heatherwickData) {
            $items = Get-ChildItem -Path $heatherwickData -ErrorAction SilentlyContinue
            if ($items.Count -eq 0) {
                Remove-Item -Path $heatherwickData -Force -ErrorAction SilentlyContinue
                Write-Log "Removed empty Heatherwick Studio data directory" "INFO"
            }
        }
        
        # Clean up temporary files
        Write-Log "Cleaning up temporary files..."
        $tempPattern = "$env:TEMP\HeatherwickStudio*"
        Get-ChildItem -Path $env:TEMP -Name "HeatherwickStudio*" -ErrorAction SilentlyContinue | ForEach-Object {
            $tempPath = Join-Path $env:TEMP $_
            Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Removed temporary file: $_" "INFO"
        }
        
        return $true
        
    } catch {
        Write-Log "Uninstallation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-Uninstallation {
    Write-Log "Verifying uninstallation..."
    
    $appDataPath = "$env:APPDATA\McNeel\Rhinoceros\8.0\packages"
    $pluginName = "HeatherwickStudioToolbar"
    $pluginDir = Join-Path $appDataPath $pluginName
    $registryPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Plug-ins\$pluginName"
    
    $verificationFailed = $false
    
    # Check plugin directory
    if (-not (Test-Path $pluginDir)) {
        Write-Log "✓ Plugin directory removed" "SUCCESS"
    } else {
        Write-Log "✗ Plugin directory still exists: $pluginDir" "ERROR"
        $verificationFailed = $true
    }
    
    # Check registry entries
    if (-not (Test-Path $registryPath)) {
        Write-Log "✓ Registry entries removed" "SUCCESS"
    } else {
        Write-Log "✗ Registry entries still exist" "ERROR"
        $verificationFailed = $true
    }
    
    # Check for orphaned files
    $orphanedFiles = @(
        (Join-Path $appDataPath "Heatherwick Studio Toolbar.rhp"),
        (Join-Path $appDataPath "Heatherwick Studio Toolbar.rui")
    )
    
    foreach ($file in $orphanedFiles) {
        if (-not (Test-Path $file)) {
            Write-Log "✓ Orphaned file removed: $($file.Split('\')[-1])" "SUCCESS"
        } else {
            Write-Log "✗ Orphaned file still exists: $($file.Split('\')[-1])" "ERROR"
            $verificationFailed = $true
        }
    }
    
    return -not $verificationFailed
}

# Main execution
try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Heatherwick Studio Toolbar Uninstaller" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $Force) {
        Write-Host "This will completely remove the Heatherwick Studio Toolbar plugin."
        Write-Host "All plugin files and settings will be deleted."
        Write-Host ""
        $confirm = Read-Host "Are you sure you want to continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Log "Uninstallation cancelled by user"
            exit 0
        }
        Write-Host ""
    }
    
    $success = Uninstall-Plugin
    
    if ($success) {
        $verificationSuccess = Test-Uninstallation
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        if ($verificationSuccess) {
            Write-Host "Uninstallation Complete!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "The Heatherwick Studio Toolbar plugin has been removed." -ForegroundColor White
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor White
            Write-Host "1. Restart Rhino 8 to ensure all changes take effect" -ForegroundColor White
            Write-Host "2. The plugin will no longer load automatically" -ForegroundColor White
            Write-Host "3. Any custom toolbars using this plugin will need to be reconfigured" -ForegroundColor White
            Write-Host ""
            Write-Host "If you need to reinstall the plugin, run the installer.ps1 script." -ForegroundColor White
        } else {
            Write-Host "Uninstallation Completed with Warnings" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "The plugin has been removed, but some components may not have been fully cleaned up." -ForegroundColor White
            Write-Host "You may need to manually clean up remaining files." -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Uninstallation Failed!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check the error messages above and try again." -ForegroundColor Red
        Write-Host "You may need to manually remove the plugin files." -ForegroundColor Red
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