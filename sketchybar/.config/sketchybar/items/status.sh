#!/bin/bash
#
# Network, bluetooth and volume — three separate inline items.
#
# These were one anchor with a hover popup behind it. The reference layout
# shows all three at rest, so the popup and its anchor are gone and each is
# now its own item on the bar.
#
# Connected is the state worth signalling, so it gets ACCENT; anything off or
# disconnected falls to DIM. TEXT is for "on, nothing attached".

# Order matters: items placed `right` are laid out right-to-left in the order
# they are added, so this reads volume, bluetooth, network on screen.
sketchybar --add item volume right \
  --set volume \
  icon.color=$GREY \
  icon.padding_left=14 \
  icon.padding_right=4 \
  label.color=$TEXT \
  label.padding_right=0 \
  background.drawing=off \
  update_freq=15 \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change

sketchybar --add item bluetooth right \
  --set bluetooth \
  icon.color=$GREY \
  icon.padding_left=14 \
  icon.padding_right=0 \
  label.drawing=off \
  background.drawing=off \
  update_freq=15 \
  script="$PLUGIN_DIR/bluetooth.sh" \
  --subscribe bluetooth system_woke

sketchybar --add item network right \
  --set network \
  icon.color=$GREY \
  icon.padding_left=14 \
  icon.padding_right=4 \
  label.color=$TEXT \
  label.padding_right=0 \
  background.drawing=off \
  update_freq=10 \
  script="$PLUGIN_DIR/network.sh" \
  --subscribe network wifi_change system_woke
