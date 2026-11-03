@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title GitHub Auto Upload Script - v3.0

REM ==========================================================
REM GitHub Auto Upload Script
REM Author: Md. Sohag Rana (@sohag1192)
REM Repository: https://github.com/sohag1192/emby-to-telegram.git
REM Branch: main
REM Package: v3.0 (Cross-Platform Edition)
REM ==========================================================

set "LOCAL_DIR=%~dp0"
set "REPO_URL=https://github.com/sohag1192/emby-to-telegram.git"
set "USER_NAME=sohag1192"
set "USER_EMAIL=sohag1192@gmail.com"
set "BRANCH_NAME=main"
set "VERSION=v3.0"
set "DEFAULT_MSG=Release %VERSION% - Cross-platform package update"

echo ==========================================================
echo 🚀 GitHub Auto Upload Script - %VERSION%
echo 👤 Author: %USER_NAME% (%USER_EMAIL%)
echo 📂 Directory: %LOCAL_DIR%
echo 🌿 Branch: %BRANCH_NAME%
echo ==========================================================
echo.

REM --- Determine Commit Message ---
set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" (
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

REM --- Navigate to project directory ---
cd /d "%LOCAL_DIR%"
if errorlevel 1 (
    echo ❌ Failed to access directory: %LOCAL_DIR%
    pause
    exit /b 1
)

REM --- Git Configuration ---
echo ⚙️ Configuring Git credentials...
git config user.name "%USER_NAME%"
git config user.email "%USER_EMAIL%"

REM --- Initialize if not a git repo ---
if not exist ".git" (
    echo 📦 Initializing repository...
    git init
    git branch -M %BRANCH_NAME%
    git remote add origin "%REPO_URL%"
)

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

REM --- Create or update tag ---
echo 🏷️ Updating version tag %VERSION%...
git tag -fa %VERSION% -m "Release %VERSION%" >nul 2>&1
echo ✅ Tag %VERSION% ready.

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

REM --- Push tags ---
echo 🏷️ Pushing %VERSION% tag to GitHub...
git push origin %VERSION% --force >nul 2>&1
if errorlevel 1 (
    echo ℹ️ Tag push skipped or already up to date.
) else (
    echo ✅ Tag %VERSION% pushed to GitHub!
)

echo.
echo ==========================================================
echo  ✅ GitHub Upload Completed Successfully! [Package %VERSION%]
echo  🌐 Repo: %REPO_URL%
echo ==========================================================
echo.
pause
