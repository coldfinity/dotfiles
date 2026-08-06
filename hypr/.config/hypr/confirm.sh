#!/usr/bin/env bash
#
# Yes/no confirmation prompt for destructive keybinds, via rofi.
#
#   confirm.sh "<prompt>" <command> [args...]
#
# Runs the command only on an explicit "Yes". Used by ALT+SHIFT+E in
# hyprland.conf, which quits the session and sits one key away from ALT+E.
#
# dmenu.rasi rather than the launcher theme: launcher.rasi is a 4-column
# grid of 48px icons, which turns a two-line prompt into something absurd.
# -theme replaces the theme from config.rasi outright, so no launcher
# settings leak in.

set -euo pipefail

prompt=$1
shift

# "Cancel" is listed first so it is the pre-selected row — hitting Enter
# on reflex dismisses the prompt rather than confirming it.
choice=$(printf 'Cancel\nYes\n' | rofi \
    -dmenu \
    -l 2 \
    -p "$prompt" \
    -theme "$HOME/.config/rofi/dmenu.rasi")

[ "$choice" = "Yes" ] && exec "$@"
exit 0
