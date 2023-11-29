
# Challenge: Generating an HTML Report from XML Data Using PowerShell in Visual Studio Code

By the end of this challenge, you should be able to read and process XML data using PowerShell and then generate an HTML report from that data using Visual Studio Code.

## Prerequisites

* Basic understanding of PowerShell scripting.
* Access to a Windows environment with Visual Studio Code installed.

## Tasks

1. **Launch Visual Studio Code as an Administrator**.
   ![Right Click on Visual Studio Code to Launch as an Administrator](./Images/Challenge-1.0.png "Right Click on Visual Studio Code to Launch as an Administrator")

2. **From the Visual Studio Code welcome screen, click the Open Folder option**.
   ![Open a Folder by Clicking Open Folder on the Welcome Screen](./Images/Challenge-1.1.png "Open a Folder by Clicking Open Folder on the Welcome Screen")

3. **Navigate to the LAB_FILES folder from the Desktop, and select Select Folder**.

4. **In the left navigation, double-click the file `Challenge-2.ps1` to load it into the main window**.

5. **Click Terminal from the top navigation within Visual Studio Code, and click New Terminal**.
   ![Click Terminal to Launch a Terminal Window](./Images/Challenge-1.2.png "Click Terminal to Launch a Terminal Window")

6. **Ensure the Terminal is set to PowerShell (pwsh) by checking the top of the Terminal which is below the main PowerShell script**.
   ![Check the Terminal is PowerShell (pwsh)](./Images/Challenge-1.3.png "Check the Terminal is PowerShell (pwsh)")

7. **Load the XML Data into PowerShell**:
   - Locate the section called "Step 1".
   - Highlight the entire code.
   - Right-click the highlighted text and select "Run Selection".
   ![Run XML Parsing Section](./Images/Challenge-1.4.png "Run XML Parsing Section")

8. **Convert Departments and Employees to HTML**:
   - Find the section that starts with `function Convert-SectionToHtml...`.
   - Highlight the entire function definition.
   - Right-click the highlighted text and select "Run Selection".
   ![Process Departments and Employees](./Images/Challenge-1.5.png "Process Departments and Employees")

9. **Convert Products to HTML**:
   - Highlight the lines that include `$productsHtml = Convert-SectionToHtml -SectionTitle "Products"...`.
   - Right-click and choose "Run Selection".
   ![Process Products](./Images/Challenge-1.6.png "Process Products")

10. **Generate the Full HTML Report**:
    - Highlight the section starting with `# Combine HTML content...` and ending with `$fullHtml | Out-File...`.
    - Right-click and select "Run Selection" to execute.
    ![Generate Full HTML Report](./Images/Challenge-1.7.png "Generate Full HTML Report")

11. **Save the HTML Report**:
    - Highlight the last line of the script: `$fullHtml | Out-File '.\Challenge 2\Challenge-2-All.html'`.
    - Right-click and select "Run Selection" to save the file.
    ![Save HTML Report](./Images/Challenge-1.8.png "Save HTML Report")

12. **Validate the Report**:
    - Open File Explorer and navigate to the `Challenge 2` directory.
    - Locate and double-click `Challenge-2-All.html` to open it in your web browser.
    - Verify the content of the HTML report against the XML data.
    ![Open and Validate HTML Report](./Images/Challenge-1.9.png "Open and Validate HTML Report")

Well done on completing this challenge! You've now learned how to process XML data with PowerShell and create an HTML report using Visual Studio Code.
