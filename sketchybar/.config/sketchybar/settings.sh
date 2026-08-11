#!/bin/bash
#
# Values shared between the item definitions and the plugins that repaint
# them.
#
# These lived in both places until now — items/workspaces.sh built the chips
# from one list and plugins/workspaces.sh looped over another, and the same
# went for the taskbar's slot count. That duplication is what left the bar
# drawing five workspace chips while aerospace had nine: one copy was
# updated and the other wasn't. Sourced by sketchybarrc (which covers
# everything under items/) and by the plugins directly, since plugins run as
# their own processes and inherit nothing.

##### Typography #####
# One dial for the whole bar. The size was hardcoded as 13.0 in three
# separate places — the defaults block, the workspace numerals and the media
# item — which meant changing it missed one of them every time.
#
# FONT_MAIN is what items should use; FONT_FACE is exported too because a few
# items want a different weight or size off the same family.
export FONT_FACE="JetBrainsMono Nerd Font"
export FONT_SIZE=15.0
export FONT_MAIN="$FONT_FACE:SemiBold:$FONT_SIZE"

export BAR_HEIGHT=40

# Breathing space at the screen edges. The first and last items sit this far
# in from the left and right edges.
export BAR_EDGE_PADDING=24

##### Workspaces #####
# WS_IDS and WS_ICONS are parallel: index i in one pairs with index i in the
# other. Not an associative array — macOS ships bash 3.2, which has none.
#
# Aerospace defines nine workspaces and all nine are still reachable by
# keybind; the bar deliberately lists only these. A workspace left off this
# list simply isn't drawn.
#
# CJK numerals rather than digits, matching waybar. JetBrainsMono has no CJK
# coverage, so these resolve through macOS font fallback to PingFang. They
# are full-width glyphs and render wider than the digits they replace, which
# is what NARROW/WIDE in plugins/workspaces.sh are sized for.
export WS_IDS=(1 2 3 4 5)
export WS_ICONS=(一 二 三 四 五)

##### Taskbar #####
# Slots are pre-created and toggled rather than added and removed, because
# bracket membership is fixed when the bracket is created — an item added
# later cannot join left_frame. See items/taskbar.sh.
export TASKBAR_SLOTS=12
