# Define the parent folder where the directories are located
$parentFolder = "F:\Testhublink"

# Retrieve all directories in the parent folder
$dossiers = Get-ChildItem -Path $parentFolder -Directory

# Display the list of directories with numbers for user selection
Write-Host "Select the folders to include (separated by commas):"
Write-Host "Enter '*' or 'all' to select all folders."
Write-Host "Enter 'all-except' followed by indices (e.g., 'all-except 1,3') to select all folders except specific ones."
for ($i = 0; $i -lt $dossiers.Count; $i++) {
    Write-Host "$i : $($dossiers[$i].Name)"
}

# Read the user's input for selected folder numbers
$choix = Read-Host "Enter your selection"

# Check if the user wants to select all folders
if ($choix -eq "*" -or $choix -eq "all") {
    # Select all folders
    $sourcePaths = $dossiers.FullName
    Write-Host "All folders have been selected."
} elseif ($choix -like "all-except*") {
    # Handle the "all-except" option
    $exclusions = $choix -replace "all-except", "" -split "," | ForEach-Object { $_.Trim() }
    $validExclusions = @()

    # Validate the excluded indices
    foreach ($index in $exclusions) {
        if ($index -match "^\d+$" -and $index -ge 0 -and $index -lt $dossiers.Count) {
            $validExclusions += [int]$index
        } else {
            Write-Host "Invalid exclusion number: $index. Please enter valid numbers between 0 and $($dossiers.Count - 1)."
        }
    }

    # Select all folders except the excluded ones
    $sourcePaths = $dossiers | Where-Object { -not ($dossiers.IndexOf($_) -in $validExclusions) } | ForEach-Object { $_.FullName }
    Write-Host "All folders except the following have been selected:"
    $validExclusions | ForEach-Object { Write-Host "$_ : $($dossiers[$_].Name)" }
} else {
    # Split the user's input by commas and trim any extra spaces
    $indexChoisis = $choix -split "," | ForEach-Object { $_.Trim() }

    # Validate the selected indices to ensure they are valid numbers within range
    $validIndices = @()
    foreach ($index in $indexChoisis) {
        if ($index -match "^\d+$" -and $index -ge 0 -and $index -lt $dossiers.Count) {
            $validIndices += $index
        } else {
            Write-Host "Invalid number: $index. Please enter valid numbers between 0 and $($dossiers.Count - 1)."
        }
    }

    # If no valid indices are found, stop the script
    if ($validIndices.Count -eq 0) {
        Write-Host "No valid folders were selected. The script will stop."
        exit
    }

    # Retrieve the full paths of the selected folders
    $sourcePaths = $validIndices | ForEach-Object { $dossiers[$_].FullName }
}

# Display the selected folders for verification
Write-Host "Selected folders:"
$sourcePaths

# Define the target path and the name of the folder where symbolic links will be created
$targetPath = "F:\Testhublink"
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

    # Retrieve all files in the subdirectories of the source path
    Get-ChildItem -Path $sourcePath -Recurse -File | ForEach-Object {
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