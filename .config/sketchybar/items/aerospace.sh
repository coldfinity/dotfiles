#!/bin/bash

sketchybar --add event aerospace_workspace_change

letters=("1" "2" "3" "4" "5" "B" "C")

for sid in "${letters[@]}"; do
  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.drawing=on \
    background.color=$ITEM_BG_COLOR \
    background.corner_radius=0 \
    background.height=24 \
    icon.drawing=off \
    label.padding_left=8 \
    label.padding_right=8 \
    label="$sid" \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
