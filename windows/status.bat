@echo off
setlocal
chcp 65001 >nul
title Emby to Telegram Notifier - Status Check

echo ==========================================================
echo 📊 Emby to Telegram Notifier - Status Check
echo ==========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$procs = Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and ($_.CommandLine -like '*emby_to_telegram*') }; if ($procs) { Write-Host '✅ Emby Notifier is currently RUNNING:' -ForegroundColor Green; $procs | ForEach-Object { Write-Host ('   • PID: ' + $_.ProcessId + ' | Executable: ' + $_.Name) -ForegroundColor Cyan } } else { Write-Host 'ℹ️ Emby Notifier is NOT running (STOPPED).' -ForegroundColor Yellow }"

echo.
echo ==========================================================
echo.
pause
