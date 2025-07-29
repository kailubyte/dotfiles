#!/usr/bin/env zsh

# macOS fzf configuration

# Set fzf paths for Homebrew
if command -v brew >/dev/null 2>&1; then
    FZF_BASE="$(brew --prefix fzf)"
    FZF_KEY_BINDINGS="${FZF_BASE}/shell/key-bindings.zsh"
    FZF_COMPLETION="${FZF_BASE}/shell/completion.zsh"
fi

# Load fzf default keybindings:
# - Ctrl-R: fuzzy search command history
# - Ctrl-T: fuzzy find files and insert path
# - Alt-C: fuzzy cd to directory (we'll rebind this below)
[[ -f "$FZF_KEY_BINDINGS" ]] && source "$FZF_KEY_BINDINGS"

# CUSTOM KEYBIND: Rebind Alt-C to Ctrl-E for directory navigation
# Remove default Alt-C binding from all editing modes
bindkey -rM emacs '\ec'  # emacs mode (default)
bindkey -rM vicmd '\ec'  # vi command mode  
bindkey -rM viins '\ec'  # vi insert mode

# Bind Ctrl-E to the directory navigation widget in all modes
zle     -N              fzf-cd-widget
bindkey -M emacs '\C-e' fzf-cd-widget  # Ctrl-E in emacs mode
bindkey -M vicmd '\C-e' fzf-cd-widget  # Ctrl-E in vi command mode
bindkey -M viins '\C-e' fzf-cd-widget  # Ctrl-E in vi insert mode

# Load fzf completion enhancements:
# - Enhanced <TAB> completion for commands like vim, cd, kill, ssh
# - Uses fuzzy search when there are many completion options
[[ -f "$FZF_COMPLETION" ]] && source "$FZF_COMPLETION"

# Load fzf utility functions
[[ -f "$DOTFILES/.config/zsh/plugins/fzf-utils/fzf-utils.zsh" ]] && source "$DOTFILES/.config/zsh/plugins/fzf-utils/fzf-utils.zsh"

# COMPLETION CUSTOMIZATION: How fzf displays completion results
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd|tree)     find . -type d | fzf --preview 'tree -C {}' "$@";;  # Show tree preview for directories
        *)           fzf "$@" ;;  # Default fzf for everything else
    esac
}

# COMPLETION GENERATION: What files/dirs to show in completion
_fzf_compgen_path() {
    rg --files --glob "!.git" "$1"  # Use ripgrep for file completion (excludes .git)
}

_fzf_compgen_dir() {
   fd --type d --hidden --follow --exclude ".git" "$1"  # Use fd for directory completion
}