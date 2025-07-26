# System Setup Script

This script (`setup.py`) automates the installation of Python and a set of development tools on Linux (Ubuntu, Arch, Fedora) and Windows systems. It detects the operating system and, for Linux, the specific distribution, then installs Python, package managers, and common tools like Git, VLC, LibreOffice, and more.

## Features

- **Cross-Platform Support**: Works on Linux (Ubuntu, Arch, Fedora) and Windows.
- **Python Installation**: Installs Python 3 and pip if not already present.
- **Tool Installation**:
  - Linux: Installs tools like Git, VLC, LibreOffice, Clang, Docker, GitHub CLI, and Jupyter Notebook via native package managers. Also installs Flatpak and applications like Telegram, PyCharm, Google Chrome, and Brave Browser.
  - Windows: Installs tools like Git, PyCharm, Telegram, Google Chrome, Brave Browser, and Visual Studio Community using winget, plus Jupyter Notebook via pip.
- **Error Handling**: Provides detailed error messages and skips non-critical failures to ensure partial success.
- **Idempotency**: Checks for existing installations to avoid redundant setups.

## Prerequisites

- **Linux**:
  - Supported distributions: Ubuntu, Arch, Fedora.
  - `sudo` access for installing packages.
  - Internet connection for downloading packages.
- **Windows**:
  - `winget` (Windows Package Manager) installed (available by default on Windows 10 1709+ and Windows 11).
  - Internet connection for downloading packages.
- Python 3 (if running the script on a system where Python is already installed).

## Usage

1. **Clone or Download the Script**:
   ```bash
   git clone https://github.com/RDX463/setup.git
   cd setup
   ```

2. **Run the Script**:
   ```bash
   python3 setup.py
   ```

3. **Follow Prompts**:
   - The script will detect the OS and, for Linux, the distribution.
   - It will install Python (if not already installed) and the specified tools.
   - You may be prompted for `sudo` passwords on Linux or admin permissions on Windows.

## Installed Tools

### Linux
- **Native Packages** (via apt, pacman, or dnf):
  - Git
  - VLC
  - LibreOffice
  - Clang
  - Docker
  - GitHub CLI
  - Jupyter Notebook
- **Flatpak Applications** (via Flathub):
  - Telegram
  - PyCharm Community
  - Google Chrome
  - Brave Browser

### Windows
- **winget Packages**:
  - Git
  - PyCharm Community
  - Telegram Desktop
  - Google Chrome
  - Brave Browser
  - Microsoft Visual Studio Community 2022
- **pip Packages**:
  - Jupyter Notebook

## Notes

- **Docker Configuration**: The script installs Docker but does not configure it (e.g., adding the user to the `docker` group on Linux). You may need to run additional commands like `sudo usermod -aG docker $USER` on Linux.
- **Flatpak/Winget Failures**: If a Flatpak or winget installation fails (e.g., due to network issues), the script will log the error and continue with other installations.
- **Python Version**: The script installs the default Python version for the system. For specific versions, modify the `install_python` function in `setup.py`.
- **Permissions**: On Linux, ensure you have `sudo` access. On Windows, run the script in a terminal with administrator privileges if prompted.

## Troubleshooting

- **Command Failures**: Check the console output for error messages. The script captures and displays errors for failed commands.
- **Unsupported OS/Distribution**: If the script detects an unsupported OS or Linux distribution, it will exit with an error message. Supported distributions are Ubuntu, Arch, and Fedora.
- **Existing Installations**: The script checks for existing installations to avoid redundant setups. If an installation fails, verify your internet connection and package manager configuration.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue on the repository for bugs, feature requests, or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
