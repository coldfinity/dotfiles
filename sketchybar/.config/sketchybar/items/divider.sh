#!/bin/bash
#
# Section rules inside a frame.
#
# Waybar draws these with `border-left` on every section that isn't first in
# its frame. Sketchybar has no such property, so a divider is its own item: a
# 1px-wide box with a background, sized to sit clear of the frame's own top
# and bottom edges.
#
# Usage: add_divider <name> <position>
#   add_divider taskbar left   ->  item `divider.taskbar`
#
# The divider belongs to the section that FOLLOWS it and is hidden by that
# section's plugin when the section is empty — otherwise a workspace with no
# windows, or an idle media player, leaves a rule with nothing after it.
#
# padding is 2, not the 6 this started at. The gap between two sections is
# the sum of four things — the left section's right padding, this padding
# twice, and the right section's left padding — so with sections at 8px a
# 6px divider padding put 29px between them. Waybar's equivalent gap is a
# 1px border between two `padding: 0 8px` sections, so 17px. 2 lands at 21,
# which is as close as this gets without stripping the divider's own air out
# entirely.

add_divider() {
  sketchybar --add item divider.$1 $2 \
    --set divider.$1 \
    icon.drawing=off \
    label.drawing=off \
    width=1 \
    padding_left=2 \
    padding_right=2 \
    background.drawing=on \
    background.color=$DIVIDER \
    background.height=16 \
    background.corner_radius=0
}
