# Mod Asset Checker Script

This PowerShell script is designed to identify mismatches between Mod Assets stored in a SQLite database and Mod Assets contained within `.pak` files for a Conan Exiles server. It performs the following tasks:

1. Creates a backup of the specified SQLite database.
2. Extracts Mod Asset paths from the database and `.pak` files.
3. Compares the two lists to identify any "wrong assets" in the database that do not match assets in the `.pak` files.
4. Generates output files with asset lists only when relevant assets are found.

## Prerequisites

- **UnrealPak.exe**: Ensure that `UnrealPak.exe` (found in the Conan Exiles DevKit) is located in the same directory as this script. This tool is used to read `.pak` files and extract asset paths.
- **Database Name**: Set the `$databaseName` variable within the script to match the name of your SQLite database (without the `.db` extension).
- **Script Location**: Place this script in the `Saved` directory of your Conan Exiles server at the following path:
