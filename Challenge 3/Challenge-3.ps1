
# Step 1: Retrieve Basic Computer Information from Local Computer using CIM Instance
$ComputerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$ComputerName = $ComputerInfo.Name
Write-Host "Computer Name: $ComputerName"

# Retrieve Important CPU Information
$CPUInfo = Get-CimInstance -ClassName Win32_Processor
$CPUName = $CPUInfo.Name
$CPUArch = $CPUInfo.Architecture
$CPUCoreCount = $CPUInfo.NumberOfCores
$CPUThreadCount = $CPUInfo.NumberOfLogicalProcessors

Write-Host "CPU Name: $CPUName"
Write-Host "CPU Architecture: $CPUArch"
Write-Host "CPU Core Count: $CPUCoreCount"
Write-Host "CPU Thread Count: $CPUThreadCount"


# Step 2: Retrieve Memory Information from Local Computer using CIM Instance
$MemoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory

# Retrieve Important Memory Information
$MemoryCapacity = $MemoryInfo.Capacity
$MemorySpeed = $MemoryInfo.Speed
$MemoryManufacturer = $MemoryInfo.Manufacturer

# Display Memory Information
Write-Host "Memory Capacity: $MemoryCapacity"
Write-Host "Memory Speed: $MemorySpeed"
Write-Host "Memory Manufacturer: $MemoryManufacturer"


# Step 3: Retrieve Disk Information from Local Computer using CIM Instance
$DiskInfo = Get-CimInstance -ClassName Win32_DiskDrive

# Retrieve Important Disk Information
$DiskModel = $DiskInfo.Model
$DiskSize = $DiskInfo.Size
$DiskInterface = $DiskInfo.InterfaceType

# Display Disk Information
Write-Host "Disk Model: $DiskModel"
Write-Host "Disk Size: $DiskSize"
Write-Host "Disk Interface: $DiskInterface"


# Step 4: Retrieve Operating System Information from Local Computer using CIM Instance
$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem

# Retrieve Important Operating System Information
$OSName = $OSInfo.Caption
$OSVersion = $OSInfo.Version
$OSArchitecture = $OSInfo.OSArchitecture

# Display Operating System Information
Write-Host @"
Operating System Name: $OSName
Operating System Version: $OSVersion
Operating System Architecture: $OSArchitecture
"@


# Step 5: Retrieve System Details and Return as a PowerShell Object
$systemInfo = New-Object -TypeName PSObject

# Gather and format CPU Information
$cpuInfo = Get-CimInstance -ClassName Win32_Processor | ForEach-Object {
    "Name: $($_.Name)`nCores: $($_.NumberOfCores)`nLogical Processors: $($_.NumberOfLogicalProcessors)`nMax Speed: $($_.MaxClockSpeed) MHz"
}
$systemInfo | Add-Member -MemberType NoteProperty -Name "CPU Information" -Value ($cpuInfo -join "`n")

# Gather and format Memory Information
$memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory | ForEach-Object {
    "Manufacturer: $($_.Manufacturer)`nCapacity: $([math]::round($_.Capacity/1GB, 2)) GB`nSpeed: $($_.Speed) MHz"
}
$totalMemory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
$totalMemoryFormatted = "$([math]::round($totalMemory/1GB, 2)) GB"
$systemInfo | Add-Member -MemberType NoteProperty -Name "Memory Information" -Value ($memoryInfo -join "`n")
$systemInfo | Add-Member -MemberType NoteProperty -Name "Total Physical Memory" -Value $totalMemoryFormatted

# Gather and format Disk Information
$diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
    "DeviceID: $($_.DeviceID)`nSize: $([math]::round($_.Size/1GB, 2)) GB`nFree Space: $([math]::round($_.FreeSpace/1GB, 2)) GB"
}
$systemInfo | Add-Member -MemberType NoteProperty -Name "Disk Information" -Value ($diskInfo -join "`n")

# Gather and format Network Adapter Information
$networkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null } | ForEach-Object {
    "Description: $($_.Description)`nIP Address: $($_.IPAddress[0])`nMAC Address: $($_.MACAddress)"
}
$systemInfo | Add-Member -MemberType NoteProperty -Name "Network Adapter Information" -Value ($networkInfo -join "`n")

# Display the collected system information
$systemInfo | Format-List



