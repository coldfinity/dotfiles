#!/bin/bash
#
# Network and bluetooth — pure connectivity, split out from audio/input
# (items/audio.sh, items/input_source.sh) into its own cluster. The two
# used to sit in one four-item blob with volume and the input indicator;
# network hardware and audio/input devices aren't the same kind of thing,
# so they read better as separate clusters with their own GROUP_GAP.
#
# Connected is the state worth signalling, so it gets ACCENT; anything off
# or disconnected falls to DIM. TEXT is for "on, nothing attached".

# Order matters: items placed `right` are laid out right-to-left in the
# order they are added, so this reads network, bluetooth on screen.
# network is leftmost of the cluster, so it carries the gap to the stats
# cluster before it; bluetooth is rightmost, carrying the gap to audio.
sketchybar --add item bluetooth right \
  --set bluetooth \
  icon.color=$GREY \
  icon.padding_left=10 \
  icon.padding_right=$GROUP_GAP \
  label.drawing=off \
  background.drawing=off \
  update_freq=15 \
  script="$PLUGIN_DIR/bluetooth.sh" \
  --subscribe bluetooth system_woke

sketchybar --add item network right \
  --set network \
  icon.color=$GREY \
  icon.padding_left=$GROUP_GAP \
  icon.padding_right=4 \
  label.font="$FONT_MONO" \
  label.color=$TEXT \
  label.padding_right=0 \
  background.drawing=off \
  update_freq=10 \
  script="$PLUGIN_DIR/network.sh" \
  --subscribe network wifi_change system_woke
