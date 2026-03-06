# onedrive-control-toolkit
PowerShell toolkit for controlled removal and restoration of Microsoft OneDrive in Windows environments.


OneDrive Control Scripts (Remove & Reinstall)
These PowerShell scripts allow you to fully remove Microsoft OneDrive from Windows and later reinstall and restore it if needed.
They are designed as a reversible pair, giving you explicit control over a Windows feature that is normally persistent and self-restoring.
This is intended for lab systems, privacy-focused setups, gold images, and administrative environments.

What This Does (At a Glance)
•	Completely uninstalls OneDrive
•	Prevents Windows from reinstalling or re-enabling it
•	Removes OneDrive from File Explorer 
•	Cleans up leftover data folders
•	Allows full restoration later using the companion reinstall script
•	Nothing is hidden. Nothing runs in the background. Every change is explicit.

Included Scripts:

1)	remove_OneDrive.ps1
Permanently removes OneDrive and disables all known mechanisms Windows uses to bring it back.

Actions performed:
•	Stops running OneDrive processes
•	Uninstalls OneDrive using the official installer
•	Applies system-wide registry policies to disable OneDrive
•	Removes Active Setup entries that reinstall OneDrive for new users
•	Removes OneDrive from the File Explorer sidebar
•	Deletes leftover OneDrive data folders for the current user
•	Restarts File Explorer to apply changes

 
2)	reinstall_OneDrive.ps1
Reverses the changes made by the removal script and restores OneDrive functionality.

Actions performed:
•	Removes OneDrive block policies
•	Restores OneDrive Explorer integration
•	Reinstalls OneDrive using the official Windows installer
•	Restarts File Explorer
•	This script is safe to run even if OneDrive was never removed.

Requirements
•	Windows 10 or Windows 11
•	Administrator privileges
•	PowerShell execution enabled for the session
•	Before running either script you need to run: 
-	Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
-	Then Hit Yes (Y) for that one script, will need to run this per script
•	Then run the script as Administrator.

Usage
•	Remove OneDrive - .\remove_OneDrive.ps1

Warning:
This disables OneDrive system-wide. Ensure all important files are backed up or moved to a different location before running.

•	Reinstall OneDrive - .\reinstall_OneDrive.ps1
If the installer is not found locally, the script will prompt you to download it from Microsoft.

 
Scope & Notes
•	Removal cleans current-user OneDrive data folders only
-	(other user profiles are not modified)
•	Policies are applied system-wide
•	Explorer is restarted automatically
•	No reboot is required
•	These scripts do not rely on third-party tools or unsupported hacks

When Should You Use This?
•	Security labs and homelabs
•	Privacy-focused Windows setups
•	Gold images and VM templates
•	Systems where cloud sync is undesired or prohibited
•	Learning environments where OS control matters
•	When You Should Not Use This
•	Systems that rely on OneDrive for backups or compliance
•	Shared family PCs without user consent
•	Environments where cloud sync is mandatory

Philosophy
•	Windows treats OneDrive as a default assumption.
•	These scripts turn it into a choice.
•	No telemetry tricks. No binary patching
•	Just documented, reversible control over your own system.

Author
Joshua “Viper” Costanza
