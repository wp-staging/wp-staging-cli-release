@goto :WINDOWS 2>nul
echo ""
echo "======================================================================"
echo "ERROR: This installer is for Windows CMD only"
echo "======================================================================"
echo ""
echo "For Linux/macOS/WSL, please use:"
echo "  curl -fsSL https://wp-staging.com/install.sh | bash"
echo ""
echo "For Windows PowerShell, please use:"
echo "  irm https://wp-staging.com/install.ps1 | iex"
echo ""
echo "======================================================================"
echo ""
exit 1
:WINDOWS
@echo off
setlocal enabledelayedexpansion

REM WP Staging CLI Installer for Windows (CMD)
REM This script downloads and installs the wpstaging cli binary
REM
REM Usage:
REM   Install latest stable version (default):
REM     install.cmd
REM
REM   Install specific version:
REM     install.cmd -v 1.4.0-beta.1
REM
REM   Install with license key (for immediate use without prompts):
REM     install.cmd -l YOUR_LICENSE_KEY
REM
REM   Install specific version with license:
REM     install.cmd -v 1.4.0 -l YOUR_LICENSE_KEY
REM
REM Options:
REM   -v, --version VERSION    Install specific version (e.g., 1.4.0, 1.4.0-beta.1)
REM   -l, --license KEY        Register license key after installation
REM   -d, --bin-dir DIR        Install binary to custom directory
REM   -e, --extract DIR        Extract all files to directory (no installation)
REM   -a, --cli-args ARGS      Extra arguments passed to every wpstaging binary call
REM
REM Examples:
REM   install.cmd -v 1.4.0-beta.1           # Install version 1.4.0-beta.1
REM   install.cmd -v 1.3.5                  # Install version 1.3.5
REM   install.cmd                           # Install latest stable (no beta/alpha/rc)
REM   install.cmd -l abc123                 # Install latest with license
REM   install.cmd -v 1.4.0 -l abc123        # Install 1.4.0 with license
REM   install.cmd -d C:\mytools             # Install binary to C:\mytools
REM   install.cmd -e C:\tmp\wpstaging       # Extract all files without installing
REM   install.cmd -a "--debug"              # Install and pass --debug to binary calls

