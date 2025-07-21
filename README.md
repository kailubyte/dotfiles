# Dotfiles

A comprehensive, cross-platform dotfiles configuration with intelligent prompt features, smart completions, and productivity enhancements for macOS and Linux.

For other setup related documentation, reference your TECH MOC in Obsidian.

## Table of Contents

- [Overview](#overview)
- [Smart ZSH Prompt](#smart-zsh-prompt)
- [Aliases and Shortcuts](#aliases-and-shortcuts)
- [FZF Integration](#fzf-integration)
- [ZSH Plugins and Features](#zsh-plugins-and-features)
- [Applications Configured](#applications-configured)
- [Installation](#installation)
- [Repository Structure](#repository-structure)
- [Customization Guide](#customization-guide)
- [Platform Support](#platform-support)

## Overview

This dotfiles configuration provides a modern, intelligent development environment with:

- Context-aware prompt that shows relevant project information
- Extensive alias system for common tasks
- Fuzzy finding integration throughout the shell
- Cross-platform support (macOS and Linux)
- Automatic dependency management
- Font installation and terminal configuration

## Smart ZSH Prompt

### Example Prompts

**Simple directory:**
```
~/.dotfiles
❯ 
```

**Node.js project with git:**
```
~/p/r/my-app node v20.1.0 npm λ:main [ ● ○ ]
❯ 
```

**Full-stack project with all contexts:**
```
~/p/r/b/infrastructure/ansible node v20.1.0 py 3.11.0 go 1.21.0 yarn gh-actions aws staging tf prod λ:feature-deploy [ ● ○ ◦ ]
❯ 
```

**After a long command:**
```
sleep 5 took 5s

~/projects
❯ 
```

### Core Features

- **Fish-style path truncation**: `~/projects/repos/bsky-util/infrastructure/ansible` becomes `~/p/r/b/infrastructure/ansible`
- **Git integration**: Branch name, status indicators (● = modified, ○ = untracked, ◦ = staged)
- **Execution timing**: Shows command duration for long-running commands  
- **Error indication**: Red cursor when last command failed, blue when successful
- **Two-line layout**: Clean separation between context and command input

### Smart Context Detection

The prompt automatically detects and displays relevant information based on your current directory:

**Language Versions**
- **Node.js**: `node v20.1.0` when `package.json` exists
- **Python**: `py 3.11.0` when virtual env active or Python project detected
- **Go**: `go 1.21.0` when `go.mod` exists  
- **Rust**: `rust 1.75.0` when `Cargo.toml` exists

**Package Managers**
- **npm**: `npm` when `package-lock.json` exists
- **Yarn**: `yarn` when `yarn.lock` exists
- **pnpm**: `pnpm` when `pnpm-lock.yaml` exists
- **Poetry**: `poetry` when `poetry.lock` exists
- **Pipenv**: `pipenv` when `Pipfile.lock` exists
- **Cargo**: `cargo` when `Cargo.lock` exists

**Development Tools**
- **AWS Profile**: `aws staging` when `$AWS_PROFILE` is set (non-default)
- **Terraform**: `tf staging` when `.tf` files exist and workspace != default
- **Docker**: `docker prod` when context != default/desktop variants

**CI/CD Detection**
- **GitHub Actions**: `gh-actions` when `.github/workflows/` exists
- **GitLab CI**: `gitlab-ci` when `.gitlab-ci.yml` exists
- **CircleCI**: `circleci` when `.circleci/config.yml` exists
- **Travis CI**: `travis` when `.travis.yml` exists
- **Azure Pipelines**: `azure` when `azure-pipelines.yml` exists
- **Jenkins**: `jenkins` when `Jenkinsfile` exists

**Git Features**
- **Worktrees**: `worktree feature-branch` when in a git worktree
- **Status indicators**: Visual symbols for modified, staged, untracked files

## Aliases and Shortcuts

### Navigation Shortcuts
```bash
dl      # cd ~/Downloads
dt      # cd ~/Desktop  
pj      # cd ~/projects
pjr     # cd ~/projects/repos
pjf     # cd ~/projects/forks
pjp     # cd ~/projects/playground
```

### Quick Commands
```bash
clr     # clear
q       # cd ~ && clear
e       # $EDITOR
x+      # chmod +x
o       # open
oo      # open . (current directory)
finder  # open . (macOS)
term    # open terminal app (cross-platform)
```

### File Operations
```bash
# Listing files
ls      # Enhanced with colors (uses lsd if available, falls back to ls with colors)
ll      # Long format listing
la      # Long format with hidden files
l       # Short alias for 'la'
lr      # Recursive listing
lh      # Human readable file sizes
lS      # Sort by file size
lt      # Tree view (when lsd is available)
lt1     # Tree view depth 1 (lsd only)
lt2     # Tree view depth 2 (lsd only)
lt3     # Tree view depth 3 (lsd only)

# File viewing
bat     # Enhanced cat with syntax highlighting (falls back to cat)
```

### Network and System
```bash
myip    # Get local IP address (cross-platform)
path    # Show $PATH in readable format
reload  # Reload ZSH configuration
```

### Update and Maintenance
```bash
update     # Run system update script
```

### Archive Operations
```bash
extract file.zip        # Extract any archive format
mkextract file.tar.gz   # Extract archive in its own directory
compress files/         # Create timestamped tar.gz
```

### Media Downloads
```bash
ytdl "video_url"        # Download single video with yt-dlp
ytdlp "playlist_url"    # Download playlist with yt-dlp
```

### Development Utilities
```bash
cheat command_name      # Get cheatsheet from cheat.sh
screenres              # Get screen resolution (Linux)
```

### Safe File Deletion
```bash
rm file.txt             # Safely move to trash (not permanent deletion)

# Alternative rm commands for permanent deletion
rmi file.txt            # Interactive rm (asks for confirmation)
rmf file.txt            # Force rm (permanent deletion, no confirmation)
```

**Platform-specific behavior:**
- **macOS**: Uses AppleScript to move files to macOS Trash
- **Linux**: Uses interactive `rm -i` for safety

## FZF Integration

FZF (fuzzy finder) is deeply integrated throughout the shell experience:

### Default Keybindings
- **Ctrl-R**: Fuzzy search command history
- **Ctrl-T**: Fuzzy find files and insert path
- **Ctrl-E**: Fuzzy navigate to directories (custom binding, replaces Alt-C)

### Enhanced Git Workflows
```bash
fgf     # Interactive git file staging/unstaging
        # Ctrl-A: add, Ctrl-R: reset, Ctrl-D: diff

fgc     # Interactive git commit browser
        # Ctrl-O: checkout, Ctrl-Y: copy hash

fgb     # Interactive git branch management
        # Ctrl-O: checkout, Ctrl-D: delete
```

### File and Text Search
```bash
fif "search_term"   # Find text in files with preview
                    # Enter/Ctrl-E: open in editor

fman               # Enhanced man page search with preview
```

### Project and Directory Navigation
```bash
fwork    # Navigate to project directories
         # Searches ~/Projects, ~/projects, ~/code, ~/dev

fpop     # Search and navigate directory stack
```

### System Management
```bash
fkill    # Process killer with fuzzy selection
         # Usage: fkill [signal_number]

fdocker  # Docker container management
         # Ctrl-S: start, Ctrl-T: stop, Ctrl-R: restart, Ctrl-D: delete

fssh     # SSH to hosts from ~/.ssh/config
```

### Custom Completions

FZF enhances standard tab completion:
- **File completion**: Uses ripgrep for faster file discovery
- **Directory completion**: Uses fd for better directory listing
- **SSH completion**: Clean host completion from ~/.ssh/config
- **Command completion**: Fuzzy matching for command arguments

### SSH Enhancement

SSH functionality includes:
- **`fssh`**: Interactive SSH host selection with fzf UI from ~/.ssh/config
- **System tab completion**: Uses built-in fzf SSH completion for `ssh` + tab
- **Smart host parsing**: Automatic discovery from ~/.ssh/config, known_hosts, and /etc/hosts

## ZSH Plugins and Features

### Installed Plugins

**Syntax Highlighting** (`zsh-syntax-highlighting`)
- Real-time syntax highlighting as you type
- Error highlighting for invalid commands
- Path highlighting for existing files

**Smart Completions** (`zsh-completions`)
- Extended completion definitions for hundreds of commands
- Context-aware completions
- Cross-platform completion paths

**Smart Dots** (`smartdots`)
- Intelligent `..` expansion
- `...` expands to `../..`, `....` to `../../..`, etc.

**BD Navigation** (`bd`)
- Quick directory navigation
- `bd project` jumps to nearest parent directory containing "project"

**Which Key** (`which-key`)
- Shows available keybindings and commands
- Help system for discovering functionality
- **Alt+W**: Show all ZSH keybindings with fuzzy search
- **Alt+A**: Show all aliases with fuzzy search  
- **Alt+F**: Show all functions with fuzzy search

**Open Command** (`open_command`)
- Cross-platform file opening
- Smart detection of `open` vs `xdg-open`

**Gitit** (`gitit`)
- Quick Git repository web navigation
- `gitit` - Opens current file/directory in GitHub/GitLab
- `gitit compare` - Opens branch comparison page
- `gitit commits` - Opens commit history
- `gitit pulls` - Opens pull requests page
- `gitit issues` - Opens issues page
- `gitit grep <term>` - Searches repository online
- `gitit ctrlp` - Opens file finder
- Auto-detects GitHub vs GitLab repositories

### ZSH Configuration Features

**History Settings**
- 10,000 command history
- Timestamp recording
- Duplicate removal
- History shared between sessions

**Navigation Enhancements**
- Auto-cd (type directory name to navigate)
- Directory stack management
- Smart pushd/popd behavior

**Completion System**
- Case-insensitive matching
- Partial word completion
- Menu-driven completion for complex commands
- Cross-platform completion paths

**Error Correction**
- Command typo correction
- Smart suggestions for mistyped commands

## Applications Configured

### Terminal
- **Ghostty**: Modern, fast terminal emulator
- **ZSH**: Shell with extensive customization
- **Fonts**: IosevkaTerm NFM (Nerd Font) automatic installation

### Development Tools
- **Neovim**: Modern text editor with full IDE features
- **Visual Studio Code**: Modern code editor with extensions
- **Git**: Enhanced configuration with useful aliases
- **FZF**: Fuzzy finder integration throughout shell

### System Tools
- **GNU Stow**: Dotfiles management via symlinks
- **Ripgrep**: Fast text search (used in prompt and FZF)
- **Bat**: Enhanced cat with syntax highlighting
- **LSD**: Enhanced ls with colors and icons

### Window Management
- **AeroSpace**: Tiling window manager (macOS)

## Installation

### Quick Start

**Clone and install:**
```bash
# HTTPS (recommended for most users)
git clone https://github.com/kailubyte/dotfiles.git ~/.dotfiles
# OR SSH (if you have SSH keys set up)
git clone git@github.com:kailubyte/dotfiles.git ~/.dotfiles

cd ~/.dotfiles
./install/install.sh
```

**Install fonts only:**
```bash
./install/install-fonts.sh
```

### Installation Options

```bash
# Full installation
./install/install.sh

# Skip dependency installation
./install/install.sh --skip-deps

# Skip font installation
./install/install.sh --skip-fonts

# Don't backup existing configs
./install/install.sh --no-backup

# Show help
./install/install.sh --help
```

### What the installer does:

1. **Installs dependencies**
   - macOS: Installs Homebrew, then packages from Brewfile
   - Linux: Installs packages via system package manager

2. **Manages dotfiles**
   - Backs up existing configurations
   - Creates symlinks using GNU Stow

3. **Sets up environment**
   - Installs fonts (IosevkaTerm NFM)
   - Configures ZSH as default shell
   - Sources all configurations

### Manual Installation

If you prefer manual setup:

```bash
# Install dependencies (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
brew bundle --file=~/.dotfiles/Brewfile

# Install dependencies (Linux - Ubuntu/Debian)
sudo apt update
sudo apt install stow git zsh ripgrep fzf

# Create symlinks
cd ~/.dotfiles
stow .

# Install fonts
./install/install-fonts.sh

# Set ZSH as default shell
chsh -s $(which zsh)
```

## Repository Structure

```
.dotfiles/
├── .config/
│   ├── ghostty/           # Terminal configuration
│   ├── git/               # Git configuration  
│   ├── nvim/              # Neovim configuration
│   └── zsh/               # ZSH configuration
│       ├── .zshrc         # Main ZSH config
│       ├── completion.zsh # Smart completions
│       ├── fzf.zsh        # Fuzzy finder setup
│       ├── scripts.zsh    # Utility functions
│       ├── plugins/       # ZSH plugins
│       │   ├── fzf-utils/ # FZF utility functions
│       │   ├── smartdots/ # Smart .. expansion
│       │   ├── bd/        # Directory navigation
│       │   └── ...        # Other plugins
│       └── prompt/
│           └── prompt_setup # Intelligent prompt
├── scripts/
│   └── update             # System update script
├── install/
│   ├── install.sh         # Main installation script
│   └── install-fonts.sh   # Font installation script
├── .zshenv                # ZSH environment variables
├── Brewfile               # macOS dependencies
└── README.md              # This file
```

## Customization Guide

### Adding Prompt Context Detection

To add detection for a new tool:

1. **Create a detection function** in `.config/zsh/prompt/prompt_setup`:
   ```zsh
   prompt_your_tool() {
       if [[ -f your-tool.config ]] && command -v your-tool >/dev/null 2>&1; then
           echo " %F{color}tool%f $(your-tool --version)"
       fi
   }
   ```

2. **Add it to the PROMPT variable**:
   ```zsh
   PROMPT=$'...$(prompt_your_tool)...'
   ```

### Adding New Aliases

Edit `.config/zsh/aliases.zsh` and add your aliases:
```bash
# Your custom aliases
alias myalias='my command'

# OS-specific aliases
case "$(uname -s)" in
    Darwin*)
        alias mac_specific='macOS command'
        ;;
    Linux*)
        alias linux_specific='Linux command'
        ;;
esac
```

### Adding FZF Functions

Add new FZF utilities to `.config/zsh/plugins/fzf-utils/fzf-utils.zsh`:

```zsh
# Your custom FZF function
fmyfunction() {
    local selection
    selection=$(your_command | fzf --height 40% --border) &&
    do_something_with "$selection"
}
```

### Adding ZSH Scripts

Add utility functions to `.config/zsh/scripts.zsh`:

```zsh
# Your custom function
myfunction() {
    # Implementation here
}
```

### Modifying Colors

Colors in the prompt use ZSH color codes:
- `%F{red}` - Red text
- `%F{green}` - Green text  
- `%F{blue}` - Blue text
- `%F{yellow}` - Yellow text
- `%F{cyan}` - Cyan text
- `%F{magenta}` - Magenta text
- `%F{white}` - White text
- `%f` - Reset color

### Adding Dependencies

**For macOS**, edit `Brewfile`:
```ruby
# Add new packages
brew "package-name"
cask "application-name"
```

**For Linux**, edit the `install_dependencies_linux()` function in `install/install.sh`.

### Adding Fonts

Edit the FONTS array in `install/install-fonts.sh`:
```bash
declare -A FONTS=(
    ["IosevkaTerm NFM"]="font-iosevka-term-nerd-font:IosevkaTerm:IosevkaTerm"
    ["Your Font"]="homebrew-cask-name:download-name:check-name"
)
```

## Platform Support

### Supported Operating Systems

- **macOS**: Full support with Homebrew integration
- **Linux**: Support for major distributions
  - Ubuntu/Debian (apt)
  - Fedora/RHEL (dnf)
  - Arch Linux (pacman)
  - openSUSE (zypper)

### Cross-Platform Features

- **OS Detection**: Consistent `uname -s` based detection
- **Package Management**: Automatic package manager detection
- **Path Handling**: Smart path resolution across platforms
- **Command Aliases**: Platform-specific command variations
- **Font Installation**: Multiple installation methods per platform

### Dependencies

**Required:**
- ZSH (shell)
- Git (version control)
- GNU Stow (symlink management)

**Optional but recommended:**
- Ripgrep (`rg`) - Fast text search
- FZF - Fuzzy finding
- Bat - Enhanced cat
- LSD - Enhanced ls
- FD - Enhanced find
- Native trash support (macOS Finder integration, Linux interactive rm)

**Language Tools (auto-detected):**
- Node.js - For Node project detection
- Python - For Python project detection  
- Go - For Go project detection
- Rust - For Rust project detection

## Environment Variables

The configuration respects several environment variables:

- `DOTFILES` - Path to dotfiles directory (default: `~/.dotfiles`)
- `EDITOR` - Preferred editor (auto-detected: nvim > vim > vi)
- `FZF_DEFAULT_COMMAND` - Default FZF file discovery command
- `FZF_DEFAULT_OPTS` - FZF color scheme and options
- `AWS_PROFILE` - AWS profile for prompt display
- `VIRTUAL_ENV` - Python virtual environment detection

## Troubleshooting

### Common Issues

**ZSH not default shell:**
```bash
# Check current shell
echo $SHELL

# Change to ZSH
sudo chsh -s $(which zsh) $USER
# Log out and log back in
```

**Prompt not showing:**
```bash
# Reload configuration
source ~/.zshenv
source ~/.config/zsh/.zshrc
```

**Font not displaying correctly:**
```bash
# Install fonts
./install/install-fonts.sh

# Configure terminal to use IosevkaTerm NFM
```

**FZF keybindings not working:**
```bash
# Check FZF installation
which fzf

# Reload ZSH configuration
exec zsh
```

### Debug Mode

Enable debug output for troubleshooting:
```bash
# Show prompt function output
set -x
source ~/.config/zsh/prompt/prompt_setup
set +x
```

## License

MIT License - feel free to fork and customize for your own needs.

---

This configuration emphasizes productivity, performance, and developer experience with intelligent context detection and minimal visual clutter.
