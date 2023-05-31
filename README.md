The pre-command version of this script is more "reactive", meaning it only runs when necessary. It also has a longer grace peroid during the suspension of a stream, 120 seconds, before reverting back. When ending a stream in Moonlight, it will revert back instantly.

# PREREQUISITES

If using Windows 11, make sure to set your default terminal to Windows Console Host, otherwise you will notice a PowerShell window minimized on your PC at all times.

## Requirements:
- Host must be Windows
- Sunshine must be installed as a service (it does not work with the zip version of Sunshine)
- Sunshine logging level must be set to Debug
- Users must have read permissions to %WINDIR%/Temp/Sunshine.log (do not change other permissions, just make sure Users have at least read permissions)
- HDR Capable Display

## Caveats:
 - If using Windows 11, you'll need to set the default terminal to Windows Console Host as there is currently a bug in Windows Terminal that prevents hidden consoles from working properly.
    * That can be changed at Settings > Privacy & security > Security > For developers > Terminal [Let Windows decide] >> (change to) >> Terminal [Windows Console Host]
 - Prepcommands do not work from cold reboots, and will prevent Sunshine from working until you logon locally.
   * You should add a new application (with any name you'd like) in the WebUI and leave **both** the command and detached command empty.
   * When adding this new application, make sure global prep command option is disabled.
   * That will serve as a fallback option when you have to remote into your computer from a cold start.
   * Normal reboots issued from start menu, will still work without the workaround above as long as Settings > Accounts > Sign-in options and "Use my sign-in info to automatically finish setting up after an update" is enabled which is default in Windows 10 & 11.
 - The script will stop working if you move the folder, simply reinstall it to resolve that issue.

## What it Does:
Checks to see if the last connected Moonlight client asked for HDR, if so, it will enable HDR. Otherwise, it will disable it.
Once the stream ends, it will configure the last HDR setting prior to starting the stream.

## Credits:
The HDR toggling code is from the following repositories:
- https://github.com/Codectory/AutoActions - The original developer of the HDR toggle code that made calling the DLL possible.
- https://github.com/anaisbetts/AutoActions - She added two additional exported functions to make calling the DLL easier.

## Installation:
1. Store this folder in a location you intend to keep. If you delete this folder or move it, the automation will stop working.
2. To install, double click the Install.bat file. You may get a smart screen warning, this is normal.
3. To uninstall, do the same thing with Uninstall.bat.
