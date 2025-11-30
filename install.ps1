# WP Staging CLI Installer for Windows
# This script installs wpstaging on Windows
#
# Usage:
#   Install latest stable version (default):
#     irm https://wp-staging.com/install.ps1 | iex
#
#   Install specific version:
#     & ([scriptblock]::Create((irm https://wp-staging.com/install.ps1))) -v "1.4.0-beta.1"
#
#   Install with license key (for immediate use without prompts):
#     & ([scriptblock]::Create((irm https://wp-staging.com/install.ps1))) -l "YOUR_LICENSE_KEY"
#
#   Install specific version with license:
#     & ([scriptblock]::Create((irm https://wp-staging.com/install.ps1))) -v "1.4.0" -l "YOUR_LICENSE_KEY"
#
# Options:
#   -v, -Version VERSION    Install specific version (e.g., 1.4.0, 1.4.0-beta.1)
#   -l, -License KEY        Register license key after installation
#
# Examples:
#   -v "1.4.0-beta.1"                    # Install version 1.4.0-beta.1
#   -v "1.3.5"                           # Install version 1.3.5
#   -l "abc123"                          # Install latest with license
#   -v "1.4.0" -l "abc123"               # Install 1.4.0 with license
#   (no parameter)                       # Install latest stable (no beta/alpha/rc)

param(
    [Parameter(Mandatory=$false)]
    [Alias("v")]
    [string]$Version = "",

    [Parameter(Mandatory=$false)]
    [Alias("l")]
    [string]$License = ""
)

$ErrorActionPreference = "Stop"

# Configuration
$GitHubApiUrl = "https://api.github.com/repos/wp-staging/wp-staging-cli-release"
$GitHubRawUrl = "https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release"
$BinaryName = "wpstaging.exe"
$InstallDir = "$env:LOCALAPPDATA\Programs\wpstaging"

# Colors for output - Uses Write-Host for colored console output
# Note: Write-Host is intentional here as we need console coloring,
# not pipeline-compatible output
function Write-ColoredHost($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Host $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Info($Message) {
    Write-ColoredHost Cyan $Message
}

function Write-Success($Message) {
    Write-ColoredHost Green $Message
}

function Write-Warning($Message) {
    Write-ColoredHost Yellow $Message
}

function Write-Error($Message) {
    Write-ColoredHost Red "Error: $Message"
}

function Exit-WithError($Message) {
    Write-Error $Message
    exit 1
}

# Detect architecture
function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "amd64" }
        "x86" { return "386" }
        default { Exit-WithError "Unsupported architecture: $arch" }
    }
}

# Get platform string
function Get-Platform($arch) {
    return "windows_$arch"
}

# Download file
function Download-File($url, $output) {
    try {
        Write-Info "Downloading from $url..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $output)
    }
    catch {
        Exit-WithError "Failed to download file: $_"
    }
}

# Verify checksum
function Verify-Checksum($file, $expectedChecksum) {
    Write-Info "Verifying checksum..."

    # Validate checksum format (SHA256 is 64 hex characters)
    if ($expectedChecksum -notmatch '^[a-f0-9]{64}$') {
        Exit-WithError "Invalid checksum format: $expectedChecksum"
    }

    try {
        $hash = Get-FileHash -Path $file -Algorithm SHA256
        $actualChecksum = $hash.Hash.ToLower()

        if ($actualChecksum -ne $expectedChecksum) {
            Exit-WithError "Checksum verification failed!`n  Expected: $expectedChecksum`n  Got:      $actualChecksum"
        }

        Write-Success "✓ Checksum verified"
    }
    catch {
        Exit-WithError "Failed to verify checksum: $_"
    }
}

# Install aliases (batch files)
function Install-Aliases($installDir) {
    Write-Info "Installing aliases..."

    # Create wpstg.cmd
    $wpstgContent = @"
@echo off
"%~dp0wpstaging.exe" %*
"@
    $wpstgPath = Join-Path $installDir "wpstg.cmd"

    # Create wp-staging.cmd
    $wpStagingContent = @"
@echo off
"%~dp0wpstaging.exe" %*
"@
    $wpStagingPath = Join-Path $installDir "wp-staging.cmd"

    try {
        Set-Content -Path $wpstgPath -Value $wpstgContent -Force
        Set-Content -Path $wpStagingPath -Value $wpStagingContent -Force
        Write-Success "✓ Created aliases: wpstg, wp-staging"
    }
    catch {
        Write-Warning "Failed to create aliases: $_"
    }
}

# Check if directory is in PATH
function Test-InPath($directory) {
    $pathDirs = $env:PATH.Split(';')
    foreach ($dir in $pathDirs) {
        if ($dir -eq $directory) {
            return $true
        }
    }
    return $false
}

