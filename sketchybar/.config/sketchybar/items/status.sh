#!/bin/bash
#
# Device state — network, bluetooth, volume. Waybar calls this group/status:
# "two radios and the audio sink, all current state of a device".
#
# Network is the anchor rather than a synthetic glyph like the stats group
# uses. It already renders as a single icon, and connectivity is the one
# thing here worth being able to see without hovering.
#
# Connected is the state worth signalling, so it gets ACCENT; anything off or
# disconnected falls to DIM. GREY is for "on, nothing attached".

sketchybar --add item status right \
  --set status \
  icon.color=$GREY \
  icon.padding_left=8 \
  icon.padding_right=8 \
  label.drawing=off \
  background.drawing=off \
  update_freq=10 \
  script="$PLUGIN_DIR/network.sh" \
  "${popup[@]}" \
  --subscribe status mouse.entered mouse.exited mouse.exited.global \
  wifi_change system_woke

# Unlike the stats group, these two carry their own scripts: bluetooth and
# volume have nothing to share with each other or with the anchor, and volume
# is event-driven where the anchor is polled.
sketchybar --add item status.bluetooth popup.status \
  --set status.bluetooth \
  icon.color=$GREY \
  icon.padding_left=10 \
  icon.padding_right=6 \
  label.color=$GREY \
  label.padding_right=10 \
  background.drawing=off \
  width=170 \
  update_freq=15 \
  script="$PLUGIN_DIR/bluetooth.sh" \
  --subscribe status.bluetooth system_woke

sketchybar --add item status.volume popup.status \
  --set status.volume \
  icon.color=$GREY \
  icon.padding_left=10 \
  icon.padding_right=6 \
  label.color=$GREY \
  label.padding_right=10 \
  background.drawing=off \
  width=170 \
  update_freq=15 \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe status.volume volume_change
