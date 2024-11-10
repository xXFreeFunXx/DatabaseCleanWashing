param ($arg = "")
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Set main directory to the directory where the script is located
$main_dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$db_assetsPath = Join-Path $main_dir -ChildPath "db_assetsPath.txt"  # Output file for database assets
$mod_assetsPath = Join-Path $main_dir -ChildPath "mod_assetsPath.txt"  # Output file for mod assets
$wrong_assetsPath = Join-Path $main_dir -ChildPath "wrong_assets.txt"  # Output file for wrong assets
$unrealPakPath = Join-Path $main_dir -ChildPath "UnrealPak.exe"  # Path to UnrealPak.exe
$sqlitePath = Resolve-Path -Path (Join-Path $main_dir -ChildPath "..\sqlite3.exe")
$DebugMode = $false  # Set to $true to activate debug prints

# Debugging function
function Write-DebugMessage {
    param (
        [string]$Message
    )
    if ($DebugMode) {
        Write-Output "`nDebug: $Message"
    }
}

if (-Not $arg) {
    Write-Output "`n    Execute the script via one of the batch files!"
    Read-Host
    exit
} else {
    Write-Output "`nEnter the name of the database!`n   For Exiles Lands it is `"game`"`n   For Siptah it is `"dlc_siptah`"`n   For Savage Wilds it is `"savagewilds_game`"`n"
    $databaseName = Read-Host "Enter the name of the database"  # Database name without file extension Exiled Lands game.db > "game" | Siptah dlc_siptah.db > "dlc_siptah"
    $databasePath = Resolve-Path -Path (Join-Path $main_dir -ChildPath "..\$databaseName.db")  # Path to the SQLite database
}

# Check if the database name is empty or contains only whitespace
if ([string]::IsNullOrWhiteSpace($databaseName)) {
    Write-Output "`nError: The database name is empty or contains only whitespace.`nPlease set a valid database name."
    Read-Host
    exit
}

# Check if UnrealPak.exe is present in the main directory
if (-Not (Test-Path $unrealPakPath)) {
    Write-Output "`nError: UnrealPak.exe not found."
    Read-Host
    exit
}

