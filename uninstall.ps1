# WP Staging CLI Uninstaller for Windows (PowerShell)
# Build: 20260417-120000
# This script uninstalls wpstaging from Windows
#
# Download and run directly from the web (recommended):
#   irm https://wp-staging.com/uninstall.ps1 | iex
#
# Or download first, then run:
#   Invoke-WebRequest -Uri "https://wp-staging.com/uninstall.ps1" -OutFile "uninstall.ps1"
#   .\uninstall.ps1
#
# Or run locally if already downloaded:
#   .\uninstall.ps1

$ErrorActionPreference = "Stop"

# Configuration
$BinaryName = "wpstaging.exe"
# All candidate directories that the installer may use
$InstallCandidates = @(
    "$env:LOCALAPPDATA\Programs\wpstaging",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps",
    "$env:USERPROFILE\bin",
    "$env:USERPROFILE\.local\bin"
)

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

# Verify that a binary is actually WP Staging CLI
function Test-WpStagingBinary($binaryPath) {
    try {
        # Temporarily allow non-zero exit codes so native stderr does not throw
        $prevPref = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $output = & $binaryPath --version 2>&1
        $ErrorActionPreference = $prevPref

        $text = ($output | Out-String)
        if ($text -match "wpstaging|wp[-. ]staging") {
            return $true
        }
    }
    catch {
        # Binary failed to execute
        $ErrorActionPreference = $prevPref
    }
    return $false
}

# Remove binaries and aliases
function Remove-Binaries($directory) {
    if (-not (Test-Path $directory)) {
        return $false
    }

    # Include both .cmd aliases (regular dirs) and .exe aliases (WindowsApps)
    $files = @($BinaryName, "wpstg.cmd", "wp-staging.cmd", "wpstg.exe", "wp-staging.exe")
    $removed = $false

    foreach ($file in $files) {
        $path = Join-Path $directory $file
        if (Test-Path $path) {
            try {
                Remove-Item $path -Force
                $removed = $true
            }
            catch {
                Write-Warning "Failed to remove $path : $_"
            }
        }
    }

    if ($removed) {
        Write-Success "✓ Removed binaries from $directory"
    }

    # Remove directory if empty
    if ((Test-Path $directory) -and ((Get-ChildItem $directory | Measure-Object).Count -eq 0)) {
        try {
            Remove-Item $directory -Force
            Write-Success "✓ Removed empty directory: $directory"
        }
        catch {
            Write-Warning "Failed to remove directory $directory : $_"
        }
    }

    return $removed
}

# Remove from PATH
function Remove-FromPath($directory) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if (-not $currentPath) {
        return $false
    }

    $pathDirs = $currentPath.Split(';') | Where-Object { $_ -ne $directory -and $_ -ne "" }
    $newPath = $pathDirs -join ';'

    if ($newPath -ne $currentPath) {
        try {
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-Success "✓ Removed $directory from PATH"
            return $true
        }
        catch {
            Write-Warning "Failed to update PATH: $_"
            return $false
        }
    }

    return $false
}

# Remove license key environment variable
function Remove-LicenseFromEnv {
    $license = [Environment]::GetEnvironmentVariable("WPSTGPRO_LICENSE", "User")

    if ($license) {
        try {
            [Environment]::SetEnvironmentVariable("WPSTGPRO_LICENSE", $null, "User")
            Write-Success "✓ Removed WPSTGPRO_LICENSE environment variable"
            return $true
        }
        catch {
            Write-Warning "Failed to remove license environment variable: $_"
            return $false
        }
    }

    return $false
}

# Remove cache and working directories
function Remove-Cache {
    $cacheDirs = @(
        "$env:LOCALAPPDATA\wpstaging",
        "$env:APPDATA\wpstaging",                # Windows default working directory
        "$env:USERPROFILE\.wpstaging"
    )

    foreach ($cacheDir in $cacheDirs) {
        if (Test-Path $cacheDir) {
            try {
                Remove-Item $cacheDir -Recurse -Force
                Write-Success "✓ Removed directory: $cacheDir"
            }
            catch {
                Write-Warning "Failed to remove directory $cacheDir : $_"
            }
        }
    }
}

# Check for existing dockerized sites and offer cleanup
function Check-AndCleanupSites {
    $wpstaging = Get-Command wpstaging -ErrorAction SilentlyContinue
    if (-not $wpstaging) {
        Write-Info "wpstaging binary not found, skipping site check"
        return
    }

    Write-Info "Checking for existing dockerized sites..."
    Write-Host ""

    try {
        $siteOutput = & wpstaging list 2>$null

        # Check if there are any sites (look for "Host" followed by optional spaces and colon)
        if ($siteOutput -match "Host\s*:") {
            $siteOutput | ForEach-Object { Write-Host $_ }
            Write-Host ""
            Write-Warning "The above sites will remain on disk unless you delete them."

            # WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1",
            # auto-answer "No" to preserve user data. Used by CI only.
            if ($env:WPSTG_UNINSTALL_ASSUME_YES -eq "1") {
                $deleteSites = "n"
                Write-Info "Sites will be preserved (WPSTG_UNINSTALL_ASSUME_YES set)"
            } else {
                $deleteSites = Read-Host "Do you want to delete all sites and their Docker data? [y/N]"
            }

            if ($deleteSites -match '^[Yy]') {
                Write-Info "Stopping all containers first..."
                try {
                    & wpstaging stop 2>$null | Out-Null
                } catch {
                    # Ignore errors - stop may fail if no containers running
                }
                $global:LASTEXITCODE = 0

                Write-Info "Running wpstaging remove to remove all sites..."
                try {
                    $removeOutput = & wpstaging remove --yes 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Warning "Site cleanup may have encountered errors. Some files may remain."
                        if ($removeOutput) {
                            Write-Info "Details: $removeOutput"
                        }
                    } else {
                        Write-Success "✓ Sites and Docker data removed"
                    }
                } catch {
                    Write-Warning "Site removal encountered an error: $_"
                }
                $global:LASTEXITCODE = 0
            } else {
                Write-Info "Sites will be preserved on disk"
            }
        } else {
            Write-Info "No dockerized sites found"
        }
    } catch {
        Write-Info "Could not check for sites"
    }
    Write-Host ""
}

