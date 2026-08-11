#!/bin/bash
#
# CPU, RAM and GPU — inline, each an icon and a reading.
#
# NO SPARKLINES, THOUGH THE REFERENCE HAS THEM.
#
# Sketchybar's native `graph` item lays out as icon │ plot │ label: the plot
# takes horizontal space *between* the icon and its number, so a 42px graph
# put 42px of gap between every glyph and the value it belongs to. There is
# no way to put the plot underneath the text — an item gets one background,
# items flow horizontally, and the graph occupies its own column.
#
# The reference draws its line under the text, which quickshell can do
# because it lays out freely. Reproducing it here would mean overlapping the
# label back over the graph with negative padding, which fights the layout
# rather than using it. The tight icon+number pairing matters more than the
# line, so the graphs are gone.
#
# 󰘙 U+F0619 chip, 󰍛 U+F035B memory, 󰢮 U+F08AE expansion card. All Material
# Design — the U+F000-F8FF Font Awesome block does not survive being written
# into these files and lands as an empty icon.

add_stat() {
  sketchybar --add item $1 right \
    --set $1 \
    icon="$2" \
    icon.color=$GREY \
    icon.padding_left=14 \
    icon.padding_right=4 \
    label.color=$TEXT \
    label.padding_right=0 \
    background.drawing=off
}

add_stat gpu 󰢮
add_stat ram 󰍛
add_stat cpu 󰘙

# One script samples all three. Sampling CPU means holding two `ps`
# snapshots, and doing that once per item would triple the cost for no extra
# information. cpu owns the timer; ram and gpu are written by it.
sketchybar --set cpu update_freq=5 script="$PLUGIN_DIR/stats.sh"
