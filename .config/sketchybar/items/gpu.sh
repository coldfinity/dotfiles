#!/bin/bash

sketchybar --add item gpu right \
  --set gpu update_freq=2 \
  script="$PLUGIN_DIR/gpu.sh"
