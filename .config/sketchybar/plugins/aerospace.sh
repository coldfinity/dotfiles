#!/bin/sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.color=0xff5294e2 label.color=0xffffffff label.font="JetBrainsMono Nerd Font:Bold:13.0"
else
  sketchybar --set $NAME background.color=0xff333333 label.color=0xffaaaaaa label.font="JetBrainsMono Nerd Font:Regular:13.0"
fi