# Pick best installation directory
# Prefers directories already on PATH to avoid needing terminal restart
function Get-InstallDir {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\wpstaging",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps",
        "$env:USERPROFILE\bin",
        "$env:USERPROFILE\.local\bin"
    )

    # 1) If candidate is in PATH and writable, use it (works immediately)
    foreach ($dir in $candidates) {
        if ((Test-InPath $dir) -and (Test-Path $dir) -and (Test-Path $dir -PathType Container)) {
            try {
                $testFile = Join-Path $dir ".wpstaging-write-test"
                [System.IO.File]::WriteAllText($testFile, "test")
                Remove-Item $testFile -Force
                return $dir
            }
            catch {
                # Not writable, continue
            }
        }
    }

    # 2) Default to user-specific directory (will need PATH update)
    return "$env:LOCALAPPDATA\Programs\wpstaging"
}

# Add to PATH
function Add-ToPath($directory) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    # Check if already in PATH
    if (Test-InPath $directory) {
        Write-Info "✓ $directory is already in PATH"
        return $true
    }

    # Add to PATH
    try {
        $newPath = "$currentPath;$directory"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$env:PATH;$directory"
        Write-Success "✓ Added $directory to PATH"
        Write-Info "  You may need to restart your terminal for PATH changes to take effect"
        return $false
    }
    catch {
        Write-Warning "Failed to update PATH: $_"
        Write-Info "Please manually add '$directory' to your PATH"
        return $false
    }
}

