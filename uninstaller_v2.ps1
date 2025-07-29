# Heatherwick Studio Toolbar Uninstaller v2.0 (PowerShell)
# Comprehensive uninstaller with robust registry cleanup

param(
    [switch]$Force,
    [switch]$Verbose
)

# Configuration
$PluginName = "Heatherwick-Studio-Toolbar"
$AppDataPath = "$env:APPDATA\McNeel\Rhinoceros\packages\8.0"
$CurrentGuid = "12345678-1234-1234-1234-123456789abc"
$OldGuid = "3856c5bd-1cf1-4bf3-9322-3111c1b2907c"
$BuildOutputPath = "$env:USERPROFILE\OneDrive - Heatherwick Studio\Ge-CoDe - Internal\AppDev\Heatherwick Studio Toolbar\bin\Debug\net7.0"

# Registry paths
$RhinoPluginsPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Plug-ins"
$RhinoToolbarsPath = "HKCU:\Software\McNeel\Rhinoceros\8.0\Toolbars"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-RegistryEntry {
    param(
        [string]$Path,
        [string]$Description
    )
    
    try {
        if (Test-Path $Path) {
            Remove-Item $Path -Recurse -Force
            Write-Success "Removed $Description"
            return $true
        } else {
            Write-Info "No $Description found"
            return $false
        }
    }
    catch {
        Write-Warning "Failed to remove $Description`: $($_.Exception.Message)"
        return $false
    }
}

function Search-And-Remove-RegistryEntries {
    param([string]$SearchPattern, [string]$Description)
    
    Write-Info "Searching for $Description..."
    $foundEntries = 0
    
    try {
        $entries = Get-ChildItem $RhinoPluginsPath -Recurse | Where-Object {
            $_.PSChildName -like "*$SearchPattern*" -or 
            (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue | Where-Object {
                $_.PSObject.Properties | Where-Object { $_.Value -like "*$SearchPattern*" }
            })
        }
        
        foreach ($entry in $entries) {
            $foundEntries++
            Write-Info "Found: $($entry.PSPath)"
            Remove-RegistryEntry -Path $entry.PSPath -Description "registry entry: $($entry.PSChildName)"
        }
        
        if ($foundEntries -eq 0) {
            Write-Info "No $Description found"
        }
    }
    catch {
        Write-Warning "Error searching for $Description`: $($_.Exception.Message)"
    }
    
    return $foundEntries
}

# Main execution
Write-Host "========================================" -ForegroundColor White
Write-Host "Heatherwick Studio Toolbar Uninstaller v2.0" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Info "Plugin name: $PluginName"
Write-Info "Plugin location: $AppDataPath\$PluginName"
Write-Info "Current GUID: $CurrentGuid"
Write-Info "Old GUID: $OldGuid"
Write-Info "Build output path: $BuildOutputPath"
Write-Host ""

# Check for administrator privileges
if (-not (Test-Administrator)) {
    Write-Warning "Not running as administrator - some operations may fail"
    Write-Info "Consider running as administrator for complete cleanup"
    Write-Host ""
}

# Confirmation
if (-not $Force) {
    Write-Warning "This will completely remove the Heatherwick Studio Toolbar plugin."
    Write-Warning "All plugin files, settings, and registry entries will be deleted."
    Write-Host ""
    
    $confirm = Read-Host "Are you sure you want to continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Info "Operation cancelled by user"
        exit 0
    }
}

Write-Host ""
Write-Info "Starting comprehensive uninstallation..."

# Step 1: Check for running Rhino processes
Write-Info "Checking for running Rhino processes..."
$rhinoProcesses = Get-Process -Name "Rhino" -ErrorAction SilentlyContinue
if ($rhinoProcesses) {
    Write-Warning "Rhino is currently running. Please close Rhino and try again."
    Write-Info "This ensures all registry entries are properly released."
    exit 1
} else {
    Write-Info "No running Rhino processes found."
}

# Step 2: Remove registry entries by GUID
Write-Host ""
Write-Info "Removing registry entries by GUID..."

$currentGuidRemoved = Remove-RegistryEntry -Path "$RhinoPluginsPath\$CurrentGuid" -Description "registry entries for current GUID"
$oldGuidRemoved = Remove-RegistryEntry -Path "$RhinoPluginsPath\$OldGuid" -Description "registry entries for old GUID"

# Step 3: Search and remove any registry entries containing "Heatherwick"
$heatherwickEntries = Search-And-Remove-RegistryEntries -SearchPattern "heatherwick" -Description "Heatherwick-related registry entries"

