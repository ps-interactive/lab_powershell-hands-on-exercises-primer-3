
############
## Step 1 ##
############

# Retrieve Windows Services
$services = Get-Service
$services

# Loop through each service
ForEach ($service in $services) {
    # Display the service name and status
    Write-Host "Service Name: $($service.Name)"
    Write-Host "Service Status: $($service.Status)"
    Write-Host "--------------------------"
}



############
## Step 2 ##
############

# Display the service name and status
$service = Get-Service -Name "wuauserv"
Write-Host "Service Name: $($service.Name)"

# Display a message if the service is running
If ($service.Status -eq "Running") {
    Write-Host "Service Status: Running" -ForegroundColor Green
}
Else {
    Write-Host "Service Status: Stopped" -ForegroundColor Red
}


############
## Step 3 ##
############

# Create a function to retrieve Windows Services
Function Get-WindowsService {
    # Retrieve Windows Services and Ignore Errors
    $services = Get-Service -ErrorAction SilentlyContinue

    # Loop through each service
    ForEach ($service in $services) {
        # Display the service name and status
        Write-Host "Service Name: $($service.Name)" -ForegroundColor Yellow
        Write-Host "Service Status: $($service.Status)" -ForegroundColor Gray
        Write-Host "--------------------------"
    }
}

# Call the function
Get-WindowsService



############
## Step 4 ##
############

# Create a Recovery Function for Stopped Services
Function Start-RecoveryService {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$ServiceName
    )

    # Check if the service is stopped
    If ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
        # Start the service
        Start-Service -Name $ServiceName

        If ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
            # Display a message
            Write-Host "Service failed to start" -ForegroundColor Red
        }
        Else {
            # Display a message
            Write-Host "Service started successfully" -ForegroundColor Green
        }
    }
    Else {
        # Display a message
        Write-Host "Service is already running" -ForegroundColor Green
    }
}

# Call the function
Start-RecoveryService -ServiceName "wuauserv"



############
## Step 5 ##
############

# Create a Function for Sending Email called Send-MailMessage, that uses System.Net.Mail.MailMessage
Function Send-MailMessage {
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

# Test the Send-MailMessage function
Send-MailMessage -To "Administrator@localhost" -From "ServiceRecovery@localhost" -Subject "Service is Stopped" -Body "The $ServiceName service is stopped" -SmtpServer "localhost"



############
## Step 6 ##
############

# Notifies the Administrator if a Service is Stopped using smtp4dev
Function Send-AdministratorNotification {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$ServiceName
    )

    # Check if the service is stopped
    If ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
        # Display a message
        Write-Host "Service is stopped" -ForegroundColor Red

        # Send an email to the Administrator
        Send-MailMessage -To "Administrator@localhost" -From "ServiceRecovery@localhost" -Subject "Service is Stopped" -Body "The $ServiceName service is stopped" -SmtpServer "localhost"
    }
    Else {
        # Display a message
        Write-Host "Service is running" -ForegroundColor Green
    }
}

# Simulate a stopped service
Stop-Service -Name "BITS"

# Send an email to the Administrator
Send-AdministratorNotification -ServiceName "BITS"

# Recover the service
Start-RecoveryService -ServiceName "BITS"



############
## Step 7 ##
############

# Update the Start-RecoveryService function
Function Start-RecoveryService {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$ServiceName
    )

    # Check if the service is stopped
    If ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
        Send-MailMessage `
            -To "Administrator@localhost" `
            -From "ServiceRecovery@localhost" `
            -Subject "Service is Stopped" `
            -Body "The $ServiceName service is stopped. Starting recovery." `
            -SmtpServer "localhost"

        # Start the service
        Start-Service -Name $ServiceName

        If ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
            # Display a message
            Write-Host "Service failed to start" -ForegroundColor Red
            Send-MailMessage `
                -To "Administrator@localhost" `
                -From "ServiceRecovery@localhost" `
                -Subject "Service Recovery Failed" `
                -Body "The $ServiceName service failed to recover" `
                -SmtpServer "localhost"
        }
        Else {
            # Display a message
            Write-Host "Service started successfully" -ForegroundColor Green
            Send-MailMessage `
                -To "Administrator@localhost" `
                -From "ServiceRecovery@localhost" `
                -Subject "Service Recovery Successful" `
                -Body "The $ServiceName service recovered, and is now running" `
                -SmtpServer "localhost"
        }
    }
    Else {
        # Display a message
        Write-Host "Service is already running" -ForegroundColor Green
        Send-MailMessage `
            -To "Administrator@localhost" `
            -From "ServiceRecovery@localhost" `
            -Subject "Service is Running" `
            -Body "The $ServiceName service is running" `
            -SmtpServer "localhost"
    }
}

# Simulate a stopped service
Stop-Service -Name "BITS"

# Call the function
Start-RecoveryService -ServiceName "BITS"





