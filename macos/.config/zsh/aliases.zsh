#
# macOS-specific aliases
#

# Terminal launcher
alias term='open -a ghostty.app'

# My IP
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# ls with fallback - macOS version
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
  alias ls='ls -G'  # macOS color flag
  alias ll='ls -lG'
  alias la='ls -laG'
  alias l='ls -laG'
  alias lr='ls -lRG'
  alias lh='ls -lahG'
  alias lS='ls -lShG'
fi

# Smart trash management - macOS
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