<#
.SYNOPSIS
Checks JIRA issue descriptions for missing data (<100 chars) based on a JQL query using the new /search/jql API.

.PARAMETER JiraCredFilePath
Path to JSON file containing JIRA credentials, nested under "jira", e.g.:

{
    "jira": {
        "user": "Yuan-Hsun Tang",
        "email": "madeinuk14@gmail.com",
        "baseUrl": "https://yhtang68.atlassian.net",
        "token": "YOUR_API_TOKEN"
    }
}

.PARAMETER JqlQuery
JQL string to select issues. Default: "parent=JOB-5 ORDER BY rank".
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$JiraCredFilePath,

    [string]$JqlQuery = "parent=JOB-5 ORDER BY rank"
)

# --- Helper: flatten ADF (Atlassian Document Format) to plain text ---
function Get-PlainTextFromADF($ADFNode) {
    if (-not $ADFNode) { return "" }

    $text = ""

    switch ($ADFNode.type) {
        "text" { if ($ADFNode.text) { $text += $ADFNode.text } }
        "inlineCard" { if ($ADFNode.attrs.url) { $text += $ADFNode.attrs.url } }
        "hardBreak" { $text += "`n" }
        "mention" { 
            if ($ADFNode.attrs.text) { $text += $ADFNode.attrs.text } 
            elseif ($ADFNode.attrs.user.displayName) { $text += $ADFNode.attrs.user.displayName } 
        }
        default { }
    }

    if ($ADFNode.content) {
        foreach ($child in $ADFNode.content) {
            $text += Get-PlainTextFromADF $child
        }
    }

    return $text
}

# --- Load credentials (nested JSON) ---
if (-Not (Test-Path $JiraCredFilePath)) {
    Write-Error "Credential file not found: $JiraCredFilePath"
    exit
}

$CredJson = Get-Content $JiraCredFilePath -Raw | ConvertFrom-Json
$JiraUser = $CredJson.jira.email          # use email for authentication
$JiraApiToken = $CredJson.jira.token
$JiraDomain = $CredJson.jira.baseUrl      # already includes https://

# --- Build Authorization header ---
$AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JiraUser}:${JiraApiToken}"))
$Headers = @{
    Authorization = "Basic $AuthInfo"
    Accept        = "application/json"
    "Content-Type" = "application/json"
}

# --- Prepare POST body for JQL ---
$Body = @{
    jql = $JqlQuery
    fields = @("description")
    maxResults = 1000
} | ConvertTo-Json

# --- Call the new API ---
$SearchUrl = "$JiraDomain/rest/api/3/search/jql"

try {
    $SearchResponse = Invoke-RestMethod -Uri $SearchUrl -Headers $Headers -Method Post -Body $Body
} catch {
    Write-Error "Error executing JQL query: $_"
    exit
}

if (-not $SearchResponse.issues) {
    Write-Host "No issues found for query: $JqlQuery"
    exit
}

# --- Ensure issues is treated as an array ---
$IssuesArray = @($SearchResponse.issues)
$TotalReturned = $IssuesArray.Count

Write-Host "`nTotal issues returned by JQL '$JqlQuery': $TotalReturned`n"

# --- Loop through issues and check description length ---
$MissingCount = 0

foreach ($Issue in $IssuesArray) {
    $Key = $Issue.key
    $DescriptionADF = $Issue.fields.description
    $PlainDescription = Get-PlainTextFromADF $DescriptionADF
    $Length = $PlainDescription.Length

    if ($Length -lt 100) {
        Write-Host "❌ Issue ${Key}: Description may have missing data (length = $Length)"
        $MissingCount++
    } else {
        Write-Host "✅ Issue ${Key}: Description is sufficient (length = $Length)"
    }
}

# --- Summary ---
$SufficientCount = $TotalReturned - $MissingCount

# Calculate percentages
$MissingPercent = [math]::Round(($MissingCount / $TotalReturned) * 100, 2)
$SufficientPercent = 100 - $MissingPercent

Write-Host "`nSummary:"
Write-Host "Total issues returned: $TotalReturned"
Write-Host "Issues with missing description (<100 chars): $MissingCount ($MissingPercent`%)"
Write-Host "Issues with sufficient description: $SufficientCount ($SufficientPercent`%)"
