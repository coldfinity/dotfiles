#!/bin/bash
#
# Aerospace workspaces, as CJK numerals.
#
# Which workspaces get drawn, and what glyph each one wears, comes from
# settings.sh so this file and plugins/workspaces.sh cannot disagree.
#
# THE FOCUSED ONE IS BOXED, THE REST ARE BARE.
#
# Nothing else on this bar is boxed, so the outline alone carries focus —
# there is no fill to recolour and no divider to compete with it. The box is
# the whole marker; there is no underline bar inside it.

sketchybar --add event aerospace_workspace_change

for i in "${!WS_IDS[@]}"; do
  sid="${WS_IDS[$i]}"

  # Created at rest: bare, dim, no box. The watcher below paints the real
  # state on the first --update, so nothing here needs to guess which
  # workspace is focused at startup.
  sketchybar --add item space.$sid left \
    --set space.$sid \
    icon="${WS_ICONS[$i]}" \
    icon.font="$FONT_MAIN" \
    icon.color=$EMPTY \
    icon.padding_left=9 \
    icon.padding_right=9 \
    icon.y_offset=0 \
    label.drawing=off \
    background.drawing=off \
    background.corner_radius=4 \
    background.height=28 \
    background.border_width=1 \
    background.color=$WS_BOX_FILL \
    background.border_color=$WS_BOX_BORDER \
    click_script="aerospace workspace $sid"
done

# One watcher repaints every chip in a single batched sketchybar call, rather
# than each chip carrying its own script. One script per chip would mean one
# `aerospace list-workspaces` invocation each per switch, and aerospace's CLI
# is slow enough (~30ms a call) that the row visibly repaints in sequence.
#
# front_app_switched is subscribed as well as the workspace event: focusing a
# window on another workspace changes which chip is focused without aerospace
# firing exec-on-workspace-change.
sketchybar --add item workspace_watcher left \
  --set workspace_watcher \
  drawing=off \
  updates=on \
  update_freq=5 \
  script="$PLUGIN_DIR/workspaces.sh" \
  --subscribe workspace_watcher aerospace_workspace_change front_app_switched
