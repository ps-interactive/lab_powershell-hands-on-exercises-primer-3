########################################
## Setup Event Log and Custom Entries ##
########################################

$source = "PluralsightLogonFailures"
$logName = "PluralsightErrors"

if (-not (Get-EventLog -LogName $logName -Source $source -ErrorAction SilentlyContinue)) {
    New-EventLog -LogName $logName -Source $source
}

# Create a varible for JSON Data
$json = @"
[
    {
        "EventID": 4625,
        "Description": "An account failed to log on",
        "Message": "A user attempted to log on and failed [#user#]. Review the details for possible brute-force attack attempts."
    },
    {
        "EventID": 4624,
        "Description": "An account was successfully logged on",
        "Message": "A user successfully logged on to an account [#user#]. Verify if the logon is authorized, especially if outside of normal hours."
    },
    {
        "EventID": 4740,
        "Description": "A user account was locked out",
        "Message": "A user account [#user#] was locked out after multiple failed logon attempts. This could be a sign of a brute-force attack."
    },
    {
        "EventID": 4723,
        "Description": "An attempt was made to change an account's password",
        "Message": "A password change attempt was made. Ensure this was a legitimate request or action."
    },
    {
        "EventID": 4724,
        "Description": "An attempt was made to reset an account's password",
        "Message": "A password reset attempt was made by an administrator. Confirm that this action was authorized."
    },
    {
        "EventID": 4672,
        "Description": "Special privileges assigned to new logon",
        "Message": "A user logged on with administrative privileges [#user#]. Check if #user# requires these privileges and the logon is legitimate."
    },
    {
        "EventID": 4648,
        "Description": "A logon was attempted using explicit credentials",
        "Message": "A logon attempt was made with explicit credentials [#user#]. Validate the legitimacy of the logon, particularly for remote access."
    }
]
"@


# Create a Function to create custom event log entries
Function Write-LogonFailure {
    Param (
        [String]$logName,
        [String]$source,
        [Int]$Quantity
    )

    # Load $events from a JSON Path populated in $Events
    $events =  $json | ConvertFrom-Json

    # Loop through the number of events to create
    For ($i = 1; $i -le $Quantity; $i++) {
    
        # Randomly select an event ID from the $events array
        $eventitem = Get-Random -InputObject $events

        # Randomly select a User Account Name
        $user = Get-Random -InputObject @("user1", "user2", "user3", "user4", "user5", "user6")

        # Write the event to the event log
        $eventLogParams = @{
            LogName     = $logName
            Source      = $source
            EventId     = $eventitem.EventId
            EntryType   = 'Error'
            Message     = ($eventitem.Message -replace '#user#', $user)
            Category    = 0
            ComputerName= $env:COMPUTERNAME
        }

        Write-EventLog @eventLogParams

    }
}

# Call the function
Write-LogonFailure -logName "PluralsightErrors" -source "PluralsightLogonFailures" -Quantity 100



