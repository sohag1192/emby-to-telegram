@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Emby to Telegram Notifier - Background Starter

set "CURRENT_DIR=%~dp0"
for %%I in ("%CURRENT_DIR%..") do set "ROOT_DIR=%%~fI\"

cd /d "%ROOT_DIR%"

:: Determine script to run
set "TARGET_SCRIPT=%~1"
if "%TARGET_SCRIPT%"=="" (
    if exist "%ROOT_DIR%selected_script.txt" (
        set /p TARGET_SCRIPT=<"%ROOT_DIR%selected_script.txt"
    )
)
if "%TARGET_SCRIPT%"=="" (
    if exist "%ROOT_DIR%emby_to_telegram_bn.py" (
        set "TARGET_SCRIPT=emby_to_telegram_bn.py"
    ) else (
        set "TARGET_SCRIPT=emby_to_telegram.py"
    )
)

if not exist "%ROOT_DIR%venv\Scripts\python.exe" (
    echo ⚠️ Virtual environment not detected. Running installer first...
    call "%CURRENT_DIR%install.bat"
    if errorlevel 1 exit /b 1
)

:: Check if already running
powershell -NoProfile -ExecutionPolicy Bypass -Command "$found = Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and ($_.CommandLine -like '*emby_to_telegram*') }; if ($found) { Write-Host 'ALREADY_RUNNING' }" | findstr /i "ALREADY_RUNNING" >nul
if %errorlevel% equ 0 (
    echo.
    echo ⚠️ Emby Notifier is ALREADY RUNNING in the background!
    echo 💡 If you wish to restart it, run stop.bat first.
    echo.
    pause
    exit /b 0
)

echo 🚀 Launching Emby Notifier (%TARGET_SCRIPT%) in the background...
wscript.exe "%CURRENT_DIR%run_hidden.vbs"

echo.
echo ==========================================================
echo ✅ Emby Notifier is now running silently in the BACKGROUND!
echo 📂 Project Root: %ROOT_DIR%
echo 📜 Running:      %TARGET_SCRIPT%
echo 🔄 Auto-Restart: Active (restarts automatically if crashed)
echo 🕒 Running 24/7 without opening any console window.
echo 🛑 To stop it anytime, run: stop.bat
echo ==========================================================
echo.
pause
