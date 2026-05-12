@goto :WINDOWS 2>nul
echo ""
echo "======================================================================"
echo "ERROR: This uninstaller is for Windows CMD only"
echo "======================================================================"
echo ""
echo "For Linux/macOS/WSL, please use:"
echo "  curl -fsSL https://wp-staging.com/uninstall.sh | bash"
echo ""
echo "For Windows PowerShell, please use:"
echo "  irm https://wp-staging.com/uninstall.ps1 | iex"
echo ""
echo "======================================================================"
echo ""
exit 1
:WINDOWS
@echo off
setlocal enabledelayedexpansion

REM WP Staging CLI Uninstaller for Windows (CMD)
REM This script uninstalls the wpstaging cli binary
REM
REM Download and run directly from the web:
REM   curl -fsSL https://wp-staging.com/uninstall.cmd -o uninstall.cmd && uninstall.cmd
REM
REM Or using PowerShell to download:
REM   powershell -Command "Invoke-WebRequest -Uri 'https://wp-staging.com/uninstall.cmd' -OutFile 'uninstall.cmd'" && uninstall.cmd
REM
REM Or run locally if already downloaded:
REM   uninstall.cmd

set BINARY_NAME=wpstaging.exe
set APP_NAME=wpstaging
set SCRIPT_VERSION=20260430-154943

REM Early --print-version short-circuit. Print the build stamp and exit before
REM running any uninstall logic, so the smoke-test output stays clean.
if "%~1"=="--print-version" goto :do_print_version
if "%~1"=="-V" goto :do_print_version

REM All candidate directories that the installer may use
set INSTALL_DIR_1=%LOCALAPPDATA%\Programs\%APP_NAME%
set INSTALL_DIR_2=%LOCALAPPDATA%\Microsoft\WindowsApps
set INSTALL_DIR_3=%USERPROFILE%\bin

