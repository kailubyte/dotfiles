#!/usr/bin/env bash

# Comprehensive dotfiles installation script
# Supports macOS and Linux with dependency checking and OS detection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/kailubyte/dotfiles.git"

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

step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

check_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for the current session
        case "$(uname -m)" in
            arm64)
                eval "$(/opt/homebrew/bin/brew shellenv)"
                ;;
            x86_64)
                eval "$(/usr/local/bin/brew shellenv)"
                ;;
        esac
    else
        info "Homebrew already installed"
    fi
    
    # Disable Homebrew analytics
    info "Disabling Homebrew analytics..."
    brew analytics off
}

install_stow_macos() {
    if ! command_exists stow; then
        info "Installing GNU Stow via Homebrew..."
        brew install stow
    else
        info "GNU Stow already installed"
    fi
}

install_stow_linux() {
    if ! command_exists stow; then
        info "Installing GNU Stow..."
        if command_exists apt; then
            sudo apt update && sudo apt install -y stow
        elif command_exists dnf; then
            sudo dnf install -y stow
        elif command_exists pacman; then
            sudo pacman -S --noconfirm stow
        elif command_exists zypper; then
            sudo zypper install -y stow
        else
            error "Cannot install stow: no supported package manager found"
        fi
    else
        info "GNU Stow already installed"
    fi
}

install_git_linux() {
    if ! command_exists git; then
        info "Installing Git..."
        if command_exists apt; then
            sudo apt update && sudo apt install -y git
        elif command_exists dnf; then
            sudo dnf install -y git
        elif command_exists pacman; then
            sudo pacman -S --noconfirm git
        elif command_exists zypper; then
            sudo zypper install -y git
        else
            error "Cannot install git: no supported package manager found"
        fi
    else
        info "Git already installed"
    fi
}

clone_dotfiles() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        if [[ -n "${DOTFILES_REPO:-}" ]]; then
            info "Cloning dotfiles from $DOTFILES_REPO..."
            git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
            
            # Initialize and update submodules
            info "Initializing git submodules..."
            cd "$DOTFILES_DIR"
            git submodule update --init --recursive
        else
            info "Dotfiles directory not found and no repository specified"
            info "Please clone your dotfiles to $DOTFILES_DIR manually"
            error "Cannot proceed without dotfiles"
        fi
    else
        info "Dotfiles directory already exists at $DOTFILES_DIR"
        
        # Update submodules if they exist
        cd "$DOTFILES_DIR"
        if [[ -f .gitmodules ]]; then
            info "Updating git submodules..."
            git submodule update --init --recursive
        fi
    fi
}

backup_existing_configs() {
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    local files_to_backup=(".zshenv" ".zshrc")
    local backed_up=false
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
            if [[ "$backed_up" == false ]]; then
                info "Creating backup directory: $backup_dir"
                mkdir -p "$backup_dir"
                backed_up=true
            fi
            info "Backing up existing $file"
            mv "$HOME/$file" "$backup_dir/"
        fi
    done
    
    if [[ "$backed_up" == true ]]; then
        info "Existing configs backed up to $backup_dir"
    fi
}

stow_dotfiles() {
    info "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    
    # Stow main dotfiles (creates symlinks in $HOME)
    # Ignore install/ and scripts/ directories to prevent unwanted symlinks
    stow --ignore='install|scripts' -v .
    
    info "Dotfiles stowed successfully"
}

fix_zsh_compaudit() {
    info "Fixing ZSH completion security warnings..."
    
    # Fix permissions on Homebrew directories that ZSH complains about
    local homebrew_dirs=(
        "/opt/homebrew/share"
        "/opt/homebrew/share/zsh"
        "/opt/homebrew/share/zsh/site-functions"
        "/usr/local/share"
        "/usr/local/share/zsh"
        "/usr/local/share/zsh/site-functions"
    )
    
    for dir in "${homebrew_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            sudo chmod -R 755 "$dir" 2>/dev/null || true
            sudo chown -R $(whoami):$(id -gn) "$dir" 2>/dev/null || true
        fi
    done
    
    # Rebuild zcompdump
    if [[ -f ~/.zcompdump ]]; then
        rm -f ~/.zcompdump*
        info "Removed zcompdump files - they will be rebuilt on next zsh start"
    fi
}

install_dependencies_macos() {
    step "Installing macOS dependencies..."
    
    # Install Homebrew packages
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        info "Installing packages from Brewfile..."
        cd "$DOTFILES_DIR"
        brew bundle --file=Brewfile
        
        # Note: Using native AppleScript trash function - no external tools needed
        
        # Fix ZSH compaudit warnings
        fix_zsh_compaudit
    else
        warn "Brewfile not found, skipping package installation"
    fi
}

