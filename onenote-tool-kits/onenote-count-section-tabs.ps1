# -------------------------------------------------
# Variables
# -------------------------------------------------
$notebookName = "2026 03 JOB"  # Notebook to count sections in

# -------------------------------------------------
# Connect to Microsoft Graph
# -------------------------------------------------
Connect-MgGraph -Scopes "Notes.Read"

# -------------------------------------------------
# Get the notebook
# -------------------------------------------------
$notebook = Get-MgUserOnenoteNotebook -UserId "me" -All |
    Where-Object { $_.DisplayName -eq $notebookName }

if (-not $notebook) {
    Write-Host "Notebook '$notebookName' not found"
    exit 1
}

# -------------------------------------------------
# Count sections
# -------------------------------------------------
$sections = Get-MgUserOnenoteNotebookSection -UserId "me" -NotebookId $notebook.Id -All
$sectionCount = $sections.Count

Write-Host "Notebook '$notebookName' has $sectionCount sections."