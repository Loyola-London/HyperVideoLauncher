param(
    [String]$HyperVideoApp,
    [Int]$DisplaySwitchDelay = 5
)

$LogFile = "$env:LOCALAPPDATA\Temp\HyperVideoLauncher.log"

if ($PSBoundParameters.Count -eq 0) {
    Write-Host "Usage: HyperVideoLauncher.exe -HyperVideoApp <path to executable requiring OpenGL/Vulkan> -DisplaySwitchDelay <delay seconds before switching off Hyper-V Display>"
    exit 1  # Exits script with an error code
}

$ErrorActionPreference = "Stop"

try {
    "Current Working Directory: $(Get-Location)" | Out-File -Append -FilePath $LogFile

    $ScriptParameters = ($PSBoundParameters.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ", "
    "Script Parameters: $ScriptParameters" | Out-File -Append -FilePath $LogFile

    "Enabling Hyper-V Monitor to launch $HyperVideoApp" | Out-File -Append -FilePath $LogFile

    DisplaySwitch.exe /extend
    Start-Sleep -Seconds 2

    if ($HyperVideoApp.Split(" ", 2).Count -gt 1) { # Check to see if the application has command-line parameters
        $AppCommand = $HyperVideoApp.Split(" ", 2)[0].Trim() # Separate the application
        $AppArguments = $HyperVideoApp.Split(" ", 2)[1].Trim() # From the parameters

        "Starting process $AppCommand with $AppArguments arguments" | Out-File -Append -FilePath $LogFile

        $AppProcess = Start-Process -FilePath $AppCommand -Argument $AppArguments -PassThru # Start the process with passthru to allow turning HyperVMonitor off
    } else {
        $AppCommand = $HyperVideoApp # Get the application

        "Starting process $AppCommand" | Out-File -Append -FilePath $LogFile

        $AppProcess = Start-Process -FilePath $AppCommand -PassThru  # Start the process with passthru to allow turning HyperVMonitor off
    }
    $AppProcessInfo = "Process ID: $($AppProcess.Id), Name: $($AppProcess.ProcessName), Start Time: $($AppProcess.StartTime), Path: $($AppProcess.Path)"
    $AppProcessInfo | Out-File -Append -FilePath $LogFile


    "Waiting $DisplaySwitchDelay seconds to turn off monitor" | Out-File -Append -FilePath $LogFile
    Start-Sleep -Seconds $DisplaySwitchDelay

    DisplaySwitch.exe /internal
} catch {
    $ErrorMessage = "$(Get-Date) - ERROR: $($_.Exception.Message)"
    
    Add-Content -Path $LogFile -Value $ErrorMessage
    
    throw "Script encountered an error and has been stopped. Check the log: $LogFile"
}