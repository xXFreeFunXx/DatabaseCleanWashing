@echo off
set "SCRIPT_PATH=%~dp0database_clean_washing.ps1"

where pwsh >nul 2>nul

if %errorlevel% equ 0 (
	echo Starting New Powershell
	pause
    pwsh -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" cleanup
) else (
	echo Starting Old Powershell
	pause
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" cleanup
)
