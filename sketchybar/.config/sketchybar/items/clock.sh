#!/bin/bash
#
# Replaces items/calendar.sh, which rendered `Wed 06 Aug 02:30 PM` with a
# calendar glyph. Now Chinese and glyphless, matching waybar's clock — see
# plugins/clock.sh for the format.
#
# GREY, not TEXT. The format is the longest run of text on the bar, and at
# full strength it reads as highlighted next to the grey stats.

sketchybar --add item clock center \
  --set clock \
  icon.drawing=off \
  label.color=$GREY \
  label.padding_left=8 \
  label.padding_right=8 \
  update_freq=1 \
  script="$PLUGIN_DIR/clock.sh"