REM Generate ESC character for ANSI colors (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[96m"
set "NC=%ESC%[0m"

set GITHUB_API_URL=https://api.github.com/repos/wp-staging/wp-staging-cli-release
set GITHUB_RAW_URL=https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release
set BINARY_NAME=wpstaging.exe
set APP_NAME=wpstaging
set REQUESTED_VERSION=
set LICENSE_KEY=
set CUSTOM_BIN_DIR=
set EXTRACT_DIR=
set CLI_ARGS=
set SCRIPT_VERSION=20260513-091832

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_args
if "%~1"=="--print-version" goto :do_print_version
if "%~1"=="-V" goto :do_print_version
if "%~1"=="--license" (
    set LICENSE_KEY=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-l" (
    set LICENSE_KEY=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--version" (
    set REQUESTED_VERSION=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-v" (
    set REQUESTED_VERSION=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--bin-dir" (
    set CUSTOM_BIN_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-d" (
    set CUSTOM_BIN_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--extract" (
    set EXTRACT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-e" (
    set EXTRACT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--cli-args" (
    set CLI_ARGS=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-a" (
    set CLI_ARGS=%~2
    shift
    shift
    goto :parse_args
)
REM Unknown argument - show warning and skip
echo %YELLOW%Warning: Unknown argument: %~1%NC% >&2
shift
goto :parse_args
:done_args

REM Validate CLI_ARGS for unsafe CMD metacharacters to prevent command injection
if defined CLI_ARGS (
    set "CLI_ARGS_SAFE=1"
    for %%C in ("&" "|" ">" "<" "(" ")" "^" "!") do (
        echo(!CLI_ARGS!| findstr /C:%%C >nul 2>&1 && set "CLI_ARGS_SAFE="
    )
    if not defined CLI_ARGS_SAFE (
        echo %YELLOW%Warning: Unsafe characters detected in --cli-args value. Ignoring --cli-args for security.%NC%
        set "CLI_ARGS="
    )
)

REM Validate mutually exclusive flags
if defined CUSTOM_BIN_DIR if defined EXTRACT_DIR (
    echo %RED%Error: --bin-dir and --extract are mutually exclusive. Use one or the other.%NC%
    exit /b 1
)

echo %BLUE%WP Staging CLI - Installer%NC%
echo %BLUE%==============================%NC%
echo.

REM Determine version to install
if defined REQUESTED_VERSION (
    REM User specified a version
    echo %BLUE%Requested version: %REQUESTED_VERSION%%NC%
    set VERSION_REF=%REQUESTED_VERSION%
    if not "!VERSION_REF:~0,1!"=="v" set VERSION_REF=v!VERSION_REF!
) else (
    REM No version specified, fetch latest stable (no beta/alpha/rc)
    echo %BLUE%Fetching latest stable version...%NC%

    REM Fetch tags from GitHub API and filter out pre-release versions
    curl -fsSL "%GITHUB_API_URL%/tags" -o "%TEMP%\tags.json" >nul 2>&1
    if errorlevel 1 (
        echo %YELLOW%Warning: Failed to fetch tags from GitHub API, falling back to 'main'%NC%
        set VERSION_REF=main
    ) else (
        REM Use PowerShell to parse JSON and filter out beta/alpha/rc
        REM Note: Using (?i) for case-insensitive matching to avoid pipe escaping issues in CMD
        for /f "delims=" %%i in ('powershell -NoProfile -Command "$tags = Get-Content -Raw '%TEMP%\tags.json' | ConvertFrom-Json; $stableTags = @($tags | Where-Object { $_.name -notmatch '(?i)(beta|alpha|rc)' }); if ($stableTags.Count -gt 0) { $stableTags[0].name } else { 'main' }"') do set VERSION_REF=%%i
        del "%TEMP%\tags.json" >nul 2>&1

        REM Validate that we got a version
        if "!VERSION_REF!"=="" (
            echo %YELLOW%Warning: Failed to parse version from GitHub API, falling back to 'main'%NC%
            set VERSION_REF=main
        )
    )

    REM When the tags API is unreachable, resolve the latest stable version
    REM from main/manifest.json instead. main is rewritten on every release,
    REM so its manifest's version field is the canonical latest. Pinning to
    REM that tag also keeps the binary download URL reproducible. The
    REM v1.10.0/v1.11.0 refusal below still applies once we have a concrete
    REM tag. Issue #333.
    if "!VERSION_REF!"=="main" (
        curl -fsSL "%GITHUB_RAW_URL%/main/manifest.json" -o "%TEMP%\main-manifest.json" >nul 2>&1
        if errorlevel 1 (
            echo %RED%Error: Cannot determine the latest stable version. Please retry, or install a specific version explicitly with --version. See https://github.com/wp-staging/wp-staging-cli-release/tags for available versions.%NC%
            exit /b 1
        )
        set MAIN_VERSION=
        for /f "delims=" %%i in ('powershell -NoProfile -Command "$m = Get-Content -Raw '%TEMP%\main-manifest.json' | ConvertFrom-Json; if ($m.version) { $m.version } else { '' }"') do set MAIN_VERSION=%%i
        del "%TEMP%\main-manifest.json" >nul 2>&1
        if "!MAIN_VERSION!"=="" (
            echo %RED%Error: Cannot determine the latest stable version. Please retry, or install a specific version explicitly with --version. See https://github.com/wp-staging/wp-staging-cli-release/tags for available versions.%NC%
            exit /b 1
        )
        set VERSION_REF=!MAIN_VERSION!
        if not "!VERSION_REF:~0,1!"=="v" set VERSION_REF=v!VERSION_REF!
        echo %BLUE%Resolved latest stable from main manifest: !VERSION_REF!%NC%
    )
    echo %BLUE%Selected latest stable version: !VERSION_REF!%NC%
)

REM Refuse v1.10.0 and v1.11.0 regardless of how VERSION_REF was selected:
REM their dev-version check misclassifies the release tag as a dev build
REM (issue #328), so the installed binary cannot self-update again. The
REM check covers the latest-stable path in case those tags ever resurface
REM as "latest" (e.g. v1.11.1 yanked).
set "STUCK_VERSION="
if /i "!VERSION_REF!"=="v1.10.0" set "STUCK_VERSION=1"
if /i "!VERSION_REF!"=="v1.11.0" set "STUCK_VERSION=1"
if defined STUCK_VERSION (
    echo %RED%Error: Refusing to install !VERSION_REF!: this version cannot self-update due to a known bug. Pick v1.11.1 or later.%NC%
    exit /b 1
)

REM Validate the requested version exists (latest-stable is valid by definition)
if defined REQUESTED_VERSION (
    echo %BLUE%Validating version !VERSION_REF!...%NC%
    curl -fsSL -o nul -w "%%{http_code}" "%GITHUB_RAW_URL%/!VERSION_REF!/manifest.json" > "%TEMP%\http_code.txt" 2>nul
    set /p HTTP_CODE=<"%TEMP%\http_code.txt"
    del "%TEMP%\http_code.txt" >nul 2>&1

    if not "!HTTP_CODE!"=="200" (
        echo %RED%Error: Version '!VERSION_REF!' not found in release repository.%NC%
        echo.
        echo   Please check available versions at:
        echo   https://github.com/wp-staging/wp-staging-cli-release/tags
        echo.
        echo   Or install the latest stable version by omitting the version argument.
        echo.
        exit /b 1
    )
    echo %GREEN%Version !VERSION_REF! exists%NC%
)

echo.

REM Build URLs based on version
set REPO_URL=%GITHUB_RAW_URL%/!VERSION_REF!

REM Detect architecture
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set PLATFORM=windows_amd64
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set PLATFORM=windows_386
) else (
    echo %RED%Error: Unsupported architecture: %PROCESSOR_ARCHITECTURE%%NC%
    exit /b 1
)

echo %BLUE%Detected platform: %PLATFORM%%NC%
echo.

REM Create temp directory
set TEMP_DIR=%TEMP%\wp-staging-cli-install
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Download manifest.json
echo %BLUE%Downloading manifest...%NC%
curl -fsSL "!REPO_URL!/manifest.json" -o "%TEMP_DIR%\manifest.json" >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Failed to download manifest.json%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

REM Parse manifest using PowerShell
echo %BLUE%Parsing manifest...%NC%
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%TEMP_DIR%\manifest.json' | ConvertFrom-Json).version"') do set VERSION=%%i
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%TEMP_DIR%\manifest.json' | ConvertFrom-Json).platforms.'%PLATFORM%'.checksum"') do set CHECKSUM=%%i
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%TEMP_DIR%\manifest.json' | ConvertFrom-Json).platforms.'%PLATFORM%'.binary"') do set BINARY_PATH=%%i

