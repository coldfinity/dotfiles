#!/bin/bash
# Short text labels avoid ambiguous hardware glyphs. Left-aligned fixed
# readings keep the label/value gap consistent without shifting the panel.
add_stat() {
  sketchybar --add item "$1" right \
    --set "$1" icon="$2" icon.font="SF Pro:Semibold:10.0" \
    icon.color=$GREY icon.padding_left=12 icon.padding_right=6 \
    label.font="$FONT_MONO" label.width=30 label.align=left \
    label.color=$TEXT label.padding_right=0 background.drawing=off
}
add_stat gpu GPU
add_stat ram RAM
add_stat cpu CPU
# One timer updates all three readings.
sketchybar --set cpu update_freq=5 script="$PLUGIN_DIR/stats.sh"
