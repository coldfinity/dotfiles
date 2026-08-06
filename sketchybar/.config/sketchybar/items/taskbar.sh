#!/bin/bash
#
# The windows on the focused workspace, as app icons — the counterpart to
# waybar's wlr/taskbar.
#
# This replaces front_app, which is deleted. Waybar dropped hyprland/window
# for the same reason: the taskbar already marks the focused window with the
# same accent block the focused workspace uses, so a label naming it was the
# same fact written twice at opposite ends of the bar.
#
# A FIXED POOL, NOT DYNAMIC ITEMS.
#
# Slots are created up front and toggled with drawing=on/off rather than being
# added and removed as windows open and close. Bracket membership in
# sketchybar is fixed when the bracket is created, so an item added later
# cannot join left_frame — it would draw outside the frame instead of inside
# it. Anything beyond TASKBAR_SLOTS windows is not shown; twelve icons is
# already wider than the workspace row beside it. The count lives in
# settings.sh so this file and plugins/taskbar.sh cannot disagree.

for i in $(seq 1 $TASKBAR_SLOTS); do
  sketchybar --add item taskbar.$i left \
    --set taskbar.$i \
    drawing=off \
    icon.font="sketchybar-app-font:Regular:16.0" \
    icon.color=$DIM \
    icon.padding_left=6 \
    icon.padding_right=6 \
    label.drawing=off \
    background.drawing=off \
    background.corner_radius=2 \
    background.height=22
done

# Same watcher pattern as the workspaces: one script repaints every slot in a
# single batched call. update_freq catches windows opening and closing, which
# aerospace has no event for — front_app_switched only fires on focus change.
sketchybar --add item taskbar_watcher left \
  --set taskbar_watcher \
  drawing=off \
  updates=on \
  update_freq=3 \
  script="$PLUGIN_DIR/taskbar.sh" \
  --subscribe taskbar_watcher aerospace_workspace_change front_app_switched
