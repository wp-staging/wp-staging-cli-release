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
REM
REM Examples:
REM   install.cmd -v 1.4.0-beta.1           # Install version 1.4.0-beta.1
REM   install.cmd -v 1.3.5                  # Install version 1.3.5
REM   install.cmd                           # Install latest stable (no beta/alpha/rc)
REM   install.cmd -l abc123                 # Install latest with license
REM   install.cmd -v 1.4.0 -l abc123        # Install 1.4.0 with license

set GITHUB_API_URL=https://api.github.com/repos/wp-staging/wp-staging-cli-release
set GITHUB_RAW_URL=https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release
set BINARY_NAME=wpstaging.exe
set APP_NAME=wpstaging
set REQUESTED_VERSION=
set LICENSE_KEY=

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_args
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
REM Unknown argument - show warning and skip
echo %YELLOW%Warning: Unknown argument: %~1%NC% >&2
shift
goto :parse_args
:done_args

REM Generate ESC character for ANSI colors (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[96m"
set "NC=%ESC%[0m"

echo %BLUE%WP Staging CLI - Installer%NC%
echo %BLUE%==============================%NC%
echo.

REM Determine version to install
if defined REQUESTED_VERSION (
    REM User specified a version
    echo %BLUE%Requested version: %REQUESTED_VERSION%%NC%
    set VERSION_REF=%REQUESTED_VERSION%

    REM Validate version exists
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
        for /f "delims=" %%i in ('powershell -NoProfile -Command "$tags = Get-Content '%TEMP%\tags.json' | ConvertFrom-Json; $stableTags = $tags ^| Where-Object { $_.name -notmatch 'beta^|alpha^|rc^|Beta^|Alpha^|RC' }; if ($stableTags) { $stableTags[0].name } else { 'main' }"') do set VERSION_REF=%%i
        del "%TEMP%\tags.json" >nul 2>&1
    )

    if "!VERSION_REF!"=="main" (
        echo %BLUE%Using branch: main%NC%
    ) else (
        echo %BLUE%Selected latest stable version: !VERSION_REF!%NC%
    )
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

REM Determine installation directory
REM Prefer directories already in PATH to avoid needing terminal restart
set INSTALL_DIR=
set ALREADY_IN_PATH=0

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
if %ALREADY_IN_PATH%==1 (
    echo %BLUE%Installing to: %INSTALL_DIR% (already in PATH - works immediately)%NC%
) else (
    echo %BLUE%Installing to: %INSTALL_DIR% (will add to PATH)%NC%
)

REM Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy binary
copy /y "%TEMP_DIR%\%BINARY_NAME%" "%INSTALL_DIR%\%BINARY_NAME%" >nul
if errorlevel 1 (
    echo %RED%Error: Failed to copy binary to installation directory%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

echo %GREEN%Binary installed successfully%NC%
echo.

REM Add to PATH if not already present
if %ALREADY_IN_PATH%==0 (
    echo %BLUE%Updating PATH...%NC%
    setx PATH "%PATH%;%INSTALL_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo %YELLOW%Warning: Failed to update PATH automatically%NC%
        echo %YELLOW%Please add this directory to your PATH manually: %INSTALL_DIR%%NC%
    ) else (
        echo %GREEN%PATH updated successfully%NC%
        echo %YELLOW%Note: Restart your command prompt for PATH changes to take effect%NC%
    )
) else (
    echo %GREEN%Installation directory already in PATH%NC%
)

echo.

REM Register license key if provided
if defined LICENSE_KEY (
    echo %BLUE%Registering license key...%NC%

    REM Check if binary exists
    if not exist "%INSTALL_DIR%\%BINARY_NAME%" (
        echo %YELLOW%Warning: Binary not found. Cannot register license%NC%
        echo %YELLOW%You can register later with: wpstaging register%NC%
    ) else (
        REM Set environment variable temporarily for this command to avoid exposure in process list
        set "WPSTGPRO_LICENSE=!LICENSE_KEY!"
        "%INSTALL_DIR%\%BINARY_NAME%" register 2>&1
        if errorlevel 1 (
            echo %YELLOW%Warning: License registration failed%NC%
            echo %YELLOW%You can register later with: wpstaging register%NC%
        ) else (
            echo %GREEN%License registered successfully%NC%
        )
        REM Clear the temporary variable
        set "WPSTGPRO_LICENSE="
    )
    echo.
)

REM Cleanup
rmdir /s /q "%TEMP_DIR%"

REM Success message
echo.
echo %GREEN%==============================%NC%
echo %GREEN%   Installation Complete!%NC%
echo %GREEN%==============================%NC%
echo.
echo %BLUE%Installed: wpstaging v%VERSION%%NC%
echo %BLUE%Location:  %INSTALL_DIR%\%BINARY_NAME%%NC%
echo.
if %ALREADY_IN_PATH%==1 (
    REM Directory was already in PATH - works immediately
    echo %BLUE%Run wpstaging now:%NC%
    if defined LICENSE_KEY (
        echo   %APP_NAME% add mysite.local --license !LICENSE_KEY!
        echo.
        echo %BLUE%Note: The license key is only needed once to activate WP Staging CLI.%NC%
        echo       After activation, you can use wpstaging without the --license flag.
    ) else (
        echo   %APP_NAME% add mysite.local
    )
) else (
    REM Directory was added to PATH - needs restart
    echo %BLUE%Run wpstaging immediately (copy ^& paste):%NC%
    if defined LICENSE_KEY (
        echo   %INSTALL_DIR%\%BINARY_NAME% add mysite.local --license !LICENSE_KEY!
        echo.
        echo %BLUE%Note: The license key is only needed once to activate WP Staging CLI.%NC%
        echo       After activation, you can use wpstaging without the --license flag.
    ) else (
        echo   %INSTALL_DIR%\%BINARY_NAME% add mysite.local
    )
    echo.
    echo %YELLOW%Or restart your command prompt, then use:%NC%
    echo   %APP_NAME% add mysite.local
)
echo.
echo %BLUE%Get help:%NC%
echo   %APP_NAME% --help
echo.
echo %BLUE%Documentation:%NC%
echo   https://github.com/wp-staging/wp-staging-cli-release
echo.

endlocal
