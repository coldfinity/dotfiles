#!/bin/bash
#
# $INFO is the JSON payload sketchybar attaches to media_change: title,
# artist, album, app, state.
#
# Three states rather than the two this used to have. Paused no longer hides
# the item — it dims it, the same treatment a muted sink or a disabled radio
# gets, because it is the same kind of fact: this thing exists and is not
# doing anything right now. Waybar does the same with #mpris.paused.
#
# Stopped still hides, which collapses the centre frame back to just the
# clock rather than leaving an empty divided section.

source "$CONFIG_DIR/colors.sh"

STATE="$(echo "$INFO" | jq -r '.state')"
TITLE="$(echo "$INFO" | jq -r '.title // empty')"
ARTIST="$(echo "$INFO" | jq -r '.artist // empty')"

# title then artist, matching waybar's dynamic-order.
if [ -n "$ARTIST" ]; then
  LABEL="$TITLE - $ARTIST"
else
  LABEL="$TITLE"
fi

case "$STATE" in
  playing)
    # 󰎈 U+F0388, a generic note — the app is whatever MediaRemote says it is,
    # so a per-player glyph map would need an entry for every media app on
    # the system rather than waybar's two.
    sketchybar --set "$NAME" drawing=on \
      icon=󰎈 icon.color=$GREY \
      label="$LABEL" label.color=$GREY
    ;;
  paused)
    # 󰏤 U+F03E4, pause.
    sketchybar --set "$NAME" drawing=on \
      icon=󰏤 icon.color=$DIM \
      label="$LABEL" label.color=$DIM
    ;;
  *)
    sketchybar --set "$NAME" drawing=off
    ;;
esac

# The divider before this item goes with it, so a silent bar shows the clock
# alone rather than the clock and a rule.
if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
  sketchybar --set divider.media drawing=on
else
  sketchybar --set divider.media drawing=off
fi
