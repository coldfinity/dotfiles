#!/bin/sh

source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

if [[ $CHARGING != "" ]]; then
  PREFIX="BAT+"
  COLOR=$ACCENT
elif [ "$PERCENTAGE" -le 20 ]; then
  PREFIX="BAT"
  COLOR=$RED
else
  PREFIX="BAT"
  COLOR=$WHITE
fi

sketchybar --set $NAME icon.drawing=off label="${PREFIX} ${PERCENTAGE}%" label.color=$COLOR
