#!/usr/bin/env bash
#
# Power menu for the waybar ⏻ button (modules-right → custom/power).
# Presents a short wofi list and acts on the choice.
#
# --conf /dev/null is deliberate: the main wofi config sets show=drun and
# columns=4, both of which would fight --dmenu.
#
# The stylesheet is dmenu.css, not the launcher's style.css. style.css is
# shaped for the 4-column icon grid — 64px min-height cells — which made
# these five rows far too tall to fit the window. Same palette either way.

set -euo pipefail

choice=$(printf 'Lock\nSleep\nLog out\nRestart\nShut down\n' | wofi \
    --dmenu \
    --prompt "Power" \
    --width 260 \
    --height 260 \
    --conf /dev/null \
    --style "$HOME/.config/wofi/dmenu.css")

case "$choice" in
    "Lock")      hyprlock ;;
    "Sleep")     systemctl suspend ;;
    "Log out")   hyprctl dispatch exit ;;
    "Restart")   systemctl reboot ;;
    "Shut down") systemctl poweroff ;;
esac
