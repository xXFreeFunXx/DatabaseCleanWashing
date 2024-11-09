# Setze das aktuelle Verzeichnis auf den Speicherort des Skripts
$main_dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$databaseName = "game"  # Database name without file extension "game"

# Pfade zur Datenbank und zur sqlite3.exe (eine Ebene über dem aktuellen Verzeichnis)
$dbPath = Join-Path -Path $main_dir -ChildPath "..\$databaseName.db"
$sqlitePath = Join-Path -Path $main_dir -ChildPath "..\sqlite3.exe"

# Pfad zur "wrong_assets.txt" im selben Verzeichnis wie das Skript
$inputFile = Join-Path -Path $main_dir -ChildPath "wrong_assets.txt"

# Lese alle Zeilen aus der wrong_assets.txt
$assetPaths = Get-Content -Path $inputFile

# Check if the database name is empty or contains only whitespace
if ([string]::IsNullOrWhiteSpace($databaseName)) {
    Write-Output "`nError: The database name is empty or contains only whitespace.`nPlease set a valid database name."
    Read-Host
    exit
}

# Gehe jede Zeile durch und lösche den entsprechenden Eintrag in der Datenbank
foreach ($assetPath in $assetPaths) {
    # Formuliere die SQL-Abfrage für das Löschen des Eintrags
    $query = "DELETE FROM actor_position WHERE class = '$assetPath';"
    
    # Führe die Abfrage in der Datenbank aus
    & $sqlitePath $dbPath "$query"
}

Write-Output "Löschen der Einträge abgeschlossen."
