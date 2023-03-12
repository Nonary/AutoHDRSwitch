PREREQUISITES

If Windows 11, make sure to set your default terminal to Windows Console Host, otherwise you will notice a powershell window minimized on your PC at all times.


Requirements:
    Host must be Windows
    Sunshine must be installed a service (it does not work with the zip version of Sunshine)
    Sunshine logging level must be set to Debug
    Users must have read permissions to %WINDIR%/Temp/Sunshine.log (do not change other permissions, just make sure Users has atleast read permisisons)
    HDR Capable Display


CAVEAT:
	Once installed, you cannot move the folder without reinstalling the script again.
	So basically, if you move the folder, run the install script again to resolve.

What it Does:
    Checks to see if the last connected Moonlight client asked for HDR, if so, it will enable HDR. Otherwise, it will disable it.
    Once stream ends, it will configure the last HDR setting prior to starting the stream.


Credits:
    The HDR toggling code is from the following repositories
        https://github.com/Codectory/AutoActions - The original developer of the HDR toggle code that made calling the DLL possible.
        https://github.com/anaisbetts/AutoActions - She added two additional exported functions to make calling the DLL easier



Installation:
    Assuming you followed the prerequisites all you have to do is double click install script. Removing is the same, except uninstall script.