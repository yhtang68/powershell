param (
    [Parameter(Mandatory=$true)]
    [string]$JiraCredFilePath
)

# -------------------------------
# Check if credential file exists
# -------------------------------
if (-not (Test-Path $JiraCredFilePath)) {
    Write-Error "Jira credential file not found: $JiraCredFilePath"
    exit 1
}

# -------------------------------
# Read Jira credentials from JSON
# -------------------------------
try {
    $credJson = Get-Content -Path $JiraCredFilePath -Raw | ConvertFrom-Json
} catch {
    Write-Error "Failed to read or parse JSON file: $_"
    exit 1
}

$JiraUser = $credJson.jira.user
$JiraEmail = $credJson.jira.email
$JiraBaseUrl = $credJson.jira.baseUrl
$JiraToken = $credJson.jira.token

if (-not $JiraEmail -or -not $JiraToken -or -not $JiraBaseUrl) {
    Write-Error "JSON file is missing required Jira fields (email, token, baseUrl)."
    exit 1
}

# -------------------------------
# Prepare Basic Auth header
# -------------------------------
# Use ${} to safely handle special characters
$pair = "${JiraEmail}:${JiraToken}"
$encodedCreds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{
    Authorization = "Basic $encodedCreds"
    Accept = "application/json"
}

# -------------------------------
# Call Jira REST API: serverInfo
# -------------------------------
try {
    $response = Invoke-RestMethod -Uri "$JiraBaseUrl/rest/api/2/serverInfo" -Headers $headers -Method Get

    Write-Host "Jira Base URL: $($response.baseUrl)"
    Write-Host "Deployment Type: $($response.deploymentType)"
    Write-Host "Version: $($response.version)"
    Write-Host "Build Number: $($response.buildNumber)"
} catch {
    Write-Error "Failed to query Jira serverInfo API: $_"
}