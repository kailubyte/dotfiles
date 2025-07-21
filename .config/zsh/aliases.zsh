#
# Aliases
#

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
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

# Terminal launcher - OS-specific
case "$(uname -s)" in
    Darwin*)
        alias term='open -a ghostty.app'
        ;;
    Linux*)
        alias term='ghostty &'
        ;;
esac

# Run scripts
alias update="$DOTFILES/scripts/update"

# Quick jump to dotfiles
alias dotfiles="code $DOTFILES"

# Quick reload of zsh environment
alias reload="source $ZDOTDIR/.zshrc"

# My IP - OS-specific network commands
case "$(uname -s)" in
    Darwin*)
        alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
        ;;
    Linux*)
        alias myip='ip route get 1.1.1.1 | awk "/src/ {print \$7}"'
        ;;
esac

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

# ls with fallback
if _exists lsd; then
  alias ls >/dev/null 2>&1 && unalias ls
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
  alias lt='lsd --tree'
  alias l='lsd -la'
  alias lr='lsd -lR'
  alias lh='lsd -lah'
  alias lS='lsd -lSh'
  alias lt1='lsd --tree --depth 1'
  alias lt2='lsd --tree --depth 2'
  alias lt3='lsd --tree --depth 3'
else
  case "$(uname -s)" in
    Darwin*)
      alias ls='ls -G'  # macOS color flag
      alias ll='ls -lG'
      alias la='ls -laG'
      alias l='ls -laG'
      alias lr='ls -lRG'
      alias lh='ls -lahG'
      alias lS='ls -lShG'
      ;;
    Linux*)
      alias ls='ls --color=auto'  # GNU ls color flag
      alias ll='ls -l --color=auto'
      alias la='ls -la --color=auto'
      alias l='ls -la --color=auto'
      alias lr='ls -lR --color=auto'
      alias lh='ls -lah --color=auto'
      alias lS='ls -lSh --color=auto'
      ;;
  esac
fi

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

# Smart trash management - OS-specific
case "$(uname -s)" in
    Darwin*)
        # macOS - use AppleScript to move files to Trash
        trash() {
            for file in "$@"; do
                if [[ -e "$file" ]]; then
                    osascript -e "tell application \"Finder\" to delete POSIX file \"$(realpath "$file")\""
                else
                    echo "trash: $file: No such file or directory" >&2
                fi
            done
        }
        alias rm='trash'
        ;;
    Linux*)
        # Linux - use interactive rm for safety
        alias rm='command rm -i'
        ;;
esac

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
alias vsc='code'     # Shorter alias for Visual Studio Code
