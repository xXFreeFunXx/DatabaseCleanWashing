# DatabaseCleanWashing

## Overview

The `DatabaseCleanWashing` script is a tool designed to clean up asset paths in the database of a Conan Exiles server. This is especially useful when modders delete or rename their assets, or when you stop using certain mods. The script identifies and removes assets from the database that are no longer present in the mod list, ensuring that outdated or orphaned data is cleaned up.

The script compares assets found in the database against assets present in the mod files (PAK files). Any database assets not found in the mod list are flagged for removal.

---

## Requirements

To use the script, you will need the following tools and files:

1. **UnrealPak.exe**
   - This tool is required to extract information from the PAK files. It is included with the Conan Exiles DevKit under:
     ```
     ...\ConanExilesDevKit\Engine\Binaries\Win64\UnrealPak.exe
     ```
   - Copy the `UnrealPak.exe` file into the same directory as this script (`DatabaseCleanWashing`).

2. **sqlite3.exe**
   - This tool is required to process the SQLite database. It is typically found in the `Saved` folder of both the Conan Exiles server and client installations.

3. **Folder Placement**
   - Place the `DatabaseCleanWashing` folder in the `Saved` directory of your Conan Exiles server:
     ```
     ...\ConanSandbox\Saved\DatabaseCleanWashing
     ```

4. **Database Name**
   - Provide the database name **without the `.db` extension** when prompted by the script (e.g., use `game` instead of `game.db`).

---

## Usage

The script is executed using batch files included in the `DatabaseCleanWashing` directory. Follow these steps:

### Step 1: Washing (Asset Comparison)
1. Run the `start_washing.bat` file.
2. The script will compare assets in the database against assets in the mod list. 
3. If outdated assets are found, they will be flagged for removal in the `delete_assets.sql` file.

### Step 2: Cleanup (Database Cleanup)
1. If outdated assets were identified, run the `start_cleanup.bat` file.
2. This will:
   - Create a backup of your database with a timestamp.
   - Execute the SQL commands in `delete_assets.sql` to remove outdated assets from the database.

---

## Important Notes

- **Backup:** The script automatically creates a backup before making any changes to the database. If errors occur, you can restore your database from this backup.
- **User Responsibility:** Since this script directly modifies the database, use it with caution. Ensure you understand what it does before running it.
- **Debug Mode:** If you encounter issues, you can enable debug mode in the script by setting `$DebugMode = $true`. This will provide additional output for troubleshooting.
- **Feedback:** If something doesn't work as expected, feel free to provide feedback via Discord.

---

## Tools Recap

Ensure the following tools are present in the `DatabaseCleanWashing` directory:
1. **UnrealPak.exe** – Extracts asset information from PAK files.
2. **sqlite3.exe** – Processes the database.

---

Thank you for using `DatabaseCleanWashing`! It simplifies database maintenance and helps keep your Conan Exiles server clean and optimized.
