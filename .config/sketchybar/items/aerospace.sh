#!/bin/bash

sketchybar --add event aerospace_workspace_change

letters=("1" "2" "3" "4" "5" "B" "C")

for sid in "${letters[@]}"; do
  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    label.padding_left=0 \
    label.padding_right=13 \
    label="$sid" \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
