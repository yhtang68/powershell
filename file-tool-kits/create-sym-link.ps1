param (
    [Parameter(Mandatory=$true)]
    [string]$TargetFile,   # The real local file containing the token
    [Parameter(Mandatory=$true)]
    [string]$LinkPath      # The path of the symbolic link to create
)

# Check if target exists
if (-not (Test-Path $TargetFile)) {
    Write-Error "Target file not found: $TargetFile"
    exit 1
}

# Remove existing link if exists
if (Test-Path $LinkPath) {
    Remove-Item -Path $LinkPath -Force
}

# Create symbolic link
New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetFile | Out-Null

Write-Host "Symbolic link created:"
Write-Host "`tLink: $LinkPath"
Write-Host "`tTarget: $TargetFile"