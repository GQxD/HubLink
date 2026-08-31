# HubLink Script-

## Description
This PowerShell script automates the creation of symbolic links for `.aris` files found in selected directories, gathering them into a single central folder. It lets you centralize access to scattered `.aris` files without duplicating them on disk.

## Features
- **Directory Selection**:
  - Select specific directories by entering their indices (e.g., `0,2`).
  - Select all directories using `*` or `all`.
  - Exclude specific directories using `all-except` followed by indices (e.g., `all-except 1,3`).
  - Select a range of directories using a hyphen (e.g., `12-23`).
- **Symbolic Link Creation**:
  - Recursively finds every `.aris` file in the selected directories.
  - Creates symbolic links to those files in a central folder (`Files_links`).
- **Validation**:
  - Validates user input for directory selection.
  - Handles errors such as duplicate file names or paths exceeding the 260-character limit.

## Requirements
- Windows operating system.
- PowerShell 5.0 or later.
- Administrator privileges (required for creating symbolic links).

## How to use
1. Place `HubLink.ps1` in the parent folder that contains the directories you want to scan.
2. Open PowerShell with administrator privileges.
3. Run the script:
   ```powershell
   .\HubLink.ps1
   ```
4. Follow the on-screen instructions to select the directories.

## Technical Details
- The parent folder is the folder where the script is located (`$PSScriptRoot`); the script lists all directories directly inside it.
- Users can select directories to include or exclude using indices.
- Each selected directory is searched **recursively** for `*.aris` files.
- Symbolic links are created in a central folder named `Files_links`, created next to the script.
- The script handles common errors, such as:
  - Paths exceeding 260 characters (the file is skipped).
  - Duplicate file names in the central folder (the file is skipped).

## Example
Suppose the script's folder contains the following directories:
```
0 : Folder 1
1 : Folder 2
2 : Folder 3
...
```
- To select all directories: enter `*` or `all`.
- To exclude the `Folder 2` directory: enter `all-except 1`.
- To select only `Folder 1` and `Folder 3`: enter `0,2`.
- To select `Folder 1` to `Folder 3`: enter `0-2`.

## Notes
- Only `.aris` files are processed; other file types are ignored.
- If a file with the same name already exists in the central folder, it is skipped.
- The `Files_links` folder is created automatically if it does not already exist.

## License
This project is licensed under the terms of the GNU General Public License v3.0.  
You can find the full license text [here](https://www.gnu.org/licenses/gpl-3.0.en.html).
