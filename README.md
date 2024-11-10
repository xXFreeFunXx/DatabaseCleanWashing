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

## Scripts
1. `database_clean_washing.ps1`
This script:

- Creates a backup of the database in the `DatabaseCleanWashing` directory.
- Gathers asset paths from the database and mod files, compares them, and identifies mismatches.
- Outputs a list of incorrect (or "wrong") assets in a file named `wrong_assets.txt` within the `DatabaseCleanWashing` directory.
- Deletes any "wrong" assets from the database if the cleanup parameter is used.

## Usage
1. Run the script using one of the batch files:

To start asset extraction and comparison, run start_wasching.bat.
This will automatically call the script with the wasching parameter.
To delete the "wrong assets" from the database, run start_cleanup.bat.
This will automatically call the script with the cleanup parameter.
2. Database Name Prompt:

You will be prompted to enter the name of the database (without the file extension). Common database names are:
For Exiled Lands: game
For Siptah: dlc_siptah
For Savage Wilds: savagewilds_game
3. Results:

If any mismatched mod assets are found, they will be saved in wrong_assets.txt.
The database backup will be saved with a timestamped filename in the DatabaseCleanWashing directory.
4. Mod Assets:

The script checks for assets in .pak files located in the Mods directory. If no .pak files are found, it will use modlist.txt if available.
Asset paths are extracted from both the database and the mod files and compared.
5. Comparing Assets:

The script will compare asset paths from the database (db_assetsPath.txt) and mod files (mod_assetsPath.txt), and generate a list of wrong assets in wrong_assets.txt.
6. Cleanup:

If the cleanup parameter is used, the script will read from wrong_assets.txt and delete the corresponding entries from the database.
Important Files
db_assetsPath.txt – Contains the asset paths extracted from the database.
mod_assetsPath.txt – Contains the asset paths extracted from the mod files.
wrong_assets.txt – Contains the wrong (outdated) assets that can be deleted from the database.
Troubleshooting
Missing UnrealPak.exe:
If UnrealPak.exe is not found, ensure that the file is located in the ..\ConanExilesDevKit\Engine\Binaries\Win64\ directory, and that the path in the script is correctly specified.

SQLite3 Errors:
If SQLite3 does not execute properly, check that the path to sqlite3.exe is correct and that SQLite3 is properly installed on your system.

Empty or Missing Files:
If no results are found from the database query or the .pak files, ensure that the database is correct and the mod files are located in the right directory.

Notes
The script automatically creates backups of the database before processing, so no data will be lost.
If errors occur while running the script, enable the debug output by activating the Write-DebugMessage function in the script to get additional details.