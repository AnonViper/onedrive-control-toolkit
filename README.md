# onedrive-control-toolkit
PowerShell toolkit for controlled removal and restoration of Microsoft OneDrive in Windows environments.


OneDrive Control Scripts (Remove & Reinstall)

PowerShell scripts to fully remove Microsoft OneDrive from Windows and later restore it if needed.

This project provides a reversible pair of scripts that give you explicit control over a Windows component that normally reinstalls itself. Designed for lab systems, privacy-focused builds, gold images, and administrative environments.

Overview

These scripts allow you to:

Completely uninstall OneDrive

Prevent Windows from reinstalling or re-enabling it

Remove OneDrive from File Explorer

Clean leftover data folders

Fully restore OneDrive later using the companion reinstall script

Nothing runs silently.
No background services.
All changes are explicit and reversible.

Included Scripts
1️⃣ remove_OneDrive.ps1

Permanently removes OneDrive and disables known Windows mechanisms that restore it.

Actions performed:

Stops running OneDrive processes

Uninstalls OneDrive using the official installer

Applies system-wide registry policies to disable OneDrive

Removes Active Setup entries that reinstall OneDrive for new users

Removes OneDrive from the File Explorer sidebar

Deletes leftover OneDrive data folders for the current user

Restarts File Explorer to apply changes

2️⃣ reinstall_OneDrive.ps1

Reverses the removal script and restores OneDrive functionality.

Actions performed:

Removes OneDrive block policies

Restores Explorer integration

Reinstalls OneDrive using the official Windows installer

Restarts File Explorer

Safe to run even if OneDrive was never removed.

Requirements

Windows 10 or Windows 11

Administrator privileges

PowerShell execution enabled for the session

Before running either script:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Press Y to allow execution for the current session.
You will need to run this per session unless you explicitly choose A (not recommended).

Then run PowerShell as Administrator and execute the script.

Usage
Remove OneDrive
.\remove_OneDrive.ps1

⚠️ Warning:
This disables OneDrive system-wide. Ensure all important files are backed up or moved before running.

Reinstall OneDrive
.\reinstall_OneDrive.ps1

If the installer is not found locally, the script will prompt you to download it from Microsoft.

Scope & Notes

Removal cleans current-user OneDrive data folders only
(Other user profiles are not modified)

Policies are applied system-wide

File Explorer restarts automatically

No reboot required

No third-party tools

No unsupported system hacks

Recommended Use Cases

Security labs & homelabs

Privacy-focused Windows setups

Gold images & VM templates

Systems where cloud sync is undesired or prohibited

Learning environments focused on OS control

When Not To Use This

Systems relying on OneDrive for backup or compliance

Shared PCs without user consent

Environments where cloud sync is mandatory

Philosophy

Windows treats OneDrive as a default assumption.
These scripts turn it into a user choice.

No telemetry tricks.
No binary patching.
No obscure hacks.

Just documented, reversible control over your own system.

Author

Joshua “Viper” Costanza
