#!/bin/bash
#
# Volume, paired with the input-source indicator (items/input_source.sh)
# into an "audio & input" cluster — output and input devices, a more
# coherent pairing than the old blob that lumped these in with wifi and
# bluetooth.
#
# Audible is the resting state, so the number sits in TEXT. Muted dims both
# the glyph and the number rather than hiding the number — a level you can
# see is what tells you what unmuting will get you.

# volume is leftmost of the cluster (input_source, sourced right after this
# file, lands to its right), so it carries the gap to the network cluster
# before it.
sketchybar --add item volume right \
  --set volume \
  icon.color=$GREY \
  icon.padding_left=$GROUP_GAP \
  icon.padding_right=4 \
  label.font="$FONT_MONO" \
  label.color=$TEXT \
  label.padding_right=0 \
  background.drawing=off \
  update_freq=15 \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change
