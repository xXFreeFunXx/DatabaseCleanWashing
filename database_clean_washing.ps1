param ($arg = "")
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Set main directory to the directory where the script is located
$main_dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$db_assetsPath = Join-Path $main_dir -ChildPath "db_assetsPath.txt"  # Output file for database assets
$mod_assetsPath = Join-Path $main_dir -ChildPath "mod_assetsPath.txt"  # Output file for mod assets
$sql_FilePath = Join-Path $main_dir -ChildPath "delete_assets.sql"  # SQL file for deleting assets
$unrealPakPath = Join-Path $main_dir -ChildPath "UnrealPak.exe"  # Path to UnrealPak.exe
$sqlitePath = Resolve-Path -Path (Join-Path $main_dir -ChildPath "..\sqlite3.exe") # Path to sqlite3.exe
$DebugMode = $true  # Set to $true to activate debug prints

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
    # If the script was started without arguments or without the batch files
    Write-Output "`n    Execute the script via one of the batch files!"
    Read-Host
    exit
} else {
    # Specify database name
    Write-Output "`nEnter the name of the database!`n   For Exiles Lands it is `"game`"`n   For Siptah it is `"dlc_siptah`"`n   For Savage Wilds it is `"savagewilds_game`"`n"
    $databaseName = Read-Host "Enter the name of the database"  # Database name without file extension Exiled Lands game.db > "game" | Siptah dlc_siptah.db > "dlc_siptah"
    $databasePath = Resolve-Path -Path (Join-Path $main_dir -ChildPath "..\$databaseName.db") -ErrorAction Ignore  # Path to the SQLite database
    if (-Not $databasePath) {
        Write-DebugMessage "Error: The database file '$databaseName.db' does not exist at the expected location: $databasePath"
        Write-Output "`nError: No '$databaseName.db' database file exists!"
        Read-Host
        exit
    }
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
    washing {
        Write-Output "`nStart the washing process..."

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

            Write-Output "`n    Looking for real socks in the modlist...`n"
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

        # Compare assets and directly generate delete_assets.sql
        if ((Test-Path $db_assetsPath) -and (Test-Path $mod_assetsPath)) {
            Write-DebugMessage "Start comparing 'db_assetsPath.txt' & 'mod_assetsPath.txt'"
            $dbAssetPaths = Get-Content -Path $db_assetsPath | Sort-Object -Unique
            $modAssetPaths = Get-Content -Path $mod_assetsPath | Sort-Object -Unique
            $totalDbAssets = $dbAssetPaths.Count

            $sqlContent = @()
            $sqlContent += "-- SQL Script to delete assets in the actor_position table"
            $sqlContent += "-- Created on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
            $sqlContent += ""

            for ($i = 0; $i -lt $totalDbAssets; $i++) {
                $assetPath = $dbAssetPaths[$i]
                if ($assetPath -notin $modAssetPaths) {
                    $escapedAssetPath = $assetPath -replace "'", "''"
                    $sqlContent += "DELETE FROM actor_position WHERE class = '$escapedAssetPath';"
                }
                Write-Progress -Activity "  Comparing assets" -Status "$i of $totalDbAssets" -PercentComplete (($i / $totalDbAssets) * 100)
            }
            Write-Progress -Activity "  Comparing Completed" -Completed

            $sqlContent += ""
            $sqlContent += "VACUUM;"
            $sqlContent += "REINDEX;"
            $sqlContent += "ANALYZE;"
            $sqlContent += "PRAGMA integrity_check;"
            
            # Encode the SQL script 'delete_assets.sql' in UTF-8
            $utf8Encoding = New-Object System.Text.UTF8Encoding($false)
            $streamWriter = [System.IO.StreamWriter]::new($sql_FilePath, $false, $utf8Encoding)
            try {
                foreach ($line in $sqlContent) {
                    $streamWriter.WriteLine($line)
                }
            } finally {
                $streamWriter.Close()
            }
            Write-DebugMessage "SQL file created successfully: $sql_FilePath"
            Write-Output "The old socks have been washed out, you can now start cleaning!"
            Read-Host
        } else {
            Write-Output "`nError: Missing required files for comparison."
        }
    }
    cleanup {
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
        Write-Output "`n    Create a backup first..."
        CreateDatabaseBackup

        # Check if "delete_assets.sql" exists
        if (!(Test-Path -Path $sql_FilePath)) {
            Write-Output "`n    No 'delete_assets.sql' file found. Exiting script as there are no assets to delete."
            Read-Host
            exit
        }

        # Refer the SQL script "delete_assets.sql" to "sqlite3.exe"
        $sql_FilePath = $sql_FilePath -replace '\\', '\\\\'
        Write-DebugMessage "SQLite Tool Pfad: $sqlitePath"
        Write-DebugMessage "SQLite Database Pfad: $databasePath"
        Write-DebugMessage "SQLite .read Pfad: $sql_FilePath"
        $sql_output = & $sqlitePath $databasePath ".read '$sql_FilePath'"
        & $sqlitePath $databasePath ".exit"

        if ($sql_output -notmatch "ok") {
            Write-DebugMessage "Fehler: Das SQL-Skript wurde nicht erfolgreich ausgeführt."
            Write-DebugMessage "Details: $sql_output"
            Read-Host
            exit
        }

        # End of script
        Write-Output "`n    Script finished."
        Read-Host
    }
    Default {
        # It's wrong, just wrong what's going on here
        Write-Output "Whatever you do, it's wrong!"
        Read-Host
        Exit
    }
}
