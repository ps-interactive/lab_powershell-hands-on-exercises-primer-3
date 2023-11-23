# Load 'Challenge-2.xml' into a variable called $xmlData
[xml]$xmlData = Get-Content '.\Challenge 2\Challenge-2.xml'

# Display the Company Node
$xmlData.company

# Display the Departments Node
$xmlData.company.departments

# Iterate the Department Nodes
$xmlData.company.departments.department

# Display the Products Node
$xmlData.company.products

# Iterate the Product Nodes
$xmlData.company.products.product

# Iterate all Products with a price greater than 100
$xmlData.company.products.product | `
    Where-Object { [int]$_.price -lt 100 }

# Iterate all Products with a price greater than 100
$xmlData.company.products.product | `
    Where-Object { [int]$_.'price' -gt 100 }

# Iterate all Product Categories
$xmlData.company.products.product | `
Select-Object -ExpandProperty category | `
    Sort-Object -Unique

# Iterate all Products and Group by Category, then display the Category and the number of products per category
$xmlData.company.products.product | `
    Group-Object -Property category | `
        Select-Object Name, Count

# Retrieve all Products in the 'Computers' Category and Format as a Table
$xmlData.company.products.product | `
    Where-Object { $_.category -eq "Computers" } | `
        Format-Table -AutoSize

# Iterate all Products and Set the Foreground Color depending on their Category
$xmlData.company.products.product | ForEach-Object {
    $prodName = $_.name
    switch ($_.category) {
        "Accessories" { Write-Host $prodName -ForegroundColor Green }
        "Audio" { Write-Host $prodName -ForegroundColor Yellow }
        "Computers" { Write-Host $prodName -ForegroundColor Cyan }
        "Electronics" { Write-Host $prodName -ForegroundColor Magenta }
        "Storage" { Write-Host $prodName -ForegroundColor Red }
        Default { Write-Host $prodName }
    }
}

# Iterate all Employees in the Sales Department
$xmlData.company.departments.department | `
    Where-Object {$_.name -eq "Sales"} | `
        Select-Object -ExpandProperty employee

# Iterate all Employees who have 'Developer' in their title
$xmlData.company.departments.department | `
    Select-Object -ExpandProperty employee | `
        Where-Object {$_.position -match "Developer"}

# Iterate and Display All Employees - Display the Employee Name, Position, and Email
$xmlData.company.departments.department | `
    Select-Object -ExpandProperty employee | `
        Select-Object name, position, email

# Iterate and Display All Employees - Display the Employee Name, Position, Email, and Department
$xmlData.company.departments.department | `
    Select-Object -ExpandProperty employee | `
        Select-Object name, position, email, @{Name="Department";Expression={$_.ParentNode.name}}

# Iterate all Employees and Set the Foreground Color depending on their department
$xmlData.company.departments.department | ForEach-Object {
    $deptName = $_.name
    $_.employee | ForEach-Object {
        $empName = $_.name + " - " + $deptName
        switch ($deptName) {
            "Sales" { Write-Host $empName -ForegroundColor Green }
            "IT" { Write-Host $empName -ForegroundColor Yellow }
            "Development" { Write-Host $empName -ForegroundColor Cyan }
            "Human Resources" { Write-Host $empName -ForegroundColor Magenta }
            "Finance" { Write-Host $empName -ForegroundColor Red }
            Default { Write-Host $empName }
        }
    }
}

# Generate an HTML Report of all Employees
$xmlData.company.departments.department | `
    Select-Object -ExpandProperty employee | `
        Select-Object name, position, email, @{Name="Department";Expression={$_.ParentNode.name}} | `
            ConvertTo-Html -Property name, position, email, Department | `
                Out-File '.\Challenge 2\Challenge-2-Employees.html'

# Launch the HTML Report
Invoke-Item '.\Challenge 2\Challenge-2-Employees.html'

# Generate an HTML Report of all Products
$xmlData.company.products.product | `
    Select-Object name, category, price | `
        ConvertTo-Html -Property name, category, price | `
            Out-File '.\Challenge 2\Challenge-2-Products.html'

# Launch the HTML Report
Invoke-Item '.\Challenge 2\Challenge-2-Products.html'

# Generate an HTML Report to Display ALL Data
function Convert-SectionToHtml {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SectionTitle,

        [Parameter(Mandatory = $true)]
        [System.Collections.IEnumerable]$Data
    )

    "<h2>$SectionTitle</h2>" + ($Data | ConvertTo-Html -Fragment)
}

# Process departments and employees
$departmentsHtml = Convert-SectionToHtml -SectionTitle "Departments and Employees" -Data (
    $xmlData.company.departments.department | ForEach-Object {
        $dept = $_
        $_.employee | Select-Object @{Name="Department"; Expression={$dept.name}}, id, name, position, email
    }
)

# Process products
$productsHtml = Convert-SectionToHtml -SectionTitle "Products" -Data $xmlData.company.products.product

# Combine HTML content
$fullHtml = @"
<html>
<head>
    <title>Full Company Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #dddddd; text-align: left; padding: 8px; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    $departmentsHtml
    $productsHtml
</body>
</html>
"@

# Save to file
$fullHtml | Out-File '.\Challenge 2\Challenge-2-All.html'


# Launch the HTML Report
Invoke-Item '.\Challenge 2\Challenge-2-All.html'




