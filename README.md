# Heatherwick Studio Toolbar Framework

A centralized toolbar management system for Rhino 8 that allows all Heatherwick Studio plugins to share a common toolbar interface.

## Overview

This framework provides a unified toolbar experience across all Heatherwick Studio plugins. The toolbar automatically loads with Rhino 8 and provides a centralized location for all plugin commands. The implementation uses Rhino 8's native RUI format for maximum compatibility.

## Features

- **Automatic Loading**: Toolbar loads automatically when Rhino starts
- **Native RUI Format**: Uses Rhino 8's standard toolbar format
- **Easy Integration**: Simple API for plugin developers to register their commands
- **Automatic Installation**: Post-build action automatically installs files
- **Command Discovery**: All commands are automatically discoverable in Rhino's Customize dialog
- **Error Handling**: Robust error handling with detailed logging

## Installation

### Yak Package Installation (Recommended)
1. Download the latest `.yak` package from the releases
2. Double-click the `.yak` file or drag it into Rhino's Package Manager
3. The plugin will be installed to: `%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`

### Manual Installation
The plugin can also be installed manually by copying files to:
`%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`

## Uninstallation

### Comprehensive Uninstaller (Recommended)
Use the new comprehensive uninstaller for complete cleanup:

**Batch Version:**
```cmd
uninstaller_v2.bat
```

**PowerShell Version (More Robust):**
```powershell
.\uninstaller_v2.ps1
```

The comprehensive uninstaller will:
- ✅ Remove all registry entries (current and old GUIDs)
- ✅ Search and remove any Heatherwick-related registry entries
- ✅ Remove entries pointing to build output directories
- ✅ Clean up toolbar references
- ✅ Remove plugin files from Yak installation directory
- ✅ Clean up temporary files
- ✅ Verify complete removal
- ✅ Provide detailed status reporting

### Legacy Uninstaller
The old uninstaller (`uninstaller.bat`/`uninstaller.ps1`) is still available but may not remove all registry entries completely.

## Quick Start for Plugin Developers

### 1. Add Reference

Add a reference to this plugin's assembly in your plugin project.

### 2. Add Using Statement

```csharp
using HeatherwickStudio.SharedToolbar;
```

### 3. Register Your Commands

In your plugin's `OnLoad` method:

```csharp
protected override LoadReturnCode OnLoad(ref string errorMessage)
{
    try
    {
        // Register your commands with the shared toolbar
        ToolbarHelper.RegisterPluginButton(
            this.Id.ToString(),
            "YourCommandName",
            "your-icon.png",
            "Your command tooltip",
            "Your Category",
            this.GetType().Assembly
        );
        
        return LoadReturnCode.Success;
    }
    catch (Exception ex)
    {
        errorMessage = $"Failed to load plugin: {ex.Message}";
        return LoadReturnCode.ErrorShowDialog;
    }
}
```

### 4. Create Your Command

```csharp
[System.Runtime.InteropServices.Guid("your-unique-guid")]
public class YourCommand : Command
{
    public override string EnglishName => "YourCommandName";

    protected override Result RunCommand(RhinoDoc doc, RunMode mode)
    {
        // Your command implementation
        RhinoApp.WriteLine("Your command executed successfully!");
        return Result.Success;
    }
}
```

### 5. Unregister on Shutdown

In your plugin's `OnShutdown` method:

```csharp
protected override void OnShutdown()
{
    DynamicToolbarManager.Instance.UnregisterButton(this.Id.ToString(), "YourCommandName");
}
```

## RUI File Format

The toolbar uses Rhino 8's native RUI format:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RhinoUI major_ver="5" minor_ver="0" guid="your-plugin-guid">
  <tool_bar_groups>
    <tool_bar_group guid="group-guid">
      <text>
        <locale_1033>Your Toolbar Group</locale_1033>
      </text>
      <tool_bar_item guid="item-guid">
        <left_macro_id>macro-guid</left_macro_id>
      </tool_bar_item>
    </tool_bar_group>
  </tool_bar_groups>
  <tool_bars>
    <tool_bar guid="toolbar-guid" visible="true">
      <text>
        <locale_1033>Your Toolbar</locale_1033>
      </text>
      <tool_bar_item guid="item-guid">
        <left_macro_id>macro-guid</left_macro_id>
      </tool_bar_item>
    </tool_bar>
  </tool_bars>
  <macros>
    <macro_item guid="macro-guid">
      <text>
        <locale_1033>Your Command</locale_1033>
      </text>
      <tooltip>
        <locale_1033>Your command tooltip</locale_1033>
      </tooltip>
      <script>!_YourCommandName</script>
    </macro_item>
  </macros>
