<#
.SYNOPSIS
    OneDrive Control Toolkit
.DESCRIPTION
    Menu-driven toolkit to remove or reinstall Microsoft OneDrive.
.AUTHOR
    Joshua Viper Costanza
.MARK
    4
#>

# ------------------------------
# Configuration
# ------------------------------
$ToolkitVersion = "4"
$LogPath = "$env:ProgramData\OneDriveToolkit.log"
$OneDriveCLSID = "{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$PolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"

# ------------------------------
# Logging Function
# ------------------------------
function Write-Log {
    param ($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp] $Message"
}

# ------------------------------
# Admin Check
# ------------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Warning "Please run this toolkit as Administrator."
    exit 1
}

# ------------------------------
# Status Check
# ------------------------------
function Get-OneDriveStatus {
    $installed = Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe"
    $blocked = Test-Path $PolicyPath

    Write-Host ""
    Write-Host "Current OneDrive Status:" -ForegroundColor Cyan
    Write-Host "--------------------------------"

    if ($installed) {
        Write-Host "Installer Present: Yes" -ForegroundColor Green
    } else {
        Write-Host "Installer Present: No" -ForegroundColor Yellow
    }

    if ($blocked) {
        Write-Host "Blocked via Policy: Yes" -ForegroundColor Yellow
    } else {
        Write-Host "Blocked via Policy: No" -ForegroundColor Green
    }

    Write-Host ""
}

# ------------------------------
# Remove OneDrive
# ------------------------------
function Remove-OneDrive {
<#
.NOTES
    - Requires Administrator rights to execute
    - Stops all running OneDrive processes before uninstallation
    - Applies Group Policy simulation registry keys for all Windows editions (Home, Pro, Enterprise)
    - Removes Active Setup entries to prevent re-installation for new user profiles
    - Removes OneDrive from File Explorer sidebar
    - Deletes leftover OneDrive configuration and data folders
    - Restarts Windows Explorer to apply visual changes
    - Author: viper
#>

    Write-Host "--- Starting Permanent OneDrive Removal ---" -ForegroundColor Cyan

    # Detect Windows OS Edition
    $osEdition = (Get-ComputerInfo).WindowsProductName
    Write-Host "Detected OS: $osEdition" -ForegroundColor Yellow

    # Kill OneDrive processes
    Write-Host "Stopping OneDrive processes..."
    Stop-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # Uninstall OneDrive App
    Write-Host "Uninstalling OneDrive application..."
    $setupPath = "C:\Windows\System32\OneDriveSetup.exe"
    Start-Process $setupPath "/uninstall" -NoNewWindow -Wait

    # Apply Permanent Block Policies
    Write-Host "Applying Registry Blocks (Group Policy Simulation)..."
    if (-not (Test-Path $PolicyPath)) { New-Item -Path $PolicyPath -Force }
    Set-ItemProperty -Path $PolicyPath -Name "DisableFileSyncNGSC" -Value 1
    Set-ItemProperty -Path $PolicyPath -Name "DisableFileSync" -Value 1

    # Prevent Re-installation for Future Users 
    Write-Host "Disabling re-installation for future user profiles..."
    $activeSetupPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components"
    $keys = Get-ChildItem $activeSetupPath
    foreach ($key in $keys) {
        $val = Get-ItemProperty -Path $key.PSPath
        if ($val.Version -like "*OneDrive*" -or $val.StubPath -like "*OneDrive*") {
            Remove-Item -Path $key.PSPath -Recurse -Force
            Write-Host "Removed Active Setup trigger: $($key.PSChildName)" -ForegroundColor Green
        }
    }

    # Remove from File Explorer Sidebar
    Write-Host "Removing OneDrive icon from File Explorer..."
    $clsidPath = "HKCR:\CLSID\$OneDriveCLSID"
    if (Test-Path $clsidPath) { Set-ItemProperty -Path $clsidPath -Name "System.IsPinnedToNameSpaceTree" -Value 0 }
    $wow64Path = "HKCR:\WOW6432Node\CLSID\$OneDriveCLSID"
    if (Test-Path $wow64Path) { Set-ItemProperty -Path $wow64Path -Name "System.IsPinnedToNameSpaceTree" -Value 0 }

    # Clean up leftover OneDrive folders
    Write-Host "Cleaning up leftover data folders..."
    $folders = @(
        "$env:LocalAppData\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive",
        "C:\OneDriveTemp"
    )
    foreach ($f in $folders) { if (Test-Path $f) { Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue } }

    # Restart Explorer
    Write-Host "Restarting File Explorer..."
    Stop-Process -Name explorer -Force

    Write-Host "--- OneDrive has been permanently removed. ---" -ForegroundColor Cyan
    Write-Host "Written by:" -ForegroundColor Green
    Write-Host "Joshua Viper Costanza" -ForegroundColor Green
}

# ------------------------------
# Reinstall OneDrive
# ------------------------------
function Reinstall-OneDrive {
<#
.SYNOPSIS
    Reinstalls Microsoft OneDrive and restores required system settings.
#>

    Write-Host "--- Starting OneDrive Reinstallation ---" -ForegroundColor Cyan

    # Remove OneDrive Block Policies
    if (Test-Path $PolicyPath) {
        Write-Host "Removing OneDrive policy blocks..."
        Remove-Item -Path $PolicyPath -Recurse -Force
    }

    # Restore Explorer Sidebar
    Write-Host "Restoring OneDrive Explorer integration..."
    $paths = @(
        "HKCR:\CLSID\$OneDriveCLSID",
        "HKCR:\WOW6432Node\CLSID\$OneDriveCLSID"
    )
    foreach ($path in $paths) { if (Test-Path $path) { Set-ItemProperty -Path $path -Name "System.IsPinnedToNameSpaceTree" -Value 1 } }

    # Reinstall OneDrive
    $installer = "$env:SystemRoot\System32\OneDriveSetup.exe"
    if (Test-Path $installer) {
        Write-Host "Launching OneDrive installer..."
        Start-Process $installer -NoNewWindow -Wait
    } else {
        Write-Warning "OneDriveSetup.exe not found."
        Write-Host "Download from: https://www.microsoft.com/onedrive/download"
    }

    # Restart Explorer
    Write-Host "Restarting File Explorer..."
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Start-Process explorer.exe

    Write-Host "--- OneDrive reinstall completed ---" -ForegroundColor Green
    Write-Host "Written by:" -ForegroundColor Green
    Write-Host "Joshua Viper Costanza" -ForegroundColor Green
}

# ------------------------------
# Menu
# ------------------------------
function Show-Menu {
    Clear-Host
    Write-Host "====================================" -ForegroundColor DarkCyan
    Write-Host "      OneDrive Control Toolkit" -ForegroundColor Cyan
    Write-Host "             MARK $ToolkitVersion"
    Write-Host "Programmer: Joshua 'Viper' Costanza" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "1. Check OneDrive Status"
    Write-Host "2. Remove OneDrive"
    Write-Host "3. Reinstall OneDrive"
    Write-Host "4. Exit"
    Write-Host ""
}

# ------------------------------
# Main Loop
# ------------------------------
do {
    Show-Menu
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Get-OneDriveStatus; Pause }
        "2" { Remove-OneDrive; Pause }
        "3" { Reinstall-OneDrive; Pause }
        "4" { Write-Host "Exiting..." -ForegroundColor Yellow }
        default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep 2 }
    }

} while ($choice -ne "4")