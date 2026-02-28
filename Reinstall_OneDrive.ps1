
<#
.SYNOPSIS
    Reinstalls Microsoft OneDrive and restores required system settings.
#>

# --- Admin Check ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

Write-Host "--- Starting OneDrive Reinstallation ---" -ForegroundColor Cyan

# --- Remove OneDrive Block Policies ---
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
if (Test-Path $policyPath) {
    Write-Host "Removing OneDrive policy blocks..."
    Remove-Item -Path $policyPath -Recurse -Force
}

# --- Restore Explorer Sidebar ---
Write-Host "Restoring OneDrive Explorer integration..."
$clsid = "{018D5C66-4533-4307-9B53-224DE2ED1FE6}"

$paths = @(
    "HKCR:\CLSID\$clsid",
    "HKCR:\WOW6432Node\CLSID\$clsid"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "System.IsPinnedToNameSpaceTree" -Value 1
    }
}

# --- Reinstall OneDrive ---
$installer = "$env:SystemRoot\System32\OneDriveSetup.exe"

if (Test-Path $installer) {
    Write-Host "Launching OneDrive installer..."
    Start-Process $installer -NoNewWindow -Wait
} else {
    Write-Warning "OneDriveSetup.exe not found."
    Write-Host "Download from: https://www.microsoft.com/onedrive/download"
}

# --- Restart Explorer ---
Write-Host "Restarting File Explorer..."
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "--- OneDrive reinstall completed ---" -ForegroundColor Green

# Author credit
Write-Host "Written by:" -ForegroundColor Green
Write-Host "Joshua Viper Costanza" -ForegroundColor Green