# Database Clean Washing

The **Database Clean Washing** project is designed for cleaning and managing asset references in your Conan Exiles server database. The main script, `database_clean_washing.ps1`, collects asset paths from both the database and mod files, identifies any mismatches, and lists "wrong assets" that can then be removed from the database using the additional cleanup script `database_cleanup.ps1`.

## Requirements
- **UnrealPak.exe**: This tool is required to extract asset paths from `.pak` files. You can find `UnrealPak.exe` in the Conan Exiles DevKit under the following path: `...\ConanExilesDevKit\Engine\Binaries\Win64\UnrealPak.exe`
Copy `UnrealPak.exe` to the `DatabaseCleanWashing` directory, where the PowerShell scripts are also located.
- **Database Name**: Set a valid database name (without the `.db` extension) in the scripts.
- **Location**: Place the entire `DatabaseCleanWashing` directory in the `Saved` folder of your Conan Exiles server: `...\ConanSandbox\Saved\DatabaseCleanWashing

## Scripts

### 1. database_clean_washing.ps1

This script:
- Creates a backup of the database in the `DatabaseCleanWashing` directory.
- Gathers asset paths from the database and mod files, comparing them to identify mismatches.
- Outputs a list of incorrect (or "wrong") assets in a file named `wrong_assets.txt` within the `DatabaseCleanWashing` directory.

#### Usage
1. **Run the script**:
 - Open PowerShell.
 - Navigate to the `DatabaseCleanWashing` directory.
 - Execute the script:
   ```powershell
   .\database_clean_washing.ps1
   ```
2. **Results**:
 - If any mismatched mod assets are found, they will be saved in `wrong_assets.txt`.
 - The database backup will be saved with a timestamped filename.

### 2. database_cleanup.ps1

This script deletes entries listed in `wrong_assets.txt` from the database.

**Important**: Ensure the Conan Exiles server is offline before running this script, as modifying the database while the server is online may cause data corruption.

#### Usage
1. Confirm the server is offline.
2. Open PowerShell and navigate to the `DatabaseCleanWashing` directory.
3. Run the script:
   ```powershell
   .\database_cleanup.ps1
   ```