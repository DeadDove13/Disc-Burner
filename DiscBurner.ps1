# Define color codes
$ErrorColour = "Red"
$PassColour = "Green"
$WarningColour = "Yellow"
$InfoColour = "Cyan"
$ExitMessage = "Press Enter to exit"

# Function to analyze disk space usage
function AnalyzeDiskSpace {
    # Get the drives on the system
    $drives = Get-WmiObject -Class Win32_LogicalDisk

    # Create a dictionary for drive letters and their names
    $driveNames = @{}
    foreach ($drive in $drives) {
        $driveNames[$drive.DeviceID] = $drive.VolumeName
    }

    # Analyze each drive
    foreach ($drive in $drives) {
        $driveLetter = $drive.DeviceID
        $driveName = if ($driveNames.ContainsKey($driveLetter)) { $driveNames[$driveLetter] } else { "Unknown" }

        Write-Host "`nAnalyzing drive: $driveLetter - $($driveName.PadRight(30))" -ForegroundColor $InfoColour

        try {
            # Get disk usage statistics
            $totalSize = [math]::round($drive.Size / 1GB, 2)
            $usedSpace = [math]::round(($drive.Size - $drive.FreeSpace) / 1GB, 2)
            $freeSpace = [math]::round($drive.FreeSpace / 1GB, 2)
            $usedPercentage = [math]::round(($usedSpace / $totalSize) * 100, 2)

            # Display disk space usage with proper alignment
            Write-Host ("Total Space:      {0,10} GB" -f "$totalSize") -ForegroundColor $PassColour
            Write-Host ("Used Space:       {0,10} GB ({1,5}%)" -f "$usedSpace", "$usedPercentage") -ForegroundColor $WarningColour
            Write-Host ("Free Space:       {0,10} GB" -f "$freeSpace") -ForegroundColor $PassColour

            Write-Host "`n------------------------------------" -ForegroundColor Gray
        } catch {
            Write-Host "Failed to analyze drive: $driveLetter - $_" -ForegroundColor $ErrorColour
        }
    }
}

# Function to get RAM usage
function Get-RAMUsage {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $totalRAM = [math]::round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::round($totalRAM - $freeRAM, 2)
    $usedPercentage = [math]::round(($usedRAM / $totalRAM) * 100, 2)

    Write-Host "`nRAM Usage:" -ForegroundColor $InfoColour
    Write-Host ("Total RAM:         {0,10} GB" -f "$totalRAM") -ForegroundColor $PassColour
    Write-Host ("Used RAM:          {0,10} GB ({1,5}%)" -f "$usedRAM", "$usedPercentage") -ForegroundColor $WarningColour
    Write-Host ("Free RAM:          {0,10} GB" -f "$freeRAM") -ForegroundColor $PassColour
}

# Function to get CPU usage
function Get-CPUUsage {
    $cpuLoad = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -First 1
    $cpuUsage = [math]::round($cpuLoad.CookedValue, 2)

    Write-Host "`nCPU Usage:" -ForegroundColor $InfoColour
    Write-Host ("Current CPU Usage: {0,10}%" -f "$cpuUsage") -ForegroundColor $PassColour
}

# Function to get GPU information
function Get-GPUInfo {
    $gpus = Get-CimInstance Win32_VideoController

    foreach ($gpu in $gpus) {
        $gpuName = $gpu.Name
        $gpuMemorySize = $gpu.AdapterRAM
        $gpuMemoryGB = [math]::round($gpuMemorySize / 1GB, 2)

        Write-Host "`nGPU Info:" -ForegroundColor $InfoColour
        Write-Host ("GPU Name:        {0,-30}" -f "$gpuName") -ForegroundColor $PassColour
        Write-Host ("VRAM:            {0,10} GB" -f "$gpuMemoryGB") -ForegroundColor $PassColour
    }
}

# ASCII art and GitHub information
$asciiArt = @"
 (                                           
 )\ )            (                           
(()/( (        ( )\   (  (           (  (    
 /(_)))\ (   ( )((_) ))\ )(   (     ))\ )(
(_))_((_))\  )((_)_ /((_|()\  )\ ) /((_|()\  
 |   \(_|(_)((_) _ |_))( ((_)_(_/((_))  ((_) 
 | |) | (_-< _|| _ \ || | '_| ' \)) -_)| '_| 
 |___/|_/__|__||___/\_,_|_| |_||_|\___||_|                                                
                                               
"@

$githubText = @"
    GitHub: DeadDove13
"@

# Display ASCII art and GitHub information
Write-Host $asciiArt -ForegroundColor Red
Write-Host $githubText -ForegroundColor White

# Display a brief description
Write-Host "This script provides a detailed analysis of disk space usage, RAM, CPU, and GPU." -ForegroundColor $WarningColour

# User input loop to run the script or exit
do {
    $choice = Read-Host "Press 1 to run the script or 0 to close"

    # Execute based on user's choice
    if ($choice -eq "1") {
        AnalyzeDiskSpace
        Get-RAMUsage
        Get-CPUUsage
        Get-GPUInfo
        break
    } elseif ($choice -eq "0") {
        Write-Host "Exiting the script." -ForegroundColor White
        Exit
    } else {
        Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
    }
} while ($true)

# Prompt to exit
Read-Host -Prompt $ExitMessage
