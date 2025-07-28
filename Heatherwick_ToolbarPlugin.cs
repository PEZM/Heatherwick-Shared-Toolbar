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
                RhinoApp.WriteLine("Heatherwick Studio Toolbar plugin loading...");
                
                // Create the toolbar
                CreateToolbar();
                
                // Initialize the shared toolbar framework
                try
                {
                    DynamicToolbarManager.Instance.CreateOrUpdateToolbar();
                    RegisterEssentialCommands();
                }
                catch (Exception frameworkEx)
                {
                    RhinoApp.WriteLine($"Warning: Shared toolbar framework not available: {frameworkEx.Message}");
                }
                
                RhinoApp.WriteLine("Heatherwick Studio Toolbar loaded successfully!");
                
                return Rhino.PlugIns.LoadReturnCode.Success;
            }
            catch (Exception ex)
            {
                errorMessage = $"Failed to load Heatherwick Studio Toolbar: {ex.Message}";
                RhinoApp.WriteLine($"Plugin load error: {errorMessage}");
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
                // Register the list commands function
                DynamicToolbarManager.Instance.RegisterButton(
                    this.Id.ToString(),
                    "Heatherwick_ListCommands",
                    LoadHeatherwickIcon(),
                    "List all registered Heatherwick Studio commands",
                    "Utilities"
                );
                
                // Register the load toolbar command
                DynamicToolbarManager.Instance.RegisterButton(
                    this.Id.ToString(),
                    "Heatherwick_LoadToolbar",
                    LoadHeatherwickIcon(),
                    "Show toolbar status and instructions",
                    "Utilities"
                );
                
                RhinoApp.WriteLine("Essential commands registered.");
            }
            catch (Exception ex)
            {
                RhinoApp.WriteLine($"Error registering essential commands: {ex.Message}");
            }
        }
    }
}