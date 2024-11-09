# Set main directory to the directory where the script is located
$main_dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$databaseName = " "  # Database name without file extension Exiled Lands game.db > "game" | Siptah dlc_siptah.db > "dlc_siptah"
$databasePath = Join-Path $main_dir "..\$databaseName.db"  # Path to the SQLite database
$db_assets = Join-Path $main_dir -ChildPath "db_assets.txt"  # Output file for database assets
$mod_assets = Join-Path $main_dir -ChildPath "mod_assets.txt"  # Output file for mod assets
$unrealPakPath = Join-Path $main_dir -ChildPath "UnrealPak.exe"  # Path to UnrealPak.exe
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

Write-Output "`nStart the washing process..."

# Create a database backup with the current date and timestamp
function CreateDatabaseBackup {
    $timestamp = (Get-Date).ToString("yyyy.MM.dd_HH.mm.ss")
    $backupPath = Join-Path $main_dir -ChildPath "${databaseName}_${timestamp}.db"
    
    if (Test-Path $databasePath) {
        Write-DebugMessage "Creating database backup at '$backupPath'..."
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

# SQLite3 command and query to retrieve Mod Asset paths from the database
$sqlitePath = Join-Path $main_dir -ChildPath "..\sqlite3.exe"
$query = "SELECT DISTINCT class FROM actor_position WHERE class LIKE '/Game/Mods/%';"
$dbAssetResults = & $sqlitePath $databasePath -header -csv "$query"

# Save results to db_assets.txt only if results are found
if ($dbAssetResults) {
    $dbAssetResults | Out-File -FilePath $db_assets -Encoding UTF8
    # Optional: Remove the header if it's not needed
    (Get-Content $db_assets | Select-Object -Skip 1) | Set-Content $db_assets
    Write-DebugMessage "Mod Asset paths from the database have been successfully saved to '$db_assets'."
    Write-Output "`n    Searching for old socks in the database..."
} else {
    Write-Output "`nError: No Mod Asset paths found in the database query."
    Read-Host
    exit
}

# Set mods directory and modlist.txt path
$modsDir = Join-Path $main_dir -ChildPath "..\..\Mods"
$modListPath = Join-Path $modsDir "modlist.txt"
$pakFiles = Get-ChildItem -Path "$modsDir\*.pak" -ErrorAction SilentlyContinue

# Check if no .pak files were found, use modlist.txt if available, and save to mod_assets.txt if any are found
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

# Write to mod_assets.txt only if pakFiles were found or extracted from modlist.txt
if ($pakFiles) {
    # Clear the output file if it already exists
    Remove-Item -Path $mod_assets -ErrorAction Ignore
    New-Item -Path $mod_assets -ItemType File | Out-Null

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
                Add-Content -Path $mod_assets -Value "/Game/$path"
            }
        }

        $currentFileIndex++
        Write-Progress -Activity "Processing .pak files" -Status "File $currentFileIndex of $totalPakFiles" -PercentComplete (($currentFileIndex / $totalPakFiles) * 100)
    }
    Write-Progress -Completed
    Write-DebugMessage "Mod Asset paths have been written to $mod_assets."
} else {
    Write-Output "`nError: No .pak files or Mod Asset paths found; mod_assets.txt will not be created."
}

# Create list of wrong assets only if db_assets.txt and mod_assets.txt exist
if ((Test-Path $db_assets) -and (Test-Path $mod_assets)) {
    Write-DebugMessage "Get asset paths from 'db_assets.txt' & 'mod_assets.txt'"
    Write-Output "`n    Looking for old socks among the many new ones...`n"
    $dbAssetPaths = Get-Content -Path $db_assets | ForEach-Object { $_ -replace '\..+$', '' } | Sort-Object -Unique
    $modAssetPaths = Get-Content -Path $mod_assets | Sort-Object -Unique
    Write-DebugMessage "Start Compare 'db_assets.txt' & 'mod_assets.txt'"

    $totalDbAssets = $dbAssetPaths.Count
    $wrong_assets = @()

    for ($i = 0; $i -lt $totalDbAssets; $i++) {
        $assetPath = $dbAssetPaths[$i]
        if ($assetPath -notin $modAssetPaths) {
            $wrong_assets += $assetPath
        }
        Write-Progress -Activity "Comparing assets" -Status " $i of $totalDbAssets" -PercentComplete (($i / $totalDbAssets) * 100)
    }
    Write-Progress -Completed
    if ($wrong_assets) {
        $wrong_assets_path = Join-Path $main_dir -ChildPath "wrong_assets.txt"
        $wrong_assets | Set-Content -Path $wrong_assets_path
        Write-DebugMessage "Wrong Mod Assets have been saved to '$wrong_assets_path'."
        Write-Output "`nDone, now start the CleanUp if you want"
        Read-Host
    } else {
        Write-Output "`nNo wrong Mod Assets found. Good! :)"
    }
} else {
    Write-Output "`nError: Skipping wrong asset check as either db_assets.txt or mod_assets.txt is missing."
}
