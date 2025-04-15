# HubLink Script

## Description
This PowerShell script automates the creation of symbolic links for files from selected directories into a central folder. It allows users to organize and centralize file access without duplicating the files.

## Features
- **Directory Selection**:
  - Select specific directories by entering their indices.
  - Select all directories using `*` or `all`.
  - Exclude specific directories using `all-except` followed by indices (e.g., `all-except 1,3`).
  - Select a range of directories using a hyphen (e.g., `12-23`).
- **Symbolic Link Creation**:
  - Creates symbolic links for all files in the selected directories.
  - Places the symbolic links in a central folder (`Files_links`).
- **Validation**:
  - Validates user input for directory selection.
  - Handles errors such as duplicate file names or excessively long paths.

## Requirements
- Windows operating system.
- PowerShell 5.0 or later.
- Administrator privileges (required for creating symbolic links).

## How to use 
1. Place the script in a folder of your choice.
2. Open PowerShell with administrator privileges.
3. Run the script:
   ```powershell
   .\HubLink.ps1
   ```
4. Follow the on-screen instructions to select the directories.

## Technical Details
- The script retrieves all directories in the parent folder defined by the `$parentFolder` variable.
- Users can select directories to include or exclude using indices.
- Symbolic links are created in a central folder named `Files_links` located in the path defined by `$targetPath`.
- The script handles common errors, such as:
  - Paths exceeding 260 characters.
  - Duplicate file names in the central folder.

## Example
Suppose the parent folder contains the following directories:
```
0 : Folder 1
1 : Folder 2
2 : Folder 3
...
```
- To select all directories: enter `*` or `all`.
- To exclude the `Folder 2` directory: enter `all-except 1`.
- To select only `Folder 1` and `Folder 3`: enter `0,2`.
- To select `Folder 1` to `Folder 3` : enter 1-3

## Notes
- If a file with the same name already exists in the central folder, it will be skipped.
- Ensure the target path exists or will be created automatically by the script.

## License
This project is licensed under the terms of the GNU General Public License v3.0.  
You can find the full license text [here](https://www.gnu.org/licenses/gpl-3.0.en.html).