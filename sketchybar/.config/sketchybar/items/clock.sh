#!/bin/bash
#
# Replaces items/calendar.sh, which rendered `Wed 06 Aug 02:30 PM` with a
# calendar glyph. Now Chinese and glyphless, matching waybar's clock — see
# plugins/clock.sh for the format.
#
# TEXT, not GREY. In the framed design this was deliberately dimmed so the
# longest run of text on the bar didn't read as highlighted; with no frames
# and a low bar tint it needs the weight back to stay legible.

sketchybar --add item clock right \
  --set clock \
  icon.drawing=off \
  label.color=$TEXT \
  label.padding_left=8 \
  label.padding_right=4 \
  update_freq=1 \
  script="$PLUGIN_DIR/clock.sh"
