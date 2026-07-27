#!/bin/bash

GPU_PERCENT=$(ioreg -r -d 1 -w 0 -c IOAccelerator 2>/dev/null \
  | grep -o '"Device Utilization %"=[0-9]*' \
  | awk -F'=' '{print $2}' \
  | head -1)

GPU_PERCENT=${GPU_PERCENT:-0}

sketchybar --set $NAME icon.drawing=off label="GPU ${GPU_PERCENT}%"
