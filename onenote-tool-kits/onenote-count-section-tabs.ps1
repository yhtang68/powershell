<#
.SYNOPSIS
Counts total, rejected, and open sections in a specified OneNote notebook.

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
    Where-Object { $_.DisplayName -eq $NotebookName } |
    Select-Object -First 1

if (-not $notebook) {
    Write-Host "Notebook '$NotebookName' not found"
    exit 1
}

# -------------------------------------------------
# Get sections
# -------------------------------------------------
$sections = Get-MgUserOnenoteNotebookSection -UserId "me" -NotebookId $notebook.Id -All

# Total
$total = $sections.Count

# Rejected (section name starts with "(x)")
$rejected = ($sections | Where-Object {
    $_.DisplayName -match '^\(x\)'
}).Count

# Open = total - rejected
$open = $total - $rejected

# -------------------------------------------------
# Output
# -------------------------------------------------
Write-Host "Notebook '$NotebookName':"
Write-Host "  Total Jobs     : $total"
Write-Host "  Rejected       : $rejected"
Write-Host "  Open           : $open"