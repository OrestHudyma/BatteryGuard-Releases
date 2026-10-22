# Battery Guard

Windows tray battery monitor and charge-limit application.

[Download the latest installer](https://github.com/OrestHudyma/BatteryGuard-Releases/releases/latest)

This public repository distributes installers and release notes only. Application source is maintained separately in a private repository.

## Install and update

1. Exit an existing instance using **Exit and restore automatic charging** in its tray menu.
2. Run the installer. It supports Program Files, optional tray startup and standard Windows uninstall.
3. Version 0.1.1 and later check for newer releases automatically. Updates appear only in the app window; click **Update** to install. No GitHub account or token is needed.

If upgrading from 0.1, install 0.1.1 manually once to switch to this public update channel. Settings and thresholds are preserved.

## Compatibility

Windows 11 x64 and .NET Framework 4.8+. Charge control is verified only for HP EliteBook 8570w, board 176B, BIOS 68IAV Ver. F.70. The installer checks this profile and blocks unverified hardware. Similar HP models are not automatically supported.

Installer SHA-256 digests are available in the release assets. The builds are not Authenticode-signed. A complete upgrade with UAC and active charge control has not yet been exercised end-to-end.
