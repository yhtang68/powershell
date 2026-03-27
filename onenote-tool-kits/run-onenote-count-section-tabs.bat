@echo off
REM Get the directory of this .bat file
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell script in the same directory
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%onenote-count-section-tabs.ps1"

REM Optional: keep console open to see output
pause