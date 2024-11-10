# Database Clean Washing

The **Database Clean Washing** project is designed for cleaning and managing asset references in your Conan Exiles server database. The main script, `database_clean_washing.ps1`, collects asset paths from both the database and mod files, compares them, identifies mismatches, and outputs a list of "wrong assets" that can then be removed from the database.

## Requirements
- **UnrealPak.exe**: This tool is required to extract asset paths from `.pak` files. You can find `UnrealPak.exe` in the Conan Exiles DevKit under the following path: `...\ConanExilesDevKit\Engine\Binaries\Win64\UnrealPak.exe`
Copy `UnrealPak.exe` to the `DatabaseCleanWashing` directory, where the PowerShell scripts are also located.
- **Database Name**: Set a valid database name (without the `.db` extension) in the scripts.
- **Location**: Place the entire `DatabaseCleanWashing` directory in the `Saved` folder of your Conan Exiles server: `...\ConanSandbox\Saved\DatabaseCleanWashing

## Batch Files
The script can only be executed via the following batch files, which are located in the same directory as the PowerShell script:

- **start_wasching.bat**: This batch file runs the script with the `wasching` parameter, which will initiate the asset extraction and comparison process.

- **start_cleanup.bat**: This batch file runs the script with the `cleanup` parameter, which will delete the "wrong assets" from the database.

Double-click the appropriate batch file to run the script.

## Script Details
`database_clean_washing.ps1`
This script:

1. Creates a Database Backup: Saves a timestamped backup of the database in the `DatabaseCleanWashing` directory.

2. Asset Extraction and Comparison (via `wasching` parameter):

 - Extracts paths of assets from the database and mod files, saving them to `db_assetsPath.txt` and `mod_assetsPath.txt`.
 - Compares asset paths to identify mismatches and saves incorrect assets in `wrong_assets.txt`.
3. Cleanup of Wrong Assets (via `cleanup` parameter):

 - Deletes any asset paths listed in `wrong_assets.txt` from the database.
## Usage
1. Run the Script:

 - To initiate the asset extraction and comparison, run `start_wasching.bat`.
 - To delete the "wrong assets," run `start_cleanup.bat`.
2. Database Name Prompt:

 - When running the script, you will be prompted to enter the database name (without the `.db` extension).
3. Results:

 - `db_assetsPath.txt` – Contains asset paths extracted from the database.
 - `mod_assetsPath.txt` – Contains asset paths extracted from the mod files.
 - `wrong_assets.txt` – Contains "wrong" assets identified for cleanup.
4. Backup:

 - A backup of the database is automatically created before any processing. This ensures that the original data is preserved.
5. Progress Indicators:

  - The script displays progress during the asset comparison and cleanup process, providing feedback on each operation.
## Notes
**UnrealPak.exe Path**: Ensure that `UnrealPak.exe` is in the correct directory.
**SQLite3 Path**: Ensure `sqlite3.exe` is available in the parent directory to execute queries.
**Debug Mode**: Set `$DebugMode` to `$true` in the script to activate additional debug messages for troubleshooting.