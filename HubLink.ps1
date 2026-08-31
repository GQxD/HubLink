# Determine the folder the script/exe lives in.
# $PSScriptRoot works when run as a .ps1, but is empty when compiled to an
# .exe (ps2exe), so fall back to the running assembly's location in that case.
if ($PSScriptRoot) {
    $parentFolder = $PSScriptRoot
} else {
    $entryAssembly = [System.Reflection.Assembly]::GetEntryAssembly()
    if ($entryAssembly -and $entryAssembly.Location) {
        $parentFolder = Split-Path -Parent $entryAssembly.Location
    } else {
        $parentFolder = (Get-Location).Path
    }
}

# Pause helper so the console window stays open when the .exe is double-clicked.
$runningAsExe = -not $PSScriptRoot
function Wait-BeforeExit {
    if ($runningAsExe) {
        Write-Host ""
        Read-Host "Press Enter to close"
    }
}


# Retrieve all directories in the parent folder
$dossiers = Get-ChildItem -Path $parentFolder -Directory

# Display the parent folder path
Write-Host "Parent folder: $parentFolder"

# Check if there are any valid directories
if ($dossiers.Count -eq 0) {
    Write-Host "No directories were found in the parent folder."
    Wait-BeforeExit
    exit
}

Write-Host "Select the folders to include (separated by commas):"
Write-Host "Enter '*' or 'all' to select all folders."
Write-Host "Enter 'all-except' followed by indices (e.g., 'all-except 1,3') to select all folders except specific ones."
Write-Host "Enter a range (e.g., '12-23') to select folders within that range."
for ($i = 0; $i -lt $dossiers.Count; $i++) {
    Write-Host "$i : $($dossiers[$i].Name)"
}

# Read the user's input for selected folder numbers
$choix = Read-Host "Enter your selection"

# Expand ranges like "12-23" into individual numbers
$choix = $choix -replace "\s", ""  # Remove any spaces
$indexChoisis = @()
foreach ($part in $choix -split ",") {
    if ($part -match "^\d+-\d+$") {
        # Handle ranges like "12-23"
        $start, $end = $part -split "-"
        $indexChoisis += ($start..$end)
    } elseif ($part -match "^\d+$") {
        # Handle single numbers
        $indexChoisis += [int]$part
    } elseif ($part -eq "*" -or $part -eq "all") {
        # Handle "all" selection
        $indexChoisis += (0..($dossiers.Count - 1))
    } else {
        Write-Host "Invalid input: $part. Please enter valid numbers, ranges (e.g., 1,3,5-8), or '*' for all."
    }
}

# Validate the selected indices to ensure they are valid numbers within range
$validIndices = @()
foreach ($index in $indexChoisis) {
    if ($index -ge 0 -and $index -lt $dossiers.Count) {
        $validIndices += $index
    } else {
        Write-Host "Invalid number: $index. Please enter valid numbers between 0 and $($dossiers.Count - 1)."
    }
}

# If no valid indices are found, stop the script
if ($validIndices.Count -eq 0) {
    Write-Host "No valid folders were selected. The script will stop."
    Wait-BeforeExit
    exit
}

# Retrieve the full paths of the selected folders
$sourcePaths = $validIndices | ForEach-Object { $dossiers[$_].FullName }

# Display the selected folders for verification
Write-Host "Selected folders:"
$sourcePaths

# Define the target path and the name of the folder where symbolic links will be created
$targetPath = $parentFolder
$linkFolderName = "Files_links"  # Change the name here if needed
$fullPath = Join-Path -Path $targetPath -ChildPath $linkFolderName

# Create the folder for symbolic links if it doesn't already exist
if (-not (Test-Path $fullPath)) {
    New-Item -ItemType Directory -Path $fullPath
    Write-Host "Created folder: $fullPath"
} else {
    Write-Host "Folder already exists: $fullPath"
}

# Ensure the target path exists, create it if it doesn't
if (!(Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath
}

# Iterate through each selected source folder
foreach ($sourcePath in $sourcePaths) {
    # Check if the source path exists
    if (!(Test-Path $sourcePath)) {
        Write-Host "The source path $sourcePath does not exist."
        continue
    }

    # Retrieve all .aris files in the subdirectories of the source path
    Get-ChildItem -Path $sourcePath -Recurse -File -Filter "*.aris" | ForEach-Object {
        # Define the symbolic link name in the target folder
        $linkName = Join-Path $fullPath $_.Name

        # Check if the path length exceeds the maximum allowed length
        if ($linkName.Length -gt 260) {
            Write-Host "Path too long: $linkName"
            return
        }

        # Check if a file with the same name already exists in the target folder
        if (Test-Path $linkName) {
            Write-Host "The file $($_.Name) already exists in the central folder, skipping."
        } else {
            try {
                # Attempt to create the symbolic link
                New-Item -ItemType SymbolicLink -Path $linkName -Target $_.FullName
                Write-Host "Symbolic link created for $($_.Name)"
            } catch {
                # Capture and display any errors during symbolic link creation
                Write-Host "Error creating symbolic link for $($_.FullName): $_"
            }
        }
    }
}

# Indicate that all symbolic links have been processed
Write-Host "All symbolic links have been processed!"
Wait-BeforeExit