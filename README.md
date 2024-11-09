# Mod Asset Checker Script

This PowerShell script is designed to identify mismatches between Mod Assets stored in a SQLite database and Mod Assets contained within `.pak` files for a Conan Exiles server. It performs the following tasks:

1. Creates a backup of the specified SQLite database.
2. Extracts Mod Asset paths from the database and `.pak` files.
3. Compares the two lists to identify any "wrong assets" in the database that do not match assets in the `.pak` files.
4. Generates output files with asset lists only when relevant assets are found.

## Prerequisites

- **UnrealPak.exe**: Ensure that `UnrealPak.exe` (found in the Conan Exiles DevKit) is located in the same directory as this script. This tool is used to read `.pak` files and extract asset paths.
- **Database Name**: Set the `$databaseName` variable within the script to match the name of your SQLite database (without the `.db` extension).
- **Script Location**: Place this script in the `Saved` directory of your Conan Exiles server at the following path: `...\ConanSandbox\Saved`
## Script Usage

### Steps

1. **Place `UnrealPak.exe`**: Ensure `UnrealPak.exe` is in the same directory as this script.
2. **Edit Database Name**: Open the script in a text editor and set the `$databaseName` variable to match your SQLite database name (without `.db` extension).
3. **Run the Script**:
 - Open PowerShell in the `Saved` folder and execute the script.
 - Example:
   ```powershell
   .\ModAssetChecker.ps1
   ```

### Script Output

The script will generate the following files in the same directory:

- **Database Backup**: A timestamped backup of the database in the format `<databaseName>_yyyy.MM.dd_HH.mm.ss.db`.
- **db_assets.txt**: Contains Mod Asset paths found in the database.
- **mod_assets.txt**: Contains Mod Asset paths extracted from `.pak` files.
- **wrong_assets.txt**: Lists Mod Assets from the database that do not match any assets in the `.pak` files (only generated if mismatches are found).

### Notes

- If no `.pak` files or Mod Assets are found, `mod_assets.txt` will not be created.
- If the database query returns no assets, `db_assets.txt` will not be created.
- If there are no mismatched assets, `wrong_assets.txt` will not be created.
- If the `$databaseName` is empty or contains only whitespace, an error message will be shown, and the script will exit.

## Example Directory Structure

```plaintext
ConanSandbox
└── Saved
  ├── ModAssetChecker.ps1
  ├── UnrealPak.exe
  ├── savagewilds_game.db         # Example database file
  ├── Mods
  │   ├── modlist.txt
  │   ├── Mod1.pak
  │   └── Mod2.pak
  └── Output Files
      ├── db_assets.txt
      ├── mod_assets.txt
      └── wrong_assets.txt
