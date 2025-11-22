#!/usr/bin/env bash
set -euo pipefail

LOW_THRESHOLD=20
PERF_THRESHOLD=40

PROFILE_BALANCED="balanced"
PROFILE_SAVER="power-saver"
PROFILE_PERF="performance"

BAT_PATH=""
for dev in /sys/class/power_supply/*; do
  if [[ -f "$dev/type" ]] && grep -q "Battery" "$dev/type"; then
    BAT_PATH="$dev"
    break
  fi
done

if [[ -z "${BAT_PATH}" ]]; then
  exit 0
fi

CAPACITY=$(<"${BAT_PATH}/capacity")
STATUS=$(<"${BAT_PATH}/status")
CURRENT_PROFILE="$(powerprofilesctl get 2>/dev/null || echo "")"
TARGET_PROFILE=""

case "$STATUS" in
  "Charging")
    if (( CAPACITY < PERF_THRESHOLD )); then
      TARGET_PROFILE="$PROFILE_BALANCED"
    else
      TARGET_PROFILE="$PROFILE_PERF"
    fi
    ;;
  *)
    if (( CAPACITY <= LOW_THRESHOLD )); then
      TARGET_PROFILE="$PROFILE_SAVER"
    else
      TARGET_PROFILE="$PROFILE_BALANCED"
    fi
    ;;
esac

if [[ -n "$TARGET_PROFILE" && "$TARGET_PROFILE" != "$CURRENT_PROFILE" ]]; then
  powerprofilesctl set "$TARGET_PROFILE"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Power profile changed" \
      "Profile: ${TARGET_PROFILE}\nBattery: ${CAPACITY}% (${STATUS})"
  fi
fi
