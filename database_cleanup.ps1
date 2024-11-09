# Set the current directory to the script's location
$main_dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$databaseName = " "  # Database name without file extension, e.g., "game"

# Paths to the database and sqlite3.exe (one level above the current directory)
$dbPath = Join-Path -Path $main_dir -ChildPath "..\$databaseName.db"
$sqlitePath = Join-Path -Path $main_dir -ChildPath "..\sqlite3.exe"

# Path to "wrong_assets.txt" in the same directory as the script
$inputFile = Join-Path -Path $main_dir -ChildPath "wrong_assets.txt"

# Check if the database name is empty or contains only whitespace
if ([string]::IsNullOrWhiteSpace($databaseName)) {
    Write-Output "`nError: The database name is empty or contains only whitespace.`nPlease set a valid database name."
    Read-Host
    exit
}

# Check if the "wrong_assets.txt" file exists
if (!(Test-Path -Path $inputFile)) {
    Write-Output "`nNo 'wrong_assets.txt' file found. Exiting script as there are no assets to delete."
    exit
}

# Read all lines from wrong_assets.txt
$assetPaths = Get-Content -Path $inputFile

# Process each line and delete the corresponding entry in the database
foreach ($assetPath in $assetPaths) {
    # Formulate the SQL query to delete the entry
    $query = "DELETE FROM actor_position WHERE class = '$assetPath';"
    
    # Execute the query in the database
    & $sqlitePath $dbPath "$query"
}

Write-Output "Asset deletion completed."
