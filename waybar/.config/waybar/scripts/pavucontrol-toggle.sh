#!/usr/bin/env bash
# ── pavucontrol-toggle.sh ──
# If pavucontrol is running (i.e. its window exists), kill it;
# otherwise launch it.

if pgrep -x pavucontrol >/dev/null; then
  pkill pavucontrol
else
  pavucontrol &
fi

