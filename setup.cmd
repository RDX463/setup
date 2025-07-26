@echo off
setlocal EnableDelayedExpansion

:: Function to run a command and exit on failure
:run_cmd
echo Running: %1
%1
if %ERRORLEVEL% neq 0 (
    echo Failed: %1
    exit /b 1
)
exit /b 0

:: Function to check if a command is available
:is_installed
where %1 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    exit /b 0
) else (
    exit /b 1
)
goto :eof

:: Function to check if Python is installed
:is_python_installed
call :is_installed python3
if %ERRORLEVEL% equ 0 exit /b 0
call :is_installed python
if %ERRORLEVEL% equ 0 exit /b 0
call :is_installed py
if %ERRORLEVEL% equ 0 exit /b 0
exit /b 1
goto :eof

:: Function to install Python
:install_python_windows
echo Installing Python...
call :run_cmd "winget install -e --id Python.Python.3"
exit /b 0

:: Function to install Windows tools
:install_windows_tools
echo Installing Windows tools with winget...

set "apps=Git.Git JetBrains.PyCharm.Community Telegram.TelegramDesktop Google.Chrome Brave.Brave Microsoft.VisualStudio.2022.Community"

for %%a in (%apps%) do (
    winget list --id %%a >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo %%a is already installed.
    ) else (
        call :run_cmd "winget install -e --id %%a"
    )
)

:: Check if Jupyter is installed
where jupyter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Installing Jupyter Notebook...
    call :run_cmd "pip install notebook"
) else (
    echo Jupyter Notebook is already installed.
)
exit /b 0

:: Main script
:main
echo Detected OS: Windows

:: Check for Python
call :is_python_installed
if %ERRORLEVEL% neq 0 (
    echo Python not found. Installing Python...
    call :install_python_windows
) else (
    echo Python is already installed.
)

call :install_windows_tools

echo Setup complete.
pause
exit /b 0

call :main