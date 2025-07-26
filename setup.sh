#!/bin/bash

# Function to run a command and exit on failure
run_cmd() {
    echo "Running: $1"
    if ! $1; then
        echo "Failed: $1"
        exit 1
    fi
}

# Function to check if a command is available
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Python is installed
is_python_installed() {
    is_installed python3 || is_installed python || is_installed py
}

# Function to install Python based on distribution
install_python() {
    local distro=$1
    case "$distro" in
        (ubuntu)
            run_cmd "sudo apt update"
            run_cmd "sudo apt install -y python3 python3-pip"
            ;;
        (arch)
            run_cmd "sudo pacman -Syyu --noconfirm"
            run_cmd "sudo pacman -S --noconfirm python python-pip"
            ;;
        (fedora)
            run_cmd "sudo dnf install -y python3 python3-pip"
            ;;
        (*)
            echo "Unsupported Linux distribution: $distro"
            exit 1
            ;;
    esac
}

# Function to detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            (ubuntu) echo "ubuntu" ;;
            (arch) echo "arch" ;;
            (fedora) echo "fedora" ;;
            (*) echo "" ;;
        esac
    else
        echo ""
    fi
}

# Function to set up Flatpak
setup_flatpak() {
    local distro=$1
    if ! is_installed flatpak; then
        echo "Installing Flatpak..."
        case "$distro" in
            (ubuntu)
                run_cmd "sudo apt install -y flatpak gnome-software-plugin-flatpak"
                ;;
            (arch)
                run_cmd "sudo pacman -S --noconfirm flatpak"
                ;;
            (fedora)
                run_cmd "sudo dnf install -y flatpak"
                ;;
        esac
    fi
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || echo "Failed to add Flathub repo, continuing..."
}

# Function to install Linux tools
install_linux_tools() {
    local distro=$1
    echo "Installing tools for $distro..."

    case "$distro" in
        (ubuntu)
            run_cmd "sudo apt install -y git vlc libreoffice clang docker.io gh jupyter-notebook"
            ;;
        (arch)
            run_cmd "sudo pacman -S --noconfirm git vlc libreoffice-fresh clang docker github-cli jupyter-notebook"
            ;;
        (fedora)
            run_cmd "sudo dnf install -y git vlc libreoffice clang docker-ce gh jupyter-notebook"
            ;;
        (*)
            echo "No tool installation defined for $distro"
            return
            ;;
    esac

    setup_flatpak "$distro"

    # Flatpak apps
    flatpak_apps=(
        "org.telegram.desktop Telegram"
        "com.jetbrains.PyCharm-Community PyCharm"
        "com.google.Chrome Google Chrome"
        "com.brave.Browser Brave Browser"
    )

    for app in "${flatpak_apps[@]}"; do
        app_id=$(echo "$app" | cut -d' ' -f1)
        app_name=$(echo "$app" | cut -d' ' -f2-)
        if flatpak list | grep -q "$app_id"; then
            echo "$app_name is already installed via Flatpak."
        else
            echo "Installing $app_name via Flatpak..."
            flatpak install -y flathub "$app_id" || echo "Failed to install $app_name, continuing..."
        fi
    done
}

# Main function
main() {
    if [ "$(uname)" != "Linux" ]; then
        echo "This script is for Linux only."
        exit 1
    fi

    distro=$(detect_linux_distro)
    if [ -z "$distro" ]; then
        echo "Unsupported or undetectable Linux distribution."
        exit 1
    fi
    echo "Detected distribution: $distro"

    if ! is_python_installed; then
        echo "Python not found. Installing Python..."
        install_python "$distro"
    else
        echo "Python is already installed."
    fi

    install_linux_tools "$distro"
}

main