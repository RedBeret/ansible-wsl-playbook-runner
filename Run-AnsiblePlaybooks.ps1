# Import necessary .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to run an Ansible playbook through WSL
function Run-Playbook {
    param (
        [string]$Playbook
    )

    try {
        # Run the Ansible playbook via WSL
        $result = wsl ansible-playbook -i /home/redberet/inventory /home/redberet/$Playbook 2>&1

        # Determine the status based on the playbook result
        if ($result -match "FAILED! =>") {
            $status = "Partial Success"
            [System.Windows.Forms.MessageBox]::Show("Playbook '$Playbook' ran but with some failed tasks.`nOutput:`n$result", "Partial Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        } elseif ($LASTEXITCODE -eq 0) {
            $status = "Success"
            [System.Windows.Forms.MessageBox]::Show("Playbook '$Playbook' ran successfully.`nOutput:`n$result", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            $status = "Failed"
            [System.Windows.Forms.MessageBox]::Show("Failed to run playbook '$Playbook'.`nError:`n$result", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }

        # Write results to CSV
        Write-CSV -Playbook $Playbook -Status $status -Output $result
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while running the playbook.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function to write the result to a CSV file
function Write-CSV {
    param (
        [string]$Playbook,
        [string]$Status,
        [string]$Output
    )

    # Ensure the results directory exists in the same directory as the script
    $scriptDir = Split-Path -Parent $PSCommandPath
    $resultsDir = Join-Path $scriptDir "results"
    if (-not (Test-Path $resultsDir)) {
        Write-Host "Creating results directory at $resultsDir"
        New-Item -ItemType Directory -Path $resultsDir | Out-Null
    }

    # Define the CSV file path
    $csvFile = Join-Path $resultsDir "ansible_results.csv"

    # Clean up the output if necessary
    $cleanedOutput = $Output.Replace("`n", " ").Replace("`r", " ") -replace '\s+', ' ' # Replace newlines with spaces and condense multiple spaces

    # Write the results to the CSV file
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $row = "$timestamp,$Playbook,$Status,$cleanedOutput"

    try {
        if (-not (Test-Path $csvFile)) {
            Write-Host "Creating CSV file at $csvFile"
            "Timestamp,Playbook,Status,Output" | Out-File -FilePath $csvFile -Encoding UTF8 -Force
        }

        Write-Host "Appending to CSV file: $csvFile"
        $row | Out-File -FilePath $csvFile -Append -Encoding UTF8 -Force

        Write-Host "Results successfully written to $csvFile"
    }
    catch {
        Write-Host "Error writing to CSV file: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Failed to write results to the CSV file.`nError: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function to create the GUI
function Create-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Ansible Playbook Runner"
    $form.Size = New-Object System.Drawing.Size(300, 200)
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Choose a playbook to run:"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $form.Controls.Add($label)

    # Add buttons for each playbook
    $playbookButtons = @(
        @{Text = "Run Test Playbook"; Playbook = "test-playbook.yml"},
        @{Text = "Run Local Playbook"; Playbook = "test-local-playbook.yml"}
    )

    $yPos = 40
    foreach ($buttonData in $playbookButtons) {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonData.Text
        $button.Location = New-Object System.Drawing.Point(10, $yPos)
        $button.Width = 260
        $button.Add_Click({ Run-Playbook -Playbook $buttonData.Playbook })
        $form.Controls.Add($button)
        $yPos += 40
    }

    $form.Topmost = $true
    $form.ShowDialog()
}

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Run the GUI
Create-GUI
