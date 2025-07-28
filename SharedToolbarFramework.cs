using Rhino;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Versioning;

namespace HeatherwickStudio.SharedToolbar
{
    /// <summary>
    /// Centralized toolbar manager for Heatherwick Studio plugins
    /// This version focuses on command registration and execution
    /// </summary>
    public class DynamicToolbarManager
    {
        private static DynamicToolbarManager _instance;
        private Dictionary<string, ToolbarButton> _registeredButtons;
        private readonly string _toolbarName = "HeatherwickStudio";
        
        public static DynamicToolbarManager Instance
        {
            get
            {
                if (_instance == null)
                    _instance = new DynamicToolbarManager();
                return _instance;
            }
        }
        
        private DynamicToolbarManager()
        {
            _registeredButtons = new Dictionary<string, ToolbarButton>();
        }
        
        /// <summary>
        /// Registers a button for a plugin with the shared toolbar
        /// </summary>
        /// <param name="pluginId">Unique identifier for the plugin</param>
        /// <param name="commandName">Name of the command to execute</param>
        /// <param name="icon">Icon for the button (24x24 or 32x32 recommended)</param>
        /// <param name="tooltip">Tooltip text for the button</param>
        /// <param name="category">Optional category for grouping buttons</param>
        public void RegisterButton(string pluginId, string commandName, 
            Bitmap icon, string tooltip, string category = "General")
        {
            var buttonKey = $"{pluginId}_{commandName}";
            
            if (_registeredButtons.ContainsKey(buttonKey))
            {
                // Update existing button
                _registeredButtons[buttonKey].Icon = icon;
                _registeredButtons[buttonKey].Tooltip = tooltip;
                _registeredButtons[buttonKey].Category = category;
                RhinoApp.WriteLine($"Updated button: {commandName}");
            }
            else
            {
                var button = new ToolbarButton
                {
                    PluginId = pluginId,
                    CommandName = commandName,
                    Icon = icon,
                    Tooltip = tooltip,
                    Category = category
                };
                
                _registeredButtons[buttonKey] = button;
                RhinoApp.WriteLine($"Registered button: {commandName} ({category})");
            }
            
            RefreshToolbar();
        }
        
        /// <summary>
        /// Unregisters a button from the shared toolbar
        /// </summary>
        /// <param name="pluginId">Plugin identifier</param>
        /// <param name="commandName">Command name</param>
        public void UnregisterButton(string pluginId, string commandName)
        {
            var buttonKey = $"{pluginId}_{commandName}";
            if (_registeredButtons.ContainsKey(buttonKey))
            {
                _registeredButtons.Remove(buttonKey);
                RhinoApp.WriteLine($"Unregistered button: {commandName}");
                RefreshToolbar();
            }
        }
        
