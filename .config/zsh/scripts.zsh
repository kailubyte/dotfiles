#!/usr/bin/env zsh

screenres() {
    [ ! -z $1 ] && xrandr --current | grep '*' | awk '{print $1}' | sed -n "$1p"
}

# Extract files
extract() {
    for file in "$@"
    do
        if [ -f $file ]; then
            _ex $file
        else
            echo "'$file' is not a valid file"
        fi
    done
}

# Extract files in their own directories
mkextract() {
    for file in "$@"
    do
        if [ -f $file ]; then
            local filename=${file%\.*}
            mkdir -p $filename
            cp $file $filename
            cd $filename
            _ex $file
            rm -f $file
            cd -
        else
            echo "'$1' is not a valid file"
        fi
    done
}


# Internal function to extract any archive
_ex() {
    case $1 in
        *.tar.bz2)  tar xjf $1      ;;
        *.tar.gz)   tar xzf $1      ;;
        *.bz2)      bunzip2 $1      ;;
        *.gz)       gunzip $1       ;;
        *.tar)      tar xf $1       ;;
        *.tbz2)     tar xjf $1      ;;
        *.tgz)      tar xzf $1      ;;
        *.zip)      unzip $1        ;;
        *.7z)       7z x $1         ;; # require p7zip
        *.rar)      7z x $1         ;; # require p7zip
        *.iso)      7z x $1         ;; # require p7zip
        *.Z)        uncompress $1   ;;
        *)          echo "'$1' cannot be extracted" ;;
    esac
}

# Compress a file 
# TODO to improve to compress in any possible format
# TODO to improve to compress multiple files
compress() {
    local DATE="$(date +%Y%m%d-%H%M%S)"
    tar cvzf "$DATE.tar.gz" "$@"
}

# Download playlist videos with yt-dlp
ytdlp() {
    if [ ! -z $1 ]; then
        yt-dlp --restrict-filenames -f "bestvideo+bestaudio/best" -o "%(autonumber)s-%(title)s.%(ext)s" "$1"
    else
        echo "You need to specify a playlist url as argument"
    fi
}

# Download a single video with yt-dlp
ytdl() {
    if [ ! -z $1 ]; then
        yt-dlp --restrict-filenames -f "bestvideo+bestaudio/best" -o "%(title)s.%(ext)s" "$1"
    else
        echo "You need to specify a video url as argument"
    fi
}

# Pull cheatsheet from cheat.sh
cheat() {
    curl cheat.sh/$1
}

# Trash management helper functions
trash-clean() {
    local days=${1:-7}
    echo "Emptying trash older than $days days..."
    if command -v trash-empty >/dev/null 2>&1; then
        trash-empty "$days"
    else
        echo "trash-empty command not found"
    fi
}

# Show trash size
trash-size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        du -sh ~/.Trash 2>/dev/null || echo "Trash is empty"
    else
        du -sh ~/.local/share/Trash 2>/dev/null || echo "Trash is empty"
    fi
}

# Quick trash status
trash-status() {
    echo "=== Trash Status ==="
    trash-size
    echo ""
    echo "Recent items:"
    if command -v trash-list >/dev/null 2>&1; then
        trash-list | head -5
    else
        echo "trash-list command not found"
    fi
}

