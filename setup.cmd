@echo off
setlocal EnableDelayedExpansion

:: Initialize log file
set "LOGFILE=%~dp0setup.log"
echo Setup script started at %DATE% %TIME% > "%LOGFILE%"

:: Check for administrative privileges
echo Checking for administrative privileges... >> "%LOGFILE%"
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo This script requires administrative privileges. Please run as Administrator. >> "%LOGFILE%"
    echo This script requires administrative privileges. Please run as Administrator.
    pause
    exit /b 1
)

:: Function to run a command and handle errors
:run_cmd
set "cmd=%~1"
echo Running: %cmd% >> "%LOGFILE%"
echo Running: %cmd%
%cmd% >> "%LOGFILE%" 2>&1
if %ERRORLEVEL% neq 0 (
    echo Failed: %cmd% >> "%LOGFILE%"
    echo Failed: %cmd%
    pause
    exit /b 1
)
exit /b 0

:: Function to check if a command is available
:is_installed
where %1 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo %1 is installed. >> "%LOGFILE%"
    exit /b 0
) else (
    echo %1 is not installed. >> "%LOGFILE%"
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
echo Python is not installed. >> "%LOGFILE%"
exit /b 1
goto :eof

:: Function to install Python
:install_python_windows
echo Installing Python... >> "%LOGFILE%"
echo Installing Python...
call :run_cmd "winget install -e --id Python.Python.3 --accept-package-agreements --accept-source-agreements"
:: Update PATH to include Python
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Python\PythonCore" /s /v InstallPath ^| findstr InstallPath') do (
    set "PYTHON_PATH=%%b\Scripts"
    set "PATH=%PATH%;%%b;%PYTHON_PATH%"
    echo Updated PATH with Python: %%b;%PYTHON_PATH% >> "%LOGFILE%"
)
exit /b 0

:: Function to install Windows tools
:install_windows_tools
echo Installing Windows tools with winget... >> "%LOGFILE%"
echo Installing Windows tools with winget...

set "apps=Git.Git JetBrains.PyCharm.Community Telegram.TelegramDesktop Google.Chrome Brave.Brave Microsoft.VisualStudio.2022.Community"

for %%a in (%apps%) do (
    echo Checking if %%a is installed... >> "%LOGFILE%"
    echo Checking if %%a is installed...
    winget list --id %%a --exact | findstr /C:"%%a" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo %%a is already installed. >> "%LOGFILE%"
        echo %%a is already installed.
    ) else (
        call :run_cmd "winget install -e --id %%a --accept-package-agreements --accept-source-agreements"
    )
)

:: Check if Jupyter is installed
echo Checking for Jupyter Notebook... >> "%LOGFILE%"
echo Checking for Jupyter Notebook...
where jupyter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Installing Jupyter Notebook... >> "%LOGFILE%"
    echo Installing Jupyter Notebook...
    call :run_cmd "pip install notebook"
) else (
    echo Jupyter Notebook is already installed. >> "%LOGFILE%"
    echo Jupyter Notebook is already installed.
)
exit /b 0

:: Main script
echo Detected OS: Windows >> "%LOGFILE%"
echo Detected OS: Windows

:: Check for winget
echo Checking for winget... >> "%LOGFILE%"
where winget >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo winget is not installed or not found in PATH. Please install Windows Package Manager. >> "%LOGFILE%"
    echo winget is not installed or not found in PATH. Please install Windows Package Manager.
    pause
    exit /b 1
)

:: Check for Python
echo Checking for Python... >> "%LOGFILE%"
call :is_python_installed
if %ERRORLEVEL% neq 0 (
    echo Python not found. Installing Python... >> "%LOGFILE%"
    echo Python not found. Installing Python...
    call :install_python_windows
) else (
    echo Python is already installed. >> "%LOGFILE%"
    echo Python is already installed.
)

call :install_windows_tools

echo Setup complete. >> "%LOGFILE%"
echo Setup complete.
pause
exit /b 0
