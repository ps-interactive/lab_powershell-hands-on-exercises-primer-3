
############
## Step 1 ##
############

# Retrieve Event Logs using Get-WinEvent
$events = Get-WinEvent -LogName "Application" -MaxEvents 10

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

# Filter the Logs by Event ID
$events = Get-WinEvent -LogName "Application" -MaxEvents 10 | Where-Object {$_.Id -eq 1000}

# Filter the Logs by Event ID and Text
$events = Get-WinEvent -LogName "Application" -MaxEvents 10 | Where-Object {$_.Id -eq 1000 -and $_.Message -like "*error*"}

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

# Filter the Event Logs looking for failed logons
$events = Get-WinEvent -LogName "Security" -MaxEvents 10 | Where-Object {$_.Id -eq 4625}

# Filter the Event Logs looking for failed logons for a specific user
$events = Get-WinEvent -LogName "Security" -MaxEvents 10 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*TestUser*"}

# Group and results by account and IP address
$events = Get-WinEvent -LogName "Security" -MaxEvents 10 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*TestUser*"} | Group-Object -Property {$_.Properties[5].Value}   

# Generate a Report highlighting suspicious patterns from the Event Logs
$events = Get-WinEvent -LogName "Security" -MaxEvents 10 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*TestUser*"} | Group-Object -Property {$_.Properties[5].Value} | Where-Object {$_.Count -gt 1} | Select-Object -Property Name, Count

# Display the results in a Grid View
$events | Out-GridView

# Export Event Logs
$events | Export-Csv -Path "C:\Temp\FailedLogons.csv" -NoTypeInformation

# Query Multiple Event logs looking for patterns
$events = Get-WinEvent -LogName "Security", "Application" -MaxEvents 10 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*TestUser*"} | Group-Object -Property {$_.Properties[5].Value} | Where-Object {$_.Count -gt 1} | Select-Object -Property Name, Count


############
## Step 4 ##
############

# Query the Event Log 'PluralsightErros' looking for failed logons
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Id -eq 4625}

# Query the Event Log 'PluralsightErros' looking for failed logons for a specific user
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Id -eq 4625 -and $_.Message -like "*User*"}

# Group and results by event ID
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Message -like "*User*"} | Group-Object -Property {$_.Id} | Select-Object -Property Name, Count

# Look for Patterns in the Event Logs
$events = Get-WinEvent -LogName "PluralsightErrors" -MaxEvents 100 | Where-Object {$_.Message -like "*User*"} | Group-Object -Property {$_.Id} | Where-Object {$_.Count -gt 10} | Select-Object -Property Name, Count



############
## Step 5 ##
############

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









#$events | ConvertTo-Html -Property Name, Count | Out-File -FilePath "C:\Temp\FailedLogons.html"


# Display the results in a Grid View
$events | Out-GridView



