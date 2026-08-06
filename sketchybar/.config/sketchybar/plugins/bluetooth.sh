#!/bin/bash
#
# Bluetooth, via blueutil.
#
# blueutil is a new homebrew dependency for this config (`brew install
# blueutil`). The alternative, `system_profiler SPBluetoothDataType`, takes
# well over a second to return and would stall the item on every poll.
#
# If it isn't installed the row hides itself rather than erroring — the popup
# is still useful with just volume in it, and a bar module is not the right
# place to nag about a missing package.
#
# 󰂯 U+F00AF on, 󰂲 U+F00B2 off — Material Design, not waybar's Font Awesome
#  U+F293 /  U+F294. Those live in the U+F000-F8FF BMP private-use area,
# which does not survive being written into these files and arrives as an
# empty string, leaving the row with no icon.

source "$CONFIG_DIR/colors.sh"

if ! command -v blueutil >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$(blueutil -p)" != "1" ]; then
  sketchybar --set "$NAME" drawing=on \
    icon=󰂲 icon.color=$DIM \
    label="off" label.color=$DIM
  exit 0
fi

# First connected device only. Waybar shows {device_alias} for the same
# reason: the bar has no room for a list, and one name answers "is my
# headset on" — which is the question being asked.
DEVICE="$(blueutil --paired --format json 2>/dev/null \
  | jq -r '[.[] | select(.connected)] | .[0].name // empty')"

if [ -n "$DEVICE" ]; then
  sketchybar --set "$NAME" drawing=on \
    icon=󰂯 icon.color=$ACCENT \
    label="$DEVICE" label.color=$ACCENT
else
  # On, nothing attached.
  sketchybar --set "$NAME" drawing=on \
    icon=󰂯 icon.color=$GREY \
    label="—" label.color=$GREY
fi
