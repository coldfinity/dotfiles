#!/usr/bin/env bash
#
# Power menu for the waybar ⏻ button (modules-right → custom/power).
# Presents a short wofi list and acts on the choice.
#
# --conf /dev/null is deliberate: the main wofi config sets show=drun,
# which would fight --dmenu. The stylesheet is still applied so the menu
# matches the launcher.

set -euo pipefail

choice=$(printf 'Lock\nSleep\nLog out\nRestart\nShut down\n' | wofi \
    --dmenu \
    --prompt "Power" \
    --width 260 \
    --height 260 \
    --conf /dev/null \
    --style "$HOME/.config/wofi/style.css")

case "$choice" in
    "Lock")      hyprlock ;;
    "Sleep")     systemctl suspend ;;
    "Log out")   hyprctl dispatch exit ;;
    "Restart")   systemctl reboot ;;
    "Shut down") systemctl poweroff ;;
esac
