#!/bin/bash
#
# The macOS counterpart to waybar's custom/fcitx5.
#
# Nothing on this bar reported the input method before, so the only way to
# find out which mode you were in was to type something and see what came out.
#
# Polled at 1s rather than event-driven: macOS has no public notification for
# input-source change that a shell script can subscribe to, and 1s is fast
# enough that the bar has caught up before you finish the first character.

# Rightmost of the audio & input cluster (items/audio.sh), so it carries
# the gap to the battery cluster after it; its left side, facing volume,
# stays tight.
sketchybar --add item input_source right \
  --set input_source \
  icon.drawing=off \
  label.color=$TEXT \
  label.padding_left=8 \
  label.padding_right=$GROUP_GAP \
  background.drawing=off \
  update_freq=1 \
  script="$PLUGIN_DIR/input_source.sh" \
  click_script="$PLUGIN_DIR/input_source.sh cycle"
