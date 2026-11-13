#!/bin/bash
#
# Wi-Fi: link state, plus signal strength as a percentage.
#
# TWO SOURCES, BECAUSE ONE OF THEM IS SLOW.
#
# Link state comes from ifconfig and costs 0.01s, so it can be polled.
# Signal strength has exactly one sudo-free source on macOS 26 —
# `system_profiler SPAirPortDataType` — and that call takes 4.3 seconds,
# warm, with -detailLevel mini making no difference. Polling it would leave a
# multi-second process running against the bar continuously.
#
# So the signal is refreshed by a DETACHED background job into a cache file
# and read from there. The bar never blocks on it; the number is at most
# RSSI_MAX_AGE seconds stale, which is invisible for a figure that drifts a
# few dBm as you move around.
#
# `airport -I` was removed in Sonoma and `wdutil info` needs sudo, which is
# why neither appears here.
#
# 󰖩 U+F05A9 wifi, 󰖪 U+F05AA wifi-off, 󰈀 U+F0200 ethernet — all Material
# Design. The U+F000-F8FF Font Awesome block does not survive being written
# into these files and lands as an empty icon.

source "$CONFIG_DIR/colors.sh"

CACHE="${TMPDIR:-/tmp}/sketchybar_wifi_rssi"
RSSI_MAX_AGE=180

# Discovered rather than hardcoded to en0: the Wi-Fi port moves between
# interfaces across Mac models, and a wrong guess reads as "off" forever
# rather than failing loudly.
WIFI_DEV="$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Hardware Port: Wi-Fi/ { getline; print $2; exit }')"

# Which interface holds the default route. An ethernet dongle can be up while
# Wi-Fi is also associated, and the one carrying traffic is worth reporting.
DEFAULT_DEV="$(route -n get default 2>/dev/null \
  | awk '/interface:/ { print $2; exit }')"

if [ -n "$DEFAULT_DEV" ] && [ "$DEFAULT_DEV" != "$WIFI_DEV" ]; then
  sketchybar --set "$NAME" icon=󰈀 icon.color=$ACCENT label.drawing=off
  exit 0
fi

if [ -z "$WIFI_DEV" ]; then
  # DIM rather than RED: a radio being off is a state you chose, not a fault.
  sketchybar --set "$NAME" icon=󰖪 icon.color=$DIM label.drawing=off
  exit 0
fi

case "$(networksetup -getairportpower "$WIFI_DEV" 2>/dev/null)" in
  *": Off"*)
    sketchybar --set "$NAME" icon=󰖪 icon.color=$DIM label.drawing=off
    exit 0
    ;;
esac

if ! ifconfig "$WIFI_DEV" 2>/dev/null | grep -q "status: active"; then
  # Radio on, not associated.
  sketchybar --set "$NAME" icon=󰖩 icon.color=$GREY label.drawing=off
  exit 0
fi

##### Signal, from the cache #####
age=$RSSI_MAX_AGE
[ -f "$CACHE" ] && age=$(( $(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0) ))

if [ "$age" -ge "$RSSI_MAX_AGE" ]; then
  # Detached, output discarded, and `touch` first so a slow refresh can't be
  # started again on every tick while the first one is still running.
  touch "$CACHE"
  ( system_profiler SPAirPortDataType 2>/dev/null \
      | awk -F'[ /]+' '/Signal \/ Noise/ { print $4; exit }' > "$CACHE.tmp" \
    && mv "$CACHE.tmp" "$CACHE" ) >/dev/null 2>&1 &
fi

RSSI="$(cat "$CACHE" 2>/dev/null)"
case "$RSSI" in
  -[0-9]*) ;;
  *) RSSI="" ;;
esac

if [ -n "$RSSI" ]; then
  # -90 dBm is unusable, -30 is excellent; map that span onto 0-100.
  PCT=$(awk -v r="$RSSI" 'BEGIN {
    p = (r + 90) * 100 / 60
    if (p < 0) p = 0; if (p > 100) p = 100
    printf "%.0f", p
  }')
  sketchybar --set "$NAME" icon=󰖩 icon.color=$ACCENT \
    label="$PCT" label.color=$TEXT label.drawing=on
else
  # Associated, but the first background refresh hasn't landed yet.
  sketchybar --set "$NAME" icon=󰖩 icon.color=$ACCENT label.drawing=off
fi
