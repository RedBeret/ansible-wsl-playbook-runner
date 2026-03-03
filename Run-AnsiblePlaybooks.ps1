#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Resolve the WSL home directory for the current WSL default user.
# Translates to a Windows UNC path so we don't hardcode a username.
function Get-WslHome {
    $user = (wsl echo '$HOME') -replace "`r", ""
    return $user
}

# Discover all .yml files in the script directory (and a configurable playbook dir).
function Get-Playbooks {
    param ([string]$PlaybookDir)
    $items = @()
    if (Test-Path $PlaybookDir) {
        $items = Get-ChildItem -Path $PlaybookDir -Filter "*.yml" | Select-Object -ExpandProperty Name
    }
    return $items
}

function Run-Playbook {
    param (
        [string]$Playbook,
        [string]$WslHome,
        [string]$Inventory
    )

    $status = "Unknown"
    $result = ""

    try {
        # Run ansible-playbook inside WSL using the resolved home path
        $result = wsl ansible-playbook -i "$WslHome/$Inventory" "$WslHome/playbooks/$Playbook" 2>&1

        if ($LASTEXITCODE -ne 0 -or ($result -match "FAILED! =>")) {
            if ($result -match "FAILED! =>") {
                $status = "Partial"
                [System.Windows.Forms.MessageBox]::Show(
                    "Playbook '$Playbook' completed with failed tasks.`n`n$result",
                    "Partial Success",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
            } else {
                $status = "Failed"
                [System.Windows.Forms.MessageBox]::Show(
                    "Playbook '$Playbook' failed.`n`n$result",
                    "Failed",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        } else {
            $status = "Success"
            [System.Windows.Forms.MessageBox]::Show(
                "Playbook '$Playbook' ran successfully.`n`n$result",
                "Success",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        }
    } catch {
        $status = "Error"
        $result = $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show(
            "Exception running playbook '$Playbook'.`n`n$($_.Exception.Message)",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }

    Write-RunLog -Playbook $Playbook -Status $status -Output ($result -join " ")
}

function Write-RunLog {
    param (
        [string]$Playbook,
        [string]$Status,
        [string]$Output
    )

    $resultsDir = Join-Path (Split-Path -Parent $PSCommandPath) "results"
    if (-not (Test-Path $resultsDir)) {
        New-Item -ItemType Directory -Path $resultsDir | Out-Null
    }

    $csvFile = Join-Path $resultsDir "run-log.csv"

    # Use Export-Csv-safe object so commas/quotes in output don't break the file
    $entry = [PSCustomObject]@{
        Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Playbook  = $Playbook
        Status    = $Status
        Output    = $Output -replace '[\r\n]+', ' '
    }

    $entry | Export-Csv -Path $csvFile -Append -NoTypeInformation -Encoding UTF8
}

function Create-GUI {
    param (
        [string[]]$Playbooks,
        [string]$WslHome,
        [string]$Inventory
    )

    $rowHeight = 40
    $formHeight = 80 + ($Playbooks.Count * $rowHeight)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Ansible WSL Playbook Runner"
    $form.Size = New-Object System.Drawing.Size(340, $formHeight)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Select a playbook to run:"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(12, 12)
    $form.Controls.Add($label)

    $yPos = 40
    foreach ($pb in $Playbooks) {
        # Capture loop variable explicitly to avoid closure-over-reference bug
        $captured = $pb
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $captured
        $btn.Location = New-Object System.Drawing.Point(12, $yPos)
        $btn.Width = 300
        $btn.Add_Click({
            Run-Playbook -Playbook $captured -WslHome $WslHome -Inventory $Inventory
        }.GetNewClosure())
        $form.Controls.Add($btn)
        $yPos += $rowHeight
    }

    [void]$form.ShowDialog()
}

# --- Entry point ---

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$wslHome  = Get-WslHome
$inventory = "inventory"  # relative to $wslHome — change if yours lives elsewhere
$playbookDir = Join-Path (Split-Path -Parent $PSCommandPath) "playbooks"
$playbooks = Get-Playbooks -PlaybookDir $playbookDir

if ($playbooks.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "No .yml playbooks found in:`n$playbookDir`n`nAdd playbooks there and rerun.",
        "No Playbooks Found",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    exit
}

Create-GUI -Playbooks $playbooks -WslHome $wslHome -Inventory $inventory
