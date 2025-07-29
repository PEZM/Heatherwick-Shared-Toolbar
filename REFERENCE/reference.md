Heatherwick Studio Rhino Plugin Standards

Plugin instal folder: C:\Users\<your_username>\AppData\Roaming\McNeel\Rhinoceros\packages\8.0
Local Data Storage: C:\Users\<your_username>\AppData\Roaming\HeatherwickStudio
Auto load for Toolbars: If you give your custom RUI file the exact same name as the plugin RHP file and install it in the folder containing the RHP file, then Rhino will automatically open it the first time your plugin loads
Methods: We should make sure evrything is coded in a modular way and well documented so we can use methods across different plugins. 
Correct plugin and toolbar registration, including automatic updating for Visual Studio: 