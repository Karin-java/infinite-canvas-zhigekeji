@echo off
setlocal
title Infinite Canvas Zhige

cd /d "%~dp0web"
if errorlevel 1 goto :missing_project
if not exist "package.json" goto :missing_project

if /I "%~1"=="--check" (
    echo Windows launcher check passed.
    exit /b 0
)

where bun >nul 2>&1
if not errorlevel 1 (
    set "BUN_BIN=bun"
    goto :bun_ready
)

set "BUN_BIN=%USERPROFILE%\.bun\bin\bun.exe"
if exist "%BUN_BIN%" goto :bun_ready

echo Bun is not installed. Installing it for the current user...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
if errorlevel 1 goto :bun_install_failed
if not exist "%BUN_BIN%" goto :bun_install_failed

:bun_ready
if not exist "node_modules\vite\package.json" (
    echo Installing project dependencies...
    "%BUN_BIN%" install --frozen-lockfile
    if errorlevel 1 goto :dependency_failed
)

echo Starting Infinite Canvas at http://localhost:3000 ...
"%BUN_BIN%" run launch
if errorlevel 1 goto :launch_failed
exit /b 0

:missing_project
echo ERROR: The web project was not found next to this launcher.
goto :failed

:bun_install_failed
echo ERROR: Bun installation failed. Check the network and try again.
goto :failed

:dependency_failed
echo ERROR: Project dependencies could not be installed.
goto :failed

:launch_failed
echo ERROR: Infinite Canvas could not start. Port 3000 may already be in use.

:failed
echo.
pause
exit /b 1
