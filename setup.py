import platform
import subprocess
import sys
import shutil
import os

def run_cmd(cmd, check=True):
    """Run a shell command and handle errors."""
    print(f"Running: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, check=check, capture_output=True, text=True)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Failed: {cmd}\nError: {e.stderr}")
        if check:
            sys.exit(1)
        return None

def is_installed(command):
    """Check if a command is available on the system."""
    return shutil.which(command) is not None

def is_python_installed():
    """Check if Python is installed."""
    return is_installed("python3") or is_installed("python") or is_installed("py")

def install_python(distro):
    """Install Python based on Linux distribution."""
    if distro == "ubuntu":
        run_cmd("sudo apt update")
        run_cmd("sudo apt install -y python3 python3-pip")
    elif distro == "arch":
        run_cmd("sudo pacman -Syyu --noconfirm")
        run_cmd("sudo pacman -S --noconfirm python python-pip")
    elif distro == "fedora":
        run_cmd("sudo dnf install -y python3 python3-pip")
    else:
        print(f"Unsupported Linux distribution: {distro}")
        sys.exit(1)

def install_python_windows():
    """Install Python on Windows using winget."""
    run_cmd("winget install -e --id Python.Python.3")

def detect_linux_distro():
    """Detect Linux distribution."""
    try:
        if os.path.exists("/etc/os-release"):
            with open("/etc/os-release") as f:
                os_data = f.read().lower()
                if "ubuntu" in os_data:
                    return "ubuntu"
                elif "arch" in os_data:
                    return "arch"
                elif "fedora" in os_data:
                    return "fedora"
        return None
    except Exception as e:
        print(f"Error detecting Linux distribution: {e}")
        return None

def setup_flatpak():
    """Install Flatpak and add Flathub repository."""
    distro = detect_linux_distro()
    if not distro:
        print("Could not detect Linux distribution for Flatpak setup.")
        return

    if not is_installed("flatpak"):
        print("Installing Flatpak...")
        if distro == "ubuntu":
            run_cmd("sudo apt install -y flatpak gnome-software-plugin-flatpak")
        elif distro == "arch":
            run_cmd("sudo pacman -S --noconfirm flatpak")
        elif distro == "fedora":
            run_cmd("sudo dnf install -y flatpak")
    
    print("Adding Flathub repository...")
    run_cmd("flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo", check=False)

def install_linux_tools():
    """Install tools on Linux based on distribution."""
    distro = detect_linux_distro()
    if not distro:
        print("Unsupported or undetectable Linux distribution.")
        sys.exit(1)

    print(f"Installing tools for {distro}...")

    base_install = {
        "ubuntu": "sudo apt install -y git vlc libreoffice clang docker.io gh jupyter-notebook",
        "arch": "sudo pacman -S --noconfirm git vlc libreoffice-fresh clang docker github-cli jupyter-notebook",
        "fedora": "sudo dnf install -y git vlc libreoffice clang docker-ce gh jupyter-notebook"
    }

    if distro in base_install:
        run_cmd(base_install[distro])
    else:
        print(f"No tool installation defined for {distro}")
        return

    setup_flatpak()

    flatpak_apps = {
        "org.telegram.desktop": "Telegram",
        "com.jetbrains.PyCharm-Community": "PyCharm",
        "com.google.Chrome": "Google Chrome",
        "com.brave.Browser": "Brave Browser"
    }

    for app_id, name in flatpak_apps.items():
        # Check if Flatpak app is already installed
        if run_cmd(f"flatpak list | grep {app_id}", check=False):
            print(f"{name} is already installed via Flatpak.")
            continue
        print(f"Installing {name} via Flatpak...")
        run_cmd(f"flatpak install -y flathub {app_id}", check=False)

def install_windows_tools():
    """Install tools on Windows using winget."""
    print("Installing Windows tools with winget...")

    apps = [
        "Git.Git",
        "JetBrains.PyCharm.Community",
        "Telegram.TelegramDesktop",
        "Google.Chrome",
        "Brave.Brave",
        "Microsoft.VisualStudio.2022.Community"
    ]

    for app in apps:
        # Check if app is already installed
        if run_cmd(f"winget list --id {app}", check=False):
            print(f"{app} is already installed.")
            continue
        run_cmd(f"winget install -e --id {app}", check=False)

    if not is_installed("jupyter"):
        print("Installing Jupyter Notebook...")
        run_cmd("pip install notebook")

def main():
    """Main function to orchestrate installation."""
    os_type = platform.system()
    print(f"Detected OS: {os_type}")

    # Install Python if not already installed
    if not is_python_installed():
        print("Python not found. Installing Python...")
        if os_type == "Linux":
            distro = detect_linux_distro()
            if distro:
                install_python(distro)
            else:
                print("Unsupported or undetectable Linux distribution.")
                sys.exit(1)
        elif os_type == "Windows":
            install_python_windows()
        else:
            print(f"Unsupported OS: {os_type}")
            sys.exit(1)
    else:
        print("Python is already installed.")

    # Install tools based on OS
    if os_type == "Linux":
        install_linux_tools()
    elif os_type == "Windows":
        install_windows_tools()
    else:
        print(f"Unsupported OS: {os_type}")
        sys.exit(1)

if __name__ == "__main__":
    main()