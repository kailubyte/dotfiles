#!/bin/bash

# Modular font installation script
# Supports macOS and Linux

set -e

# Font configuration - add new fonts here
NERD_FONTS_VERSION="v3.1.1"
declare -A FONTS=(
    # Format: ["display_name"]="homebrew_cask:download_name:check_name"
    ["IosevkaTerm NFM"]="font-iosevka-term-nerd-font:IosevkaTerm:IosevkaTerm"
    # ["JetBrains Mono"]="font-jetbrains-mono-nerd-font:JetBrainsMono:JetBrains"
    # ["Fira Code"]="font-fira-code-nerd-font:FiraCode:FiraCode"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_font_installed() {
    local font_check_name="$1"
    case "$(uname -s)" in
        Darwin*|Linux*)
            fc-list | grep -q "$font_check_name" 2>/dev/null || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

install_font_macos() {
    local font_name="$1"
    local homebrew_cask="$2"
    
    info "Installing ${font_name} on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew is required for font installation on macOS"
    fi
    
    # Install font via Homebrew
    if ! brew list --cask "$homebrew_cask" >/dev/null 2>&1; then
        info "Installing font via Homebrew..."
        brew install --cask "$homebrew_cask"
    else
        info "Font already installed via Homebrew"
    fi
}

install_font_linux() {
    local font_name="$1"
    local download_name="$2"
    local check_name="$3"
    
    info "Installing ${font_name} on Linux..."
    
    # Create fonts directory
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    # Check if font is already installed
    if ls "$FONT_DIR"/*"$check_name"*.ttf >/dev/null 2>&1; then
        info "Font already installed in $FONT_DIR"
        return 0
    fi
    
    # Download and install font
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${download_name}.zip"
    
    info "Downloading ${font_name}..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "${download_name}.zip" "$download_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "${download_name}.zip" "$download_url"
    else
        error "Neither curl nor wget is available for downloading fonts"
    fi
    
    info "Extracting font files..."
    unzip -q "${download_name}.zip"
    
    # Copy TTF files to fonts directory
    cp *.ttf "$FONT_DIR/" 2>/dev/null || true
    
    info "Font files installed to $FONT_DIR"
    
    # Update font cache
    if command -v fc-cache >/dev/null 2>&1; then
        info "Updating font cache..."
        fc-cache -f "$FONT_DIR"
    else
        warn "fc-cache not available, font cache not updated"
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
}

install_font_linux_package_manager() {
    local font_name="$1"
    local check_name="$2"
    
    # Try to install via package manager first (limited support)
    # Note: Package manager font names vary significantly across distros
    # This is best-effort only, manual installation is more reliable
    
    if [[ "$font_name" == "IosevkaTerm NFM" ]]; then
        if command -v apt >/dev/null 2>&1; then
            # Ubuntu/Debian
            if apt list --installed 2>/dev/null | grep -q fonts-iosevka-term; then
                info "Font already installed via apt"
                return 0
            fi
            info "Trying to install via apt..."
            if sudo apt install -y fonts-iosevka-term-nerd-font 2>/dev/null; then
                info "Font installed via apt"
                return 0
            fi
        elif command -v dnf >/dev/null 2>&1; then
            # Fedora
            if dnf list installed 2>/dev/null | grep -q iosevka-term; then
                info "Font already installed via dnf"
                return 0
            fi
            info "Trying to install via dnf..."
            if sudo dnf install -y iosevka-term-fonts 2>/dev/null; then
                info "Font installed via dnf"
                return 0
            fi
        elif command -v pacman >/dev/null 2>&1; then
            # Arch Linux
            if pacman -Q ttf-iosevka-term-nerd >/dev/null 2>&1; then
                info "Font already installed via pacman"
                return 0
            fi
            info "Trying to install via pacman..."
            if sudo pacman -S --noconfirm ttf-iosevka-term-nerd 2>/dev/null; then
                info "Font installed via pacman"
                return 0
            fi
        fi
    fi
    
    # Fallback to manual installation
    warn "Package manager installation not available for $font_name, using manual installation"
    return 1
}

install_single_font() {
    local font_name="$1"
    local font_config="$2"
    
    # Parse font configuration: "homebrew_cask:download_name:check_name"
    IFS=':' read -ra PARTS <<< "$font_config"
    local homebrew_cask="${PARTS[0]}"
    local download_name="${PARTS[1]}"
    local check_name="${PARTS[2]}"
    
    info "Installing ${font_name}..."
    
    # Check if already installed
    if check_font_installed "$check_name"; then
        info "✅ ${font_name} is already installed"
        return 0
    fi
    
    case "$(uname -s)" in
        Darwin*)
            install_font_macos "$font_name" "$homebrew_cask"
            ;;
        Linux*)
            # Try package manager first, then manual installation
            if ! install_font_linux_package_manager "$font_name" "$check_name"; then
                install_font_linux "$font_name" "$download_name" "$check_name"
            fi
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac
    
    # Verify installation
    if check_font_installed "$check_name"; then
        info "✅ ${font_name} installed successfully!"
    else
        warn "Font installation completed but verification failed"
        warn "You may need to restart your terminal or update font cache manually"
    fi
}

show_usage() {
    echo "Usage: $0 [FONT_NAME|--all|--list]"
    echo ""
    echo "Options:"
    echo "  --all          Install all configured fonts"
    echo "  --list         List available fonts"
    echo "  FONT_NAME      Install specific font (e.g., 'IosevkaTerm NFM')"
    echo "  (no args)      Install all fonts (same as --all)"
    echo ""
    echo "Available fonts:"
    for font_name in "${!FONTS[@]}"; do
        echo "  - $font_name"
    done
}

main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --list)
            echo "Available fonts:"
            for font_name in "${!FONTS[@]}"; do
                if check_font_installed "${FONTS[$font_name]##*:}"; then
                    echo "  ✅ $font_name (installed)"
                else
                    echo "  ❌ $font_name (not installed)"
                fi
            done
            exit 0
            ;;
        --all|"")
            # Install all fonts
            info "Installing all configured fonts..."
            for font_name in "${!FONTS[@]}"; do
                install_single_font "$font_name" "${FONTS[$font_name]}"
            done
            ;;
        *)
            # Install specific font
            if [[ -n "${FONTS[$1]}" ]]; then
                install_single_font "$1" "${FONTS[$1]}"
            else
                error "Unknown font: $1. Use --list to see available fonts."
            fi
            ;;
    esac
    
    info "Font installation completed!"
    info "You may need to restart your terminal or configure it to use the new fonts."
}

main "$@"