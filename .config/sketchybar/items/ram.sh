#!/bin/bash

sketchybar --add item ram right \
  --set ram update_freq=5 \
  script="$PLUGIN_DIR/ram.sh"
