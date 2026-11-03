@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Emby to Telegram Notifier (Always-Run Mode)

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: Check if virtual environment exists
if not exist "venv\Scripts\python.exe" (
    echo ⚠️ Virtual environment not detected. Running installer first...
    echo.
    call "%SCRIPT_DIR%install.bat"
    if errorlevel 1 (
        echo ❌ Installation failed.
        pause
        exit /b 1
    )
)

echo ==========================================================
echo 🎬 Emby to Telegram Notifier (Always-Run Mode)
echo 📂 Directory: %SCRIPT_DIR%
echo 🔄 Auto-Restart: Active (restarts automatically if crashed)
echo 🛑 Stop anytime: Close this window or press Ctrl+C
echo ==========================================================
echo.

:loop
echo [%date% %time%] 🚀 Starting Emby Notifier...
"%SCRIPT_DIR%venv\Scripts\python.exe" "%SCRIPT_DIR%emby_to_telegram.py"

echo.
echo ⚠️ [%date% %time%] Emby Notifier stopped or disconnected.
echo ⏳ Restarting in 10 seconds... (Press Ctrl+C to abort)
timeout /t 10 >nul
echo.
goto loop