REM Generate ESC character for ANSI colors (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[96m"
set "NC=%ESC%[0m"

echo %BLUE%WP Staging CLI - Uninstaller%NC%
echo %BLUE%==============================%NC%
echo.

REM Check if wpstaging is installed in any candidate directory.
REM Track per-directory verification flags so the removal phase only deletes
REM from locations that passed the --version check (a foreign wpstaging.exe
REM in a candidate dir must not be removed).
set FOUND=0
set VERIFIED_1=0
set VERIFIED_2=0
set VERIFIED_3=0

if exist "%INSTALL_DIR_1%\%BINARY_NAME%" (
    call :verify_binary "%INSTALL_DIR_1%\%BINARY_NAME%"
    if not errorlevel 1 (
        set FOUND=1
        set VERIFIED_1=1
        echo %BLUE%Found installation in: !INSTALL_DIR_1!%NC%
    ) else (
        echo %YELLOW%Binary at !INSTALL_DIR_1!\!BINARY_NAME! is not WP Staging CLI, skipping%NC%
    )
)

if exist "%INSTALL_DIR_2%\%BINARY_NAME%" (
    call :verify_binary "%INSTALL_DIR_2%\%BINARY_NAME%"
    if not errorlevel 1 (
        set FOUND=1
        set VERIFIED_2=1
        echo %BLUE%Found installation in: !INSTALL_DIR_2!%NC%
    ) else (
        echo %YELLOW%Binary at !INSTALL_DIR_2!\!BINARY_NAME! is not WP Staging CLI, skipping%NC%
    )
)

if exist "%INSTALL_DIR_3%\%BINARY_NAME%" (
    call :verify_binary "%INSTALL_DIR_3%\%BINARY_NAME%"
    if not errorlevel 1 (
        set FOUND=1
        set VERIFIED_3=1
        echo %BLUE%Found installation in: !INSTALL_DIR_3!%NC%
    ) else (
        echo %YELLOW%Binary at !INSTALL_DIR_3!\!BINARY_NAME! is not WP Staging CLI, skipping%NC%
    )
)

if !FOUND!==0 (
    where wpstaging >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%i in ('where wpstaging 2^>nul') do (
            call :verify_binary "%%i"
            if not errorlevel 1 (
                set FOUND=1
                echo %BLUE%Found wpstaging at: %%i%NC%
                REM Mark matching candidate dir as verified so removal targets it.
                for %%d in ("%%~dpi.") do (
                    if /i "%%~fd"=="%INSTALL_DIR_1%" set VERIFIED_1=1
                    if /i "%%~fd"=="%INSTALL_DIR_2%" set VERIFIED_2=1
                    if /i "%%~fd"=="%INSTALL_DIR_3%" set VERIFIED_3=1
                )
            ) else (
                echo %YELLOW%Binary at %%i is not WP Staging CLI, skipping%NC%
            )
        )
    )
)

if !FOUND!==0 (
    echo %YELLOW%WP Staging CLI does not appear to be installed%NC%
    echo %BLUE%Checking for leftover configuration...%NC%
)

echo.

REM Confirm uninstallation
echo %BLUE%This will remove:%NC%
echo   - wpstaging binary and aliases
echo   - PATH entry
echo   - License key environment variable
echo   - Cache and working directories
echo.

REM WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1", skip this
REM confirmation. Used by CI to test the documented install.cmd invocation.
if "%WPSTG_UNINSTALL_ASSUME_YES%"=="1" (
    set "CONFIRM=y"
    echo %BLUE%Proceeding ^(WPSTG_UNINSTALL_ASSUME_YES set^)%NC%
) else (
    set /p CONFIRM="Are you sure you want to uninstall WP Staging CLI? [y/N] "
)
if /i not "!CONFIRM!"=="y" (
    echo.
    echo %BLUE%Uninstallation cancelled%NC%
    goto :EOF
)

echo.

REM Check for existing dockerized sites
echo %BLUE%Checking for existing dockerized sites...%NC%

where wpstaging >nul 2>&1
if errorlevel 1 (
    echo %BLUE%wpstaging binary not found, skipping site check%NC%
    goto :skip_site_check
)

REM Use unique temp file to avoid conflicts if multiple instances run
set "TEMP_SITES=%TEMP%\wpstaging_sites_%RANDOM%.txt"

REM Capture site list to temp file
wpstaging list > "%TEMP_SITES%" 2>&1

REM Check if there are any sites
REM Pattern explanation: wpstaging list outputs "Dockerize: Host   : sitename.local"
REM We look for "Host" followed by 3 spaces and colon (the exact output format)
REM Note: findstr /r has limited regex - using literal /c: for reliable matching
findstr /i /c:"Host   :" "%TEMP_SITES%" >nul 2>&1
if not errorlevel 1 (
    echo.
    type "%TEMP_SITES%"
    echo.
    echo %YELLOW%The above sites will remain on disk unless you delete them.%NC%

    REM WPSTG_UNINSTALL_ASSUME_YES (internal, undocumented): when "1",
    REM auto-answer "No" here to preserve user data. Used by CI only.
    if "%WPSTG_UNINSTALL_ASSUME_YES%"=="1" (
        set "DELETE_SITES=n"
        echo %BLUE%Sites will be preserved ^(WPSTG_UNINSTALL_ASSUME_YES set^)%NC%
    ) else (
        set /p DELETE_SITES="Do you want to delete all sites and their Docker data? [y/N] "
    )

    if /i "!DELETE_SITES!"=="y" (
        echo %BLUE%Stopping all containers first...%NC%
        wpstaging stop >nul 2>&1 || ver >nul

        echo %BLUE%Running wpstaging remove to remove all sites...%NC%
        wpstaging remove --yes >nul 2>&1
        if errorlevel 1 (
            echo %YELLOW%Warning: Site cleanup may have encountered errors. Some files may remain.%NC%
        ) else (
            echo %GREEN%Sites and Docker data removed%NC%
        )
    ) else (
        echo %BLUE%Sites will be preserved on disk%NC%
    )
) else (
    echo %BLUE%No dockerized sites found%NC%
)

del "%TEMP_SITES%" >nul 2>&1
:skip_site_check
echo.

REM Stop any running wpstaging containers (fallback for containers not in site list)
echo %BLUE%Stopping any running wpstaging containers...%NC%
where wpstaging >nul 2>&1
if not errorlevel 1 (
    REM Ignore exit code - stop may fail if no license or no containers running
    wpstaging stop >nul 2>&1 || ver >nul
    echo %GREEN%Stopped wpstaging containers - if any were running%NC%
) else (
    echo %BLUE%wpstaging binary not found, skipping container stop%NC%
)

echo.

REM Deactivate license on server before removing binary
set "WPSTAGING_CMD="
REM Prefer a known install location if it exists
if exist "%LOCALAPPDATA%\Programs\wpstaging\wpstaging.exe" (
    set "WPSTAGING_CMD=%LOCALAPPDATA%\Programs\wpstaging\wpstaging.exe"
) else (
    REM Fallback: try to locate wpstaging via PATH
    for /f "delims=" %%P in ('where wpstaging 2^>nul') do (
        if not defined WPSTAGING_CMD set "WPSTAGING_CMD=%%P"
    )
)
if defined WPSTAGING_CMD (
    "!WPSTAGING_CMD!" deactivate --yes >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%License deactivated%NC%
    ) else (
        echo %YELLOW%Failed to deactivate license%NC%
    )
) else (
    echo %BLUE%wpstaging binary not found; skipping license deactivation%NC%
)

