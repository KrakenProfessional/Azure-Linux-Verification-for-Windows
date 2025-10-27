$downloadPath = "$env:USERPROFILE\Downloads\AzureLinux"
New-Item -ItemType Directory -Path $downloadPath -Force

# Download files
Invoke-WebRequest -Uri "https://aka.ms/AzureLinux-3.0-x86_64.iso" -OutFile "$downloadPath\AzureLinux-3.0-x86_64.iso"
Invoke-WebRequest -Uri "https://aka.ms/azurelinux-3.0-x86_64-iso-checksum" -OutFile "$downloadPath\azurelinux-3.0-x86_64-iso-checksum"
Invoke-WebRequest -Uri "https://aka.ms/azurelinux-3.0-x86_64-iso-checksum-signature" -OutFile "$downloadPath\azurelinux-3.0-x86_64-iso-checksum-signature"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/microsoft/azurelinux/3.0/SPECS/azurelinux-repos/MICROSOFT-RPM-GPG-KEY" -OutFile "$downloadPath\MICROSOFT-RPM-GPG-KEY"

# Set variables
$CHECKSUM_FILE = "$downloadPath\azurelinux-3.0-x86_64-iso-checksum"
$SIGNATURE_FILE = "$downloadPath\azurelinux-3.0-x86_64-iso-checksum-signature"
$ISO_FILE = "$downloadPath\AzureLinux-3.0-x86_64.iso"
$logPath = "$downloadPath\checksum-verification.log"

# Check if GPG is available
$gpgCmd = Get-Command gpg -ErrorAction SilentlyContinue
if ($null -eq $gpgCmd) {
    Write-Host "GPG is not installed or not in PATH." -ForegroundColor Red
    exit 1
}

# Import GPG key
try {
    gpg --import "$downloadPath\MICROSOFT-RPM-GPG-KEY"
    Add-Content $logPath "[$(Get-Date)] GPG key imported successfully."
} catch {
    Write-Host "Failed to import GPG key: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify signature
try {
    gpg --verify $SIGNATURE_FILE $CHECKSUM_FILE
    Add-Content $logPath "[$(Get-Date)] Signature verification passed."
} catch {
    Write-Host "Signature verification failed: $($_.Exception.Message)" -ForegroundColor Red
    Add-Content $logPath "[$(Get-Date)] Signature verification failed."
    exit 1
}

# Normalize line endings
(Get-Content $CHECKSUM_FILE) | Set-Content -NoNewline $CHECKSUM_FILE

# Verify checksum
$expectedHash = (Get-Content $CHECKSUM_FILE | Select-String -Pattern "AzureLinux-3.0-x86_64.iso").Line.Split(" ")[0].Trim()
$actualHash = (Get-FileHash -Path $ISO_FILE -Algorithm SHA256).Hash

if ($actualHash -eq $expectedHash) {
    Write-Host "Checksum matches. File integrity verified." -ForegroundColor Green
    $status = "PASS"
} else {
    Write-Host "Checksum mismatch! File may be corrupted or tampered." -ForegroundColor Red
    Write-Host "Expected: $expectedHash"
    Write-Host "Actual:   $actualHash"
    $status = "FAIL"
}

# Check if ISO filename is present in checksum file
$match = Get-Content $CHECKSUM_FILE | Select-String -Pattern "AzureLinux-3.0-x86_64.iso"
if (-not $match) {
    Write-Host "ISO filename not found in checksum file." -ForegroundColor Yellow
    exit 1
}

# Log results
Add-Content $logPath "[$(Get-Date)] Expected: $expectedHash"
Add-Content $logPath "[$(Get-Date)] Actual:   $actualHash"
Add-Content $logPath "[$(Get-Date)] Result:   $($actualHash -eq $expectedHash)"
Add-Content $logPath "[$(Get-Date)] Algorithm: SHA256"
Add-Content $logPath "[$(Get-Date)] Status: $status"

if ($status -eq "PASS") {
    exit 0
} else {
    exit 1
}



