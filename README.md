# DiscBurner

DiscBurner is a PowerShell script that provides a comprehensive analysis of system resources, including disk space, RAM, CPU, GPU, and network activity. It’s designed to help you monitor and evaluate your system's performance and resource usage.

## Features

- **Disk Space Analysis**: Displays detailed information about disk usage for all logical drives, including total, used, and free space, as well as usage percentages.
- **RAM Usage**: Provides insights into total, used, and free RAM with usage percentages.
- **CPU Usage**: Shows current overall CPU usage and lists the top CPU-consuming processes with their percentage of total CPU time.
- **GPU Information**: Reports on the installed GPUs, including their names and VRAM capacity.
- **Network Activity**: Monitors network activity by interface and offers an option to display active network connections and associated processes.

## Usage

1. **Run the Script**: Execute the script in PowerShell to initiate the analysis.
2. **Interact with Prompts**: Follow the prompts to choose between running various analyses or exiting the script.

## How It Works

- **Disk Space**: Uses `Get-WmiObject` to retrieve disk information and calculates space usage.
- **RAM**: Uses `Get-CimInstance` to get RAM details.
- **CPU Usage**: Utilizes `Get-Counter` and `Get-Process` to measure CPU performance.
- **GPU Info**: Retrieves GPU details using `Get-CimInstance`.
- **Network Activity**: Uses `Get-Counter` for network statistics and `netstat` for connection details.

## Additional Information

- **Color-Coded Output**: Provides clear, color-coded output for better readability.
- **User Prompts**: Allows interactive choices for displaying network connections.

For more details and updates, visit the [GitHub profile](https://github.com/DeadDove13).

## License

This script is provided as-is. No warranties or guarantees are provided.


Thanks gpt for the read-me
