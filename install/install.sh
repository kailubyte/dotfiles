#!/usr/bin/env bash

# macOS dotfiles installation script
# macOS-only with dependency checking

set -e

# Set up logging
LOG_DIR="$HOME/dotfile-logs"
mkdir -p "$LOG_DIR"
LOGFILE="$LOG_DIR/dotfiles-install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

# Output function helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step() { echo -e "\n${BLUE}[STEP]${NC} $1\n"; }

# Check if running on macOS
check_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        *) error "This script only supports macOS" ;;
    esac
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

validate_package_file() {
    local file="$1"
    [[ -f "$file" && -r "$file" ]] || error "Package file missing or unreadable: $file"
    grep -v '^#' "$file" | grep -v '^$' | grep -q . || { warn "No installable packages found in $file"; return 1; }
    info "Validated package list: $file"
    return 0
}

install_homebrew() {
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
        
        # Add Homebrew to PATH for current session
        if [[ -d "/opt/homebrew/bin" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -d "/usr/local/bin" ]]; then
            export PATH="/usr/local/bin:$PATH"
        fi
    fi
}

install_git() {
    if ! command_exists git; then
        info "Installing Git via Homebrew..."
        brew install git || error "Failed to install Git"
    fi
}

install_stow() {
    if ! command_exists stow; then
        info "Installing Stow via Homebrew..."
        brew install stow || error "Failed to install Stow"
    fi
}

install_zsh() {
    if ! command_exists zsh; then
        info "Installing ZSH via Homebrew..."
        brew install zsh || error "Failed to install ZSH"
    fi
}

install_packages() {
    local packages_file="$HOME/.dotfiles/packages/macos.txt"
    validate_package_file "$packages_file" || return 1

    step "Installing packages from Homebrew Brewfile"
    cd "$HOME/.dotfiles"
    brew bundle --file="$packages_file" || error "Homebrew bundle install failed"
}

clone_dotfiles() {
    local dir="$HOME/.dotfiles"
    if [[ ! -d "$dir" ]]; then
        # Try to detect repository URL from environment or use default
        local repo_url="${DOTFILES_REPO:-https://github.com/kailubyte/dotfiles.git}"
        info "Cloning dotfiles from: $repo_url"
        git clone "$repo_url" "$dir" || error "Clone failed"
        cd "$dir"
        git submodule update --init --recursive || error "Submodule init failed"
    else
        cd "$dir"
        [[ -f .gitmodules ]] && git submodule update --init --recursive
    fi
}

backup_and_stow() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    
    info "Backing up and stowing dotfiles..."
    cd "$HOME/.dotfiles"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    info "Created backup directory: $backup_dir"
    
    # Backup existing files that would conflict
    local files_to_check=(".zshenv" ".gitconfig")
    local backed_up_count=0
    
    # Also backup .config directory if it exists and isn't a symlink
    if [[ -e "$HOME/.config" && ! -L "$HOME/.config" ]]; then
        info "Backing up existing .config directory"
        mv "$HOME/.config" "$backup_dir/config"
        ((backed_up_count++))
    fi
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            mv "$HOME/$file" "$backup_dir/"
            info "Backed up: $file"
            ((backed_up_count++))
        fi
    done
    
    # Stow macOS dotfiles first
    info "Stowing macOS dotfiles..."
    stow -v macos || error "Failed to stow macOS dotfiles"
    
    # Then stow common dotfiles  
    info "Stowing common dotfiles..."
    stow -v common || error "Failed to stow common dotfiles"
    
    if [[ $backed_up_count -gt 0 ]]; then
        info "Backed up $backed_up_count files to $backup_dir"
    fi
}

setup_zsh() {
    step "Configuring ZSH"
    
    # Check if ZSH is installed
    if ! command_exists zsh; then
        error "ZSH is not installed - this should have been installed earlier"
    fi
    
    ZSH_PATH="$(command -v zsh)"
    info "Found ZSH at: $ZSH_PATH"
    
    # Check current shell
    info "Current shell: $SHELL"
    
    # Add zsh to /etc/shells if not already there
    if ! grep -qxF "$ZSH_PATH" /etc/shells; then
        info "Adding ZSH to /etc/shells"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null || error "Failed to add ZSH to /etc/shells"
    else
        info "ZSH is already in /etc/shells"
    fi
    
    # Change default shell if needed
    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        info "Setting ZSH as default shell for $USER"
        sudo chsh -s "$ZSH_PATH" "$USER" || error "Failed to change default shell to ZSH"
        info "Default shell changed to ZSH (restart terminal to take effect)"
    else
        info "ZSH is already the default shell"
    fi
    
    info "ZSH configuration complete"
}


post_install_message() {
    echo -e "\n${GREEN}ð Dotfiles installation complete!${NC}"
    echo "Log file saved to: $LOGFILE"
}

main() {
    step "Checking macOS compatibility"
    check_os

    step "Installing base dependencies"
    install_homebrew
    install_git
    install_stow
    install_zsh

    step "Cloning dotfiles"
    clone_dotfiles

    step "Backing up conflicting files and stowing dotfiles"
    backup_and_stow

    step "Installing packages"
    install_packages

    setup_zsh
    post_install_message
}

main "$@"
