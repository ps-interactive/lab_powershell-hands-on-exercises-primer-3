############
## Step 1 ##
############

# Import the Active Directory module
Import-Module ActiveDirectory

# Set the OU to search in
$OU = "CN=Users,DC=globomantics,DC=co"

# Set the search filter
$LDAPFilter = "(&(objectCategory=person)(objectClass=user))"

# Search for the users
$Users = Get-ADUser -SearchBase $OU -LDAPFilter $LDAPFilter
$Users | Select-Object Name, mail
$Users

# Loop through the users
ForEach ($User in $Users) {
    # Display Base User Properties
    Write-Host "Name: $($User.Name)"
    Write-Host "Email: $($User.mail)"
    Write-Host "--------------------------"
}



############
## Step 2 ##
############

# Create New AD user
New-ADUser `
    -Name "Test User" `
    -SamAccountName "TestUser" `
    -UserPrincipalName "#" `
    -GivenName "Test" `
    -Surname "User" `
    -DisplayName "Test User" `
    -Path $OU `
    -AccountPassword (ConvertTo-SecureString -AsPlainText "Password123" -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -EmailAddress ""
Get-ADuser -Identity "TestUser" -Properties *

# Set the user's email address
Set-ADUser `
    -Identity "TestUser" `
    -EmailAddress "TestUser@globomantics.co"
Get-ADuser -Identity "TestUser" -Properties *

# Set the user's Department
Set-ADUser `
    -Identity "TestUser" `
    -Department "IT"
Get-ADuser -Identity "TestUser" -Properties *

# Set Advanced User properties
$UserProperties = @{
    Identity = "TestUser"
    Title = "IT Administrator"
    Description = "IT Administrator"
    Company = "Contoso"
    Office = "London"
    OfficePhone = "0123456789"
    MobilePhone = "0123456789"
    StreetAddress = "123 Test Street"
    PostalCode = "SW1A 1AA"
    Country = "UK"
}

Set-ADUser @UserProperties
Get-ADuser -Identity "TestUser" -Properties *

# Delete the user
Remove-ADUser `
    -Identity "TestUser" `
    -Confirm:$false
Get-ADuser -Identity "TestUser"


############
## Step 3 ##
############

# Create JSON Data representing the user
$JSON = @"
{
    "Name": "Test User",
    "SamAccountName": "TestUser",
    "UserPrincipalName": "#",
    "GivenName": "Test",
    "Surname": "User",
    "DisplayName": "Test User",
    "Path": "$OU",
    "AccountPassword": "Password123",
    "Enabled": true,
    "ChangePasswordAtLogon": true,
    "EmailAddress": ""
}
"@

# Convert the JSON to a PowerShell object
$User = ConvertFrom-Json $JSON

# Create New AD user
New-ADUser `
    -Name $User.Name `
    -SamAccountName $User.SamAccountName `
    -UserPrincipalName $User.UserPrincipalName `
    -GivenName $User.GivenName `
    -Surname $User.Surname `
    -DisplayName $User.DisplayName `
    -Path $User.Path `
    -AccountPassword (ConvertTo-SecureString -AsPlainText $User.AccountPassword -Force) `
    -Enabled $User.Enabled `
    -ChangePasswordAtLogon $User.ChangePasswordAtLogon `
    -EmailAddress $User.EmailAddress

Get-ADuser -Identity "TestUser" -Properties *

# Create function to check if a user exists
Function UserExists {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$SamAccountName
    )

    # Check if the user exists
    If (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'") {
        # Return true
        Return $true
    }
    Else {
        # Return false
        Return $false
    }
}

# Check if the user exists
If (UserExists -SamAccountName "TestUser") {
    # Display a message
    Write-Host "User exists" -ForegroundColor Green
} Else {
    # Display a message
    Write-Host "User does not exist" -ForegroundColor Red
}

# Create function for creating a user in AD, include the UserExists function
Function New-ADUser {
    Param (
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$SamAccountName,
        [Parameter(Mandatory=$true)]
        [String]$UserPrincipalName,
        [Parameter(Mandatory=$true)]
        [String]$GivenName,
        [Parameter(Mandatory=$true)]
        [String]$Surname,
        [Parameter(Mandatory=$true)]
        [String]$DisplayName,
        [Parameter(Mandatory=$true)]
        [String]$Path,
        [Parameter(Mandatory=$true)]
        [SecureString]$AccountPassword,
        [Parameter(Mandatory=$true)]
        [Boolean]$Enabled,
        [Parameter(Mandatory=$true)]
        [Boolean]$ChangePasswordAtLogon,
        [Parameter(Mandatory=$true)]
        [String]$EmailAddress
    )

    # Check if the user exists
    If (UserExists -SamAccountName $SamAccountName) {
        # Display a message
        Write-Host "User already exists"
    }
    Else {
        # Create the user
        New-ADUser `
            -Name $Name `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -GivenName $GivenName `
            -Surname $Surname `
            -DisplayName $DisplayName `
            -Path $Path `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $AccountPassword -Force) `
            -Enabled $Enabled `
            -ChangePasswordAtLogon $ChangePasswordAtLogon `
            -EmailAddress $EmailAddress
        
            Get-ADuser -Identity $SamAccountName -Properties *
    }
}