</RhinoUI>
```

## API Reference

### ToolbarHelper Class

#### RegisterPluginButton

```csharp
public static void RegisterPluginButton(
    string pluginId,           // Your plugin's unique identifier
    string commandName,        // Name of the command to execute
    string iconResourceName,   // Name of the icon resource
    string tooltip,           // Tooltip text for the button
    string category = "General", // Optional category for grouping
    Assembly assembly = null   // Assembly containing the icon resource
)
```

### DynamicToolbarManager Class

#### Direct Registration

```csharp
// For more control over icon loading
var icon = LoadYourIcon();
DynamicToolbarManager.Instance.RegisterButton(
    pluginId, commandName, icon, tooltip, category
);
```

#### Unregister Button

```csharp
DynamicToolbarManager.Instance.UnregisterButton(pluginId, commandName);
```

#### Get All Buttons

```csharp
var buttons = DynamicToolbarManager.Instance.GetRegisteredButtons();
```

#### Clear All Buttons

```csharp
DynamicToolbarManager.Instance.ClearAllButtons();
```

## Icon Requirements

- **Size**: 24x24 or 32x32 pixels recommended
- **Format**: PNG or ICO
- **Embedding**: Must be embedded as resources in your plugin assembly
- **Naming**: Use consistent naming like `YourPluginName.Resources.icon-name.png`

### Embedding Icons

1. Add your icon files to your project
2. Set the build action to "Embedded Resource"
3. Ensure the resource name matches what you specify in the registration

## Categories

Organize your buttons into categories for better organization:

- `"General"` - Default category
- `"Modeling"` - Modeling tools
- `"Analysis"` - Analysis tools
- `"Utilities"` - Utility functions
- `"Custom Category"` - Your own categories

## Project Configuration

### Post-Build Installation

The project includes automatic post-build installation:

```xml
<Target Name="PostBuild" AfterTargets="PostBuildEvent">
  <Exec Command="if not exist &quot;$(APPDATA)\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\&quot; mkdir &quot;$(APPDATA)\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\&quot;&#xD;&#xA;copy &quot;$(TargetDir)*.dll&quot; &quot;$(APPDATA)\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\&quot;&#xD;&#xA;copy &quot;$(TargetDir)*.pdb&quot; &quot;$(APPDATA)\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\&quot;&#xD;&#xA;copy &quot;$(TargetDir)*.rui&quot; &quot;$(APPDATA)\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\&quot;" />
</Target>
```

### RUI File Inclusion

```xml
<ItemGroup>
  <None Update="YourToolbar.rui">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
  </None>
</ItemGroup>
```

## Example Plugin Integration

### Complete Example

```csharp
using Rhino;
using Rhino.PlugIns;
using Rhino.Commands;
using HeatherwickStudio.SharedToolbar;

namespace YourPlugin
{
    public class YourPlugin : PlugIn
    {
        protected override LoadReturnCode OnLoad(ref string errorMessage)
        {
            try
            {
                // Register commands with the shared toolbar
                ToolbarHelper.RegisterPluginButton(
                    this.Id.ToString(),
                    "YourCommand",
                    "your-icon.png",
                    "Execute your command",
                    "Your Category",
                    this.GetType().Assembly
                );
                
                return LoadReturnCode.Success;
            }
            catch (Exception ex)
            {
                errorMessage = $"Failed to load plugin: {ex.Message}";
                return LoadReturnCode.ErrorShowDialog;
            }
        }

        protected override void OnShutdown()
        {
            DynamicToolbarManager.Instance.UnregisterButton(this.Id.ToString(), "YourCommand");
        }
    }

    [System.Runtime.InteropServices.Guid("your-unique-guid")]
    public class YourCommand : Command
    {
        public override string EnglishName => "YourCommand";

        protected override Result RunCommand(RhinoDoc doc, RunMode mode)
        {
            RhinoApp.WriteLine("Your command executed successfully!");
            return Result.Success;
        }
    }
}
```

## File Structure

```
Heatherwick Studio Toolbar/
├── SharedToolbarFramework.cs      # Core framework classes
├── Heatherwick_ToolbarPlugin.cs   # Main plugin implementation
├── Heatherwick_ToolbarCommand.cs  # Example commands
├── Heatherwick Studio Toolbar.rui # RUI toolbar definition
├── EmbeddedResources/             # Icons and resources
└── README.md                      # This file
```

## Troubleshooting

### Common Issues

1. **Commands not appearing**: Ensure commands have proper `[Guid]` attributes
2. **Toolbar not loading**: Check that RUI file name matches RHP file name exactly
3. **Icons not loading**: Verify icons are embedded as resources with correct names

### Debug Information

The framework provides logging to the Rhino command line. Check for messages starting with "Heatherwick Studio Toolbar" for debugging information.

## Support

For issues or questions about this framework, please refer to the troubleshooting section above or check the Rhino command line for detailed error messages.

## Current Status

### ✅ Working Features
- Plugin loads successfully in Rhino 8
- Commands are properly registered and discoverable
- Embedded resources (icons) are found and loaded correctly
- Dynamic toolbar framework initializes without errors
- Yak package distribution works correctly
- All essential commands (`Heatherwick_ListCommands`, `Heatherwick_LoadToolbar`) are functional

### ❌ Known Limitations
- **Toolbar Icons Not Displaying**: While the `DynamicToolbarManager` framework successfully loads icons from embedded resources, they are not displayed in Rhino's native toolbar UI. The toolbar shows generic mouse pointer icons instead of the custom icons.
- **Framework Integration Issue**: The custom `DynamicToolbarManager` and `ToolbarHelper` classes appear to be designed for a different toolbar system than Rhino's native toolbar implementation.

### 🔧 Next Steps
1. **Investigate Native Rhino Toolbar Integration**: Research how to properly integrate custom icons with Rhino's native toolbar system
2. **Alternative Icon Loading Methods**: Explore direct command icon assignment or Rhino-specific toolbar customization APIs
3. **Framework Refactoring**: Consider simplifying the approach by removing the custom framework and using Rhino's built-in toolbar capabilities
4. **Cross-Plugin Icon Loading**: Once basic icon display is working, implement the ability to load icons from other plugins

### Technical Details
- Icons are successfully embedded and loaded: `ListCommands.ico` (109KB) and `plugin-utility.ico` (103KB)
- The `LoadIconFromResources` method correctly finds resources using the pattern `Heatherwick_Studio_Toolbar.EmbeddedResources.{iconName}`
- Commands are registered with the framework but the visual representation in Rhino's UI is not updated

## License

This framework is provided as-is for internal Heatherwick Studio use. 