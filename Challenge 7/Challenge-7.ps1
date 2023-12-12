
####################################
##             Step 1             ##
####################################
## UserName: globomantics\ralthor ##
## Password: JustAn0therG!ng3r    ##
####################################

# Add the Mail Sending Function
Function Send-CustomMailMessage {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$To,
        [Parameter(Mandatory=$true)]
        [String]$From,
        [Parameter(Mandatory=$true)]
        [String]$Subject,
        [Parameter(Mandatory=$true)]
        [String]$Body,
        [Parameter(Mandatory=$true)]
        [String]$SmtpServer
    )

    # Create a MailMessage object
    $message = New-Object System.Net.Mail.MailMessage

    # Specify the From and To addresses
    $message.From = $From
    $message.To.Add($To)

    # Set the subject and body
    $message.Subject = $Subject
    $message.Body = $Body

    # Create an SMTP client and specify the server and port
    $smtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, 25) 

    # Send the message
    $smtpClient.Send($message)
}


# Create Credentials
$Credentials = Get-Credential -UserName "globomantics\ralthor"

# Test PSRemoting on a Computer
Test-WSMan -ComputerName "DC01"

# Test Remote COnnectivity to a Computer
Test-NetConnection -ComputerName "DC01" -Port 5985

# Remotely Connect to a Computer
Enter-PSSession -ComputerName "DC01" -Credential $Credentials

# Remotely Connect to a Computer with Credentials and a Port
Enter-PSSession -ComputerName "FS01" -Credential $Credentials -Port 5985

# Query a Remote Computer
Invoke-Command -ComputerName "DC01" -Credential $Credentials -ScriptBlock {Get-Process}

# Query a Remote Computer with a Port
Invoke-Command -ComputerName "FS01" -Credential $Credentials -Port 5985 -ScriptBlock {Get-Process}



############
## Step 2 ##
############

# View Current User Sessions
Get-PSSession

# View Current User Sessions with Detailed Information
Get-PSSession | Format-List

# Create a New User Session
$Session = New-PSSession -ComputerName "DC01" -Credential $Credentials -Port 5985
Get-PSSession

# Create Multiple Sessions
New-PSSession -ComputerName "DC01" -Credential $Credentials -Port 5985
New-PSSession -ComputerName "FS01" -Credential $Credentials -Port 5985
New-PSSession -ComputerName "DC01" -Credential $Credentials -Port 5985
New-PSSession -ComputerName "FS01" -Credential $Credentials -Port 5985


# View Current User Sessions with Detailed Information and Filter by Computer Name
Get-PSSession | Where-Object {$_.ComputerName -eq "DC01"} | Format-Table

# Connect to a User Session
Get-PSSession | Format-Table

Enter-PSSession -Id 7
Enter-PSSession -Id 9

# Disconnect from a User Session
Exit-PSSession

# Remove a User Session
Remove-PSSession -Id 7
Remove-PSSession -Id 9



############
## Step 3 ##
############

# Retrieve Installed Applications from a Remote Computer
Invoke-Command -ComputerName "DC01" -Credential $Credentials -Port 5985 -ScriptBlock {
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
    Format-Table -AutoSize
}

# Retrieve Installed Applications from Multiple Remote Computers
Invoke-Command -ComputerName "DC01", "FS01" -Credential $Credentials -Port 5985 -ScriptBlock {
    Write-Host "------------------------------------------------" -ForegroundColor Blue
    $ComputerName = $env:COMPUTERNAME
    Write-Host "COMPUTER: $ComputerName" -ForegroundColor Green
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, 
        DisplayVersion, 
        Publisher, 
        InstallDate | 
    Format-Table -AutoSize
}



############
## Step 4 ##
############

# Retrieve Installed Applications from Multiple Remote Computers and Compare to a List of Approved Applications
Invoke-Command -ComputerName "DC01", "FS01" -Credential $Credentials -Port 5985 -ScriptBlock {
    Write-Host "------------------------------------------------" -ForegroundColor Blue
    $ComputerName = $env:COMPUTERNAME
    Write-Host "COMPUTER: $ComputerName" -ForegroundColor Green
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName, 
        DisplayVersion, 
        Publisher, 
        InstallDate
} | Where-Object {$_.DisplayName -notin "Microsoft Edge", "Nmap 7.80", "PowerShell 7-x64", "Microsoft Visual Studio Code" } 
| Format-Table -AutoSize

# Retrieve Installed Applications from Multiple Remote Computers and Compare to a List of Approved Applications and Send an Email to an Administrator
$unapprovedApps = Invoke-Command -ComputerName "DC01", "FS01" -Credential $Credentials -Port 5985 -ScriptBlock {
    $ComputerName = $env:COMPUTERNAME
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object @{Name="ComputerName"; Expression={"$ComputerName"}}, 
        DisplayName, 
        DisplayVersion, 
        Publisher, 
        InstallDate
} | Where-Object {$_.DisplayName -notin "Microsoft Edge", "Nmap 7.80", "PowerShell 7-x64", "Microsoft Visual Studio Code" } 

$emailBody = $unapprovedApps | Group-Object ComputerName | ForEach-Object {
    $computerName = $_.Name
    $unapprovedAppList = $_.Group.DisplayName -join "`n"
    "$computerName Unapproved Applications:`n$unapprovedAppList`n------------------------`n"
} | Out-String

Send-CustomMailMessage -To "Administrator@localhost" -From "UnapprovedApplication@localhost" -Subject "Unapproved Applications Installed" -Body $emailBody -SmtpServer "localhost"



############
## Step 5 ##
############

# Create an Approved Applications List in JSON Format
$ApprovedApplications = @"
{
    "Applications": [
        {
          "DisplayName": "Nmap 7.80",
          "DisplayVersion": "7.80",
          "Publisher": "Nmap Project"
        },
        {
          "DisplayName": "Microsoft Edge",
          "DisplayVersion": "119.0.2151.58",
          "Publisher": "Microsoft Corporation"
        },
        {
          "DisplayName": "PowerShell 7-x64",
          "DisplayVersion": "7.3.9.0",
          "Publisher": "Microsoft Corporation"
        },
        {
          "DisplayName": "Microsoft Visual Studio Code",
          "DisplayVersion": "1.84.2",
          "Publisher": "Microsoft Corporation"
        }
      ]
}
"@

# Convert the JSON to a PowerShell Object
$ApprovedApplicationsList = ConvertFrom-Json $ApprovedApplications

# Retrieve Installed Applications from Multiple Remote Computers and Compare to a List of Approved Applications and Display the Results in a Grid View with an extra column for Approved Applications
$unapprovedApps = Invoke-Command -ComputerName "DC01", "FS01" -Credential $Credentials -Port 5985 -ScriptBlock {
    $ComputerName = $env:COMPUTERNAME
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object @{
        Name="ComputerName"
        Expression={"$ComputerName"}
    }, 
    DisplayName, 
    DisplayVersion, 
    Publisher, 
    InstallDate
} | Where-Object {$_.DisplayName -notin $ApprovedApplicationsList.Applications.DisplayName} 

$unapprovedApps | Out-GridView
