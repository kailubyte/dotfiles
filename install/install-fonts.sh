#!/bin/bash

# Modular font installation script
# macOS-only

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
        Darwin*)
            fc-list | grep -q "$font_check_name" 2>/dev/null || return 1
            ;;
        *)
            error "This script only supports macOS"
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
        *)
            error "This script only supports macOS"
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