@echo off
title Emby to Telegram Notifier - Windows Installer
setlocal EnableDelayedExpansion

echo ==========================================================
echo  Emby to Telegram Notifier - Windows Setup
echo ==========================================================
echo.

:: Step 1: Check Python installation
echo [1/4] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in your system PATH!
    echo Please download and install Python 3.8+ from https://www.python.org/
    echo Make sure to check the box "Add python.exe to PATH" during installation.
    echo.
    pause
    exit /b 1
)
python --version

:: Step 2: Create Python Virtual Environment
echo.
echo [2/4] Setting up Python virtual environment...
if not exist "%~dp0venv\Scripts\python.exe" (
    python -m venv "%~dp0venv"
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
)
echo Virtual environment ready.

:: Step 3: Install Dependencies
echo.
echo [3/4] Installing dependencies from requirements.txt...
"%~dp0venv\Scripts\python.exe" -m pip install --upgrade pip >nul 2>&1
"%~dp0venv\Scripts\pip.exe" install -r "%~dp0requirements.txt"
if errorlevel 1 (
    echo [ERROR] Failed to install requirements.
    pause
    exit /b 1
)
echo Dependencies installed successfully.

:: Step 4: Configure Auto-Start on Windows Boot
echo.
echo [4/4] Setting up background auto-start on Windows boot...
set "VBS_PATH=%~dp0start_background.vbs"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%STARTUP_FOLDER%\EmbyToTelegram.lnk'); $s.TargetPath = 'wscript.exe'; $s.Arguments = '\"%VBS_PATH%\"'; $s.WorkingDirectory = '%~dp0'; $s.Description = 'Emby to Telegram Notifier Background Service'; $s.Save()" >nul 2>&1

:: Launch now in background
echo Starting notifier in background...
cscript //nologo "%VBS_PATH%"

echo.
echo ==========================================================
echo  Setup Complete! 
echo ==========================================================
echo.
echo  The notifier is now RUNNING IN THE BACKGROUND silently!
echo  It will also automatically start every time Windows boots.
echo.
echo  To STOP the background notifier anytime, double-click:
echo  stop_windows.bat
echo.
echo ==========================================================
pause
