#!/bin/bash
#
# The audio sink: glyph plus level, inline.
#
# Audible is the resting state, so the number sits in TEXT. Muted dims both
# the glyph and the number rather than hiding the number — the reference
# keeps a reading here at all times, and a level you can see is what tells
# you what unmuting will get you.
#
# 󰕾 U+F057E audible, 󰖁 U+F0581 muted.

source "$CONFIG_DIR/colors.sh"

# volume_change carries the new level in $INFO, which is why this is
# subscribed at all — it makes the item correct the instant a media key is
# pressed rather than on the next poll. Every other invocation (startup, the
# update_freq tick) has to ask CoreAudio itself.
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  VOLUME="$INFO"
else
  VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi
MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

# With no output device attached, AppleScript returns "missing value" rather
# than a number.
case "$VOLUME" in
  ''|*[!0-9]*) VOLUME=0 ;;
esac

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  sketchybar --set "$NAME" icon=󰖁 icon.color=$DIM \
    label="$VOLUME" label.color=$DIM
else
  sketchybar --set "$NAME" icon=󰕾 icon.color=$GREY \
    label="$VOLUME" label.color=$TEXT
fi