        /// <summary>
        /// Creates or updates the shared toolbar
        /// </summary>
        public void CreateOrUpdateToolbar()
        {
            try
            {
                RhinoApp.WriteLine("=== Heatherwick Studio Toolbar Framework ===");
                RhinoApp.WriteLine($"Initialized with {_registeredButtons.Count} registered buttons.");
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error creating toolbar: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Refreshes the toolbar with all registered buttons
        /// </summary>
        private void RefreshToolbar()
        {
            try
            {
                var groupedButtons = _registeredButtons.Values
                    .GroupBy(b => b.Category)
                    .OrderBy(g => g.Key);
                
                foreach (var group in groupedButtons)
                {
                    foreach (var button in group.OrderBy(b => b.Tooltip))
                    {
                        // Toolbar refresh logic would go here
                    }
                }
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error refreshing toolbar: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Gets all registered buttons
        /// </summary>
        public IEnumerable<ToolbarButton> GetRegisteredButtons()
        {
            return _registeredButtons.Values;
        }
        
        /// <summary>
        /// Gets buttons by category
        /// </summary>
        public IEnumerable<ToolbarButton> GetButtonsByCategory(string category)
        {
            return _registeredButtons.Values.Where(b => b.Category == category);
        }
        
        /// <summary>
        /// Clears all registered buttons
        /// </summary>
        public void ClearAllButtons()
        {
            _registeredButtons.Clear();
            RhinoApp.WriteLine("All buttons cleared from toolbar.");
            RefreshToolbar();
        }
        
        /// <summary>
        /// Executes a command by name
        /// </summary>
        /// <param name="commandName">Name of the command to execute</param>
        public void ExecuteCommand(string commandName)
        {
            try
            {
                var button = _registeredButtons.Values.FirstOrDefault(b => b.CommandName == commandName);
                if (button != null)
                {
                    RhinoApp.WriteLine($"Executing command: {commandName}");
                    RhinoApp.RunScript(commandName, false);
                }
                else
                {
                    RhinoApp.WriteLine($"Command '{commandName}' not found in registered buttons.");
                    RhinoApp.WriteLine("Available commands:");
                    foreach (var cmd in _registeredButtons.Values.OrderBy(b => b.CommandName))
                    {
                        RhinoApp.WriteLine($"  - {cmd.CommandName}");
                    }
                }
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error executing command {commandName}: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Lists all registered commands
        /// </summary>
        public void ListAllCommands()
        {
            if (_registeredButtons.Count == 0)
            {
                RhinoApp.WriteLine("No commands registered.");
                return;
            }
            
            var groupedButtons = _registeredButtons.Values
                .GroupBy(b => b.Category)
                .OrderBy(g => g.Key);
            
            RhinoApp.WriteLine("\n=== Registered Commands ===");
            foreach (var group in groupedButtons)
            {
                RhinoApp.WriteLine($"\n[{group.Key}]");
                foreach (var button in group.OrderBy(b => b.CommandName))
                {
                    RhinoApp.WriteLine($"  {button.CommandName} - {button.Tooltip}");
                }
            }
            RhinoApp.WriteLine("=== End Commands ===\n");
        }
    }
    
    /// <summary>
    /// Represents a button in the shared toolbar
    /// </summary>
    public class ToolbarButton
    {
        public string PluginId { get; set; }
        public string CommandName { get; set; }
        public Bitmap Icon { get; set; }
        public string Tooltip { get; set; }
        public string Category { get; set; } = "General";
    }
    
    /// <summary>
    /// Helper class for easy plugin integration
    /// </summary>
    public static class ToolbarHelper
    {
        /// <summary>
        /// Easy registration method for plugins
        /// </summary>
        /// <param name="pluginId">Plugin identifier</param>
        /// <param name="commandName">Command name</param>
        /// <param name="iconResourceName">Name of the icon resource</param>
        /// <param name="tooltip">Button tooltip</param>
        /// <param name="category">Button category</param>
        /// <param name="assembly">Assembly containing the icon resource</param>
        public static void RegisterPluginButton(string pluginId, string commandName, 
            string iconResourceName, string tooltip, string category = "General", 
            Assembly assembly = null)
        {
            try
            {
                var icon = LoadIconFromResources(iconResourceName, assembly);
                DynamicToolbarManager.Instance.RegisterButton(
                    pluginId, commandName, icon, tooltip, category);
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error registering button: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Loads an icon from embedded resources
        /// </summary>
        /// <param name="resourceName">Name of the resource</param>
        /// <param name="assembly">Assembly containing the resource</param>
        /// <returns>Bitmap icon or null if not found</returns>
        private static Bitmap LoadIconFromResources(string resourceName, Assembly assembly = null)
        {
            try
            {
                assembly = assembly ?? Assembly.GetCallingAssembly();
                
                // Try different resource name patterns
                var possibleNames = new[]
                {
                    resourceName,
                    $"{assembly.GetName().Name}.{resourceName}",
                    $"{assembly.GetName().Name}.Resources.{resourceName}",
                    $"{assembly.GetName().Name}.Icons.{resourceName}",
                    $"{assembly.GetName().Name}.EmbeddedResources.{resourceName}"
                };
                
                foreach (var name in possibleNames)
                {
                    using (var stream = assembly.GetManifestResourceStream(name))
                    {
                        if (stream != null)
                        {
                            return new Bitmap(stream);
                        }
                    }
                }
                
                return null;
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error loading icon resource '{resourceName}': {ex.Message}");
                return null;
            }
        }
    }
} 