# DevTrash Cleaner

## Introduction

**DevTrash Cleaner** is a powerful and interactive PowerShell-based utility designed to clean up common development folder clutter, such as `node_modules`, `.angular`, and `bin`, from your project directories. The tool efficiently scans directories, identifies these unwanted folders, and allows you to delete them with ease, recovering valuable disk space. It includes an engaging console interface with color-coded outputs, progress bars, and animations for an enhanced user experience.

### Key Features:
- **Targeted Folder Cleanup**: Automatically identifies and deletes common development folders like `node_modules`, `.angular`, and `bin`.
- **Optimized Folder Selection**: Avoids redundant deletions by ensuring only top-level folder instances are selected.
- **Disk Space Recovery Estimation**: Displays the size of each folder and calculates the total disk space that can be recovered.
- **Interactive Console**: Features progress bars, typing effects, and animations to make the cleanup process engaging.
  
## Installation

### Adding to Context Menu (Windows)
You can easily add **DevTrash Cleaner** to the Windows context menu for quick access. Follow these steps:

1. **Download the Script**:  
   Download the `FolderCleanup.ps1` script from the [DevTrash Cleaner GitHub repository](https://github.com/WaseemAhmadNaeem/DevTrash-Cleaner).

2. **Create a Batch File to Run the Script**:
   - Open Notepad (or any text editor).
   - Paste the following code:
     ```batch
     @echo off
     powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\FolderCleanup.ps1" "%1"
     ```
   - Save the file as `DevTrashCleaner.bat` in a folder of your choice (e.g., `C:\Scripts\DevTrashCleaner.bat`).

3. **Add the Script to Windows Context Menu**:
   - Press `Win + R` to open the Run dialog, type `regedit`, and press Enter to open the Registry Editor.
   - Navigate to `HKEY_CLASSES_ROOT\Directory\Background\shell`.
   - Right-click on `shell` and select **New** > **Key**. Name the new key `DevTrashCleaner`.
   - Right-click on the `DevTrashCleaner` key and select **New** > **Key**. Name this key `command`.
   - On the right side, double-click the `(Default)` string value and enter the following path:
     ```
     "C:\Scripts\DevTrashCleaner.bat" "%V"
     ```
     (Replace `"C:\Scripts\DevTrashCleaner.bat"` with the path where you saved your batch file.)
   - Close the Registry Editor.

Now, you can right-click any folder in Windows Explorer and select **DevTrashCleaner** from the context menu to clean up unwanted folders.

## Usage

1. **Running the Script**:
   - Navigate to any folder where you want to clean up the unwanted directories.
   - Right-click the folder and select **DevTrashCleaner** from the context menu.

2. **Interactive Console Interface**:
   - The script will start by scanning the directory for target folders (`node_modules`, `.angular`, `bin`).
   - It will display the size of each detected folder, estimated disk space savings, and show progress.
   - You'll be asked to confirm the deletion of each folder. Type `YES` (case-sensitive) to proceed with deletion or press Enter to cancel.

3. **Folder Cleanup Process**:
   - The script will identify and delete the folders one by one, displaying progress and animations.
   - Afterward, it will show a summary of the number of folders deleted and the total space recovered.

### Example Output:
```plaintext
  INITIALIZING DEVTRASH CLEANER...

  DEVTRASH CLEANER v1.0  
  Developed By: Waseem Ahmad Naeem (@WaseemAhmadNaeem)

  Path: C:\Users\YourUser\Projects
  Target Folders: node_modules, .angular, bin

Scanning file system for target folders... Found 3 instances.
Optimizing folder selection for efficient deletion... Optimized to 3 folders.
...
Deleting node_modules... Complete!
Successfully deleted: C:\Users\YourUser\Projects\project1\node_modules
...
