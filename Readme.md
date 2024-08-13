## Requirements:
- Host must be Windows
- HDR Capable Display
- Sunshine 0.21.0 or higher

## Caveats:
 - If using Windows 11, you'll need to set the default terminal to Windows Console Host as there is currently a bug in Windows Terminal that prevents hidden consoles from working properly.
    * That can be changed at Settings > Privacy & security > Security > For developers > Terminal [Let Windows decide] >> (change to) >> Terminal [Windows Console Host]
 - Due to Windows API restrictions, this script does not work on cold reboots (hard crashes or shutdowns of your computer).
    * Fortunately recent changes to Sunshine makes this issue much easier to workaround.
    * Simply sign into the computer using the "Desktop" app on Moonlight, then end the stream, then start it again to resolve issue in this scenario. 
 - The script will stop working if you move the folder, simply reinstall it to resolve that issue.

## What it Does:
Checks to see if the last connected Moonlight client asked for HDR, if so, it will enable HDR. Otherwise, it will disable it.
Once the stream ends, it will configure the last HDR setting prior to starting the stream.

(Optionally) If enabled, will toggle HDR on and off automatically to fix issues with the IDDSampleDriver on overblown colors when streaming in HDR.

## Credits:
The HDR toggling code is from the following repositories:
- https://github.com/Codectory/AutoActions - The original developer of the HDR toggle code that made calling the DLL possible.
- https://github.com/anaisbetts/AutoActions - She added two additional exported functions to make calling the DLL easier.

## Installation:
1. Store this folder in a location you intend to keep. If you delete this folder or move it, the automation will stop working.
2. If you intend on using IDDSampleDriver, which has known issues with HDR you should enable the "IDDSampleFix" setting located in the settings.json file.
3. To install, double click the Install.bat file. You may get a smart screen warning, this is normal.
4. To uninstall, do the same thing with Uninstall.bat.

### Recent Changes
- Migrated to [Sunshine Script Installer Template](https://github.com/Nonary/SunshineScriptInstaller)
- Added new option for fixing HDR issues on IDDSampleDriver displays.