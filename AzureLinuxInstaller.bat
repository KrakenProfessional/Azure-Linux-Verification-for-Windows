@echo off
setlocal
set TESTMODE=0
set RESTARTED = 0

set /a RESTARTED+=1
if %RESTARTED% GEQ 3 (
    echo Restart limit reached. Aborting. 
    echo [%date% %time%] Restart limit hit [Count: %RESTARTED%] >> "%~dp0restart.log"
    exit /b 1
)

if "%TESTMODE%"=="1" goto HandleTestChoice

:ContinueGOTO
:: Check if GPG is here
where gpg >nul 2>nul
if %errorlevel%==0 (
    echo GPG is already installed.
    goto LaunchAzure
)

echo GPG not detected.
echo Do you want to install GPG? (Y/N)
choice /C YN /N /M "Press Y to install, N to skip."

if errorlevel 2 (
    echo Skipping GPG installer...
    goto LaunchAzureNoGPG
)

:: Run GPG installer
echo Launching GPG installer...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-GPG.ps1"
if errorlevel 1 (
    echo GPG installation or verification failed.
   exit /b 1
)

:: After install, check again (restart)
where gpg >nul 2>nul
if %errorlevel%==0 (
    echo GPG installed successfully. Restarting script to refresh environment...
    call "%~f0"
    exit /b
) else (
    echo GPG still not detected after install.
    exit /b 1
)

:LaunchAzure
echo Launching Azure Installer...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0InstallAndVerifyISO.ps1"
pause
exit /b

:LaunchAzureNoGPG
echo Launching Azure Installer (No GPG)...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0GPGInstallAndVerifyISO.ps1"
pause
exit /b

:: [TEST MODE OPTIONS]

:HandleTestChoice 
echo TestMode is enabled... [TEST MODE]
echo Do you want to exit TestMode? [Y/N]
choice /C YN /N /M "Press Y to exit, N to continue."
if errorlevel 2 (
    echo Continuing... [TEST MODE]
    goto RestartTester
) else (
    echo Exiting TestMode... [TEST MODE]
    set TESTMODE=0
    goto :ContinueGOTO
)

:RestartTester
echo Launching Restart Test [TEST MODE]
call "%~f0"
goto :EOF