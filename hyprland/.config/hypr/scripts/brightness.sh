#!/usr/bin/env bash
# Usage:
#   brightness-osd.sh +5%
#   brightness-osd.sh 5%-
#
# Adjusts brightness and shows a single OSD that auto-closes shortly
# after the last change.

set -euo pipefail

ADJUST="${1:-+5%}"

# How long (ms) the OSD should stay visible after the last update
OSD_TIMEOUT_MS=1200

CACHE_DIR="${HOME}/.cache"
mkdir -p "$CACHE_DIR"
ID_FILE="${CACHE_DIR}/brightness-osd.id"

# Adjust brightness (suppress stdout)
brightnessctl set "$ADJUST" >/dev/null 2>&1

# Current brightness percentage
PERCENT=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

# Get last notification ID if it exists
if [[ -f "$ID_FILE" ]]; then
  LAST_ID=$(cat "$ID_FILE" 2>/dev/null || echo 0)
else
  LAST_ID=0
fi

# Send or replace the notification:
# -p : print ID
# -r : replace existing notification with this ID
# -t : expire after timeout (ms)
# -h int:value : percentage for progress bar
NEW_ID=$(notify-send -p \
  -r "$LAST_ID" \
  -t "$OSD_TIMEOUT_MS" \
  -h int:value:"$PERCENT" \
  -h string:category:brightness \
  "Brightness" "Brightness: ${PERCENT}%")

echo "$NEW_ID" > "$ID_FILE"

