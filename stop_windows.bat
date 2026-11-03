@echo off
title Stop Emby to Telegram Notifier
echo ==========================================================
echo  Stopping Emby to Telegram Notifier Background Process...
echo ==========================================================
echo.

powershell -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*emby_to_telegram.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; Write-Host ('Stopped process ID: ' + $_.ProcessId) }"

echo.
echo Process terminated.
echo.
set /p REMOVE_STARTUP="Do you also want to remove auto-start on Windows boot? (y/n): "
if /i "%REMOVE_STARTUP%"=="y" (
    if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EmbyToTelegram.lnk" (
        del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\EmbyToTelegram.lnk" >nul 2>&1
        echo Auto-start shortcut removed from Windows Startup folder.
    ) else (
        echo No auto-start shortcut found.
    )
)
echo.
echo ==========================================================
echo  Done!
echo ==========================================================
pause