# Step 6: Function to Retrieve System Information from Local Computer using CIM Instance
function Get-SystemInfo {
    # Initialize a new PowerShell object
    $systemInfo = New-Object -TypeName PSObject

    # Gather system details using CIM Instances
    # Example: CPU information
    $cpuInfo = Get-CimInstance -ClassName Win32_Processor | ForEach-Object {
        "<b>Name:</b> $($_.Name)<br><b>Cores:</b> $($_.NumberOfCores)<br><b>Logical Processors:</b> $($_.NumberOfLogicalProcessors)<br><b>Max Speed:</b> $($_.MaxClockSpeed) MHz"
    }
    $memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory | ForEach-Object {
        "<b>Manufacturer:</b> $($_.Manufacturer)<br><b>Capacity:</b> $([math]::round($_.Capacity/1GB, 2)) GB<br><b>Speed:</b> $($_.Speed) MHz"
    }
    $diskInfo = Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
        "<b>Model:</b> $($_.Model)<br><b>Size:</b> $([math]::round($_.Size/1GB, 2)) GB<br><b>Interface Type:</b> $($_.InterfaceType)"
    }
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem | ForEach-Object {
        "<b>Caption:</b> $($_.Caption)<br><b>Version:</b> $($_.Version)<br><b>Architecture:</b> $($_.OSArchitecture)"
    }
    $networkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $null -ne $_.IPAddress } | ForEach-Object {
        "<b>Description:</b> $($_.Description)<br><b>IP Address:</b> $($_.IPAddress[0])<br><b>MAC Address:</b> $($_.MACAddress)"
    }
    $userInfo = Get-CimInstance -ClassName Win32_UserAccount | ForEach-Object {
        "<b>Username:</b> $($_.Name)<br><b>Full Name:</b> $($_.FullName)<br><b>SID:</b> $($_.SID)"
    }
    $groupInfo = Get-CimInstance -ClassName Win32_Group | ForEach-Object {
        "<b>Name:</b> $($_.Name)<br><b>SID:</b> $($_.SID)"
    }
    $runningProcesses = Get-CimInstance -ClassName Win32_Process | ForEach-Object {
        "<b>Name:</b> $($_.Name)<br><b>Process ID:</b> $($_.ProcessId)<br><b>Thread Count:</b> $($_.ThreadCount)"
    }
    $runningServices = Get-CimInstance -ClassName Win32_Service | ForEach-Object {
        "<b>Name:</b> $($_.Name)<br><b>Display Name:</b> $($_.DisplayName)<br><b>State:</b> $($_.State)"
    }

    # Populate the PSObject with formatted data
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Operating System Information" -Value ($osInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "CPU Information" -Value ($cpuInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Memory Information" -Value ($memoryInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Disk Information" -Value ($diskInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Network Adapter Information" -Value ($networkInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "User Information" -Value ($userInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Group Information" -Value ($groupInfo -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Running Processes" -Value ($runningProcesses -join "<br>")
    $systemInfo | Add-Member -MemberType NoteProperty -Name "Running Services" -Value ($runningServices -join "<br>")

    # CSS for the HTML report
    $css = @"
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
        }
        .container {
            width: 80%;
            margin: auto;
            overflow: hidden;
        }
        h1 {
            color: #444;
            text-align: center;
            padding: 20px 0;
        }
        .info-section h2 {
            background-color: #0078D7;
            color: white;
            padding: 10px;
            border-radius: 5px;
            font-weight: bold;
        }
        .info-section p {
            margin: 0;
        }
        @media screen and (max-width: 600px) {
            .container {
                width: 100%;
            }
        }
    </style>
"@

    # Start building HTML content
    $htmlContent = "<div class='container'><h1>System Information Report</h1>"
    foreach ($prop in $systemInfo.PSObject.Properties) {
        $htmlContent += "<div class='info-section'><h2>$($prop.Name)</h2><p>$($prop.Value)</p></div>"
    }
    $htmlContent = "<html><head>$css</head><body>$htmlContent</body></html>"

    # Save the HTML report
    $htmlContent | Out-File "SystemInfoReport.html"

    # Open the report in the default browser
    Invoke-Item "SystemInfoReport.html"
}

# Execute the function
Get-SystemInfo


# Iteraate all Local Users and Display their Name, Enabled, LastLogon, and a new column that dispays if they are a local administrator or not
Get-LocalUser | Select-Object Name, Enabled, LastLogon, @{Name="IsAdmin";Expression={(Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Name -eq $_.Name }).Count -gt 0}} | Format-Table -AutoSize

# Iteraate all Local Users and Display their Name, Enabled, LastLogon, and a new column that dispays if they are a member of the local administrators group or not
Get-LocalUser | Select-Object Name, Enabled, LastLogon, @{Name="IsAdmin";Expression={(Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Name -eq $_.Name }).Count -gt 0}} | Format-Table -AutoSize


# Create App Locker Rule to allow the script "C:\PowerShell\TrustedScript.ps1" to Run
New-AppLockerPolicy -RuleType Script -User Everyone -Action Allow -Path "C:\PowerShell\TrustedScript.ps1" -Description "Allow Trusted Script to Run"
