#!/bin/bash
#
# The audio sink, in the status popup beside the two radios.
#
# Audible is the resting state, so GREY. Muted is a deviation, so DIM — the
# same treatment a disconnected radio gets, because it is the same kind of
# fact: this device is not doing anything right now.
#
# Muted drops the number as well as changing the glyph. The level a muted
# sink would return to is not information you need while it is silent.
#
# Glyphs match waybar's: 󰕾 U+F057E audible, 󰖁 U+F0581 muted.

source "$CONFIG_DIR/colors.sh"

# volume_change carries the new level in $INFO, which is why this is
# subscribed at all — it makes the popup correct the instant a media key is
# pressed rather than on the next poll. Every other invocation (startup, the
# update_freq tick) has to ask CoreAudio itself.
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  VOLUME="$INFO"
  MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"
else
  VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
  MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"
fi

# With no output device attached at all, AppleScript returns "missing value"
# for the level rather than a number.
case "$VOLUME" in
  ''|*[!0-9]*) VOLUME=0 ;;
esac

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  sketchybar --set "$NAME" icon=󰖁 icon.color=$DIM label="muted" label.color=$DIM
else
  sketchybar --set "$NAME" icon=󰕾 icon.color=$GREY label="${VOLUME}%" label.color=$GREY
fi