switch ($arg) {
    wasching {
        Write-Output "`nStart the washing process..."

        # Create a database backup with the current date and timestamp
        function CreateDatabaseBackup {
            $timestamp = (Get-Date).ToString("yyyy.MM.dd_HH.mm.ss")
            $backupPath = Join-Path $main_dir -ChildPath "${databaseName}_${timestamp}.db"
            
            if (Test-Path $databasePath) {
                Write-DebugMessage "Creating database backup at '$backupPath'"
                Copy-Item -Path $databasePath -Destination $backupPath -Force
                Write-DebugMessage "Backup successfully created: $backupPath"
            } else {
                Write-Output "`nError: Database file '$databasePath' not found."
                Read-Host
                exit
            }
        }

        # Create the database backup
        CreateDatabaseBackup

        # Execute sqlite3 query in batch mode and redirect the output to a temporary file
        $query = "SELECT DISTINCT class FROM actor_position WHERE class LIKE '/Game/Mods/%';"
        & $sqlitePath -batch $databasePath "$query" > $db_assetsPath

        # Check if the file has content (more than 0 bytes)
        if ((Get-Item $db_assetsPath).Length -gt 0) {
            Write-DebugMessage "Mod Asset paths from the database have been successfully saved to '$db_assetsPath'."
            Write-Output "`n    Searching for old socks in the database..."
        } else {
            Write-Output "`nError: No Mod Asset paths found in the database query."
            Read-Host
            exit
        }

        # Set mods directory and modlist.txt path
        $modsDir = Resolve-Path -Path (Join-Path $main_dir -ChildPath "..\..\Mods")
        $modListPath = Join-Path $modsDir "modlist.txt"
        $pakFiles = Get-ChildItem -Path "$modsDir\*.pak" -ErrorAction SilentlyContinue

        # Check if no .pak files were found, use modlist.txt if available, and save to mod_assetsPath.txt if any are found
        if (-Not $pakFiles) {
            if (Test-Path $modListPath) {
                Write-DebugMessage "No .pak files found in the Mods directory. Using modlist.txt instead."
                $pakFiles = Get-Content -Path $modListPath | Where-Object { $_ -match "\.pak$" }
            } else {
                Write-Output "`nError: Neither .pak files nor modlist.txt found in the Mods directory."
                Read-Host
                exit
            }
        }

        # Write to mod_assetsPath.txt only if pakFiles were found or extracted from modlist.txt
        if ($pakFiles) {
            # Clear the output file if it already exists
            Remove-Item -Path $mod_assetsPath -ErrorAction Ignore
            New-Item -Path $mod_assetsPath -ItemType File | Out-Null

            $totalPakFiles = $pakFiles.Count
            $currentFileIndex = 0

            Write-Output "`n    Looking for real socks in the modlist..."
            foreach ($pakFile in $pakFiles) {
                $pakFilePath = if ($pakFile -is [System.IO.FileInfo]) { $pakFile.FullName } else { $pakFile }
                Write-DebugMessage "Processing $pakFilePath"
                $output = & "$unrealPakPath" "$pakFilePath" "-Test" 2>&1

                foreach ($line in $output) {
                    if ($line -match '"Mods\/([^"]+?)\.uasset"') {
                        $path = "Mods/$($matches[1])"
                        Add-Content -Path $mod_assetsPath -Value "/Game/$path"
                    }
                }

                $currentFileIndex++
                Write-Progress -Activity "  Read the modlist" -Status "File $currentFileIndex of $totalPakFiles" -PercentComplete (($currentFileIndex / $totalPakFiles) * 100)
            }
            Write-Progress -Activity "  Done with reading the modlist" -Completed
            Write-DebugMessage "Mod Asset paths have been written to $mod_assetsPath."
        } else {
            Write-Output "`nError: No .pak files or Mod Asset paths found; mod_assetsPath.txt will not be created."
        }

        # Create list of wrong assets only if db_assetsPath.txt and mod_assetsPath.txt exist
        if ((Test-Path $db_assetsPath) -and (Test-Path $mod_assetsPath)) {
            Write-DebugMessage "Get asset paths from 'db_assetsPath.txt' & 'mod_assetsPath.txt'"
            Write-Output "`n    Looking for old socks among the many new ones..."
            $dbAssetPaths = Get-Content -Path $db_assetsPath | ForEach-Object { $_ -replace '\..+$', '' } | Sort-Object -Unique
            $modAssetPaths = Get-Content -Path $mod_assetsPath | Sort-Object -Unique
            Write-DebugMessage "Start Compare 'db_assetsPath.txt' & 'mod_assetsPath.txt'"

            $totalDbAssets = $dbAssetPaths.Count
            $wrong_assets = @()

            for ($i = 0; $i -lt $totalDbAssets; $i++) {
                $assetPath = $dbAssetPaths[$i]
                if ($assetPath -notin $modAssetPaths) {
                    $wrong_assets += $assetPath
                }
                Write-Progress -Activity "  Comparing assets" -Status " $i of $totalDbAssets" -PercentComplete (($i / $totalDbAssets) * 100)
            }
            Write-Progress -Activity "  Comparing Completed" -Completed
            if ($wrong_assets) {
                $wrong_assets | Set-Content -Path $wrong_assetsPath
                Write-DebugMessage "Wrong Mod Assets have been saved to '$wrong_assetsPath'."
                Write-Output "`nDone, now start the CleanUp if you want"
                Read-Host
            } else {
                Write-Output "`nNo wrong Mod Assets found. Good! :)"
            }
        } else {
            Write-Output "`nError: Skipping wrong asset check as either db_assetsPath.txt or mod_assetsPath.txt is missing."
        }
    }
    cleanup {
        # Check if the "wrong_assets.txt" file exists
        if (!(Test-Path -Path $mod_assetsPath)) {
            Write-Output "`nNo 'wrong_assets.txt' file found. Exiting script as there are no assets to delete."
            exit
        }

        # Read all lines from wrong_assets.txt
        $assetPaths = Get-Content -Path $mod_assetsPath
        $totalAssets = $assetPaths.Count  # Total number of assets for progress tracking
        $currentAsset = 0  # Initialize the current progress

        # Process each line and delete the corresponding entry in the database
        foreach ($assetPath in $assetPaths) {
            # Formulate the SQL query to delete the entry
            $query = "DELETE FROM actor_position WHERE class = '$assetPath';"
            
            # Execute the query in the database
            & $sqlitePath $databasePath "$query"
            
            # Update the progress
            $currentAsset++
            $percentComplete = ($currentAsset / $totalAssets) * 100
            
            # Display the progress bar
            Write-Progress -Activity "Deleting assets" -Status "Processing $currentAsset of $totalAssets" -PercentComplete $percentComplete
        }
        Write-Progress -Activity "  Deleting assets Completed" -Completed
        Write-Output "`n    Old socks completely removed"
        Read-Host
    }
    Default {
        Write-Output "Whatever you do, it's wrong!"
        Read-Host
        Exit
    }
}
