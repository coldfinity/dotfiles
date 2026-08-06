#!/bin/bash
#
# System stats — CPU, RAM, GPU — collapsed behind one glyph.
#
# Waybar keeps these in a GTK drawer that grows the frame in place on hover.
# Sketchybar has no revealer, so they live in a popup instead. An in-bar
# reveal is reproducible with mouse.entered plus drawing=on and --animate,
# but it flickers whenever the pointer crosses the group quickly; the popup
# is the sketchybar-native idiom and doesn't.
#
# The anchor carries the state, so the resting bar can still go amber or red
# without the numbers being on screen — see plugins/stats.sh, which colours it
# from whichever of the three is worst.
#
# 󰓅 U+F04C5, speedometer. Same glyph waybar's stats.sh prints.

sketchybar --add item stats right \
  --set stats \
  icon=󰓅 \
  icon.color=$GREY \
  icon.padding_left=8 \
  icon.padding_right=8 \
  label.drawing=off \
  background.drawing=off \
  update_freq=5 \
  script="$PLUGIN_DIR/stats.sh" \
  "${popup[@]}" \
  --subscribe stats mouse.entered mouse.exited mouse.exited.global

# The three readings, stacked in the popup. They have no scripts of their own:
# the anchor samples all three and writes them in one batched call, because
# sampling CPU means holding two `ps` snapshots and doing that three times
# over would triple the cost for no extra information.
for stat in cpu ram gpu; do
  sketchybar --add item stats.$stat popup.stats \
    --set stats.$stat \
    icon.color=$GREY \
    icon.padding_left=10 \
    icon.padding_right=6 \
    label.color=$GREY \
    label.padding_right=10 \
    background.drawing=off \
    width=130
done

# 󰘙 U+F0619 chip, 󰍛 U+F035B memory, 󰢮 U+F08AE expansion card — the same
# three glyphs waybar labels cpu/memory/custom-gpu with.
sketchybar --set stats.cpu icon=󰘙 \
  --set stats.ram icon=󰍛 \
  --set stats.gpu icon=󰢮
