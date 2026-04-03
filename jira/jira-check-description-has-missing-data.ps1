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

# --- Loop through issues ---
foreach ($Issue in $SearchResponse.issues) {
    $Key = $Issue.key
    $Description = $Issue.fields.description

    if ([string]::IsNullOrWhiteSpace($Description) -or $Description.Length -lt 100) {
        Write-Host "❌ Issue ${Key}: Description may have missing data (length = $($Description.Length))"
    } else {
        Write-Host "✅ Issue ${Key}: Description is sufficient (length = $($Description.Length))"
    }
}