# Check if command exists
function Test-CommandExists($command) {
    try {
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

# Fetch latest stable version from GitHub (excludes beta/alpha/rc)
function Get-LatestStableVersion {
    Write-Info "Fetching latest stable version..."

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $webClient = New-Object System.Net.WebClient
        $tagsJson = $webClient.DownloadString("$GitHubApiUrl/tags")
        $tags = $tagsJson | ConvertFrom-Json

        # Filter out pre-release versions (beta, alpha, rc)
        $stableTags = $tags | Where-Object {
            $_.name -notmatch 'beta|alpha|rc|Beta|Alpha|RC'
        }

        if ($stableTags -and $stableTags.Count -gt 0) {
            $latestVersion = $stableTags[0].name
            return $latestVersion
        }
        else {
            Write-Warning "No stable version found, falling back to 'main'"
            return "main"
        }
    }
    catch {
        Write-Warning "Failed to fetch tags from GitHub API, falling back to 'main'"
        return "main"
    }
}

# Validate that a version exists in the release repository
function Test-VersionExists($versionRef) {
    # Skip validation for 'main'
    if ($versionRef -eq "main") {
        return $true
    }

    Write-Info "Validating version $versionRef..."

    try {
        $manifestUrl = "$GitHubRawUrl/$versionRef/manifest.json"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Try to access the manifest
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadString($manifestUrl) | Out-Null

        Write-Success "✓ Version $versionRef exists"
        return $true
    }
    catch {
        Exit-WithError "Version '$versionRef' not found in release repository.`n`n  Please check available versions at:`n  https://github.com/wp-staging/wp-staging-cli-release/tags`n`n  Or install the latest stable version by omitting the version parameter."
        return $false
    }
}

# Main installation
function Main {
    param(
        [string]$RequestedVersion,
        [string]$LicenseKey
    )
    Write-Info "WP Staging CLI Installer for Windows"
    Write-Info "======================================"
    Write-Host ""

    # Determine version to install
    if ($RequestedVersion) {
        # User specified a version
        Write-Info "Requested version: $RequestedVersion"
        $versionRef = $RequestedVersion

        # Validate version exists
        Test-VersionExists $versionRef | Out-Null
    }
    else {
        # No version specified, fetch latest stable (no beta/alpha/rc)
        $versionRef = Get-LatestStableVersion

        if ($versionRef -eq "main") {
            Write-Info "Using branch: main"
        }
        else {
            Write-Info "Selected latest stable version: $versionRef"
        }
    }

    # Build URLs based on version
    $repoUrl = "$GitHubRawUrl/$versionRef"
    $manifestUrl = "$repoUrl/manifest.json"

    # Detect platform
    Write-Info "`nDetecting platform..."
    $arch = Get-Architecture
    $platform = Get-Platform $arch

    Write-Info "  Architecture: $arch"
    Write-Info "  Platform: $platform"
    Write-Host ""

    # Create temporary directory
    $tempDir = Join-Path $env:TEMP "wpstaging-install-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        # Download manifest
        Write-Info "Downloading manifest..."
        $manifestFile = Join-Path $tempDir "manifest.json"
        Download-File $manifestUrl $manifestFile

        $manifest = Get-Content $manifestFile -Raw | ConvertFrom-Json
        $installedVersion = $manifest.version

        if (-not $installedVersion) {
            Exit-WithError "Failed to parse version from manifest"
        }

        Write-Success "✓ Version: $installedVersion"
        Write-Host ""

        # Get checksum from manifest
        Write-Info "Downloading wpstaging..."

        $platformData = $manifest.platforms.$platform
        if (-not $platformData) {
            Exit-WithError "No binary found for platform: $platform"
        }

        $checksum = $platformData.checksum
        if (-not $checksum) {
            Exit-WithError "No checksum found for platform: $platform"
        }

        $binaryPath = $platformData.binary
        if (-not $binaryPath) {
            Exit-WithError "No binary path found for platform: $platform"
        }

        # Download binary using path from manifest
        $binaryUrl = "$repoUrl/build/$binaryPath"
        $binaryFile = Join-Path $tempDir $BinaryName
        Download-File $binaryUrl $binaryFile

        Write-Success "✓ Downloaded binary"
        Write-Host ""

        # Verify checksum
        Verify-Checksum $binaryFile $checksum
        Write-Host ""

        # Determine installation directory
        # Prefer directories already on PATH to avoid needing terminal restart
        Write-Info "Installing wpstaging..."
        $InstallDir = Get-InstallDir
        $alreadyInPath = Test-InPath $InstallDir

        if ($alreadyInPath) {
            Write-Info "Installing to $InstallDir (already in PATH - works immediately)"
        }
        else {
            Write-Info "Installing to $InstallDir (will add to PATH)"
        }

        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        }

        # Install binary
        $targetPath = Join-Path $InstallDir $BinaryName
        Copy-Item $binaryFile $targetPath -Force

        Write-Success "✓ Installed binary to $targetPath"
        Write-Host ""

        # Install aliases
        Install-Aliases $InstallDir
        Write-Host ""

        # Add to PATH if needed
        if (-not $alreadyInPath) {
            Write-Info "Updating PATH..."
            Add-ToPath $InstallDir | Out-Null
            Write-Host ""
        }

        # Register license key if provided
        if ($LicenseKey) {
            Write-Info "Registering license key..."

            # Check if binary exists
            if (-not (Test-Path $targetPath)) {
                Write-Warning "Binary not found. Cannot register license"
                Write-Warning "You can register later with: wpstaging register"
            }
            else {
                try {
                    # Set environment variable temporarily to avoid exposure in process list
                    $env:WPSTGPRO_LICENSE = $LicenseKey
                    $registerOutput = & $targetPath register 2>&1

                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "✓ License registered successfully"
                    }
                    else {
                        Write-Warning "License registration failed: $registerOutput"
                        Write-Warning "You can register later with: wpstaging register"
                    }
                }
                finally {
                    # Always clean up environment variable
                    Remove-Item Env:\WPSTGPRO_LICENSE -ErrorAction SilentlyContinue
                }
            }
            Write-Host ""
        }

        # Verify installation
        Write-Info "Verifying installation..."
        if (Test-CommandExists "wpstaging") {
            try {
                $versionOutput = & wpstaging --version 2>&1
                Write-Success "✓ Installation successful!"
                Write-Host ""
                Write-Success "Installed: $versionOutput"
            }
            catch {
                Write-Warning "Installation complete, but verification failed"
                Write-Info "You may need to restart your terminal"
            }
        }
        else {
            Write-Warning "⚠ Installation complete, but 'wpstaging' is not in PATH"
            Write-Info "  Please restart your terminal or PowerShell session"
        }

        # Show usage
        Write-Host ""
        if ($alreadyInPath) {
            # Directory was already in PATH - works immediately
            Write-Info "Run wpstaging now:"
            if ($LicenseKey) {
                Write-Info "  wpstaging add mysite.local --license $LicenseKey"
                Write-Host ""
                Write-Info "Note: The license key is only needed once to activate WP Staging CLI."
                Write-Info "      After activation, you can use wpstaging without the --license flag."
            }
            else {
                Write-Info "  wpstaging add mysite.local"
            }
        }
        else {
            # Directory was added to PATH - needs restart
            Write-Info "Run wpstaging immediately (copy & paste):"
            if ($LicenseKey) {
                Write-Info "  $targetPath add mysite.local --license $LicenseKey"
                Write-Host ""
                Write-Info "Note: The license key is only needed once to activate WP Staging CLI."
                Write-Info "      After activation, you can use wpstaging without the --license flag."
            }
            else {
                Write-Info "  $targetPath add mysite.local"
            }
            Write-Host ""
            Write-Info "Or restart your terminal, then use:"
            Write-Info "  wpstaging add mysite.local"
        }
        Write-Host ""
        Write-Info "Get help:"
        Write-Info "  wpstaging --help"
        Write-Host ""
        Write-Info "Documentation:"
        Write-Info "  https://github.com/wp-staging/wp-staging-cli-release"
        Write-Host ""
    }
    catch {
        Exit-WithError "Installation failed: $_"
    }
    finally {
        # Clean up temporary directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Run main function with version and license parameters (if provided)
Main -RequestedVersion $Version -LicenseKey $License
