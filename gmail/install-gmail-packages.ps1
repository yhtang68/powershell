# ----------------------------
# Stage 0: Install required Gmail API packages
# ----------------------------

param(
    [bool]$forceInstall = $true
)

$packages = @(
    # @{ Name = "Google.Apis"; Version = "1.73.0" }
    @{ Name = "Google.Apis.Core"; Version = "1.73.0" }
    @{ Name = "Google.Apis.Auth"; Version = "1.73.0" }
    @{ Name = "Google.Apis.Gmail.v1"; Version = "1.73.0" }
)

foreach ($pkg in $packages) {
    $installed = Get-Package -Name $pkg.Name -RequiredVersion $pkg.Version -ErrorAction SilentlyContinue

    if ($installed -and -not $forceInstall) {
        Write-Host "✅ $($pkg.Name) $($pkg.Version) is already installed. Skipping."
        continue
    }

    Write-Host "Installing package $($pkg.Name) version $($pkg.Version)..."
    try {
        Install-Package $pkg.Name -Source nuget.org -RequiredVersion $pkg.Version -Scope CurrentUser -Force:$forceInstall -ErrorAction Stop
        # Install-Package Google.Apis.Auth -Source nuget.org -SkipDependencies -Force
        Write-Host "✅ $($pkg.Name) installed successfully."
    }
    catch {
        Write-Warning "⚠ Failed to install $($pkg.Name): $_"
    }
}

Write-Host "`nAll required Gmail API packages processed."
Write-Host "You can now run Stage 1 (Create-Gmail-Token.ps1) and Stage 2 (Fetch-LinkedIn-Jobs.ps1)."