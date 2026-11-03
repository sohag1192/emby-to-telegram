@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Emby to Telegram Notifier - Windows Installer

set "CURRENT_DIR=%~dp0"
for %%I in ("%CURRENT_DIR%..") do set "ROOT_DIR=%%~fI\"

cd /d "%ROOT_DIR%"

echo ==========================================================
echo 🎬 Emby to Telegram Notifier - Windows Installer
echo 📂 Project Root: %ROOT_DIR%
echo ==========================================================
echo.

:: Step 1: Check Python installation
echo 🔍 [1/4] Checking Python installation...
set "PYTHON_CMD="

where python >nul 2>&1
if !errorlevel! equ 0 (
    set "PYTHON_CMD=python"
) else (
    where py >nul 2>&1
    if !errorlevel! equ 0 (
        set "PYTHON_CMD=py"
    )
)

if "%PYTHON_CMD%"=="" (
    echo.
    echo ❌ Python is not installed or not in system PATH!
    echo ➡️ Please download and install Python 3.8+ from: https://www.python.org/downloads/
    echo ⚠️ IMPORTANT: Check the box "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('%PYTHON_CMD% --version 2^>^&1') do echo ✅ Found %%v

:: Step 2: Virtual Environment
echo.
echo 🐍 [2/4] Setting up Python virtual environment (venv)...
if not exist "%ROOT_DIR%venv\Scripts\python.exe" (
    "%PYTHON_CMD%" -m venv "%ROOT_DIR%venv"
    if !errorlevel! neq 0 (
        echo ❌ Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo ✅ Virtual environment created at "%ROOT_DIR%venv"
) else (
    echo ℹ️ Virtual environment already exists.
)

:: Step 3: Install dependencies
echo.
echo 📥 [3/4] Installing dependencies from requirements.txt...
"%ROOT_DIR%venv\Scripts\python.exe" -m pip install --upgrade pip >nul 2>&1
"%ROOT_DIR%venv\Scripts\python.exe" -m pip install -r "%ROOT_DIR%requirements.txt"
if !errorlevel! neq 0 (
    echo ❌ Failed to install required packages.
    pause
    exit /b 1
)
echo ✅ All dependencies installed successfully.

:: Step 4: Configure Auto-Start on Windows Boot
echo.
echo ⚙️ [4/4] Configuring Windows Auto-Start...
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "STARTUP_VBS=%STARTUP_FOLDER%\EmbyNotifier_AutoStart.vbs"

echo Do you want Emby Notifier to start automatically every time Windows boots?
set /p AUTO_BOOT="Enable Auto-Start on Windows boot? (Y/N) [Default: Y]: "
if /i "%AUTO_BOOT%"=="" set "AUTO_BOOT=Y"

if /i "%AUTO_BOOT%"=="Y" (
    echo Set WshShell = CreateObject("WScript.Shell") > "%STARTUP_VBS%"
    echo WshShell.CurrentDirectory = "%ROOT_DIR%" >> "%STARTUP_VBS%"
    echo WshShell.Run Chr(34) ^& "%CURRENT_DIR%run_hidden.vbs" ^& Chr(34), 0, False >> "%STARTUP_VBS%"
    echo ✅ Auto-start configured in Windows Startup folder!
) else (
    if exist "%STARTUP_VBS%" (
        del /f /q "%STARTUP_VBS%" >nul 2>&1
        echo ℹ️ Removed existing auto-start configuration.
    )
    echo ℹ️ Windows Auto-Start was skipped.
)

echo.
echo ==========================================================
echo ✅ Installation Complete!
echo ==========================================================
echo.
echo How would you like to run Emby Notifier now?
echo   [1] Run now in Console (shows live logs, auto-restarts on crash)
echo   [2] Run silently in Background (hidden, runs 24/7)
echo   [3] Exit
echo.

set /p RUN_CHOICE="Select an option (1-3) [Default: 1]: "
if "%RUN_CHOICE%"=="" set "RUN_CHOICE=1"

if "%RUN_CHOICE%"=="1" (
    echo 🚀 Starting Emby Notifier in console...
    start "Emby to Telegram Notifier" "%CURRENT_DIR%run.bat"
    exit /b 0
)

if "%RUN_CHOICE%"=="2" (
    call "%CURRENT_DIR%run_background.bat"
    exit /b 0
)

exit /b 0