# Step 4: Search and remove entries pointing to build output directory
$buildEntries = Search-And-Remove-RegistryEntries -SearchPattern "Heatherwick Studio Toolbar\bin\Debug" -Description "build output registry entries"

# Step 5: Clean up toolbar references
Write-Host ""
Write-Info "Cleaning up toolbar references..."
try {
    Remove-ItemProperty -Path $RhinoToolbarsPath -Name "Heatherwick Studio Toolbar" -ErrorAction SilentlyContinue
    Write-Success "Removed toolbar reference"
} catch {
    Write-Info "No toolbar reference found"
}

# Step 6: Remove plugin files
Write-Host ""
Write-Info "Removing plugin files..."

# Remove from Yak installation directory
$pluginDir = "$AppDataPath\$PluginName"
if (Test-Path $pluginDir) {
    Write-Info "Removing plugin directory: $pluginDir"
    try {
        Remove-Item $pluginDir -Recurse -Force
        Write-Success "Plugin directory removed"
    } catch {
        Write-Warning "Failed to remove plugin directory: $($_.Exception.Message)"
    }
} else {
    Write-Info "Plugin directory not found: $pluginDir"
}

# Remove from build output (if it exists and is different from current location)
if (Test-Path $BuildOutputPath) {
    Write-Info "Checking build output directory: $BuildOutputPath"
    $currentBuildPath = "$PWD\bin\Debug\net7.0"
    if ($BuildOutputPath -ne $currentBuildPath) {
        Write-Info "Removing build output directory"
        try {
            Remove-Item $BuildOutputPath -Recurse -Force
            Write-Success "Build output directory removed"
        } catch {
            Write-Warning "Failed to remove build output directory: $($_.Exception.Message)"
        }
    } else {
        Write-Info "Skipping current build output directory"
    }
}

# Step 7: Clean up temporary files
Write-Host ""
Write-Info "Cleaning up temporary files..."
try {
    $tempFiles = Get-ChildItem $env:TEMP -Name "Heatherwick*" -ErrorAction SilentlyContinue
    if ($tempFiles) {
        Remove-Item "$env:TEMP\Heatherwick*" -Force
        Write-Success "Temporary files cleaned"
    } else {
        Write-Info "No temporary files found"
    }
} catch {
    Write-Info "No temporary files found"
}

# Step 8: Verify uninstallation
Write-Host ""
Write-Info "Verifying uninstallation..."

$verificationPassed = 0
$verificationFailed = 0

# Check if plugin directory still exists
if (Test-Path $pluginDir) {
    Write-Host "[❌] Plugin directory still exists" -ForegroundColor Red
    $verificationFailed++
} else {
    Write-Host "[✅] Plugin directory removed" -ForegroundColor Green
    $verificationPassed++
}

# Check if registry entries still exist
if (Test-Path "$RhinoPluginsPath\$CurrentGuid") {
    Write-Host "[❌] Registry entries still exist (current GUID)" -ForegroundColor Red
    $verificationFailed++
} else {
    Write-Host "[✅] Registry entries removed (current GUID)" -ForegroundColor Green
    $verificationPassed++
}

if (Test-Path "$RhinoPluginsPath\$OldGuid") {
    Write-Host "[❌] Registry entries still exist (old GUID)" -ForegroundColor Red
    $verificationFailed++
} else {
    Write-Host "[✅] Registry entries removed (old GUID)" -ForegroundColor Green
    $verificationPassed++
}

# Final summary
Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Uninstallation Complete" -ForegroundColor White
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Info "Verification results:"
Write-Info "- Passed: $verificationPassed"
Write-Info "- Failed: $verificationFailed"
Write-Host ""

if ($verificationFailed -gt 0) {
    Write-Warning "Some components may not have been fully removed"
    Write-Info "You may need to manually clean up remaining files"
    Write-Info "Consider running as administrator for complete cleanup"
} else {
    Write-Success "All components successfully removed!"
}

Write-Host ""
Write-Info "Next steps:"
Write-Info "1. Restart Rhino 8 to ensure all changes take effect"
Write-Info "2. The plugin will no longer load automatically"
Write-Info "3. Any custom toolbars using this plugin will need to be reconfigured"
Write-Host ""
Write-Info "If you need to reinstall the plugin, use the Yak package installer."
Write-Host ""

if (-not $Force) {
    Read-Host "Press Enter to continue"
} 