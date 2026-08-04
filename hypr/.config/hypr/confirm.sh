#!/usr/bin/env bash
#
# Yes/no confirmation prompt for destructive keybinds, via wofi.
#
#   confirm.sh "<prompt>" <command> [args...]
#
# Runs the command only on an explicit "Yes". Used by ALT+SHIFT+E in
# hyprland.conf, which quits the session and sits one key away from ALT+E.
#
# --conf /dev/null is deliberate: the main wofi config sets show=drun and
# columns=4, both of which fight --dmenu. dmenu.css gives the compact list
# geometry, since the launcher's style.css is shaped for the icon grid.

set -euo pipefail

prompt=$1
shift

# "Cancel" is listed first so it is the pre-selected row — hitting Enter
# on reflex dismisses the prompt rather than confirming it.
choice=$(printf 'Cancel\nYes\n' | wofi \
    --dmenu \
    --prompt "$prompt" \
    --width 300 \
    --height 120 \
    --conf /dev/null \
    --style "$HOME/.config/wofi/dmenu.css")

[ "$choice" = "Yes" ] && exec "$@"
exit 0
