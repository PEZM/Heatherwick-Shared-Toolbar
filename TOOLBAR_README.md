# Heatherwick Studio Toolbar

A shared toolbar framework for Rhino 8 that provides a centralized interface for all Heatherwick Studio plugins.

## Installation

### Quick Install
1. Run the `install.bat` script in this directory
2. Restart Rhino 8
3. The plugin will load automatically
4. The toolbar will be automatically loaded because the RUI file has the same name as the RHP file

### Manual Install
1. Copy `bin\Debug\net7.0\Heatherwick Studio Toolbar.rhp` to:
   `%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`
2. Copy `bin\Debug\net7.0\Heatherwick Studio Toolbar.rui` to:
   `%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`
3. Restart Rhino 8
4. The toolbar will be automatically loaded because the RUI file has the same name as the RHP file

## Using the Toolbar

### Available Commands

The plugin provides two main commands:

1. **Heatherwick_ListCommands** - Lists all registered Heatherwick Studio commands
2. **Heatherwick_LoadToolbar** - Shows toolbar status and instructions

### Adding Commands to Toolbars

1. Right-click on any toolbar in Rhino
2. Select "Customize"
3. In the search box, type "Heatherwick"
4. Drag the desired commands to your toolbar
5. Click "OK" to save

### Using Commands

- **Command Line**: Type the command name in Rhino's command line
- **Toolbar**: Click the button on your toolbar
- **Menu**: Commands can be added to menus through the Customize dialog

## Features

### Shared Toolbar Framework
- Centralized command registration system
- Automatic categorization of commands
- Icon support for buttons
- Easy integration for other plugins

### Command Categories
- **Utilities**: General utility commands
- **Custom**: User-defined categories

### Plugin Integration
Other plugins can easily register their commands with this framework:

```csharp
// In your plugin's OnLoad method
DynamicToolbarManager.Instance.RegisterButton(
    this.Id.ToString(),
    "YourCommandName",
    yourIcon,
    "Your command tooltip",
    "Your Category"
);
```

## Troubleshooting

### Plugin Not Loading
1. Check that the `.rhp` file is in the correct location
2. Verify Rhino 8 is installed
3. Check Rhino's plugin manager for error messages

### Commands Not Available
1. Type `Heatherwick_ListCommands` to see all available commands
2. Restart Rhino if commands don't appear
3. Check the command line for error messages

### Toolbar Not Appearing
1. Commands are available through the command line even without a visible toolbar
2. Add commands to existing toolbars using the Customize dialog
3. The toolbar file (`.rui`) provides a template for creating toolbars
4. **Important**: The RUI file must have the exact same name as the RHP file for automatic loading
5. Check that both files are in the same directory: `%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`

## Development

### Building the Plugin
```bash
dotnet build
```

### Testing
1. Build the project
2. Run `install.bat` to install
3. Restart Rhino 8
4. Test commands in the command line

### Adding New Commands
1. Create a new command class inheriting from `Rhino.Commands.Command`
2. Register the command in the plugin's `OnLoad` method
3. Add the command to the toolbar file if desired

## File Structure

```
Heatherwick Studio Toolbar/
├── Heatherwick_ToolbarPlugin.cs      # Main plugin class
├── Heatherwick_ToolbarCommand.cs     # Command implementations
├── SharedToolbarFramework.cs         # Shared framework
├── Heatherwick Studio Toolbar.rui    # Toolbar definition
├── install.bat                       # Installation script
└── TOOLBAR_README.md                 # This file
```

## Support

For issues or questions:
1. Check the command line output for error messages
2. Use `Heatherwick_ListCommands` to verify plugin loading
3. Restart Rhino and try again
4. Check that all files are in the correct locations 