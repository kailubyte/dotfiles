#!/usr/bin/env zsh

fpath=($DOTFILES/.config/zsh/plugins $fpath)

# Helper function for safe sourcing with warnings
safe_source() {
    if [[ -f "$1" ]]; then
        source "$1"
    else
        echo "Warning: Missing config file: $1" >&2
    fi
}

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Load common aliases first, then OS-specific
safe_source "$DOTFILES/common/.config/zsh/common-aliases.zsh"
safe_source "$ZDOTDIR/aliases.zsh"

# Default editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
  # on the server
  if command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
  else
    export EDITOR='vi'
  fi
else
  export EDITOR='nvim'
fi

#------

# opts - https://zsh.sourceforge.io/Doc/Release/Options.html

# Navigation
setopt AUTO_CD              # Go to folder path without using cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt CORRECT              # Spelling correction
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB        # Use extended globbing syntax.

# History
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# Profiling
zmodload zsh/zprof

# Completion
# compinit is handled in completion.zsh
_comp_options+=(globdots) # With hidden files
safe_source "$ZDOTDIR/completion.zsh"

# Open command
safe_source "$DOTFILES/common/.config/zsh/plugins/open_command.zsh"

# Prompt
safe_source "$DOTFILES/common/.config/zsh/prompt/prompt_setup"

# bd
safe_source "$DOTFILES/common/.config/zsh/plugins/bd/bd.zsh"

# smartdots
safe_source "$DOTFILES/common/.config/zsh/plugins/smartdots/smartdots.zsh"

safe_source "$DOTFILES/common/.config/zsh/plugins/which-key/which-key.zsh"

# fzf utilities
safe_source "$DOTFILES/common/.config/zsh/plugins/fzf-utils/fzf-utils.zsh"

# gitit - Git repository web navigation
safe_source "$DOTFILES/common/.config/zsh/plugins/gitit.zsh"

# Scripts
safe_source "$DOTFILES/common/.config/zsh/scripts.zsh"

# fzf
if [ $(command -v "fzf") ]; then
    source $ZDOTDIR/fzf.zsh
fi

# git SSH yubikey

export GIT_SSH_COMMAND="/opt/homebrew/bin/ssh"

# zoxide

eval "$(zoxide init zsh)"

# zsh-you-should-use - alias tips
safe_source "$DOTFILES/common/.config/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh"

# Syntax highlighting - Should be at the end of the file
safe_source "$DOTFILES/common/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
