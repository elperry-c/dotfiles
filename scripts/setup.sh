#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/.local/dotfiles/wsl"

# XDG Base Directory構成の作成
function create_xdg_directories() {
    local dirs=(
        "$HOME/bin"
        "$HOME/temp"
        "$HOME/.config"
        "$HOME/.local/share"
        "$HOME/.local/cache"
        "$HOME/.local/state"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        else
            echo "Directory already exists: $dir"
        fi
    done
}

# シンボリックリンクの作成
function create_symlink() {
    local target="$1"
    local link="$2"

    if [ -e "$link" ]; then
        if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
            echo "Symlink for $target already exists at $link"
            return
        else
            echo "Removing existing file or symlink at $link"
            rm -rf "$link"
        fi
    fi

    ln -sfn "$target" "$link"
    echo "Created symlink: $link -> $target"
}

# ~/.profile に .config/profile 読み込み設定を追加
function add_profile_source() {
    local profile="$HOME/.profile"
    local source_line='[ -f "$HOME/.config/profile" ] && . "$HOME/.config/profile"'

    if ! grep -Fxq "$source_line" "$profile"; then
        echo "$source_line" >> "$profile"
        echo "Added profile source to $profile"
    else
        echo "Profile source already exists in $profile"
    fi
}

#### メイン処理 ####

# XDG Base Directory構成の作成
create_xdg_directories

# シンボリックリンクの作成
[ -e "$DOTFILES/config" ] && create_symlink "$DOTFILES/config" "$HOME/.config"
[ -e "$DOTFILES/bin" ] && create_symlink "$DOTFILES/bin" "$HOME/bin"

# profile設定
add_profile_source
