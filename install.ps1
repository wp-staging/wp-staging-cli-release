# WP Staging CLI Installer for Windows
# This script installs wpstaging on Windows
# Usage: irm https://wp-staging.com/install.ps1 | iex

$ErrorActionPreference = "Stop"

# Configuration
$RepoUrl = "https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release/main"
$ManifestUrl = "$RepoUrl/manifest.json"
$BinaryName = "wpstaging.exe"
$InstallDir = "$env:LOCALAPPDATA\Programs\wpstaging"

# Colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Info($Message) {
    Write-ColorOutput Cyan $Message
}

function Write-Success($Message) {
    Write-ColorOutput Green $Message
}

function Write-Warning($Message) {
    Write-ColorOutput Yellow $Message
}

function Write-Error($Message) {
    Write-ColorOutput Red "Error: $Message"
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

# Add to PATH
function Add-ToPath($directory) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    # Check if already in PATH
    $pathDirs = $currentPath.Split(';')
    foreach ($dir in $pathDirs) {
        if ($dir -eq $directory) {
            Write-Info "✓ $directory is already in PATH"
            return
        }
    }

    # Add to PATH
    try {
        $newPath = "$currentPath;$directory"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$env:PATH;$directory"
        Write-Success "✓ Added $directory to PATH"
        Write-Info "  You may need to restart your terminal for PATH changes to take effect"
    }
    catch {
        Write-Warning "Failed to update PATH: $_"
        Write-Info "Please manually add '$directory' to your PATH"
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

# Main installation
function Main {
    Write-Info "WP Staging CLI Installer for Windows"
    Write-Info "======================================"
    Write-Host ""

    # Detect platform
    Write-Info "Detecting platform..."
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
        Write-Info "Fetching latest version..."
        $manifestFile = Join-Path $tempDir "manifest.json"
        Download-File $ManifestUrl $manifestFile

        $manifest = Get-Content $manifestFile -Raw | ConvertFrom-Json
        $version = $manifest.version

        if (-not $version) {
            Exit-WithError "Failed to parse version from manifest"
        }

        Write-Success "✓ Latest version: $version"
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

        # Download binary
        $binaryUrl = "$RepoUrl/build/$platform/$BinaryName"
        $binaryFile = Join-Path $tempDir $BinaryName
        Download-File $binaryUrl $binaryFile

        Write-Success "✓ Downloaded binary"
        Write-Host ""

        # Verify checksum
        Verify-Checksum $binaryFile $checksum
        Write-Host ""

        # Create installation directory
        Write-Info "Installing wpstaging..."
        if (-not (Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        }

        # Install binary
        $targetPath = Join-Path $InstallDir $BinaryName
        Copy-Item $binaryFile $targetPath -Force

        Write-Success "✓ Installed binary to $targetPath"
        Write-Host ""

        # Add to PATH
        Write-Info "Updating PATH..."
        Add-ToPath $InstallDir
        Write-Host ""

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
        Write-Info "Usage:"
        Write-Info "  wpstaging add <mysite.com>"
        Write-Host ""
        Write-Info "Get started:"
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

# Run main function
Main
