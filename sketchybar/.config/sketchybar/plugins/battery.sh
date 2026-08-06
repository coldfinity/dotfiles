#!/bin/bash
#
# Battery, on the bar's escalation ramp rather than the binary red-at-20%
# this used to do.
#
#   ACCENT  charging — a state change worth signalling
#   GREY    above 20% — normal, nothing to report
#   ORANGE  20% or below — elevated
#   RED     10% or below — critical
#
# ORANGE at 20 and RED at 10 rather than waybar's 70/90 stat thresholds
# because the scale runs the other way: on a battery, low is the bad end.
# The colours still mean what they mean everywhere else on the bar.
#
# A glyph plus the percentage, replacing the old `BAT 85%` — the text prefix
# was doing the job an icon does, in three times the width.

source "$CONFIG_DIR/colors.sh"

BATT="$(pmset -g batt)"
PERCENT="$(printf '%s' "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"

# A Mac mini or a desktop-mode machine reports no battery at all. Hide rather
# than draw a zero.
if [ -z "$PERCENT" ]; then
  sketchybar --set "$NAME" drawing=off --set divider.battery drawing=off
  exit 0
fi

CHARGING=""
printf '%s' "$BATT" | grep -q "AC Power" && CHARGING=1

# Nerd Font battery ramp: 󰂎 empty through 󰁹 full, plus 󰂄 charging.
if [ -n "$CHARGING" ]; then
  ICON=󰂄
  COLOR=$ACCENT
else
  if [ "$PERCENT" -le 10 ]; then
    COLOR=$RED
  elif [ "$PERCENT" -le 20 ]; then
    COLOR=$ORANGE
  else
    COLOR=$GREY
  fi

  case 1 in
    $((PERCENT <= 10))) ICON=󰁺 ;;
    $((PERCENT <= 25))) ICON=󰁻 ;;
    $((PERCENT <= 40))) ICON=󰁽 ;;
    $((PERCENT <= 55))) ICON=󰁿 ;;
    $((PERCENT <= 70))) ICON=󰂁 ;;
    $((PERCENT <= 85))) ICON=󰂂 ;;
    *) ICON=󰁹 ;;
  esac
fi

sketchybar --set "$NAME" drawing=on \
  icon="$ICON" icon.color="$COLOR" \
  label="${PERCENT}%" label.color="$COLOR" \
  --set divider.battery drawing=on
