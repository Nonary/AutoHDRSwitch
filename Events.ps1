# Determine the path of the currently running script and set the working directory to that path
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("n")]
    [string]$scriptName
)
$path = (Split-Path $MyInvocation.MyCommand.Path -Parent)
Set-Location $path
. .\Helpers.ps1 -n $scriptName

# Load settings from a JSON file located in the same directory as the script
$settings = Get-Settings

# Initialize a script scoped dictionary to store variables.
# This dictionary is used to pass parameters to functions that might not have direct access to script scope, like background jobs.
if (-not $script:arguments) {
    $script:arguments = @{}
}


$dllPath = "$($PWD.Path)\HDRController.dll".Replace("\", "\\")

# Define the function signature
Add-Type -TypeDefinition @"
    using System.Runtime.InteropServices;

    public static class HDRController {
        [DllImport("$dllPath", EntryPoint = "GetGlobalHDRState")]
        public static extern bool GetGlobalHDRState();


        [DllImport("$dllPath", EntryPoint = "EnableGlobalHDRState")]
        public static extern void EnableGlobalHDRState();

        [DllImport("$dllPath", EntryPoint = "DisableGlobalHDRState")]
        public static extern void DisableGlobalHDRState();
    }
"@


# Function to execute at the start of a stream
function OnStreamStart() {
    Write-Host "Stream started!"
    Write-Debug "Optional Debug Message"
    # Add a new key-value pair to the dictionary, demonstrating parameter storage for future retrieval
    $script:arguments.Add("Message", "This is an example of retrieving parameters in the future")
    $hostHDR = [HDRController]::GetGlobalHDRState()

    $script:arguments.Add("hostHDR", $hostHDR)
    $clientHdrState = $env:SUNSHINE_CLIENT_HDR
    Write-Host "Current (Host) HDR State: $hostHDR"
    Write-Host "Current (Client) HDR State: $clientHdrState"

    if ($hostHDR -ne $clientHdrState) {
        if ($clientHdrState) {
            Write-Host "Enabling HDR"
            [HDRController]::EnableGlobalHDRState()
        }
        else {
            Write-Host "Turning off HDR"
            [HDRController]::DisableGlobalHDRState()
        }
    }
    
    if($settings.IDDSampleFix){
        if($hostHDR -and $clientHdrState){
            Write-Host "IDDSample Fix is enabled, now automating turning HDR off and on again."
            [HDRController]::DisableGlobalHDRState()
            [HDRController]::EnableGlobalHDRState()
            Write-Host "HDR has been toggled successfully!"
        }
    }

    if($hostHDR -eq $clientHdrState) {
        Write-Host "Client already matches the host for HDR, no changes will be applied."
    }
}

# Function to execute at the end of a stream. This function is called in a background job,
# and hence doesn't have direct access to the script scope. $kwargs is passed explicitly to emulate script:arguments.
function OnStreamEnd($kwargs) {

    if ($kwargs["hostHDR"]) {
        Write-Host "Enabling HDR"
        [HDRController]::EnableGlobalHDRState()
    }
    else {
        Write-Host "Turning off HDR"
        [HDRController]::DisableGlobalHDRState()
    }

    return $true
}