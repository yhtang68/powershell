<#
.SYNOPSIS
Stage 2: Fetch LinkedIn Job Emails via Gmail API and generate job-list.html

.DESCRIPTION
- Loads Google API DLLs from NuGet packages
- Uses OAuth token created in Stage 1
- Fetches emails from sender: jobalerts-noreply@linkedin.com
- Parses email content for job listings
- Deduplicates jobs by title + company
- Generates a simple job-list.html
#>

# ----------------------------
# LOAD CONFIG
# ----------------------------
$configPath = ".\gmail-api.config.json"

if (-not (Test-Path $configPath)) {
    Write-Error "Config file not found: $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json

$tokenPath = $config.gmailApiConfig.paths.tokenCopy  # symlink / script-friendly path

# ----------------------------
# AUTO-LOAD GOOGLE API DLLS
# ----------------------------
$packageRoot = "C:\Program Files\PackageManagement\NuGet\Packages"

function Get-DllPath($packageName, $dllName) {
    $pkg = Get-ChildItem $packageRoot -Directory |
        Where-Object { $_.Name -like "$packageName*" } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if (-not $pkg) { throw "Package not found: $packageName" }

    $dll = Get-ChildItem -Path $pkg.FullName -Recurse -Filter $dllName |
        Where-Object { $_.FullName -like "*netstandard2.0*" } |
        Select-Object -First 1

    if (-not $dll) { throw "DLL not found: $dllName in $($pkg.FullName)" }

    return $dll.FullName
}

try {
    Add-Type -Path (Get-DllPath "Google.Apis" "Google.Apis.dll")
    Add-Type -Path (Get-DllPath "Google.Apis.Core" "Google.Apis.Core.dll")
    Add-Type -Path (Get-DllPath "Google.Apis.Auth" "Google.Apis.Auth.dll")
    Add-Type -Path (Get-DllPath "Google.Apis.Gmail.v1" "Google.Apis.Gmail.v1.dll")
    Write-Host "Google API DLLs loaded successfully."
}
catch {
    Write-Error "Failed to load Google API DLLs: $_"
    exit 1
}

# ----------------------------
# DEFINE SCOPES
# ----------------------------
$scopes = [Google.Apis.Gmail.v1.GmailService+Scope]::GmailReadonly

# ----------------------------
# LOAD STORED CREDENTIAL
# ----------------------------
try {
    $credential = [Google.Apis.Auth.OAuth2.GoogleWebAuthorizationBroker]::AuthorizeAsync(
        (New-Object Google.Apis.Auth.OAuth2.ClientSecrets), 
        $scopes,
        "user",
        [Threading.CancellationToken]::None,
        (New-Object Google.Apis.Util.Store.FileDataStore($tokenPath, $true))
    ).Result
}
catch {
    Write-Error "Failed to load OAuth token: $_"
    exit 1
}

# ----------------------------
# INIT GMAIL SERVICE
# ----------------------------
$service = New-Object Google.Apis.Gmail.v1.GmailService(
    (New-Object Google.Apis.Services.BaseClientService+Initializer -Property @{
        HttpClientInitializer = $credential
        ApplicationName = "LinkedIn Job Fetcher"
    })
)

# ----------------------------
# FETCH MESSAGES
# ----------------------------
$query = "from:jobalerts-noreply@linkedin.com"
$messagesRequest = $service.Users.Messages.List("me")
$messagesRequest.Q = $query
$messages = $messagesRequest.Execute().Messages

if (-not $messages) {
    Write-Host "No LinkedIn job emails found."
    exit 0
}

Write-Host "Found $($messages.Count) LinkedIn emails."

# ----------------------------
# PARSE EMAIL CONTENT
# ----------------------------
$jobs = @{}

foreach ($msg in $messages) {
    $messageDetail = $service.Users.Messages.Get("me", $msg.Id).Execute()
    
    $payload = $messageDetail.Payload
    $body = $payload.Parts | Where-Object { $_.MimeType -eq "text/html" } | Select-Object -First 1
    
    if ($body -and $body.Body.Data) {
        $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($body.Body.Data.Replace('-','+').Replace('_','/')))
        
        # Example regex to extract jobs: <li>Job Title @ Company</li>
        $matches = [regex]::Matches($content, "<li>(.+?)</li>")
        
        foreach ($m in $matches) {
            $line = $m.Groups[1].Value.Trim()
            if (-not $jobs.ContainsKey($line)) {
                $jobs[$line] = $true
            }
        }
    }
}

Write-Host "Extracted $($jobs.Keys.Count) unique job listings."

# ----------------------------
# GENERATE HTML
# ----------------------------
$html = @"
<!DOCTYPE html>
<html>
<head>
<title>LinkedIn Job List</title>
<meta charset='utf-8'>
<style>
body { font-family: Arial; padding: 20px; }
ul { list-style-type: square; }
li { margin: 5px 0; }
</style>
</head>
<body>
<h1>LinkedIn Job Alerts</h1>
<ul>
"@

foreach ($job in $jobs.Keys) {
    $html += "<li>$job</li>`n"
}

$html += @"
</ul>
</body>
</html>
"@

$outFile = ".\job-list.html"
$html | Out-File -FilePath $outFile -Encoding UTF8

Write-Host "`n✅ Job list generated: $outFile"