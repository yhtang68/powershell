<#
.SYNOPSIS
Counts the number of sections in a specified OneNote notebook.

.PARAMETER NotebookName
The display name of the OneNote notebook to count sections for.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$NotebookName
)

# -------------------------------------------------
# Connect to Microsoft Graph
# -------------------------------------------------
Connect-MgGraph -Scopes "Notes.Read"

# -------------------------------------------------
# Get the notebook
# -------------------------------------------------
$notebook = Get-MgUserOnenoteNotebook -UserId "me" -All |
    Where-Object { $_.DisplayName -eq $NotebookName } | Select-Object -First 1

if (-not $notebook) {
    Write-Host "Notebook '$NotebookName' not found"
    exit 1
}

# -------------------------------------------------
# Count sections
# -------------------------------------------------
$sections = Get-MgUserOnenoteNotebookSection -UserId "me" -NotebookId $notebook.Id -All
$sectionCount = $sections.Count

Write-Host "Notebook '$NotebookName' has $sectionCount sections."