if "%VERSION%"=="" (
    echo %RED%Error: Failed to parse version from manifest%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

if "%CHECKSUM%"=="" (
    echo %RED%Error: No checksum found for platform: %PLATFORM%%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

if "%BINARY_PATH%"=="" (
    echo %RED%Error: No binary path found for platform: %PLATFORM%%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

echo %GREEN%Version: %VERSION%%NC%
echo.

REM Download binary using path from manifest
set BINARY_URL=!REPO_URL!/build/%BINARY_PATH%
echo %BLUE%Downloading binary...%NC%
curl -fsSL "!BINARY_URL!" -o "%TEMP_DIR%\%BINARY_NAME%" >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Failed to download binary%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)
echo %GREEN%Downloaded binary%NC%
echo.

REM Verify checksum
echo %BLUE%Verifying checksum...%NC%
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-FileHash '%TEMP_DIR%\%BINARY_NAME%' -Algorithm SHA256).Hash.ToLower()"') do set ACTUAL_CHECKSUM=%%i

if /i not "%ACTUAL_CHECKSUM%"=="%CHECKSUM%" (
    echo %RED%Error: Checksum mismatch!%NC%
    echo %RED%Expected: %CHECKSUM%%NC%
    echo %RED%Actual:   %ACTUAL_CHECKSUM%%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)
echo %GREEN%Checksum verified%NC%
echo.

REM ── Extract mode ────────────────────────────────────────────────────
REM Copy downloaded binary to the given directory and exit early.
if not defined EXTRACT_DIR goto :skip_extract_mode

if not exist "!EXTRACT_DIR!" (
    mkdir "!EXTRACT_DIR!"
    if errorlevel 1 (
        echo %RED%Error: Cannot create directory: !EXTRACT_DIR!%NC%
        rmdir /s /q "%TEMP_DIR%"
        exit /b 1
    )
)
copy /y "%TEMP_DIR%\%BINARY_NAME%" "!EXTRACT_DIR!\%BINARY_NAME%" >nul
if errorlevel 1 (
    echo %RED%Error: Failed to copy binary to !EXTRACT_DIR!%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)
echo.
echo %GREEN%Files extracted to !EXTRACT_DIR!:%NC%
dir /b "!EXTRACT_DIR!"
echo.
echo %BLUE%To install manually, copy the binary to a directory in your PATH.%NC%
echo.
rmdir /s /q "%TEMP_DIR%"
goto :eof

:skip_extract_mode

REM Determine installation directory
REM Prefer existing installation, then directories already in PATH
set INSTALL_DIR=
set ALREADY_IN_PATH=0

REM ── Custom bin-dir mode ────────────────────────────────────────────
if defined CUSTOM_BIN_DIR (
    set INSTALL_DIR=!CUSTOM_BIN_DIR!
    REM Use semicolon-delimited matching to avoid false positives (e.g., C:\Tools vs C:\Tools2)
    echo ;!PATH!; | findstr /i /c:";!CUSTOM_BIN_DIR!;" >nul
    if not errorlevel 1 (
        set ALREADY_IN_PATH=1
    ) else (
        set ALREADY_IN_PATH=0
    )
    goto :install_dir_chosen
)

REM First, check if wpstaging is already installed somewhere
where %BINARY_NAME% >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%i in ('where %BINARY_NAME%') do (
        for %%p in ("%%~dpi.") do set EXISTING_DIR=%%~fp
        goto :check_existing_dir
    )
)
goto :check_candidates

