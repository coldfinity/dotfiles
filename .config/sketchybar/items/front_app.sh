#!/bin/bash

sketchybar --add item front_app left \
  --set front_app background.drawing=off \
  icon.drawing=off \
  label.color=$WHITE \
  label.font="JetBrainsMono Nerd Font:Regular:13.0" \
  script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched
