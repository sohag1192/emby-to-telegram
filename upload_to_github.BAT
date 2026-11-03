@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title GitHub Auto Upload Script - v3.0

REM ====== GitHub Auto Upload Script ======
REM Author: Md. Sohag Rana
REM GitHub: https://github.com/sohag1192
REM Package: v3.0 (Cross-Platform Windows & Linux Edition)

:: === CONFIGURATION ===
set "LOCAL_DIR=%~dp0"
set "REPO_URL=https://github.com/sohag1192/emby-to-telegram.git"
set "USER_NAME=sohag1192"
set "USER_EMAIL=sohag1192@gmail.com"
set "BRANCH_NAME=main"
set "VERSION=v3.0"

echo ==========================================================
echo 🚀 GitHub Auto Upload Script - %VERSION%
echo 👤 Author: %USER_NAME% (%USER_EMAIL%)
echo 📂 Directory: %LOCAL_DIR%
echo 🌿 Branch: %BRANCH_NAME%
echo ==========================================================
echo.

:: === COMMIT MESSAGE ===
set "DEFAULT_MSG=Release %VERSION%: Cross-platform Windows & Linux package update"

if "%~1"=="" (
    echo Enter commit message (or press Enter for default):
    echo Default: "%DEFAULT_MSG%"
    set /p "INPUT_MSG=Commit Message: "
    if "!INPUT_MSG!"=="" (
        set "COMMIT_MSG=%DEFAULT_MSG%"
    ) else (
        set "COMMIT_MSG=!INPUT_MSG!"
    )
) else (
    set "COMMIT_MSG=%~1"
)

echo.
echo 📝 Commit Message: "!COMMIT_MSG!"
echo.

:: === NAVIGATE TO LOCAL DIRECTORY ===
cd /d "%LOCAL_DIR%"
if errorlevel 1 (
    echo ❌ Failed to access directory: %LOCAL_DIR%
    pause
    exit /b 1
)

:: === SET GIT CONFIG ===
echo ⚙️ Configuring Git credentials...
git config user.name "%USER_NAME%"
git config user.email "%USER_EMAIL%"

:: === INITIALIZE REPO IF NEEDED ===
if not exist ".git" (
    echo 📦 Initializing repository...
    git init
    git branch -M %BRANCH_NAME%
    git remote add origin "%REPO_URL%"
)

:: === ADD ALL CHANGES ===
echo 📦 Staging all project changes...
git add -A

:: === COMMIT ===
git diff --cached --quiet
if errorlevel 1 (
    echo 💾 Committing changes...
    git commit -m "%COMMIT_MSG%"
    if errorlevel 1 (
        echo ⚠️ Commit failed.
    ) else (
        echo ✅ Changes committed successfully.
    )
) else (
    echo ℹ️ Working tree clean. No new changes to commit.
)

:: === CREATE OR UPDATE VERSION TAG ===
echo 🏷️ Tagging release %VERSION%...
git tag -fa %VERSION% -m "Release %VERSION%" >nul 2>&1
if errorlevel 1 (
    echo ℹ️ Tag %VERSION% already exists or could not be created.
) else (
    echo ✅ Created tag %VERSION%
)

:: === PULL BEFORE PUSH TO AVOID CONFLICTS ===
echo 📥 Pulling latest changes from origin/%BRANCH_NAME%...
git pull origin %BRANCH_NAME% --rebase >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Pull rebase encountered warnings (continuing)...
)

:: === PUSH TO GITHUB ===
echo 🚀 Pushing branch %BRANCH_NAME% to GitHub...
git push -u origin %BRANCH_NAME%
if errorlevel 1 (
    echo.
    echo ❌ Push failed! Please check your credentials or network connection.
    pause
    exit /b 1
)

echo 🏷️ Pushing tag %VERSION% to GitHub...
git push origin %VERSION% --force >nul 2>&1
if errorlevel 1 (
    echo ℹ️ Could not push tag (may already be up to date).
) else (
    echo ✅ Tag %VERSION% pushed to GitHub!
)

:: === DONE ===
echo.
echo ==========================================================
echo  ✅ GitHub Upload Completed Successfully! [Package %VERSION%]
echo  🌐 Repo: %REPO_URL%
echo ==========================================================
echo.
pause
