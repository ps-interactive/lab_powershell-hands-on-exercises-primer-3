
############
## Step 1 ##
############

# Retrieve Event Logs using Get-WinEvent
$events = Get-WinEvent -LogName "Application" -MaxEvents 10
$events

# Loop through each event
ForEach ($event in $events) {
    # Display the event ID and message
    Write-Host "Event ID: $($event.Id)"
    Write-Host "Message: $($event.Message)"
    Write-Host "--------------------------"
}



############
## Step 2 ##
############

# Filter the Logs by Text
$events = Get-WinEvent -LogName "Application" -MaxEvents 10 | Where-Object {$_.Message -like "*error*"}
$events

# Filter the Logs by Event ID
$events = Get-WinEvent -LogName "Application" -MaxEvents 10 | Where-Object {$_.Id -eq 1000}
$events

# Filter the Logs by Event ID and Text
$events = Get-WinEvent -LogName "Application" -MaxEvents 10 | Where-Object {$_.Id -eq 1000 -and $_.Message -like "*error*"}
$events

# Create a function to retrieve Event Logs
Function Get-EventLogEntries {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$LogName,
        [Parameter(Mandatory=$true)]
        [Int]$MaxEvents
    )

    # Retrieve Event Logs using Get-WinEvent
    $events = Get-WinEvent -LogName $LogName -MaxEvents $MaxEvents

    Write-Host "Event Log Entries: $($LogName)"
    # Loop through each event
    ForEach ($event in $events) {
        # Display the event ID and message
        Write-Host "Event ID: $($event.Id)"
        Write-Host "Message: $($event.Message)"
        Write-Host "--------------------------"
    }
}

# Call the function
Get-EventLogEntries  -LogName "Application" -MaxEvents 10



############
## Step 3 ##
############

# Query the Event Log 'PluralsightErros' looking for failed logons
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Id -eq 4625}
$events

# Query the Event Log 'PluralsightErros' looking for failed logons for a specific user
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*User*"}
$events

# Group and results by event ID
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Message -like "*User*"} | Group-Object -Property {$_.Id} | Select-Object -Property Name, Count
$events

# Look for Patterns in the Event Logs
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Message -like "*User*"} | Group-Object -Property {$_.Id} | Where-Object {$_.Count -gt 10} | Select-Object -Property Name, Count
$events



############
## Step 4 ##
############

# Get all the Event Logs
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100

# Define the CSS styles
$css = @"
<style>
    body { font-family: Arial, sans-serif; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    tr:nth-child(even) { background-color: #f9f9f9; }
    .highlight { background-color: #ffcccb; }
</style>
"@

# Convert to HTML with CSS
$html = $events | ConvertTo-Html -Property id, message -Head $css | Out-String

# If the column value is 4625, highlight the entire row <tr>, not just the cell <td>
$html = $html -replace "<tr>(.*?)<td>4625</td>(.*?)</tr>", '<tr class="highlight">$1<td>4625</td>$2</tr>'

# If the column value is 4740, highlight the entire row <tr>, not just the cell <td>
$html = $html -replace "<tr>(.*?)<td>4740</td>(.*?)</tr>", '<tr class="highlight">$1<td>4740</td>$2</tr>'

# Output to file
$html | Out-File -FilePath "FailedLogons.html"
Invoke-Item -Path "FailedLogons.html"
