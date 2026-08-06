#!/bin/bash
#
# Aerospace workspaces, as CJK numerals — the same treatment waybar gives the
# Hyprland ones (see the format-icons map in waybar/config.jsonc).
#
# Which workspaces get drawn, and what glyph each one wears, comes from
# settings.sh so this file and plugins/workspaces.sh cannot disagree.

sketchybar --add event aerospace_workspace_change

for i in "${!WS_IDS[@]}"; do
  sid="${WS_IDS[$i]}"

  # Every chip is created at rest: DIM, no block, narrow. The watcher below
  # paints the real state on the first --update, so nothing here needs to
  # guess which workspace is focused at startup.
  #
  # THE CHIP IS SIZED BY ITS PADDING, NOT BY `width`.
  #
  # Setting width=26/46 is the obvious way to do this and it is wrong:
  # sketchybar left-aligns an item's content inside a forced width, so the
  # focused chip drew its numeral hard against the left edge of the block
  # with the rest of the 46px empty beside it. Waybar has no such problem —
  # GTK centres the label in the button — which is why the two bars needed
  # different mechanics here.
  #
  # Balanced icon padding gives the same widths and keeps the glyph centred
  # by construction, at any width, with no arithmetic to keep in sync.
  sketchybar --add item space.$sid left \
    --set space.$sid \
    icon="${WS_ICONS[$i]}" \
    icon.font="$FONT_FACE:SemiBold:13.0" \
    icon.color=$EMPTY \
    icon.padding_left=6 \
    icon.padding_right=6 \
    padding_left=1 \
    padding_right=1 \
    label.drawing=off \
    background.drawing=off \
    background.corner_radius=2 \
    background.height=22 \
    background.border_width=1 \
    click_script="aerospace workspace $sid"
done

# One watcher redraws all nine in a single batched sketchybar call, rather
# than each chip carrying its own script. Nine scripts would mean nine
# `aerospace list-workspaces` invocations per switch, and aerospace's CLI is
# slow enough (~30ms a call) that the row visibly repaints in sequence.
#
# front_app_switched is subscribed as well as the workspace event: focusing a
# window on another workspace changes which chip is focused without
# aerospace firing exec-on-workspace-change.
sketchybar --add item workspace_watcher left \
  --set workspace_watcher \
  drawing=off \
  updates=on \
  update_freq=5 \
  script="$PLUGIN_DIR/workspaces.sh" \
  --subscribe workspace_watcher aerospace_workspace_change front_app_switched
