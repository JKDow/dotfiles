#!/usr/bin/env bash
set -euo pipefail

target="${1:-}"; [[ -z "$target" ]] && { echo "usage: swap-ws.sh <workspace-number>"; exit 1; }

cur="$(hyprctl -j activeworkspace | jq -r '.id')"     # current WS id
[[ "$target" == "$cur" ]] && exit 0

tmp=9999
[[ "$tmp" -eq "$cur" || "$tmp" -eq "$target" ]] && tmp=9998

# capture addresses before moving anything
mapfile -t cur_addrs < <(hyprctl -j clients | jq -r --argjson ws "$cur" '.[] | select(.workspace.id==$ws) | .address')
mapfile -t tgt_addrs < <(hyprctl -j clients | jq -r --argjson ws "$target" '.[] | select(.workspace.id==$ws) | .address')

# A -> TMP
for a in "${cur_addrs[@]}"; do hyprctl dispatch movetoworkspacesilent "$tmp,address:$a"; done
# B -> A
for a in "${tgt_addrs[@]}"; do hyprctl dispatch movetoworkspacesilent "$cur,address:$a"; done
# TMP -> B
for a in $(hyprctl -j clients | jq -r --argjson ws "$tmp" '.[] | select(.workspace.id==$ws) | .address'); do
  hyprctl dispatch movetoworkspacesilent "$target,address:$a"
done

# note: we stay on the same workspace number; its contents were swapped.

