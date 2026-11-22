@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title GitHub Auto Upload & Release Script

REM ==========================================================
REM GitHub Auto Upload & Release Script
REM Author: Md. Sohag Rana (@sohag1192)
REM Repository: https://github.com/sohag1192/emby-to-telegram.git
REM Branch: main
REM ==========================================================

set "LOCAL_DIR=%~dp0"
set "REPO_URL=https://github.com/sohag1192/emby-to-telegram.git"
set "USER_NAME=sohag1192"
set "USER_EMAIL=sohag1192@gmail.com"
set "BRANCH_NAME=main"

REM --- Navigate to project directory ---
cd /d "%LOCAL_DIR%"
if errorlevel 1 (
    echo ❌ Failed to access directory: %LOCAL_DIR%
    pause
    exit /b 1
)

REM --- Git Configuration ---
git config user.name "%USER_NAME%"
git config user.email "%USER_EMAIL%"

REM --- Initialize if not a git repo ---
if not exist ".git" (
    echo 📦 Initializing repository...
    git init
    git branch -M %BRANCH_NAME%
    git remote add origin "%REPO_URL%"
)

REM --- Detect Current & Suggested Version ---
set "CURRENT_TAG=v3.0"
set "SUGGESTED_TAG=v3.1"

where python >nul 2>&1
if %errorlevel% equ 0 (
    if exist ".github\bump_version.py" (
        for /f "tokens=1,2 delims==" %%a in ('python .github\bump_version.py --suggest 2^>nul') do (
            if "%%a"=="CURRENT" set "CURRENT_TAG=%%b"
            if "%%a"=="SUGGESTED" set "SUGGESTED_TAG=%%b"
        )
    )
)

echo ==========================================================
echo 🚀 GitHub Auto Upload & Release Manager
echo 👤 Author: %USER_NAME% (%USER_EMAIL%)
echo 📂 Directory: %LOCAL_DIR%
echo 🌿 Branch: %BRANCH_NAME%
echo 🏷️ Current Version:   %CURRENT_TAG%
echo 💡 Suggested Version: %SUGGESTED_TAG%
echo ==========================================================
echo.
echo Select Release & Tagging Option:
echo   [1] Auto-bump to %SUGGESTED_TAG% and publish GitHub Release (Recommended)
echo   [2] Enter Custom Version Tag (e.g. v3.2, v4.0)
echo   [3] Re-release / Keep current tag (%CURRENT_TAG%)
echo   [4] Push Code Only (No new tag, no release trigger)
echo.

set "CHOICE=1"
set /p "CHOICE=Enter choice [1-4] (Default is 1): "
if "%CHOICE%"=="" set "CHOICE=1"

set "DO_RELEASE=1"
set "SELECTED_TAG=%SUGGESTED_TAG%"

if "%CHOICE%"=="1" (
    set "SELECTED_TAG=%SUGGESTED_TAG%"
    set "DO_RELEASE=1"
) else if "%CHOICE%"=="2" (
    set "CUSTOM_TAG="
    set /p "CUSTOM_TAG=Enter custom tag (e.g. v3.2): "
    if "!CUSTOM_TAG!"=="" (
        set "SELECTED_TAG=%SUGGESTED_TAG%"
    ) else (
        if not "!CUSTOM_TAG:~0,1!"=="v" if not "!CUSTOM_TAG:~0,1!"=="V" set "CUSTOM_TAG=v!CUSTOM_TAG!"
        set "SELECTED_TAG=!CUSTOM_TAG!"
    )
    set "DO_RELEASE=1"
) else if "%CHOICE%"=="3" (
    set "SELECTED_TAG=%CURRENT_TAG%"
    set "DO_RELEASE=1"
) else if "%CHOICE%"=="4" (
    set "DO_RELEASE=0"
    set "SELECTED_TAG="
) else (
    echo ⚠️ Invalid choice, defaulting to Option 1: %SUGGESTED_TAG%
    set "SELECTED_TAG=%SUGGESTED_TAG%"
    set "DO_RELEASE=1"
)

REM --- Update version in python files if releasing ---
if "%DO_RELEASE%"=="1" (
    echo.
    echo 🏷️ Preparing Release: %SELECTED_TAG%...
    where python >nul 2>&1
    if %errorlevel% equ 0 (
        if exist ".github\bump_version.py" (
            python .github\bump_version.py %SELECTED_TAG%
        )
    )
    set "DEFAULT_MSG=Release %SELECTED_TAG% - Auto release package"
) else (
    echo.
    echo 📦 Push mode: Code only (no tag)
    set "DEFAULT_MSG=Update emby-to-telegram codebase"
)

REM --- Determine Commit Message ---
set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" (
    echo.
    echo Enter commit message ^(press Enter for default^):
    echo Default: "%DEFAULT_MSG%"
    set "INPUT_MSG="
    set /p "INPUT_MSG=Commit Message: "
    if "!INPUT_MSG!"=="" (
        set "COMMIT_MSG=%DEFAULT_MSG%"
    ) else (
        for /f "tokens=* delims= " %%a in ("!INPUT_MSG!") do set "CLEAN_MSG=%%a"
        if "!CLEAN_MSG!"=="" (
            set "COMMIT_MSG=%DEFAULT_MSG%"
        ) else (
            set "COMMIT_MSG=!CLEAN_MSG!"
        )
    )
)

echo.
echo 📝 Using Commit Message: "!COMMIT_MSG!"
echo.

REM --- Stage all changes ---
echo 📦 Staging all project changes...
git add -A

REM --- Commit ---
git diff --cached --quiet
if errorlevel 1 (
    echo 💾 Committing changes...
    git commit -m "!COMMIT_MSG!"
    if !errorlevel! equ 0 (
        echo ✅ Changes committed successfully.
    ) else (
        echo ⚠️ Commit failed.
    )
) else (
    echo ℹ️ Nothing new to commit ^(working tree clean^).
)

REM --- Pull with rebase ---
echo 📥 Syncing with remote repository...
git pull origin %BRANCH_NAME% --rebase >nul 2>&1

REM --- Push branch ---
echo 🚀 Pushing %BRANCH_NAME% branch to GitHub...
git push -u origin %BRANCH_NAME%
if errorlevel 1 (
    echo.
    echo ❌ Push failed! Please check your internet connection or Git credentials.
    pause
    exit /b 1
)

REM --- Handle Tag and Release Trigger ---
if "%DO_RELEASE%"=="1" (
    echo 🏷️ Creating version tag %SELECTED_TAG%...
    git tag -fa %SELECTED_TAG% -m "Release %SELECTED_TAG%" >nul 2>&1
    echo 🚀 Pushing %SELECTED_TAG% tag to GitHub (Triggers GitHub Actions Release)...
    git push origin %SELECTED_TAG% --force
    if errorlevel 1 (
        echo ⚠️ Tag push failed or encountered error.
    ) else (
        echo ✅ Tag %SELECTED_TAG% successfully pushed to GitHub!
    )
)

echo.
echo ==========================================================
if "%DO_RELEASE%"=="1" (
    echo  ✅ Upload Completed & Release %SELECTED_TAG% Triggered!
    echo  🌐 Repo:     https://github.com/sohag1192/emby-to-telegram
    echo  🚀 Releases: https://github.com/sohag1192/emby-to-telegram/releases
    echo  ⚙️ Actions:  https://github.com/sohag1192/emby-to-telegram/actions
) else (
    echo  ✅ GitHub Code Upload Completed Successfully!
    echo  🌐 Repo:     https://github.com/sohag1192/emby-to-telegram
)
echo ==========================================================
echo.
pause
