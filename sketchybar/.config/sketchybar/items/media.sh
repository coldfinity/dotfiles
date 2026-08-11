#!/bin/bash
#
# Now playing, beside the clock in the centre frame — the counterpart to
# waybar's mpris module.
#
# Driven by sketchybar's built-in media_change event, which reads MediaRemote,
# so this follows whatever app is playing rather than being pinned to one.
# That is the same behaviour waybar gets from talking to playerctld instead of
# a specific bus name, and it is why items/spotify.sh is deleted.
#
# GREY like the clock beside it: this is ambient, not something you need to be
# told about. Nothing here escalates.
#
# max_chars caps the shift. The centre frame is centred against the bar, so a
# title that grows moves the clock with it; 38 keeps the worst case to a few
# characters' drift, matching waybar's max-length.

sketchybar --add item media center \
  --set media \
  drawing=off \
  icon.font="$FONT_MAIN" \
  icon.color=$GREY \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color=$GREY \
  label.padding_left=4 \
  label.padding_right=8 \
  label.max_chars=38 \
  scroll_texts=on \
  background.drawing=off \
  script="$PLUGIN_DIR/media.sh" \
  --subscribe media media_change
