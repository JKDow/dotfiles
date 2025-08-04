#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

if [[ $# -ne 1 ]]; then
    exit 1
fi
wallpaper=$1
# wallust run -s $wallpaper &
wallust run $wallpaper &

sleep 1

tmux source-file $HOME/.config/tmux/colors.conf
