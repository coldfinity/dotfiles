#!/bin/bash
#
# The frontmost app's name, beside the workspace pill — not the window
# title. macOS has no cheap public API for the latter; the accurate way is
# an Accessibility query through System Events on every keystroke-adjacent
# event, which is slow and needs a permission grant just to show text.
# front_app_switched already carries the app name for free, event-driven,
# with no polling.

sketchybar --add item window_title left \
  --set window_title \
  icon.drawing=off \
  label.color=$GREY \
  label.padding_left=14 \
  label.padding_right=0 \
  label.max_chars=$TITLE_MAX_CHARS \
  script="$PLUGIN_DIR/window_title.sh" \
  --subscribe window_title front_app_switched
