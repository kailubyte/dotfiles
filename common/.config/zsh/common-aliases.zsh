#
# Common aliases (cross-platform)
#

# Enable aliases to be sudo'ed
alias sudo='sudo '

_exists() {
  command -v $1 > /dev/null 2>&1
}

# Just because clr is shorter than clear
alias clr='clear'

# Go to the /home/$USER (~) directory and clears window of your terminal
alias q="cd ~ && clear"

# Folders Shortcuts - Cross-platform (checks both cases for system dirs)
[ -d ~/Downloads ] && alias dl='cd ~/Downloads' || [ -d ~/downloads ] && alias dl='cd ~/downloads'
[ -d ~/Desktop ]   && alias dt='cd ~/Desktop'   || [ -d ~/desktop ]   && alias dt='cd ~/desktop'

# Personal project directories - lowercase preferred
[ -d ~/projects ]             && alias pj='cd ~/projects'
[ -d ~/projects/forks ]       && alias pjf='cd ~/projects/forks'
[ -d ~/projects/playground ]  && alias pjp='cd ~/projects/playground'
[ -d ~/projects/repos ]       && alias pjr='cd ~/projects/repos'

# Commands Shortcuts
alias e='$EDITOR'
alias x+='chmod +x'

# Open aliases
alias open='open_command'
alias o='open'
alias oo='open .'
alias finder='open .'

# Run scripts
alias update="$DOTFILES/scripts/update"

# Quick jump to dotfiles
alias dotfiles="code $DOTFILES"

# Quick reload of zsh environment
alias reload="source $ZDOTDIR/.zshrc"

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Use tldr as help util
if _exists tldr; then
  alias help="tldr"
fi

# Docker
alias dcd="docker compose down"
alias dcu="docker compose up"

# git
alias git-root='cd $(git rev-parse --show-toplevel)'
alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gpo='git push origin'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'
alias grb='git branch -r'
alias gplo='git pull origin'
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gl='git log'
alias gr='git remote'
alias grs='git remote show'
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'

# cat/bat with fallback
if _exists bat; then
  alias cat='bat --paging=never'
fi

# Ping with fallback
if _exists prettyping; then
  alias ping='prettyping'
fi

# dirs
alias d='dirs -v'
for index in {1..9}; do alias "$index"="cd +${index}"; done; unset index

# Quick jump to dotfiles directory
alias dotf='cd ~/.dotfiles'
alias dotfiles="cd ~/.dotfiles"

# Keep original rm available for when you really need it
alias rmi='command rm -i'  # Interactive rm
alias rmf='command rm -f'  # Force rm

# NCDU disk usage analyzer
if _exists ncdu; then
  alias du='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
  alias space='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
  alias diskusage='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
fi

# Visual Studio Code
alias vsc='code .'   # Shorter alias for Visual Studio Code (open current dir)