#!/bin/bash
#
# The status group's anchor: Wi-Fi, or ethernet when that is what's carrying
# the default route.
#
# NO SIGNAL PERCENTAGE, unlike waybar's {signalStrength}%.
#
# `airport -I` was removed in Sonoma, and its replacement `wdutil info`
# requires sudo — a bar module is not worth a sudoers entry. So this reports
# associated / not associated and the SSID, and nothing finer. It is the one
# place the Mac bar carries strictly less than the Linux one.
#
# 󰖩 U+F05A9 wifi, 󰖪 U+F05AA wifi-off, 󰈀 U+F0200 ethernet — all Material
# Design. Waybar uses Font Awesome's  U+F1EB for wifi, but that block
# (U+F000-F8FF, the BMP private-use area) does not survive being written into
# these files and arrives as an empty string, leaving the item with no icon.
# Everything on this bar comes from the U+F0000+ MD block for that reason.

source "$CONFIG_DIR/colors.sh"

case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" popup.drawing=on
    exit 0
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
esac

# Discovered rather than hardcoded to en0: the Wi-Fi port moves between
# interfaces across Mac models, and a wrong guess here reads as "off" forever
# rather than failing loudly.
WIFI_DEV="$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Hardware Port: Wi-Fi/ { getline; print $2; exit }')"

# Which interface actually holds the default route. An ethernet dongle can be
# up while Wi-Fi is also associated, and the one carrying traffic is the one
# worth reporting.
DEFAULT_DEV="$(route -n get default 2>/dev/null \
  | awk '/interface:/ { print $2; exit }')"

if [ -n "$DEFAULT_DEV" ] && [ "$DEFAULT_DEV" != "$WIFI_DEV" ]; then
  sketchybar --set "$NAME" icon=󰈀 icon.color=$ACCENT
  exit 0
fi

if [ -z "$WIFI_DEV" ]; then
  sketchybar --set "$NAME" icon=󰖪 icon.color=$DIM
  exit 0
fi

POWER="$(networksetup -getairportpower "$WIFI_DEV" 2>/dev/null)"
case "$POWER" in
  *": Off"*)
    # DIM rather than RED: a radio being off is a state you chose, not a
    # fault. RED is reserved for things that need acting on.
    sketchybar --set "$NAME" icon=󰖪 icon.color=$DIM
    exit 0
    ;;
esac

SSID="$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null \
  | sed -n 's/^Current Wi-Fi Network: //p')"

if [ -n "$SSID" ]; then
  sketchybar --set "$NAME" icon=󰖩 icon.color=$ACCENT
else
  # Radio on, nothing associated. GREY is the "on, nothing attached" state.
  sketchybar --set "$NAME" icon=󰖩 icon.color=$GREY
fi
