#!/bin/sh

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO
  sketchybar --set $NAME icon.drawing=off label="VOL ${VOLUME}%"
fi
