# Define color codes
$ErrorColour = "Red"
$PassColour = "Green"
$WarningColour = "Yellow"
$InfoColour = "Cyan"
$ExitMessage = "Press Enter to exit"

$CpuProcesses = 20 #The number of cpu Processes shown

# Function to analyze disk space usage
function AnalyzeDiskSpace {
    $drives = Get-WmiObject -Class Win32_LogicalDisk
    $driveNames = @{}
    foreach ($drive in $drives) {
        $driveNames[$drive.DeviceID] = $drive.VolumeName
    }

    foreach ($drive in $drives) {
        $driveLetter = $drive.DeviceID
        $driveName = if ($driveNames.ContainsKey($driveLetter)) { $driveNames[$driveLetter] } else { "Unknown" }

        Write-Host "`nAnalyzing drive: $driveLetter - $($driveName.PadRight(30))" -ForegroundColor $InfoColour

        try {
            $totalSize = [math]::round($drive.Size / 1GB, 2)
            $usedSpace = [math]::round(($drive.Size - $drive.FreeSpace) / 1GB, 2)
            $freeSpace = [math]::round($drive.FreeSpace / 1GB, 2)
            $usedPercentage = [math]::round(($usedSpace / $totalSize) * 100, 2)

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
    # Get overall CPU usage
    $cpuLoad = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -First 1
    $cpuUsage = [math]::round($cpuLoad.CookedValue, 2)

    Write-Host "`nCPU Usage:" -ForegroundColor $InfoColour
    Write-Host ("Current CPU Usage: {0,10}%" -f "$cpuUsage") -ForegroundColor $PassColour

    # Get CPU usage by process
    $processes = Get-Process | Sort-Object -Property CPU -Descending
    $totalCpuTime = [math]::round(($processes | Measure-Object -Property CPU -Sum).Sum, 2)
    
    Write-Host "`nTop $CpuProcesses CPU Usage by Process (% of Total CPU):" -ForegroundColor $InfoColour
    foreach ($process in $processes | Select-Object -First $CpuProcesses) {
        $processCpuTime = [math]::round($process.CPU, 2)
        $cpuPercentage = if ($totalCpuTime -ne 0) { [math]::round(($processCpuTime / $totalCpuTime) * 100, 2) } else { 0 }
        Write-Host ("{0,-30} {1,10} %" -f $process.Name, "$cpuPercentage") -ForegroundColor $PassColour
    }
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

# Function to get network activity
function Get-NetworkActivity {
    $networkInterfaces = Get-Counter '\Network Interface(*)\Bytes Total/sec' | Select-Object -ExpandProperty CounterSamples

    Write-Host "`nNetwork Activity by Interface:" -ForegroundColor $InfoColour

    foreach ($interface in $networkInterfaces) {
        $interfaceName = $interface.InstanceName
        $bytesPerSec = [math]::round($interface.CookedValue / 1MB, 2)
        Write-Host ("{0,-30} {1,10} MB/s" -f $interfaceName, "$bytesPerSec") -ForegroundColor $PassColour
    }
}

# Function to get network connections and associated processes
function Get-NetworkConnections {
    $netstat = netstat -ano
    $tcpConnections = $netstat | Select-String "TCP"
    $udpConnections = $netstat | Select-String "UDP"

    $connections = @()
    $connections += $tcpConnections
    $connections += $udpConnections

    $results = @()

    foreach ($connection in $connections) {
        if ($connection -match "^(.*?)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)$") {
            $protocol = $matches[1]
            $localAddress = $matches[2]
            $foreignAddress = $matches[3]
            $state = $matches[4]
            $processID = $matches[5]  # Renamed variable to avoid conflict

            $process = Get-Process -Id $processID -ErrorAction SilentlyContinue
            $processName = if ($process) { $process.Name } else { "Unknown" }

            $results += [pscustomobject]@{
                Protocol       = $protocol
                LocalAddress   = $localAddress
                ForeignAddress = $foreignAddress
                State          = $state
                ProcessName    = $processName
                PID            = $processID  # Updated field name
            }
        }
    }

    Write-Host "`nNetwork Connections and Processes:" -ForegroundColor $InfoColour
    $results | Format-Table -AutoSize
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
Write-Host "This script provides a detailed analysis of disk space usage, RAM, CPU, GPU, and network activity." -ForegroundColor $WarningColour

# User input loop to run the script or exit
do {
    $choice = Read-Host "Press 1 to run the script or 0 to close"

    if ($choice -eq "1") {
        AnalyzeDiskSpace
        Get-RAMUsage
        Get-CPUUsage
        Get-GPUInfo
        Get-NetworkActivity
        Get-NetworkConnections
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
