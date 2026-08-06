#!/bin/bash
#
# Opens the power popup on hover, and turns the glyph RED while the cursor is
# on it — the destructive affordance waybar gives with #custom-power:hover.

source "$CONFIG_DIR/colors.sh"

case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" icon.color=$RED popup.drawing=on
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set "$NAME" icon.color=$GREY popup.drawing=off
    ;;
  mouse.clicked)
    # Click toggles, so the menu is reachable without hovering precisely —
    # and so a click that lands on the glyph rather than an action doesn't
    # leave the popup stuck open.
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
esac
