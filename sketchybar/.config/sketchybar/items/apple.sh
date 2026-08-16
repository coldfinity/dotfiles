#!/bin/bash
#
# The Apple logo, leftmost item on the bar — the one thing this config
# still borrows from the native menu bar it replaces.
#
# U+F8FF is the Apple logo glyph itself, baked into Apple's own system
# fonts (SF Pro included) for exactly this use, so this is SF Pro rather
# than the Nerd Font used for every other icon on the bar - sized up on
# its own, since regular text size draws this particular glyph small
# next to the CJK workspace numerals beside it.
#
# Click opens System Settings, the modern stand-in for the old Apple menu's
# "System Preferences...".

sketchybar --add item apple left \
  --set apple \
  icon=$'' \
  icon.font="SF Pro:Semibold:22.0" \
  icon.color=$GREY \
  icon.padding_left=$BAR_EDGE_PADDING \
  icon.padding_right=$GROUP_GAP \
  label.drawing=off \
  background.drawing=off \
  click_script="open -a 'System Settings'"