echo.

REM Remove binaries only from verified candidate directories. Iterating every
REM candidate here would delete a foreign wpstaging.exe in a candidate dir,
REM defeating the --version verification above.
echo %BLUE%Removing binaries...%NC%

if "!VERIFIED_1!"=="1" call :remove_binaries_from_dir "%INSTALL_DIR_1%"
if "!VERIFIED_2!"=="1" call :remove_binaries_from_dir "%INSTALL_DIR_2%"
if "!VERIFIED_3!"=="1" call :remove_binaries_from_dir "%INSTALL_DIR_3%"

goto :after_remove_binaries

:verify_binary
REM Verify a candidate binary with a 5s timeout (#295). Args: %1 = full path.
REM Sets errorlevel 0 on verified, non-zero otherwise. Wraps PowerShell because
REM cmd has no portable timeout primitive that survives across Windows versions.
REM Path is passed as a PowerShell argument (param binding) rather than
REM string-interpolated, to stay safe if %~1 ever contains a single quote.
REM PowerShell command stays on a single line: line continuation inside an
REM if-block fails to parse on some Windows versions.
powershell -NoProfile -Command "& { param([string]$p) $psi = New-Object System.Diagnostics.ProcessStartInfo; $psi.FileName = $p; $psi.Arguments = '--version'; $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.CreateNoWindow = $true; try { $proc = [System.Diagnostics.Process]::Start($psi); if (-not $proc.WaitForExit(5000)) { try { $proc.Kill() } catch {}; exit 2 }; $out = $proc.StandardOutput.ReadToEnd() + $proc.StandardError.ReadToEnd(); if ($out -match 'wpstaging|wp[-. ]staging') { exit 0 } else { exit 1 } } catch { exit 3 } }" "%~1"
goto :eof

:remove_binaries_from_dir
set "DIR=%~1"
if exist "%DIR%\%BINARY_NAME%" (
    del /f /q "%DIR%\%BINARY_NAME%" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed %BINARY_NAME% from %DIR%%NC%
    ) else (
        echo %YELLOW%Failed to remove %BINARY_NAME% from %DIR%%NC%
    )
)
REM Remove .cmd aliases (used in regular directories)
if exist "%DIR%\wpstg.cmd" (
    del /f /q "%DIR%\wpstg.cmd" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed wpstg.cmd from %DIR%%NC%
    ) else (
        echo %YELLOW%Failed to remove wpstg.cmd from %DIR%%NC%
    )
)
if exist "%DIR%\wp-staging.cmd" (
    del /f /q "%DIR%\wp-staging.cmd" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed wp-staging.cmd from %DIR%%NC%
    ) else (
        echo %YELLOW%Failed to remove wp-staging.cmd from %DIR%%NC%
    )
)
REM Remove .exe aliases (used in WindowsApps directory)
if exist "%DIR%\wpstg.exe" (
    del /f /q "%DIR%\wpstg.exe" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed wpstg.exe from %DIR%%NC%
    ) else (
        echo %YELLOW%Failed to remove wpstg.exe from %DIR%%NC%
    )
)
if exist "%DIR%\wp-staging.exe" (
    del /f /q "%DIR%\wp-staging.exe" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed wp-staging.exe from %DIR%%NC%
    ) else (
        echo %YELLOW%Failed to remove wp-staging.exe from %DIR%%NC%
    )
)
REM Remove directory if empty (only for our dedicated wpstaging directory)
if "%DIR%"=="%INSTALL_DIR_1%" (
    if exist "%DIR%" (
        dir /b "%DIR%" 2>nul | findstr "^" >nul
        if errorlevel 1 (
            rmdir "%DIR%" >nul 2>&1
            echo %GREEN%Removed empty directory: %DIR%%NC%
        )
    )
)
goto :eof