install_dependencies_linux() {
    step "Installing Linux dependencies..."
    
    # Basic development tools
    local packages=(
        "git" "zsh" "curl" "wget" "unzip"
        "build-essential" "software-properties-common"
        "fontconfig" "ripgrep" "fzf" "bat"
    )
    
    if command_exists apt; then
        info "Installing packages via apt..."
        sudo apt update
        # Convert package names for apt
        packages=("${packages[@]/build-essential/build-essential}")
        packages=("${packages[@]/software-properties-common/software-properties-common}")
        sudo apt install -y "${packages[@]}" 2>/dev/null || true
        
        # Try to install additional packages
        sudo apt install -y lsd fd-find exa 2>/dev/null || true
        
    elif command_exists dnf; then
        info "Installing packages via dnf..."
        packages=("${packages[@]/build-essential/gcc gcc-c++ make}")
        packages=("${packages[@]/software-properties-common/}")
        sudo dnf install -y "${packages[@]}" 2>/dev/null || true
        
    elif command_exists pacman; then
        info "Installing packages via pacman..."
        packages=("${packages[@]/build-essential/base-devel}")
        packages=("${packages[@]/software-properties-common/}")
        sudo pacman -S --noconfirm "${packages[@]}" 2>/dev/null || true
        
    else
        warn "No supported package manager found for Linux dependencies"
    fi
    
    # Install Rust (used by prompt)
    if ! command_exists rustc; then
        info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
}

install_fonts() {
    step "Installing fonts..."
    
    if [[ -x "$DOTFILES_DIR/install/install-fonts.sh" ]]; then
        "$DOTFILES_DIR/install/install-fonts.sh"
    else
        warn "Font installation script not found or not executable"
    fi
}

setup_zsh() {
    step "Setting up ZSH..."
    
    # Check if ZSH is installed
    if ! command_exists zsh; then
        error "ZSH is not installed. Please install it first."
    fi
    
    # Set ZSH as default shell if it isn't already
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        info "Setting ZSH as default shell..."
        sudo chsh -s "$(which zsh)" "$USER"
        info "Please log out and log back in for the shell change to take effect"
    else
        info "ZSH is already the default shell"
    fi
}

post_install_message() {
    echo ""
    echo -e "${GREEN}🎉 Dotfiles installation completed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshenv && source ~/.config/zsh/.zshrc"
    echo "2. Configure your terminal to use the IosevkaTerm NFM font"
    echo "3. Enjoy your new development environment!"
    echo ""
    
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo -e "${YELLOW}⚠️  Remember to log out and log back in to use ZSH as your default shell${NC}"
        echo ""
    fi
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --skip-deps    Skip dependency installation"
    echo "  --skip-fonts   Skip font installation"
    echo "  --no-backup    Don't backup existing config files"
    echo ""
    echo "Environment variables:"
    echo "  DOTFILES_REPO  Git repository URL to clone (if not already present)"
    echo ""
    echo "This script will:"
    echo "1. Install required dependencies (Git, Stow, etc.)"
    echo "2. Clone dotfiles repository (if needed)"
    echo "3. Backup existing config files"
    echo "4. Stow dotfiles to create symlinks"
    echo "5. Install platform-specific dependencies"
    echo "6. Install fonts"
    echo "7. Set up ZSH as default shell"
}

main() {
    local skip_deps=false
    local skip_fonts=false
    local no_backup=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --skip-fonts)
                skip_fonts=true
                shift
                ;;
            --no-backup)
                no_backup=true
                shift
                ;;
            *)
                error "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done
    
    local os_type
    os_type=$(check_os)
    
    info "Starting dotfiles installation for $os_type..."
    
    # Step 1: Install basic dependencies
    if [[ "$skip_deps" == false ]]; then
        step "Installing basic dependencies..."
        case "$os_type" in
            macos)
                install_homebrew
                install_stow_macos
                ;;
            linux)
                install_git_linux
                install_stow_linux
                ;;
        esac
    fi
    
    # Step 2: Clone dotfiles if needed
    clone_dotfiles
    
    # Step 3: Backup existing configs
    if [[ "$no_backup" == false ]]; then
        step "Backing up existing configurations..."
        backup_existing_configs
    fi
    
    # Step 4: Stow dotfiles
    step "Creating symlinks with GNU Stow..."
    stow_dotfiles
    
    # Step 5: Install platform-specific dependencies
    if [[ "$skip_deps" == false ]]; then
        case "$os_type" in
            macos)
                install_dependencies_macos
                ;;
            linux)
                install_dependencies_linux
                ;;
        esac
    fi
    
    # Step 6: Install fonts
    if [[ "$skip_fonts" == false ]]; then
        install_fonts
    fi
    
    # Step 7: Setup ZSH
    setup_zsh
    
    # Done!
    post_install_message
}

main "$@"