# Main uninstallation
function Main {
    Write-Info "WP Staging CLI Uninstaller for Windows"
    Write-Info "======================================="
    Write-Host ""

    # Check if wpstaging is installed in any candidate directory
    $found = $false
    $foundDirs = @()

    foreach ($dir in $InstallCandidates) {
        $binaryPath = Join-Path $dir $BinaryName
        if (Test-Path $binaryPath) {
            if (Test-WpStagingBinary $binaryPath) {
                $found = $true
                $foundDirs += $dir
                Write-Info "Found installation in: $dir"
            }
            else {
                Write-Warning "Binary at $binaryPath is not WP Staging CLI, skipping"
            }
        }
    }

    if (-not $found) {
        try {
            $wpstaging = Get-Command wpstaging -ErrorAction SilentlyContinue
            if ($wpstaging) {
                if (Test-WpStagingBinary $wpstaging.Source) {
                    Write-Info "Found wpstaging at: $($wpstaging.Source)"
                    $found = $true
                    $foundDirs += Split-Path $wpstaging.Source -Parent
                }
                else {
                    Write-Warning "Binary at $($wpstaging.Source) is not WP Staging CLI, skipping"
                }
            }
        }
        catch {
            # Command not found
        }
    }

    if (-not $found) {
        Write-Warning "WP Staging CLI does not appear to be installed"
        Write-Info "Checking for leftover configuration..."
    }

    Write-Host ""

    # Confirm uninstallation
    Write-Info "This will remove:"
    Write-Info "  - wpstaging binary and aliases"
    Write-Info "  - PATH entry"
    Write-Info "  - License key environment variable"
    Write-Info "  - Cache and working directories"
    Write-Host ""

    # WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1", skip this
    # confirmation. Used by CI to test the documented `irm | iex` form.
    if ($env:WPSTG_UNINSTALL_ASSUME_YES -eq "1") {
        $confirm = "y"
        Write-Info "Proceeding (WPSTG_UNINSTALL_ASSUME_YES set)"
    } else {
        $confirm = Read-Host "Are you sure you want to uninstall WP Staging CLI? [y/N]"
    }

    if ($confirm -notmatch '^[Yy]') {
        Write-Info "Uninstallation cancelled"
        return
    }

    Write-Host ""

    # Check for existing dockerized sites and offer cleanup
    Check-AndCleanupSites

    # Stop any running wpstaging containers (fallback for containers not in site list)
    Write-Info "Stopping any running wpstaging containers..."
    try {
        $wpstaging = Get-Command wpstaging -ErrorAction SilentlyContinue
        if ($wpstaging) {
            # Ignore exit code - stop may fail if no license or no containers running
            & wpstaging stop 2>$null | Out-Null
            # Reset exit code to prevent script failure
            $global:LASTEXITCODE = 0
            Write-Success "✓ Stopped wpstaging containers (if any were running)"
        } else {
            Write-Info "wpstaging binary not found, skipping container stop"
        }
    } catch {
        Write-Info "No containers to stop or wpstaging not available"
    }

    Write-Host ""

    # Deactivate license on server before removing binary
    $wpstaging = Get-Command wpstaging -ErrorAction SilentlyContinue
    if ($wpstaging) {
        try {
            $null = & wpstaging deactivate --yes 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✓ License deactivated"
            }
            $global:LASTEXITCODE = 0
        } catch {
            # Silently ignore errors
        }
    }

    Write-Host ""

    # Remove binaries only from verified directories. Iterating all candidates
    # here would delete an unrelated wpstaging.exe in a candidate dir, defeating
    # the Test-WpStagingBinary verification above.
    Write-Info "Removing binaries..."
    foreach ($dir in $foundDirs) {
        Remove-Binaries $dir | Out-Null
    }

    Write-Host ""

    # Remove from PATH (all candidate directories)
    Write-Info "Removing from PATH..."
    $anyPathRemoved = $false
    foreach ($dir in $InstallCandidates) {
        if (Remove-FromPath $dir) {
            $anyPathRemoved = $true
        }
    }

    if (-not $anyPathRemoved) {
        Write-Info "No installation directories were in PATH"
    }

    Write-Host ""

    # Remove license key
    Write-Info "Removing license key..."
    $licenseRemoved = Remove-LicenseFromEnv

    if (-not $licenseRemoved) {
        Write-Info "No license key environment variable found"
    }

    Write-Host ""

    # Remove cache
    Write-Info "Removing cache and working directories..."
    Remove-Cache

    Write-Host ""

    # Summary
    Write-Success "======================================"
    Write-Success "   Uninstallation Complete!"
    Write-Success "======================================"
    Write-Host ""

    Write-Info "WP Staging CLI has been removed from your system."
    Write-Host ""

    Write-Warning "Note: You may need to restart your terminal or PowerShell session"
    Write-Warning "for changes to take effect."
    Write-Host ""
}

# Run main function
Main
