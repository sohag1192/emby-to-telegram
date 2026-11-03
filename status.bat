@echo off
setlocal
chcp 65001 >nul
title Emby to Telegram Notifier - Status

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0service_manager.ps1" status
pause
