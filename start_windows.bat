@echo off
title Start Emby to Telegram Notifier
echo Starting Emby to Telegram Notifier silently in background...
cscript //nologo "%~dp0start_background.vbs"
echo Running in background!
timeout /t 3 >nul
