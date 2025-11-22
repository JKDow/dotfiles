#!/usr/bin/env bash

current=$(powerprofilesctl get)

options=$(cat <<EOF
  performance
  balanced
  power-saver
EOF
)

options=$(echo "$options" | while read -r line; do
    prof=$(echo "$line" | awk '{print $2}')
    if [ "$prof" = "$current" ]; then
        echo "$line (current)"
    else
        echo "$line"
    fi
done)

choice=$(printf "%s" "$options" | wofi --show dmenu --prompt "Power Profile")

[ -z "$choice" ] && exit 0

profile=$(echo "$choice" | awk '{print $2}')     # second field is always the name
profile=$(echo "$profile" | sed 's/(current)//g')

powerprofilesctl set "$profile" || exit 1

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Power profile" "Switched to: $profile"
fi

