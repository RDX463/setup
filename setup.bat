@echo off
setlocal EnableDelayedExpansion
title 📦 Developer Tools Full Setup

echo === Setup Script Started at %DATE% %TIME% ===
echo.

:: Check for winget
echo 🔍 Checking for winget...
where winget >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ winget not found! Please install Windows Package Manager.
    pause
    exit /b 1
) else (
    echo ✅ winget found.
)

:: Check for Python
echo.
echo 🔍 Checking for Python...
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Python not found!
    echo Installing Python...
    winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
) else (
    echo ✅ Python already installed.
)

:: Upgrade pip
echo.
echo 🔄 Upgrading pip...
python -m pip install --upgrade pip

:: Install Jupyter Notebook
echo.
echo 📦 Installing Jupyter Notebook...
python -m pip install notebook

:: Install Visual Studio Code
echo.
echo 🖥️ Installing Visual Studio Code...
winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

:: Install Git
echo.
echo 🔧 Installing Git...
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements

:: Install Node.js
echo.
echo 🌐 Installing Node.js LTS...
winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements

:: Install Brave Browser
echo.
echo 🦁 Installing Brave Browser...
winget install -e --id Brave.Brave --accept-package-agreements --accept-source-agreements

:: Install Figma
echo.
echo 🎨 Installing Figma...
winget install -e --id Figma.Figma --accept-package-agreements --accept-source-agreements

:: Install MongoDB Compass
echo.
echo 🗃️ Installing MongoDB Compass...
winget install -e --id MongoDB.Compass.Full --accept-package-agreements --accept-source-agreements

:: Install Java (OpenJDK 21)
echo.
echo ☕ Installing Java JDK 21...
winget install -e --id EclipseAdoptium.Temurin.21.JDK --accept-package-agreements --accept-source-agreements

:: Install C++ Build Tools
echo.
echo 🛠️ Installing C++ Build Tools...
winget install -e --id Microsoft.VisualStudio.2022.BuildTools --accept-package-agreements --accept-source-agreements

:: Install Google Chrome
echo.
echo 🌐 Installing Google Chrome...
winget install -e --id Google.Chrome --accept-package-agreements --accept-source-agreements

echo.
echo ✅✅✅ All tools installed successfully!
echo === Setup Completed at %DATE% %TIME% ===
pause
exit /b 0
