<#
.SYNOPSIS
Stage 1: Create Gmail OAuth token for your account.

.DESCRIPTION
- Auto-loads Google API DLLs from NuGet packages
- Runs OAuth flow to create Gmail token
- Saves token to secure folder
- Logs safe credential info
- Copies token to a stable path (no admin required)
- Loads all paths from gmail-api.config.json
#>

# ----------------------------
# LOAD CONFIG
# ----------------------------
$configPath = ".\gmail-api.config.json"

if (-not (Test-Path $configPath)) {
    Write-Error "Config file not found: $configPath"
    exit 1
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse config.json: $_"
    exit 1
}

# Extract paths from config
$clientSecretPath = $config.gmailApiConfig.paths.clientSecret
$tokenPath        = $config.gmailApiConfig.paths.token
$tokenCopyPath    = $config.gmailApiConfig.paths.tokenCopy  # script-friendly copy

Write-Host "Config loaded successfully."

# ----------------------------
# AUTO-LOAD GOOGLE API DLLS
# ----------------------------
$packageRoot = "C:\Program Files\PackageManagement\NuGet\Packages"

function Get-DllPath($packageName, $dllName) {
    $pkg = Get-ChildItem $packageRoot -Directory |
        Where-Object { $_.Name -like "$packageName*" } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if (-not $pkg) {
        throw "Package not found: $packageName"
    }

    $dll = Get-ChildItem -Path $pkg.FullName -Recurse -Filter $dllName |
        Where-Object { $_.FullName -like "*netstandard2.0*" } |
        Select-Object -First 1

    if (-not $dll) {
        throw "DLL not found: $dllName in $($pkg.FullName)"
    }

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
# LOAD CLIENT SECRET
# ----------------------------
if (-not (Test-Path $clientSecretPath)) {
    Write-Error "Client secret file not found: $clientSecretPath"
    exit 1
}

try {
    $clientSecrets = [Google.Apis.Auth.OAuth2.GoogleClientSecrets]::FromFile($clientSecretPath)
}
catch {
    Write-Error "Failed to load client secret JSON: $_"
    exit 1
}

# ----------------------------
# RUN OAUTH FLOW
# ----------------------------
try {
    $credential = [Google.Apis.Auth.OAuth2.GoogleWebAuthorizationBroker]::AuthorizeAsync(
        $clientSecrets.Secrets,
        $scopes,
        "user",
        [Threading.CancellationToken]::None,
        (New-Object Google.Apis.Util.Store.FileDataStore($tokenPath, $true))
    ).Result

    Write-Host "`nOAuth flow completed."
}
catch {
    Write-Error "OAuth failed: $_"
    exit 1
}

# ----------------------------
# LOG SAFE INFO
# ----------------------------
Write-Host "Token saved at: $tokenPath"

if ($credential -and $credential.UserId) {
    Write-Host "Credential user: $($credential.UserId)"
}

if ($credential -and $credential.Token -and $credential.Token.AccessToken) {
    Write-Host "Token expiry: $($credential.Token.Expiry)"
    Write-Host "Access token length: $($credential.Token.AccessToken.Length) characters"
} else {
    Write-Host "Token not fully available yet."
}

# ----------------------------
# COPY TOKEN (NO ADMIN NEEDED)
# ----------------------------
try {
    Copy-Item -Path $tokenPath -Destination $tokenCopyPath -Force
    Write-Host "Token copied to: $tokenCopyPath (overwrite if existed)"
}
catch {
    Write-Warning "Failed to copy token: $_"
}

Write-Host "`n✅ Stage 1 complete: Gmail token ready for scripts."