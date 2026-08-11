#!/bin/bash
#
# Waybar has no battery module — that machine is a desktop with no
# /sys/class/power_supply. This is the one section the Mac bar carries that
# the Linux one doesn't.
#
# update_freq is a backstop: power_source_change fires on plug and unplug, so
# the poll only exists to move the percentage while nothing else happens.

sketchybar --add item battery right \
  --set battery \
  icon.color=$GREY \
  icon.padding_left=14 \
  icon.padding_right=4 \
  label.color=$TEXT \
  label.padding_right=0 \
  background.drawing=off \
  update_freq=60 \
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change
