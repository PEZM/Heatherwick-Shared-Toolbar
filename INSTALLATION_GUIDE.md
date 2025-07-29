# Heatherwick Studio Toolbar - Installation Guide

## 🚨 **IMPORTANT: Plugin Loading Issues Fixed**

The plugin was not loading because it was using an old GUID and loading from the wrong location. Follow these steps to fix it.

## **Step-by-Step Installation**

### **Step 1: Clean Up Old Installation**
1. **Close Rhino 8 completely**
2. Run `clean_registry.bat` to remove old plugin registration
3. Run `clean_install.bat` to install to correct location

### **Step 2: Verify Installation**
1. **Restart Rhino 8**
2. Go to **Tools → Options → Plug-ins**
3. Look for **"Heatherwick Studio Toolbar"**
4. Should show:
   - **Loaded: Yes**
   - **GUID: 12345678-1234-1234-1234-123456789ABC**
   - **Location: %APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\**

### **Step 3: Test Commands**
1. In Rhino command line, type: `Heatherwick_ListCommands`
2. Should show available commands
3. Try: `Heatherwick_TestCommand`
4. Try: `Heatherwick_Execute`

### **Step 4: Check Toolbar**
1. Right-click any toolbar → **Customize**
2. Search for **"Heatherwick"**
3. Commands should appear in the list
4. Drag commands to your toolbar

## **What Was Fixed**

### **Issue 1: Wrong GUID**
- **Old GUID**: `3856c5bd-1cf1-4bf3-9322-3111c1b2907c`
- **New GUID**: `12345678-1234-1234-1234-123456789ABC`
- **Solution**: Registry cleanup removes old registration

### **Issue 2: Wrong Location**
- **Old Location**: Visual Studio build directory
- **New Location**: `%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\`
- **Solution**: Clean installation to correct directory

### **Issue 3: Missing Commands**
- **Problem**: Commands not being discovered
- **Solution**: Added GUID attributes to command classes
- **Result**: Commands now properly registered

### **Issue 4: Toolbar Not Loading**
- **Problem**: RUI file not in same directory as RHP
- **Solution**: Both files installed to same directory
- **Result**: Automatic toolbar loading

## **File Locations**

### **Correct Installation:**
```
%APPDATA%\McNeel\Rhinoceros\packages\8.0\Heatherwick-Studio-Toolbar\
├── Heatherwick Studio Toolbar.rhp
└── Heatherwick Studio Toolbar.rui
```

### **Registry Location:**
```
HKEY_CURRENT_USER\Software\McNeel\Rhinoceros\8.0\Plug-Ins\
└── 12345678-1234-1234-1234-123456789ABC\
```

## **Troubleshooting**

### **Plugin Still Not Loading:**
1. **Close Rhino completely**
2. Run `clean_registry.bat`
3. Run `clean_install.bat`
4. **Restart Rhino**

### **Commands Not Found:**
1. Check if plugin shows "Loaded: Yes"
2. Try typing command names exactly
3. Check command line for error messages

### **Toolbar Not Appearing:**
1. Verify RUI file is in same directory as RHP
2. Check file names match exactly
3. Restart Rhino after installation

## **Success Indicators**

✅ Plugin shows "Loaded: Yes" in Plug-ins dialog  
✅ Commands work when typed in command line  
✅ Commands appear in Customize dialog  
✅ Toolbar loads automatically  
✅ Correct GUID shown in plugin properties  

## **Next Steps**

Once the plugin is working:
1. Test all commands
2. Add commands to toolbars
3. Integrate with other Heatherwick Studio plugins
4. Customize toolbar layout as needed 