# Create the user
New-ADUser `
    -Name "Test User" `
    -SamAccountName "TestUser" `
    -UserPrincipalName "#" `
    -GivenName "Test" `
    -Surname "User" `
    -DisplayName "Test User" `
    -Path $OU `
    -AccountPassword (ConvertTo-SecureString -AsPlainText "Pass@word123" -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true `
    -EmailAddress "TestUser@globomantics.co"



############
## Step 4 ##
############

# Create CSV data with mutiple users
$CSV = @"
Name,SamAccountName,UserPrincipalName,GivenName,Surname,DisplayName,AccountPassword,EmailAddress
Test User 1,TestUser1,TestUser1@globomantics.co,Test,User 1,Test User 1,Password123,TestUser1@globomantics.co
Test User 2,TestUser2,TestUser2@globomantics.co,Test,User,Test User 2,Password123,TestUser2@globomantics.co
"@

# Convert the CSV to a PowerShell object
$Users = ConvertFrom-Csv $CSV

# Create the Users from the CSV using the New-ADUser function
ForEach ($User in $Users) {
    New-ADUser `
        -Name $User.Name `
        -SamAccountName $User.SamAccountName `
        -UserPrincipalName $User.UserPrincipalName `
        -GivenName $User.GivenName `
        -Surname $User.Surname `
        -DisplayName $User.DisplayName `
        -Path $OU `
        -AccountPassword (ConvertTo-SecureString -AsPlainText $User.AccountPassword -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -EmailAddress $User.EmailAddress
}


############
## Step 5 ##
############

# Create the Test OU
New-ADOrganizationalUnit -Name "UserTemplates" -ProtectedFromAccidentalDeletion $False
Get-ADOrganizationalUnit -Filter "Name -eq 'UserTemplates'"

# Set Variables
$UserTemplatesOU = "OU=UserTemplates,DC=globomantics,DC=co"
$templateUserName = "Sales_Template_User"
$password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force

# Create Template User
New-ADUser `
    -Name $templateUserName `
    -GivenName "Sales" `
    -Surname "Template User" `
    -DisplayName "Sales Template User" `
    -Description "Sales Template User" `
    -AccountPassword $password `
    -Enabled $false `
    -PasswordNeverExpires $true `
    -CannotChangePassword $true `
    -Path $UserTemplatesOU

# Set common properties
$params = @{
    Identity = $templateUserName
    UserPrincipalName = $templateUserName + "@globomantics.co"
    Department = "Sales"
    Title = "Sales Representative"
    Company = "Globomantics"
    Office = "Manhattan"
    City = "New York"
    State = "New York"
    Country = "US"
    ProfilePath = "\\globomantics.co\profiles\$templateUserName"
    HomeDrive = "H:"
    HomeDirectory = "\\globomantics.co\home\$templateUserName"
}

Set-ADUser @params
Get-ADuser -Identity $params.Identity -Properties Department, Company, Office, City, State, Country

# Add the template user to standard groups
New-ADGroup -Name "StaffGroup" -GroupScope Global -GroupCategory Security -Path $UserTemplatesOU
Add-ADGroupMember -Identity "StaffGroup" -Members $templateUserName

# Function to create a new user from a template
Function New-UserFromTemplate {
    param (
        [string]$templateUsername,
        [string]$newUsername,
        [string]$newUserDisplayName,
        [string]$givenName,
        [string]$surname,
        [SecureString]$newUserPassword
    )

    $templateUser = Get-ADUser -Identity $templateUsername -Properties *

    $newUserProperties = @{
        SamAccountName = $newUsername
        UserPrincipalName = $newUsername + "@globomantics.co"
        Name = $newUserDisplayName
        GivenName = $givenName
        Surname = $surname
        DisplayName = $newUserDisplayName
        Description = $newUserDisplayName
        Office = $templateUser.Office
        Enabled = $true
        AccountPassword = (ConvertTo-SecureString $newUserPassword -AsPlainText -Force)
        Path = $OU
        Department = $templateUser.Department
        Title = $templateUser.Title
        Company = $templateUser.Company
        City = $templateUser.City
        State = $templateUser.State
        Country = $templateUser.Country

        ProfilePath = $templateUser.ProfilePath -replace $templateUsername, $newUsername
        HomeDirectory = $templateUser.HomeDirectory -replace $templateUsername, $newUsername

        HomeDrive = $templateUser.HomeDrive
    }

    New-ADUser @newUserProperties

    Get-ADUser -Identity $templateUsername -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf |
    Where-Object {$_ -notlike "*CN=Domain Users*"} |
    ForEach-Object { Add-ADGroupMember -Identity $_ -Members $newUsername }
}

# Usage example

$params = @{
    templateUsername = "Sales_Template_User"
    newUsername = "jdoe"
    newUserDisplayName = "John Doe"
    newUserPassword = (ConvertTo-SecureString "Password123" -AsPlainText -Force)
}

New-UserFromTemplate @params










