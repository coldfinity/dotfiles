#!/usr/bin/env bash
#
# Power menu for the waybar ⏻ button (modules-right → custom/power).
# Presents a short rofi list and acts on the choice.
#
# dmenu.rasi, not the launcher theme: launcher.rasi is a 4-column grid of
# 48px icons, which made these five text rows far taller than the window.
# Same palette either way.

set -euo pipefail

choice=$(printf 'Lock\nSleep\nLog out\nRestart\nShut down\n' | rofi \
    -dmenu \
    -l 5 \
    -p "Power" \
    -theme "$HOME/.config/rofi/dmenu.rasi")

case "$choice" in
    "Lock")      hyprlock ;;
    "Sleep")     systemctl suspend ;;
    "Log out")   hyprctl dispatch exit ;;
    "Restart")   systemctl reboot ;;
    "Shut down") systemctl poweroff ;;
esac
