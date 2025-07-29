#
# Linux-specific aliases
#

# Terminal launcher
alias term='ghostty &'

# My IP
alias myip='ip route get 1.1.1.1 | awk "/src/ {print \$7}"'

# ls with fallback - Linux version
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
  alias ls='ls --color=auto'  # GNU ls color flag
  alias ll='ls -l --color=auto'
  alias la='ls -la --color=auto'
  alias l='ls -la --color=auto'
  alias lr='ls -lR --color=auto'
  alias lh='ls -lah --color=auto'
  alias lS='ls -lSh --color=auto'
fi

# Smart trash management - Linux
alias rm='command rm -i'