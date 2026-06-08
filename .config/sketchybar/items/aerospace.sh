#!/bin/bash

sketchybar --add event aerospace_workspace_change

letters=("1" "2" "3" "4" "5")

for sid in "${letters[@]}"; do
  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.drawing=off \
    icon.padding_left=8 \
    icon.padding_right=4 \
    label.font="sketchybar-app-font:Regular:16.0" \
    label.padding_left=0 \
    label.padding_right=8 \
    update_freq=5 \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
