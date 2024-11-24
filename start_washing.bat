@echo off
set "SCRIPT_PATH=%~dp0database_clean_washing.ps1"

where pwsh >nul 2>nul

if %errorlevel% equ 0 (
    pwsh -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" washing
) else (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" washing
)
