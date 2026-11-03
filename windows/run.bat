@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Emby to Telegram Notifier (Always-Run Mode)

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

:: Check if virtual environment exists
if not exist "%ROOT_DIR%venv\Scripts\python.exe" (
    echo ⚠️ Virtual environment not detected. Running installer first...
    echo.
    call "%CURRENT_DIR%install.bat"
    if errorlevel 1 (
        echo ❌ Installation failed.
        pause
        exit /b 1
    )
)

echo ==========================================================
echo 🎬 Emby to Telegram Notifier (Always-Run Mode)
echo 📂 Project Root: %ROOT_DIR%
echo 📜 Running:      %TARGET_SCRIPT%
echo 🔄 Auto-Restart: Active (restarts automatically if crashed)
echo 🛑 Stop anytime: Close this window or press Ctrl+C
echo ==========================================================
echo.

:loop
echo [%date% %time%] 🚀 Starting %TARGET_SCRIPT%...
"%ROOT_DIR%venv\Scripts\python.exe" "%ROOT_DIR%%TARGET_SCRIPT%"

echo.
echo ⚠️ [%date% %time%] %TARGET_SCRIPT% stopped or disconnected.
echo ⏳ Restarting in 10 seconds... (Press Ctrl+C to abort)
timeout /t 10 >nul
echo.
goto loop
