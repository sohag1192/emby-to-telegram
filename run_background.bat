@echo off
setlocal
chcp 65001 >nul
title Emby to Telegram Notifier - Background Starter

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

if not exist "venv\Scripts\python.exe" (
    echo ⚠️ Virtual environment not detected. Running installer first...
    call "%SCRIPT_DIR%install.bat"
    if errorlevel 1 exit /b 1
)

:: Check if already running
powershell -NoProfile -ExecutionPolicy Bypass -Command "$found = Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and ($_.CommandLine -like '*emby_to_telegram.py*') }; if ($found) { Write-Host 'ALREADY_RUNNING' }" | findstr /i "ALREADY_RUNNING" >nul
if %errorlevel% equ 0 (
    echo.
    echo ⚠️ Emby Notifier is ALREADY RUNNING in the background!
    echo 💡 If you wish to restart it, run stop.bat first.
    echo.
    pause
    exit /b 0
)

echo 🚀 Launching Emby Notifier silently in the background...
wscript.exe "%SCRIPT_DIR%run_hidden.vbs"

echo.
echo ==========================================================
echo ✅ Emby Notifier is now running silently in the BACKGROUND!
echo 📂 Directory: %SCRIPT_DIR%
echo 🔄 Auto-Restart: Active (restarts automatically if crashed)
echo 🕒 Running 24/7 without opening any console window.
echo 🛑 To stop it anytime, run: stop.bat
echo ==========================================================
echo.
pause
