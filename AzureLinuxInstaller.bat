@echo off
echo Launching GPG installer...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-GPG.ps1"
if errorlevel 1 (
    echo GPG installation or verification failed.
    exit /b 1
)
echo GPG installed and verified successfully.
echo Launching Azure Installer...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0InstallAndVerifyISO.ps1"
pause
