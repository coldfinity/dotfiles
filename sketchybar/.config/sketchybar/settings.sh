#!/bin/bash
#
# Values shared between the item definitions and the plugins that repaint
# them. Sourced by sketchybarrc (which covers everything under items/) and
# by the plugins directly, since plugins run as their own processes and
# inherit nothing.

##### Typography #####
# Icons need a Nerd Font — SF Pro and SF Mono don't carry the Material
# Design glyphs this bar uses (network, battery, cpu, power, ...), so text
# and icons are deliberately different font families. Mixing them into one
# FONT_MAIN, like the previous version did, is what made switching the text
# font also blank out every icon.
#
#   FONT_ICON   glyphs only — network/battery/cpu/gpu/power/media icons.
#               Must stay a Nerd Font or these render as empty boxes.
#   FONT_TEXT   prose: clock, window title, media title, the EN/中 input
#               indicator, and the CJK workspace numerals (SF Pro falls back
#               to PingFang for CJK the same way the old Nerd Font did).
#   FONT_MONO   numbers that change on every tick — cpu/ram/gpu/battery/
#               network/volume percentages — so a reading going from 9% to
#               10% doesn't shift anything beside it.
export FONT_ICON="JetBrainsMono Nerd Font:Regular:15.0"
export FONT_TEXT="SF Pro:Semibold:14.0"
export FONT_MONO="SF Mono:Regular:13.0"

##### Bar geometry #####
# A floating bar, inset from every edge. This is the fix for the previous
# layout, which set margin=0 y_offset=0 and ran the bar flush and
# full-width — visually indistinguishable from "covering the screen".
#
# margin insets left and right; y_offset pushes down from the top. Both use
# BAR_MARGIN so the inset reads as uniform on the three visible sides.
export BAR_HEIGHT=32
export BAR_MARGIN=8
export BAR_RADIUS=12
export BAR_EDGE_PADDING=12

##### The notch #####
# No item sits at `center` — the notch is avoided by not placing anything
# there in the first place, rather than by sketchybar's own
# notch_width/notch_display_height bar properties. Those properties exist
# for exactly this, but on this sketchybar build they make every item's
# window span the full display height instead of just the bar's, which
# silently blocks clicks to desktop icons and interactive widgets. See the
# long comment above the `--bar` call in sketchybarrc.

##### Group spacing #####
# No pill backgrounds — the native menu bar never draws one either; it
# groups items by spacing alone. GROUP_GAP is the wider gap between
# unrelated clusters (workspaces / window title / stats / connectivity /
# battery+power / clock); the tighter, unnamed 8-10px paddings inside each
# item file are the gap between items that belong to the same cluster.
export GROUP_GAP=22

##### Window title #####
export TITLE_MAX_CHARS=32

##### Media #####
export MEDIA_MAX_CHARS=38

##### Workspaces #####
# WS_IDS and WS_ICONS are parallel: index i in one pairs with index i in the
# other. Not an associative array — macOS ships bash 3.2, which has none.
#
# Aerospace defines nine workspaces and all nine are still reachable by
# keybind; the bar deliberately lists only these. A workspace left off this
# list simply isn't drawn.
#
# CJK numerals, matching waybar. They render through font fallback to
# PingFang and are full-width glyphs, wider than the digits they replace.
export WS_IDS=(1 2 3 4 5)
export WS_ICONS=(一 二 三 四 五)
