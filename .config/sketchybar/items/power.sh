#!/bin/bash
#
# The power menu — macOS counterpart to waybar/power-menu.sh, which puts the
# same five actions in a rofi list.
#
# GREY at rest and RED only under the cursor: it is the one destructive
# control on the bar, and it should not wear a warning colour while it is
# just sitting there.
#
# 󰐥 U+F0425, Material Design power.
#
# NOT  U+F011, which is what waybar uses and what this started as. Every
# glyph on this bar has to come from the U+F0000+ Material Design block: the
# Font Awesome glyphs in the U+F000-F8FF BMP private-use area do not survive
# being written into these files, and land here as an empty string — an item
# with no icon at all, which draws as a gap. The MD block is four bytes in
# UTF-8 and comes through intact.
#
# Shares its glyph with the Shut Down row in the popup. That row carries a
# text label, so there is nothing to confuse it with.

sketchybar --add item power right \
  --set power \
  icon=󰐥 \
  icon.color=$GREY \
  icon.padding_left=10 \
  icon.padding_right=$GROUP_GAP \
  label.drawing=off \
  background.drawing=off \
  script="$PLUGIN_DIR/power.sh" \
  "${popup[@]}" \
  --subscribe power mouse.entered mouse.exited mouse.exited.global mouse.clicked

# Five actions, matching power-menu.sh. Each one closes the popup before
# acting: `restart` and `shut down` put up a confirmation dialog of their
# own, and leaving our popup open behind it looks like a hang.
add_power_action() {
  sketchybar --add item power.$1 popup.power \
    --set power.$1 \
    icon="$2" \
    icon.color=$GREY \
    icon.padding_left=14 \
    icon.padding_right=8 \
    label="$3" \
    label.color=$GREY \
    label.padding_right=12 \
    background.drawing=off \
    width=150 \
    click_script="sketchybar --set power popup.drawing=off; $4"
}

# 󰌾 lock, 󰒲 sleep, 󰍃 log out, 󰜉 restart, 󰐥 shut down.
add_power_action lock     󰌾 "Lock"      "pmset displaysleepnow"
add_power_action sleep    󰒲 "Sleep"     "pmset sleepnow"
add_power_action logout   󰍃 "Log Out"   "osascript -e 'tell application \"System Events\" to log out'"
add_power_action restart  󰜉 "Restart"   "osascript -e 'tell application \"System Events\" to restart'"
add_power_action shutdown 󰐥 "Shut Down" "osascript -e 'tell application \"System Events\" to shut down'"