:check_existing_dir
REM Found existing installation, use that directory
echo %BLUE%Found existing installation at !EXISTING_DIR! ^(will update^)%NC%
set INSTALL_DIR=!EXISTING_DIR!
set ALREADY_IN_PATH=1
goto :install_dir_chosen

:check_candidates
REM Check candidates in order of preference
REM 1) Check %LOCALAPPDATA%\Programs\wpstaging (our default)
echo %PATH% | findstr /i /c:"%LOCALAPPDATA%\Programs\%APP_NAME%" >nul
if not errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\%APP_NAME%" (
        set INSTALL_DIR=%LOCALAPPDATA%\Programs\%APP_NAME%
        set ALREADY_IN_PATH=1
        goto :install_dir_chosen
    )
)

REM 2) Check %LOCALAPPDATA%\Microsoft\WindowsApps (often in PATH by default)
echo %PATH% | findstr /i /c:"%LOCALAPPDATA%\Microsoft\WindowsApps" >nul
if not errorlevel 1 (
    if exist "%LOCALAPPDATA%\Microsoft\WindowsApps" (
        set INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps
        set ALREADY_IN_PATH=1
        goto :install_dir_chosen
    )
)

REM 3) Check %USERPROFILE%\bin
echo %PATH% | findstr /i /c:"%USERPROFILE%\bin" >nul
if not errorlevel 1 (
    if exist "%USERPROFILE%\bin" (
        set INSTALL_DIR=%USERPROFILE%\bin
        set ALREADY_IN_PATH=1
        goto :install_dir_chosen
    )
)

REM 4) Fallback to default directory (will need PATH update)
set INSTALL_DIR=%LOCALAPPDATA%\Programs\%APP_NAME%
set ALREADY_IN_PATH=0

:install_dir_chosen
if "!ALREADY_IN_PATH!"=="1" (
    echo %BLUE%Installing to: !INSTALL_DIR! ^(already in PATH - works immediately^)%NC%
) else (
    echo %BLUE%Installing to: !INSTALL_DIR! ^(will add to PATH^)%NC%
)

