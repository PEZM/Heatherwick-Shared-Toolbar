using Rhino;
using System;
using System.Drawing;
using HeatherwickStudio.SharedToolbar;
using System.Linq;

namespace HeatherwickStudio.Toolbar
{
    ///<summary>
    /// <para>Every RhinoCommon .rhp assembly must have one and only one PlugIn-derived
    /// class. DO NOT create instances of this class yourself. It is the
    /// responsibility of Rhino to create an instance of this class.</para>
    /// <para>To complete plug-in information, please also see all PlugInDescription
    /// attributes in AssemblyInfo.cs (you might need to click "Project" ->
    /// "Show All Files" to see it in the "Solution Explorer" window).</para>
    ///</summary>
    public class Heatherwick_ToolbarPlugin : Rhino.PlugIns.PlugIn
    {
        private Guid _toolbarId = new Guid("12345678-1234-1234-1234-123456789ABC");
        
        public Heatherwick_ToolbarPlugin()
        {
            Instance = this;
        }

        ///<summary>Gets the only instance of the Heatherwick_ToolbarPlugin plug-in.</summary>
        public static Heatherwick_ToolbarPlugin Instance { get; private set; }

        ///<summary>
        /// Called when the plugin is loaded
        ///</summary>
        protected override Rhino.PlugIns.LoadReturnCode OnLoad(ref string errorMessage)
        {
            try
            {
                RhinoApp.WriteLine("=== Heatherwick Studio Toolbar plugin loading... ===");
                
                // Create the toolbar
                CreateToolbar();
                
                // Initialize the shared toolbar framework
                try
                {
                    RhinoApp.WriteLine("Initializing shared toolbar framework...");
                    DynamicToolbarManager.Instance.CreateOrUpdateToolbar();
                    RegisterEssentialCommands();
                    RhinoApp.WriteLine("Shared toolbar framework initialized successfully!");
                }
                catch (Exception frameworkEx)
                {
                    RhinoApp.WriteLine($"Warning: Shared toolbar framework not available: {frameworkEx.Message}");
                    RhinoApp.WriteLine("Falling back to basic command registration...");
                    
                    // Fallback: basic command discovery
                    var commands = this.GetType().Assembly.GetTypes()
                        .Where(t => t.IsSubclassOf(typeof(Rhino.Commands.Command)))
                        .ToList();
                    
                    RhinoApp.WriteLine($"Found {commands.Count} command types for fallback:");
                    foreach (var cmdType in commands)
                    {
                        RhinoApp.WriteLine($"  - {cmdType.FullName}");
                    }
                }
                
                RhinoApp.WriteLine("=== Plugin loaded successfully! ===");
                
                return Rhino.PlugIns.LoadReturnCode.Success;
            }
            catch (Exception ex)
            {
                errorMessage = $"Failed to load Heatherwick Studio Toolbar: {ex.Message}";
                RhinoApp.WriteLine($"Plugin load error: {errorMessage}");
                RhinoApp.WriteLine($"Exception details: {ex}");
                return Rhino.PlugIns.LoadReturnCode.ErrorShowDialog;
            }
        }

        ///<summary>
        /// Called when the plugin is unloaded
        ///</summary>
        protected override void OnShutdown()
        {
            try
            {
                RhinoApp.WriteLine("Heatherwick Studio Toolbar unloaded.");
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error during toolbar shutdown: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Creates the toolbar in Rhino's UI
        /// </summary>
        private void CreateToolbar()
        {
            try
            {
                // Load the toolbar file
                var toolbarFile = RhinoApp.ToolbarFiles.Open("Heatherwick Studio Toolbar.rui");
                if (toolbarFile != null)
                {
                    RhinoApp.WriteLine("Toolbar file loaded successfully!");
                    toolbarFile.Save();
                }
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Note: Could not load toolbar file: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Loads the Heatherwick icon from embedded resources
        /// </summary>
        private Bitmap LoadHeatherwickIcon()
        {
            try
            {
                var assembly = this.GetType().Assembly;
                using (var stream = assembly.GetManifestResourceStream(
                    "Heatherwick_Studio_Toolbar.EmbeddedResources.HeatherwickIcon.png"))
                {
                    return stream != null ? new Bitmap(stream) : null;
                }
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error loading Heatherwick icon: {ex.Message}");
                return null;
            }
        }
        
        /// <summary>
        /// Registers essential commands with the shared toolbar
        /// </summary>
        private void RegisterEssentialCommands()
        {
            try
            {
                RhinoApp.WriteLine("=== Registering Commands with Icons ===");
                
                // Debug: List all embedded resources
                var assembly = this.GetType().Assembly;
                var resources = assembly.GetManifestResourceNames();
                RhinoApp.WriteLine($"Available embedded resources ({resources.Length}):");
                foreach (var resource in resources)
                {
                    RhinoApp.WriteLine($"  - {resource}");
                }
                
                // Register the list commands function with its own icon
                RhinoApp.WriteLine("Registering Heatherwick_ListCommands with ListCommands.ico...");
                ToolbarHelper.RegisterPluginButton(
                    this.Id.ToString(),
                    "Heatherwick_ListCommands",
                    "ListCommands.ico",
                    "List all registered Heatherwick Studio commands",
                    "Utilities",
                    this.GetType().Assembly
                );
                
                // Register the load toolbar command with the plugin icon
                RhinoApp.WriteLine("Registering Heatherwick_LoadToolbar with plugin-utility.ico...");
                ToolbarHelper.RegisterPluginButton(
                    this.Id.ToString(),
                    "Heatherwick_LoadToolbar",
                    "plugin-utility.ico",
                    "Show toolbar status and instructions",
                    "Utilities",
                    this.GetType().Assembly
                );
                
                RhinoApp.WriteLine("Essential commands registered with icons.");
                RhinoApp.WriteLine("=== End Command Registration ===");
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error registering essential commands: {ex.Message}");
            }
        }
    }
}