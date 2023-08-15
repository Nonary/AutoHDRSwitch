param($terminate)

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

# Call the function and store the result in a variable


$script:hdrState = $false
function OnStreamStart($hdrMode) {
    $script:hdrState = [HDRController]::GetGlobalHDRState() 
    $clientHdrState = [System.Boolean]::Parse($hdrMode)
    Write-Host "Current (Host) HDR State: $($script:hdrState)"
    Write-Host "Current (Client) HDR State: $clientHdrState"

    if ($script:hdrState -ne $clientHdrState) {
        if ($clientHdrState) {
            Write-Host "Enabling HDR"
            [HDRController]::EnableGlobalHDRState()
        }
        else {
            Write-Host "Turning off HDR"
            [HDRController]::DisableGlobalHDRState()
        }
    }
    else {
        Write-Host "Client already matches the host for HDR, no changes will be applied."
    }
}

function OnStreamEnd() {
    if ($script:hdrState) {
        Write-Host "Enabling HDR"
        [HDRController]::EnableGlobalHDRState()
    }
    else {
        Write-Host "Turning off HDR"
        [HDRController]::DisableGlobalHDRState()
    }
}

function IsSunshineUser() {
    return $null -ne (Get-Process sunshine -ErrorAction SilentlyContinue)
}

function IsCurrentlyStreaming() {
    if (IsSunshineUser) {
        return $null -ne (Get-NetUDPEndpoint -OwningProcess (Get-Process sunshine).Id -ErrorAction Ignore)
    }

    return $null -ne (Get-Process nvstreamer -ErrorAction SilentlyContinue)
}


function Stop-HDRToggleScript() {

    $pipeExists = Get-ChildItem -Path "\\.\pipe\" | Where-Object { $_.Name -eq "HDRToggle" } 
    if ($pipeExists.Length -gt 0) {
        $pipeName = "HDRToggle"
        $pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", $pipeName, [System.IO.Pipes.PipeDirection]::Out)
        $pipe.Connect(3)
        $streamWriter = New-Object System.IO.StreamWriter($pipe)
        $streamWriter.WriteLine("Terminate")
        try {
            $streamWriter.Flush()
            $streamWriter.Dispose()
            $pipe.Dispose()
        }
        catch {
            # We don't care if the disposal fails, this is common with async pipes.
            # Also, this powershell script will terminate anyway.
        }
    }
}


if ($terminate) {
    Stop-HDRToggleScript | Out-Null
}