REM Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Capture the existing binary's version BEFORE we overwrite it, so the
REM post-install notice can flag a recovery from the v1.10.0/v1.11.0
REM stuck-updater bug (issue #328).
set EXISTING_OLD_VERSION=
if exist "!INSTALL_DIR!\!BINARY_NAME!" (
    for /f "tokens=3" %%v in ('"!INSTALL_DIR!\!BINARY_NAME!" --version 2^>nul ^| findstr /b /c:"wpstaging version"') do if not defined EXISTING_OLD_VERSION set EXISTING_OLD_VERSION=%%v
)

REM Copy binary
copy /y "%TEMP_DIR%\%BINARY_NAME%" "%INSTALL_DIR%\%BINARY_NAME%" >nul
if errorlevel 1 (
    echo %RED%Error: Failed to copy binary to installation directory%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

echo %GREEN%Binary installed successfully%NC%
echo.

REM Create aliases (wpstg and wp-staging)
echo %BLUE%Creating aliases...%NC%

REM Check if we're in WindowsApps - need to copy exe, otherwise create .cmd wrappers
echo !INSTALL_DIR! | findstr /i /c:"WindowsApps" >nul
if not errorlevel 1 (
    REM WindowsApps directory - copy binary as aliases
    copy /y "!INSTALL_DIR!\!BINARY_NAME!" "!INSTALL_DIR!\wpstg.exe" >nul 2>&1
    copy /y "!INSTALL_DIR!\!BINARY_NAME!" "!INSTALL_DIR!\wp-staging.exe" >nul 2>&1
) else (
    REM Regular directory - create .cmd wrapper scripts
    echo @"%%~dp0!BINARY_NAME!" %%*> "!INSTALL_DIR!\wpstg.cmd"
    echo @"%%~dp0!BINARY_NAME!" %%*> "!INSTALL_DIR!\wp-staging.cmd"
)
echo %GREEN%Aliases created: wpstg, wp-staging%NC%
echo.

REM Add to PATH if not already present
if "!ALREADY_IN_PATH!"=="0" (
    echo %BLUE%Updating PATH...%NC%
    REM Use PowerShell to properly update only the user PATH
    REM This avoids the setx 1024 character limit and prevents mixing system+user PATH
    powershell -NoProfile -Command "$installDir = '!INSTALL_DIR!'; $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ([string]::IsNullOrEmpty($userPath)) { $userPath = '' }; if ($userPath -notlike \"*$installDir*\") { $newPath = if ($userPath) { $userPath + ';' + $installDir } else { $installDir }; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User') }"
    if errorlevel 1 (
        echo %YELLOW%Warning: Failed to update PATH automatically%NC%
        echo %YELLOW%Please add this directory to your PATH manually: !INSTALL_DIR!%NC%
    ) else (
        echo %GREEN%PATH updated successfully%NC%
        echo %YELLOW%Note: Restart your command prompt for PATH changes to take effect%NC%
    )
) else (
    echo %GREEN%Installation directory already in PATH%NC%
)

echo.

REM Register license key if provided
set "LICENSE_REGISTERED=0"
if not defined LICENSE_KEY goto :skip_license_registration

echo %BLUE%Registering license key...%NC%

REM Check if binary exists
if not exist "%INSTALL_DIR%\%BINARY_NAME%" (
    echo %YELLOW%Warning: Binary not found. Cannot register license%NC%
    echo %YELLOW%You can register later with: wpstaging register%NC%
    goto :license_done
)

REM Set environment variable temporarily for this command to avoid exposure in process list
set "WPSTGPRO_LICENSE=!LICENSE_KEY!"
"%INSTALL_DIR%\%BINARY_NAME%" register !CLI_ARGS! 2>&1
if errorlevel 1 (
    echo %YELLOW%Warning: License registration failed%NC%
    echo %YELLOW%You can register later with: wpstaging register%NC%
) else (
    echo %GREEN%License registered successfully%NC%
    set "LICENSE_REGISTERED=1"
)
REM Clear the temporary variable
set "WPSTGPRO_LICENSE="

:license_done
echo.

:skip_license_registration

REM Cleanup
rmdir /s /q "%TEMP_DIR%"

REM Verify installation
echo.
echo %BLUE%Verifying installation...%NC%
set INSTALLED_VERSION=
for /f "delims=" %%v in ('"!INSTALL_DIR!\!BINARY_NAME!" --version !CLI_ARGS! 2^>^&1') do set INSTALLED_VERSION=%%v
if not defined INSTALLED_VERSION (
    echo %YELLOW%Warning: Could not verify installed binary%NC%
) else (
    echo %GREEN%[OK] Installation successful!%NC%
)

REM Check for other installations
set OTHER_INSTALLS=
REM Normalize INSTALL_DIR to have trailing backslash for comparison
set NORM_INSTALL_DIR=!INSTALL_DIR!
if not "!NORM_INSTALL_DIR:~-1!"=="\" set NORM_INSTALL_DIR=!NORM_INSTALL_DIR!\
for /f "tokens=* delims=" %%p in ('where !BINARY_NAME! 2^>nul') do (
    if /i not "%%~dpp"=="!NORM_INSTALL_DIR!" (
        if not defined OTHER_INSTALLS (
            set OTHER_INSTALLS=1
            echo.
            echo %YELLOW%Warning: Other wpstaging installations found:%NC%
        )
        echo   - %%p
    )
)
if defined OTHER_INSTALLS (
    echo %YELLOW%These may take precedence over the newly installed version.%NC%
    echo %BLUE%Consider removing old installations or adjusting your PATH order.%NC%
)

REM Recovery notice for the v1.10.0/v1.11.0 stuck-updater bug (#328).
REM Those releases skipped their own update check, so users had to rerun this
REM installer to upgrade. Confirm the rerun fixed it.
if /i "!EXISTING_OLD_VERSION!"=="v1.10.0" goto :stuck_updater_notice
if /i "!EXISTING_OLD_VERSION!"=="v1.11.0" goto :stuck_updater_notice
goto :end_stuck_check
:stuck_updater_notice
echo.
echo %BLUE%Note: this reinstall fixes the stuck-updater bug present in !EXISTING_OLD_VERSION!.%NC%
echo %BLUE%      'wpstaging update' will work normally from this version onwards.%NC%
:end_stuck_check

REM Success message
echo.
echo %GREEN%==============================%NC%
echo %GREEN%   Installation Complete!%NC%
echo %GREEN%==============================%NC%
echo.
echo %BLUE%Installed: !INSTALLED_VERSION!%NC%
echo %BLUE%Location:  !INSTALL_DIR!\!BINARY_NAME!%NC%
echo.

REM Determine which command example to show
REM Use goto to avoid nested if-else parsing issues in CMD
if "!ALREADY_IN_PATH!"=="1" goto :show_immediate_cmd
goto :show_full_path_cmd

:show_immediate_cmd
REM Directory was already in PATH - works immediately
echo %BLUE%Run wpstaging now:%NC%
if not defined LICENSE_KEY goto :show_immediate_simple
if "!LICENSE_REGISTERED!"=="0" goto :show_immediate_with_license
REM License was just registered, no need to include it in the command
echo   !APP_NAME! add mysite.local
goto :show_help

:show_immediate_with_license
REM License registration failed, include it so user can try again
echo   !APP_NAME! add mysite.local --license !LICENSE_KEY!
echo.
echo %BLUE%Note: The license key is only needed once to activate WP Staging CLI.%NC%
echo       After activation, you can use wpstaging without the --license flag.
goto :show_help

:show_immediate_simple
echo   !APP_NAME! add mysite.local
goto :show_help

:show_full_path_cmd
REM Directory was added to PATH - needs restart
echo %BLUE%Run wpstaging immediately ^(copy and paste^):%NC%
if not defined LICENSE_KEY goto :show_full_path_simple
if "!LICENSE_REGISTERED!"=="0" goto :show_full_path_with_license
REM License was just registered, no need to include it in the command
echo   !INSTALL_DIR!\!BINARY_NAME! add mysite.local
goto :show_restart_note

:show_full_path_with_license
REM License registration failed, include it so user can try again
echo   !INSTALL_DIR!\!BINARY_NAME! add mysite.local --license !LICENSE_KEY!
echo.
echo %BLUE%Note: The license key is only needed once to activate WP Staging CLI.%NC%
echo       After activation, you can use wpstaging without the --license flag.
goto :show_restart_note

:show_full_path_simple
echo   !INSTALL_DIR!\!BINARY_NAME! add mysite.local
goto :show_restart_note

:show_restart_note
echo.
echo %YELLOW%Or restart your command prompt, then use:%NC%
echo   !APP_NAME! add mysite.local

:show_help
echo.
echo %BLUE%Get help:%NC%
echo   !APP_NAME! --help
echo.
echo %BLUE%Documentation:%NC%
echo   https://github.com/wp-staging/wp-staging-cli-release
echo.

endlocal
exit /b 0

REM Print installer build and latest release, then exit. Used as a release
REM smoke test instead of installing. Reachable only via goto from :parse_args
REM so that the script never falls into it during a normal install run.
:do_print_version
echo wpstaging installer
echo   build:          %SCRIPT_VERSION%
curl -fsSL "%GITHUB_API_URL%/tags" -o "%TEMP%\pv_tags.json" >nul 2>&1
if errorlevel 1 (
    echo   latest release: unknown ^(could not fetch from GitHub^)
    endlocal
    exit /b 0
)
set "PV_LATEST="
for /f "delims=" %%i in ('powershell -NoProfile -Command "$tags = Get-Content -Raw '%TEMP%\pv_tags.json' | ConvertFrom-Json; $stable = @($tags | Where-Object { $_.name -notmatch '(?i)(beta|alpha|rc)' }); if ($stable.Count -gt 0) { $stable[0].name } else { '' }"') do set "PV_LATEST=%%i"
del "%TEMP%\pv_tags.json" >nul 2>&1
if defined PV_LATEST (
    echo   latest release: !PV_LATEST!
) else (
    echo   latest release: unknown
)
endlocal
exit /b 0
