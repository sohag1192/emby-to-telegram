@echo off
setlocal
chcp 65001 >nul
title Stop Emby to Telegram Notifier

echo ==========================================================
echo 🛑 Stopping Emby to Telegram Notifier...
echo ==========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$killed = 0; $pyProcs = Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and ($_.CommandLine -like '*emby_to_telegram*') }; if ($pyProcs) { $pyProcs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host ('✅ Stopped Python process: ' + $_.ProcessId) -ForegroundColor Green; $killed++ } }; $cmdProcs = Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'cmd.exe' -and ($_.CommandLine -like '*run.bat*' -or $_.CommandLine -like '*run_background.bat*') }; if ($cmdProcs) { $cmdProcs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host ('✅ Stopped Runner cmd process: ' + $_.ProcessId) -ForegroundColor Green; $killed++ } }; if ($killed -eq 0) { Write-Host 'ℹ️ No running instances found.' -ForegroundColor Yellow }"

echo.
echo ==========================================================
echo ✅ Finished.
echo ==========================================================
echo.
pause
