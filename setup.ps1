# setup.ps1
# Automates installation of Python and development tools on Windows using winget and pip.

# Initialize logging
$LogFile = Join-Path $PSScriptRoot "setup.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"Setup script started at $Timestamp" | Out-File -FilePath $LogFile -Append

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp : $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

# Function to run a command and handle errors
function Invoke-CommandWithErrorHandling {
    param (
        [string]$Command,
        [string]$ErrorMessage
    )
    Write-Log "Running: $Command"
    try {
        $Output = Invoke-Expression $Command 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed: $Command"
            Write-Log "Error: $Output"
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
        Write-Log "Output: $Output"
    } catch {
        Write-Log "Failed: $Command"
        Write-Log "Exception: $_"
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# Function to check if a command is available
function Test-CommandExists {
    param (
        [string]$Command
    )
    $Result = Get-Command $Command -ErrorAction SilentlyContinue
    if ($Result) {
        Write-Log "$Command is installed."
        return $true
    } else {
        Write-Log "$Command is not installed."
        return $false
    }
}

# Function to check if Python is installed
function Test-PythonInstalled {
    if (Test-CommandExists "python3") { return $true }
    if (Test-CommandExists "python") { return $true }
    if (Test-CommandExists "py") { return $true }
    Write-Log "Python is not installed."
    return $false
}

# Function to install Python
function Install-Python {
    Write-Log "Installing Python..."
    Invoke-CommandWithErrorHandling -Command "winget install -e --id Python.Python.3 --accept-package-agreements --accept-source-agreements" -ErrorMessage "Failed to install Python."
    # Update PATH
    $PythonPath = Get-ItemProperty -Path "HKLM:\Software\Python\PythonCore\*\InstallPath" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty "(default)"
    if ($PythonPath) {
        $env:Path = "$env:Path;$PythonPath;$PythonPath\Scripts"
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
        Write-Log "Updated PATH with Python: $PythonPath;$PythonPath\Scripts"
    } else {
        Write-Log "Warning: Could not find Python installation path in registry."
    }
}

# Function to install Windows tools
function Install-WindowsTools {
    Write-Log "Installing Windows tools with winget..."
    $Apps = @(
        "Git.Git",
        "JetBrains.PyCharm.Community",
        "Telegram.TelegramDesktop",
        "Google.Chrome",
        "Brave.Brave",
        "Microsoft.VisualStudio.2022.Community"
    )

    foreach ($App in $Apps) {
        Write-Log "Checking if $App is installed..."
        $Installed = winget list --id $App --exact | Select-String $App
        if ($Installed) {
            Write-Log "$App is already installed."
        } else {
            Invoke-CommandWithErrorHandling -Command "winget install -e --id $App --accept-package-agreements --accept-source-agreements" -ErrorMessage "Failed to install $App."
        }
    }

    # Check and install Jupyter Notebook
    Write-Log "Checking for Jupyter Notebook..."
    if (-not (Test-CommandExists "jupyter")) {
        Write-Log "Installing Jupyter Notebook..."
        Invoke-CommandWithErrorHandling -Command "pip install notebook" -ErrorMessage "Failed to install Jupyter Notebook."
    } else {
        Write-Log "Jupyter Notebook is already installed."
    }
}

# Main script
function Main {
    Write-Log "Detected OS: Windows"

    # Check for administrative privileges
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin) {
        Write-Log "This script requires administrative privileges. Attempting to elevate..."
        Write-Host "This script requires administrative privileges. Please approve the UAC prompt."
        Start-Process powershell -Verb RunAs -ArgumentList "-File `"$PSCommandPath`"" -Wait
        exit
    }

    # Check for winget
    Write-Log "Checking for winget..."
    if (-not (Test-CommandExists "winget")) {
        Write-Log "winget is not installed or not found in PATH. Please install Windows Package Manager."
        Write-Host "winget is not installed or not found in PATH. Please install Windows Package Manager."
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # Check for Python
    Write-Log "Checking for Python..."
    if (-not (Test-PythonInstalled)) {
        Write-Log "Python not found. Installing Python..."
        Install-Python
    } else {
        Write-Log "Python is already installed."
    }

    Install-WindowsTools

    Write-Log "Setup complete."
    Write-Host "Setup complete."
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Execute main function
Main