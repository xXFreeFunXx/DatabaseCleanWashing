@echo off
set "SCRIPT_PATH=%~dp0database_clean_washing.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" wasching
