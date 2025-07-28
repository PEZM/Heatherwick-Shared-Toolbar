using Rhino;
using Rhino.Commands;
using HeatherwickStudio.SharedToolbar;
using System.Drawing;

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