# Dotfiles

My personal dotfiles configuration using GNU Stow for macOS.

## Structure

This dotfiles repository uses a **split structure** to organize configurations:

```
.dotfiles/
├── macos/          # macOS-specific configurations
│   ├── .zshenv     # macOS environment variables (Homebrew paths, SSH FIDO2)
│   ├── .gitconfig  # macOS-specific Git settings
│   └── .config/    # macOS-specific XDG configs
│       ├── zsh/    # macOS zsh configuration
│       ├── ghostty/# Terminal emulator config
│       └── aerospace/ # Window manager config
└── common/         # Shared configurations
    └── .config/    # Shared XDG configs
        ├── git/    # Global Git settings
        ├── nvim/   # Neovim configuration
        ├── tmux/   # Terminal multiplexer config
        └── zsh/    # Shared zsh plugins and utilities
```

## Features

### macOS Optimized
- **Homebrew**: Package management and application installation
- **SSH FIDO2**: Hardware security key support for Git signing
- **Development Tools**: Modern CLI tools and editor configurations

### Security
- **SSH FIDO2**: Hardware security key support for Git signing
- **Homebrew OpenSSH**: Uses Homebrew's OpenSSH with libfido2 on macOS
- **Git Signing**: Automatic commit signing with SSH keys

### Shell Configuration
- **Zsh**: Modern shell with plugins and custom prompt
- **Aliases**: Comprehensive set of useful aliases
- **FZF Integration**: Fuzzy finding for files and command history
- **Syntax Highlighting**: Real-time command syntax highlighting

### Development Tools
- **Neovim**: Modern Vim configuration with LazyVim
- **Git**: Enhanced Git workflow with useful aliases
- **Terminal**: Ghostty terminal with custom configuration
- **Window Management**: AeroSpace tiling window manager (macOS)

## Installation

### Automated Install (Recommended)

The easiest way to install these dotfiles is using the automated install script:

```bash
# Download and run the install script
curl -fsSL https://raw.githubusercontent.com/kailubyte/dotfiles/main/install/install.sh | bash
```

**Or clone first, then run:**
```bash
git clone https://github.com/kailubyte/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install/install.sh
```

**To use a different repository (if you forked this):**
```bash
export DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install/install.sh | bash
```

The script automatically:
- Installs dependencies (Homebrew, git, stow, zsh)
- Clones the repository and initializes submodules
- Backs up existing configurations
- Installs packages from macOS package list
- Deploys configurations using GNU Stow
- Sets up zsh as the default shell

### Manual Install

If you prefer manual installation:

**Prerequisites:**

Install required tools:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git stow
```

**Steps:**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kailubyte/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Initialize submodules:**
   ```bash
   git submodule update --init --recursive
   ```

3. **Install packages:**
   ```bash
   brew bundle --file=packages/macos.txt
   ```

4. **Deploy configurations:**
   ```bash
   # Deploy macOS configs
   stow macos
   
   # Deploy shared configs
   stow common
   ```

## Package Management

All packages are defined in `packages/macos.txt` using Homebrew Bundle format:
- CLI tools and development dependencies
- Applications via Homebrew Cask
- Fonts and system utilities

## Configuration Management

### Whitelisted Configs
This repository uses a **whitelist approach** to prevent bloat from random application configs:

**Tracked configs:**
- `aerospace/` - Window manager
- `ghostty/` - Terminal emulator
- `git/` - Version control
- `nvim/` - Text editor
- `tmux/` - Terminal multiplexer
- `zsh/` - Shell configuration

**Ignored:** Discord, Slack, VSCode auto-generated configs, cache files, etc.

### Adding New Configs

To track a new application config:

1. **Add to Git whitelist (`.gitignore`):**
   ```bash
   !*/.config/newapp/
   !*/.config/newapp/**
   ```

2. **Add to Stow whitelist (`.stow-local-ignore`):**
   ```bash
   !.*/.config/newapp$
   !.*/.config/newapp/.*
   ```

3. **Place config in appropriate directory:**
   ```bash
   # macOS-specific
   macos/.config/newapp/
   
   # Or shared
   common/.config/newapp/
   ```

## Usage

### Daily Commands
```bash
# Quick edit dotfiles
dotfiles                  # Opens dotfiles in editor

# Navigate to dotfiles
dotf                      # cd ~/.dotfiles

# Reload shell configuration
reload                    # Sources zsh config

# Update system packages
update                    # Runs update script
```

### Git Integration
- **Automatic signing**: Commits are signed with SSH keys
- **FIDO2 support**: Hardware security keys for authentication
- **Useful aliases**: `gs`, `ga`, `gc`, `gp`, etc.

### Package Updates
```bash
# Update all packages
./scripts/update

# Update Homebrew packages
brew upgrade
```

## Customization

### Environment Variables
- **macOS**: Edit `macos/.zshenv`
- **Shared**: Add to `macos/.zshenv`

### Aliases
- **Shared aliases**: `common/.config/zsh/common-aliases.zsh`
- **macOS-specific**: `macos/.config/zsh/aliases.zsh`

### Applications
- **Applications**: Add to `packages/macos.txt`

## Security Considerations

- SSH keys with FIDO2 hardware authentication
- Homebrew analytics disabled
- Git commit signing enabled by default
- No sensitive information stored in repository

## Troubleshooting

### Common Issues

**"No FIDO SecurityKeyProvider specified"**
- Ensure `libfido2` is installed
- Verify Homebrew's OpenSSH is being used (macOS)
- Check Git is configured to use correct ssh-keygen

**Aliases not working**
- Verify symlinks: `ls -la ~/.zshrc ~/.zshenv`
- Check environment variables: `echo $DOTFILES $ZDOTDIR`
- Reload shell: `source ~/.zshrc`

**Stow conflicts**
- Remove existing files: `rm ~/.zshrc` (backup first)
- Use `stow -R` to restow
- Check `.stow-local-ignore` for excluded files

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements via pull requests

---

**Note**: This configuration is optimized for my personal workflow. You may need to adapt package lists, aliases, and configurations for your specific needs.