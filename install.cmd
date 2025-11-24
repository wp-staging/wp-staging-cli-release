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
REM This script downloads and installs the wp-staging-cli binary

set REPO_URL=https://raw.githubusercontent.com/wp-staging/wp-staging-cli-release/main
set BINARY_NAME=wp-staging-cli.exe
set APP_NAME=wp-staging-cli

REM Colors (using escape sequences - works on Windows 10+)
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[96m
set NC=[0m

echo %BLUE%WP Staging CLI - Installer%NC%
echo %BLUE%==============================%NC%
echo.

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
curl -fsSL "%REPO_URL%/manifest.json" -o "%TEMP_DIR%\manifest.json" >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Failed to download manifest.json%NC%
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

REM Parse manifest using PowerShell
echo %BLUE%Parsing manifest...%NC%
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%TEMP_DIR%\manifest.json' | ConvertFrom-Json).version"') do set VERSION=%%i
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%TEMP_DIR%\manifest.json' | ConvertFrom-Json).platforms.'%PLATFORM%'.checksum"') do set CHECKSUM=%%i

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

echo %GREEN%Version: %VERSION%%NC%
echo.

REM Download binary
set BINARY_URL=%REPO_URL%/build/%PLATFORM%/%BINARY_NAME%
echo %BLUE%Downloading binary...%NC%
curl -fsSL "%BINARY_URL%" -o "%TEMP_DIR%\%BINARY_NAME%" >nul 2>&1
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
set INSTALL_DIR=%LOCALAPPDATA%\Programs\%APP_NAME%

echo %BLUE%Installing to: %INSTALL_DIR%%NC%

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
echo %BLUE%Updating PATH...%NC%

REM Check if directory is already in PATH
echo %PATH% | findstr /i /c:"%INSTALL_DIR%" >nul
if errorlevel 1 (
    REM Not in PATH, add it
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

REM Cleanup
rmdir /s /q "%TEMP_DIR%"

REM Success message
echo.
echo %GREEN%==============================%NC%
echo %GREEN%   Installation Complete!%NC%
echo %GREEN%==============================%NC%
echo.
echo %BLUE%Installed: wp-staging-cli v%VERSION%%NC%
echo %BLUE%Location:  %INSTALL_DIR%\%BINARY_NAME%%NC%
echo.
echo %YELLOW%Important:%NC%
echo   1. Restart your command prompt to use the updated PATH
echo   2. Run '%APP_NAME% --version' to verify installation
echo.
echo %BLUE%Usage:%NC%
echo   %APP_NAME% add ^<mysite.com^>
echo.
echo %BLUE%Get started:%NC%
echo   %APP_NAME% --help
echo.

endlocal
