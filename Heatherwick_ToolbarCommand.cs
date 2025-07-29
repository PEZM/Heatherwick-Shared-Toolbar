using Rhino;
using Rhino.Commands;
using HeatherwickStudio.SharedToolbar;
using System.Drawing;
using System.Reflection;

namespace HeatherwickStudio.Toolbar
{
    /// <summary>
    /// Command to list all registered Heatherwick Studio commands
    /// </summary>
    [System.Runtime.InteropServices.Guid("11111111-1111-1111-1111-111111111111")]
    public class Heatherwick_ListCommands : Command
    {
        public override string EnglishName => "Heatherwick_ListCommands";

        protected override Result RunCommand(RhinoDoc doc, RunMode mode)
        {
            try
            {
                RhinoApp.WriteLine("\n=== Heatherwick Studio Commands ===");
                RhinoApp.WriteLine("Available commands:");
                RhinoApp.WriteLine("  - Heatherwick_ListCommands (this command)");
                RhinoApp.WriteLine("  - Heatherwick_LoadToolbar");
                RhinoApp.WriteLine("");
                
                // Test embedded resource loading
                TestEmbeddedResources();
                
                RhinoApp.WriteLine("Plugin is working correctly!");
                RhinoApp.WriteLine("=== End Commands ===\n");
                
                return Result.Success;
            }
            catch (System.Exception ex)
            {
                RhinoApp.WriteLine($"Error listing commands: {ex.Message}");
                return Result.Failure;
            }
        }
        
        /// <summary>
        /// Test if embedded resources can be loaded
        /// </summary>
        private void TestEmbeddedResources()
        {
            try
            {
                RhinoApp.WriteLine("=== Testing Embedded Resources ===");
                
                var assembly = this.GetType().Assembly;
                RhinoApp.WriteLine($"Assembly: {assembly.FullName}");
                
                // List all embedded resources
                var resources = assembly.GetManifestResourceNames();
                RhinoApp.WriteLine($"Total embedded resources: {resources.Length}");
                foreach (var resource in resources)
                {
                    RhinoApp.WriteLine($"  - {resource}");
                }
                
                // Try to load the ListCommands.ico
                var iconResourceName = "Heatherwick_Studio_Toolbar.EmbeddedResources.ListCommands.ico";
                using (var stream = assembly.GetManifestResourceStream(iconResourceName))
                {
                    if (stream != null)
                    {
                        RhinoApp.WriteLine($"✅ Successfully loaded {iconResourceName}");
                        RhinoApp.WriteLine($"  Stream length: {stream.Length} bytes");
                    }
                    else
                    {
                        RhinoApp.WriteLine($"❌ Failed to load {iconResourceName}");
                    }
                }
                
                // Try to load the plugin-utility.ico
                var pluginIconResourceName = "Heatherwick_Studio_Toolbar.EmbeddedResources.plugin-utility.ico";
                using (var stream = assembly.GetManifestResourceStream(pluginIconResourceName))
                {
                    if (stream != null)
                    {
                        RhinoApp.WriteLine($"✅ Successfully loaded {pluginIconResourceName}");
                        RhinoApp.WriteLine($"  Stream length: {stream.Length} bytes");
                    }
                    else
                    {
                        RhinoApp.WriteLine($"❌ Failed to load {pluginIconResourceName}");
                    }
                }
                
                RhinoApp.WriteLine("=== End Embedded Resources Test ===");
            }
            catch (System.Exception ex)
            {
                RhinoApp.WriteLine($"Error testing embedded resources: {ex.Message}");
            }
        }
    }
    
    /// <summary>
    /// Command to show toolbar status and instructions
    /// </summary>
    [System.Runtime.InteropServices.Guid("44444444-4444-4444-4444-444444444444")]
    public class Heatherwick_LoadToolbar : Command
    {
        public override string EnglishName => "Heatherwick_LoadToolbar";

        protected override Result RunCommand(RhinoDoc doc, RunMode mode)
        {
            try
            {
                RhinoApp.WriteLine("=== Heatherwick Studio Toolbar Status ===");
                
                RhinoApp.WriteLine("Available commands:");
                RhinoApp.WriteLine("  - Heatherwick_ListCommands");
                RhinoApp.WriteLine("  - Heatherwick_LoadToolbar (this command)");
                
                RhinoApp.WriteLine("");
                RhinoApp.WriteLine("To add these commands to a toolbar:");
                RhinoApp.WriteLine("1. Right-click on any toolbar in Rhino");
                RhinoApp.WriteLine("2. Select 'Customize'");
                RhinoApp.WriteLine("3. In the search box, type 'Heatherwick'");
                RhinoApp.WriteLine("4. You should see both commands listed");
                RhinoApp.WriteLine("5. Drag any command to your toolbar");
                
                RhinoApp.WriteLine("=== End Status ===\n");
                
                return Result.Success;
            }
            catch (System.Exception ex)
            {
                RhinoApp.WriteLine($"Error in load toolbar command: {ex.Message}");
                return Result.Failure;
            }
        }
    }
} 