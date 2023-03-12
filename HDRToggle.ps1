

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
function OnStreamStart() {
    $script:hdrState = [HDRController]::GetGlobalHDRState() 
    Start-Sleep -Seconds 2
    Write-Host "Current HDR State: $($script:hdrState)"
    $log_path = If (IsSunshineUser) { "$env:WINDIR\Temp\sunshine.log" } Else { "$env:ProgramData\NVIDIA Corporation\NvStream\NvStreamerCurrent.log" }
    $log_text = Get-Content  $log_path
    $clientRes = $log_text | Select-String "video\[0\]\.dynamicRangeMode.*:\s?(?<hdr>\d+)" | Select-Object matches -ExpandProperty matches -Last 1

    $hdrEnabled = $clientRes[0].Groups['hdr'].Value -eq 1

    if($hdrEnabled){
        Write-Host "Enabling HDR"
        [HDRController]::EnableGlobalHDRState()
    }
    else {
        [HDRController]::DisableGlobalHDRState()
        Write-Host "Turning off HDR"
    }
}

function OnStreamEnd() {
    if($script:hdrState){
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

function IsAboutToStartStreaming() {
    # The difference with this function is that it checks to see if user recently queried the application list on the host.
    # Useful in scenarios where a script must run prior to starting a stream.
    # Sunshine already supports this functionaly, Geforce Experience does not.

    $connectionDetected = & netstat -a -i -n | Select-String 47989 | Where-Object { $_ -like '*TIME_WAIT*' } 
    [int] $duration = $connectionDetected -split " " | Where-Object { $_ } | Select-Object -Last 1
    return $null -ne $connectionDetected -and $duration -lt 1500
}

# So that it doesn't immediately do the OnStreamEnd when user reboots
$lastStreamed = [System.DateTime]::MinValue
$onStreamStartEvent = $false
while ($true) {
    $streaming = IsCurrentlyStreaming

    if ($streaming) {
        $lastStreamed = Get-Date
        if (!$onStreamStartEvent) {
            OnStreamStart
            $onStreamStartEvent = $true
        }
    }
    elseif ($onStreamStartEvent -and ((Get-Date) - $lastStreamed).TotalSeconds -gt 2) {
        OnStreamEnd
        $onStreamStartEvent = $false
    }

    Start-Sleep -Seconds 1
}
