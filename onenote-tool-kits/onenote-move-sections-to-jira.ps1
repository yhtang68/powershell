<#
.SYNOPSIS
Convert OneNote sections into Jira tickets (title only, no page content).

.VERSION NOTES
- Microsoft.Graph tested on: 2.36.1
- Section = Jira Ticket
- "(x)" prefix → Rejected
- Others → Open
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$NotebookName,

    [Parameter(Mandatory=$true)]
    [string]$JiraCredFilePath
)

# ===== FUNCTION: CREATE JIRA ISSUE =====
function New-JiraIssue {
    param(
        [Parameter(Mandatory=$true)]
        [psobject]$Issue
    )

    # Jira ADF description (required)
    $descriptionADF = @{
        type = "doc"
        version = 1
        content = @(
            @{
                type = "paragraph"
                content = @(
                    @{
                        type = "text"
                        text = $Issue.Description
                    }
                )
            }
        )
    }

    $body = @{
        fields = @{
            project     = @{ key = $Issue.JiraInfo.ProjectKey }
            summary     = $Issue.Title
            description = $descriptionADF
            issuetype   = @{ name = $Issue.JiraInfo.IssueType }
            labels      = @($Issue.Status)
        }
    } | ConvertTo-Json -Depth 10

    try {
        $resp = Invoke-RestMethod -Method Post `
            -Uri "$($Issue.JiraInfo.BaseUrl)/rest/api/3/issue" `
            -Headers $Issue.JiraInfo.Headers `
            -Body $body

        # ✅ Add ticket summary in trace
        Write-Host "Created: $($resp.key) - $($Issue.Title) [$($Issue.Status)]"

        return $resp.key
    } catch {
        Write-Warning "Failed to create: $($Issue.Title)"
        Write-Warning $_.Exception.Message
        return $null
    }
}

# ===== FUNCTION: BUILD ISSUE FROM SECTION (TITLE ONLY) =====
function New-JiraIssueFromSection {
    param(
        [psobject]$Section,
        [psobject]$JiraInfo
    )

    $status = if ($Section.DisplayName -match '^\(x\)') { 'Rejected' } else { 'Open' }
    $title  = $Section.DisplayName -replace '^\(x\)\s*',''

    # Only using section title as description
    $description = "Section: $title"

    return [PSCustomObject]@{
        Title       = $title
        Description = $description
        Status      = $status
        JiraInfo    = $JiraInfo
    }
}

# ===== FUNCTION: DUPLICATE CHECK =====
function Test-Duplicate {
    param(
        [string]$SectionName,
        [string[]]$ExistingTitles
    )

    $title  = $SectionName -replace '^\(x\)\s*',''
    $status = if ($SectionName -match '^\(x\)') { 'Rejected' } else { 'Open' }

    $isDuplicate = $false
    if ($ExistingTitles) {
        $isDuplicate = $ExistingTitles -contains $title
    }

    return [PSCustomObject]@{
        Title       = $title
        Status      = $status
        IsDuplicate = $isDuplicate
    }
}

# ===== MAIN FUNCTION =====
function main {

    # ===== LOAD JIRA CREDS =====
    if (-not (Test-Path $JiraCredFilePath)) {
        Write-Error "Jira credential file not found"
        exit
    }

    $jira = (Get-Content $JiraCredFilePath -Raw | ConvertFrom-Json).jira

    $pair = "$($jira.email):$($jira.token)"
    $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

    $jiraHeaders = @{
        Authorization = "Basic $base64"
        "Content-Type" = "application/json"
    }

    $JiraInfo = [PSCustomObject]@{
        BaseUrl    = $jira.baseUrl
        Headers    = $jiraHeaders
        ProjectKey = "JOB"
        IssueType  = "Task"
    }

    # ===== CONNECT GRAPH =====
    Connect-MgGraph -Scopes "Notes.Read"

    # ===== GET NOTEBOOK =====
    $notebook = Get-MgUserOnenoteNotebook -UserId "me" -All |
        Where-Object { $_.DisplayName -eq $NotebookName } |
        Select-Object -First 1

    if (-not $notebook) {
        Write-Error "Notebook not found"
        exit
    }

    # ===== GET SECTIONS =====
    $sections = Get-MgUserOnenoteNotebookSection -UserId "me" -NotebookId $notebook.Id -All

    $total = $sections.Count
    $rejected = ($sections | Where-Object { $_.DisplayName -match '^\(x\)' }).Count
    $open = $total - $rejected

    Write-Host "`nNotebook '$NotebookName': Total=$total Rejected=$rejected Open=$open"

    # ===== FETCH EXISTING JIRA ISSUES =====
    $existingTitles = @()
    try {
        $searchBody = @{
            jql        = "project=$($JiraInfo.ProjectKey)"
            fields     = @("summary")
            maxResults = 1000
        } | ConvertTo-Json -Depth 5

        $resp = Invoke-RestMethod -Method Post `
            -Uri "$($JiraInfo.BaseUrl)/rest/api/3/search/jql" `
            -Headers $jiraHeaders `
            -Body $searchBody

        if ($resp.issues) {
            $existingTitles = $resp.issues | ForEach-Object { $_.fields.summary }
        }
    } catch {
        Write-Warning "Jira search failed — duplicate check disabled"
    }

    # ===== PROCESS SECTIONS =====
    $totalProcessed = 0
    $createdTotal = 0
    $createdRejected = 0
    $createdOpen = 0

    foreach ($section in $sections) {
        $totalProcessed++

        $check = Test-Duplicate -SectionName $section.DisplayName -ExistingTitles $existingTitles
        if ($check.IsDuplicate) {
            Write-Host "Skipping duplicate: $($check.Title)"
            continue
        }

        $issue = New-JiraIssueFromSection -Section $section -JiraInfo $JiraInfo
        $issueKey = New-JiraIssue -Issue $issue

        if ($issueKey) {
            $createdTotal++
            if ($check.Status -eq "Rejected") { $createdRejected++ } else { $createdOpen++ }
            $existingTitles += $check.Title
        }
    }

    # ===== SUMMARY =====
    Write-Host "`nProcessed Sections: $totalProcessed"
    Write-Host "Created Tickets:"
    Write-Host "  Total     : $createdTotal"
    Write-Host "  Rejected  : $createdRejected"
    Write-Host "  Open      : $createdOpen"
    Write-Host "`nDone."
}

# ===== RUN =====
main