:after_remove_binaries

echo.

REM Remove from PATH (all candidate directories)
echo %BLUE%Removing from PATH...%NC%

REM Get current user PATH
for /f "usebackq tokens=2,*" %%A in (`reg query "HKCU\Environment" /v PATH 2^>nul`) do set "USER_PATH=%%B"

set PATH_REMOVED=0

if defined USER_PATH (
    REM Check and remove each candidate directory from PATH
    call :remove_from_path "%INSTALL_DIR_1%"
    call :remove_from_path "%INSTALL_DIR_2%"
    call :remove_from_path "%INSTALL_DIR_3%"
)

if %PATH_REMOVED%==0 (
    echo %BLUE%No installation directories were in PATH%NC%
)

goto :after_remove_path

:remove_from_path
set "PATH_DIR=%~1"
echo !USER_PATH! | findstr /i /c:"%PATH_DIR%" >nul
if not errorlevel 1 (
    REM Use PowerShell to remove from PATH (more reliable)
    powershell -NoProfile -Command "$path = [Environment]::GetEnvironmentVariable('PATH', 'User'); $newPath = ($path.Split(';') | Where-Object { $_ -ne '%PATH_DIR%' -and $_ -ne '' }) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed %PATH_DIR% from PATH%NC%
        set PATH_REMOVED=1
    ) else (
        echo %YELLOW%Failed to remove %PATH_DIR% from PATH%NC%
    )
)
goto :eof

:after_remove_path

echo.

REM Remove license key environment variable
echo %BLUE%Removing license key...%NC%

REM Check if WPSTGPRO_LICENSE exists
for /f "usebackq tokens=2,*" %%A in (`reg query "HKCU\Environment" /v WPSTGPRO_LICENSE 2^>nul`) do set "LICENSE_EXISTS=1"

if defined LICENSE_EXISTS (
    reg delete "HKCU\Environment" /v WPSTGPRO_LICENSE /f >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%Removed WPSTGPRO_LICENSE environment variable%NC%
    ) else (
        echo %YELLOW%Failed to remove license environment variable%NC%
    )
) else (
    echo %BLUE%No license key environment variable found%NC%
)

echo.

REM Remove cache and working directories
echo %BLUE%Removing cache and working directories...%NC%

if exist "%LOCALAPPDATA%\wpstaging" (
    rmdir /s /q "%LOCALAPPDATA%\wpstaging" >nul 2>&1
    echo %GREEN%Removed directory: %LOCALAPPDATA%\wpstaging%NC%
)

REM Windows default working directory
if exist "%APPDATA%\wpstaging" (
    rmdir /s /q "%APPDATA%\wpstaging" >nul 2>&1
    echo %GREEN%Removed directory: %APPDATA%\wpstaging%NC%
)

if exist "%USERPROFILE%\.wpstaging" (
    rmdir /s /q "%USERPROFILE%\.wpstaging" >nul 2>&1
    echo %GREEN%Removed directory: %USERPROFILE%\.wpstaging%NC%
)

echo.

REM Summary
echo.
echo %GREEN%==============================%NC%
echo %GREEN%   Uninstallation Complete!%NC%
echo %GREEN%==============================%NC%
echo.
echo %BLUE%WP Staging CLI has been removed from your system.%NC%
echo.
echo %YELLOW%Note: You may need to restart your command prompt%NC%
echo %YELLOW%for changes to take effect.%NC%
echo.

endlocal
exit /b 0

REM Print uninstaller build and exit. Reachable only via goto from the early
REM short-circuit so the script never falls into it during a normal run.
:do_print_version
echo wpstaging uninstaller
echo   build: %SCRIPT_VERSION%
endlocal
exit /b 0
