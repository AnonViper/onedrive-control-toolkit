<#
.SYNOPSIS
    Permanently removes Microsoft OneDrive from a Windows system.

.DESCRIPTION
    This script completely uninstalls OneDrive, applies registry policies to prevent reinstallation,
    removes OneDrive from File Explorer, and cleans up associated data folders. The script must be
    run with Administrator privileges.

.PARAMETER
    None

.NOTES
    - Requires Administrator rights to execute
    - Stops all running OneDrive processes before uninstallation
    - Applies Group Policy simulation registry keys for all Windows editions (Home, Pro, Enterprise)
    - Removes Active Setup entries to prevent re-installation for new user profiles
    - Removes OneDrive from File Explorer sidebar
    - Deletes leftover OneDrive configuration and data folders
    - Restarts Windows Explorer to apply visual changes
    - Author: viper

.EXAMPLE
    PS C:\> .\remove_OneDrive.ps1
    	Runs the script to permanently remove OneDrive from the system. 


.REQUIRES
    -RunAsAdministrator
    - Need to also run the following command:
    	-Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.WARNINGS
    This action is destructive and permanent. OneDrive will be completely removed from the system
    and cannot be easily restored through normal means. Ensure all important OneDrive files are
    backed up before running this script.
#>


if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as an Administrator."
    break
}

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
# Note: These registry keys simulate the Group Policy "Prevent the usage of OneDrive" 
# This works on Home, Pro, and Enterprise.
Write-Host "Applying Registry Blocks (Group Policy Simulation)..."
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
if (-not (Test-Path $policyPath)) { New-Item -Path $policyPath -Force }
Set-ItemProperty -Path $policyPath -Name "DisableFileSyncNGSC" -Value 1
Set-ItemProperty -Path $policyPath -Name "DisableFileSync" -Value 1

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
$clsidPath = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if (Test-Path $clsidPath) {
    Set-ItemProperty -Path $clsidPath -Name "System.IsPinnedToNameSpaceTree" -Value 0
}
# Also handle 64-bit redirection key
$wow64Path = "HKCR:\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
if (Test-Path $wow64Path) {
    Set-ItemProperty -Path $wow64Path -Name "System.IsPinnedToNameSpaceTree" -Value 0
}

# Clean up leftover Onedrive folders
Write-Host "Cleaning up leftover data folders..."
$folders = @(
    "$env:LocalAppData\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft OneDrive",
    "C:\OneDriveTemp"
)
foreach ($f in $folders) {
    if (Test-Path $f) { Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue }
}

# Restart Explorer to apply visual changes
Write-Host "Restarting File Explorer..."
Stop-Process -Name explorer -Force

Write-Host "--- OneDrive has been permanently removed. ---" -ForegroundColor Cyan

# Author credit
Write-Host "Written by:" -ForegroundColor Green
Write-Host "Joshua Viper Costanza" -ForegroundColor Green