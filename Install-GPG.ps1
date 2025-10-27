Write-Host "Starting Install-GPG.ps1" -ForegroundColor Magenta

function Test-GpgInstalled {
    $cmd = Get-Command gpg -ErrorAction SilentlyContinue
    if ($null -ne $cmd) {
        Write-Host "GPG found at: $($cmd.Source)" -ForegroundColor Cyan
        return $true
    } else {
        Write-Host "GPG not found in PATH." -ForegroundColor Red
        return $false
    }
}

function Install-Gpg4win {
    $installerUrl = "https://files.gpg4win.org/gpg4win-latest.exe"
    $installerPath = "$env:TEMP\gpg4win-latest.exe"

    Write-Host "Downloading Gpg4win installer..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    Write-Host "Launching Gpg4win installer..." -ForegroundColor Yellow
    Start-Process -FilePath $installerPath -Wait
}

if (-not (Test-GpgInstalled)) {
    Write-Host "GPG not found. Installing Gpg4win..." -ForegroundColor Red
    Install-Gpg4win
}

if (Test-GpgInstalled) {
    Write-Host "GPG is already installed." -ForegroundColor Green
}

Write-Host "Ending Install-GPG.ps1" -ForegroundColor Magenta
