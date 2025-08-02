#!/usr/bin/env bash

CHOICE=$(printf " Shutdown\n Reboot\n Suspend\n Hibernate\n Lock\n" | wofi --show dmenu -p "Power Menu")

case "$CHOICE" in
  *Shutdown*) systemctl poweroff ;;
  *Reboot*) systemctl reboot ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Lock*) hyprlock ;;
esac

