#
# Aliases
#

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

_exists() {
  command -v $1 > /dev/null 2>&1
}

# Just bcoz clr shorter than clear
alias clr='clear'

# Go to the /home/$USER (~) directory and clears window of your terminal
alias q="~ && clear"

# Folders Shortcuts
[ -d ~/Downloads ]            && alias dl='cd ~/Downloads'
[ -d ~/Desktop ]              && alias dt='cd ~/Desktop'
[ -d ~/Projects ]             && alias pj='cd ~/Projects'
[ -d ~/Projects/Forks ]       && alias pjf='cd ~/Projects/Forks'
[ -d ~/Projects/Playground ]  && alias pjp='cd ~/Projects/Playground'
[ -d ~/Projects/Repos ]       && alias pjr='cd ~/Projects/Repos'

# Commands Shortcuts
alias e="$EDITOR"
alias x+='chmod +x'

# Open aliases
alias open='open_command'
alias o='open'
alias oo='open .'
alias finder='open .'
alias term='open -a ghostty.app'

# Run scripts
alias update="source $DOTFILES/scripts/update"
alias bootstap="source $DOTFILES/scripts/bootstrap"

# Quick jump to dotfiles
alias dotfiles="code $DOTFILES"

# Quick reload of zsh environment
alias reload="source $HOME/.zshrc"

# My IP
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

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

# Docker related usefulness
alias dcd="docker compose down"
alias dcu="docker compose up"
alias dl="docker logs"

alias git-root='cd $(git rev-parse --show-toplevel)'

if _exists lsd; then
  unalias ls
  alias ls='lsd'
  alias lt='lsd --tree'
fi

alias cat='bat --paging=never'

alias ping='prettyping'