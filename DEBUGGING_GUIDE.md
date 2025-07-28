# Debugging Guide: Toolbar Loading from Visual Studio

## 🎯 **Current Status**
- ✅ Plugin loading successfully
- ✅ Commands working in command line
- ❓ Toolbar not appearing automatically

## **Testing Steps**

### **Step 1: Verify Files Are in Correct Location**
Check that both files are in the build output directory:
```
C:\Users\pablozamorano\OneDrive - Heatherwick Studio\Ge-CoDe - Internal\AppDev\Heatherwick Studio Toolbar\bin\Debug\net7.0\
├── Heatherwick Studio Toolbar.rhp
└── Heatherwick Studio Toolbar.rui
```

### **Step 2: Test Commands**
In Rhino command line, try these commands:
1. `Heatherwick_ListCommands` - Should show available commands
2. `Heatherwick_TestCommand` - Should show test message
3. `Heatherwick_Execute` - Should show execute message
4. `Heatherwick_LoadToolbar` - **NEW**: Manually loads the toolbar file

### **Step 3: Check Toolbar Availability**
1. Right-click any toolbar in Rhino
2. Select "Customize"
3. In the search box, type "Heatherwick"
4. You should see these commands:
   - Heatherwick_ListCommands
   - Heatherwick_TestCommand
   - Heatherwick_Execute
   - Heatherwick_LoadToolbar

### **Step 4: Manual Toolbar Loading**
1. Run `Heatherwick_LoadToolbar` command
2. Check command line output for messages
3. Look for any error messages

### **Step 5: Check Plugin Output**
Look for these messages in the command line when plugin loads:
```
=== Heatherwick Studio Toolbar ===
Commands available:
  - Heatherwick_ListCommands
  - Heatherwick_TestCommand
  - Heatherwick_Execute
  - Heatherwick_LoadToolbar
Toolbar file loaded successfully!
Toolbar file saved
```

## **Expected Behavior**

### **If Everything Works:**
- Commands appear in Customize dialog
- `Heatherwick_LoadToolbar` command loads the toolbar file
- No error messages in command line

### **If Toolbar Still Doesn't Appear:**
- Commands work but toolbar is not visible
- This is normal - Rhino may not auto-show toolbars
- You can manually add commands to existing toolbars

## **Troubleshooting**

### **Commands Not Found:**
1. Check if plugin shows "Loaded: Yes" in Plug-ins dialog
2. Restart Rhino completely
3. Check for error messages in command line

### **Toolbar File Not Loading:**
1. Run `Heatherwick_LoadToolbar` command
2. Check for error messages
3. Verify RUI file exists in build directory

### **Plugin Not Loading:**
1. Check Visual Studio build output
2. Verify all files are in correct location
3. Check Rhino Plug-ins dialog for errors

## **Next Steps**

Once commands are working:
1. **Add Commands to Toolbar**: Use Customize dialog to add commands to existing toolbars
2. **Test All Commands**: Make sure each command works correctly
3. **Create Custom Toolbar**: You can create a new toolbar and add the commands to it

## **Success Indicators**

✅ Plugin loads without errors  
✅ All commands work in command line  
✅ Commands appear in Customize dialog  
✅ `Heatherwick_LoadToolbar` command loads toolbar file  
✅ No error messages in command line  

The toolbar not appearing automatically is normal - Rhino often requires manual setup of toolbars. The important thing is that the commands are working and can be added to toolbars manually. 