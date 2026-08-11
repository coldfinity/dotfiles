#!/bin/bash
#
# Bluetooth, via blueutil. Icon only — the reference shows a bare glyph here
# with no device name beside it, and the item is created with label.drawing
# off to match.
#
# blueutil is a homebrew dependency (`brew install blueutil`). The
# alternative, `system_profiler SPBluetoothDataType`, takes seconds to return
# and would stall the item on every poll — the same reason the Wi-Fi signal
# is cached rather than polled.
#
# If it isn't installed the item hides itself rather than erroring; a bar
# module is not the right place to nag about a missing package.
#
# 󰂯 U+F00AF on, 󰂲 U+F00B2 off — Material Design, not Font Awesome's  /,
# which do not survive being written into these files.

source "$CONFIG_DIR/colors.sh"

if ! command -v blueutil >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$(blueutil -p)" != "1" ]; then
  sketchybar --set "$NAME" drawing=on icon=󰂲 icon.color=$DIM
  exit 0
fi

# Connected is the state worth signalling; on-but-idle is the resting state.
if blueutil --paired --format json 2>/dev/null | jq -e 'any(.[]; .connected)' >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=on icon=󰂯 icon.color=$ACCENT
else
  sketchybar --set "$NAME" drawing=on icon=󰂯 icon.color=$GREY
fi
