#!/bin/bash
#
# Repaints every workspace chip in one batched sketchybar call.
#
#   focused    numeral in ACCENT inside an outlined rounded box
#   visible    numeral in TEXT, no box — showing on some monitor, but not the
#              one holding keyboard focus
#   occupied   DIM  — has windows, not on screen
#   empty      EMPTY — listed only so the row keeps a stable width
#
# Only the focused chip is decorated. Everything else is a bare glyph, which
# is what makes the box read as focus rather than as one style among several.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"

# Four queries, not one per workspace. Each `aerospace` invocation costs
# ~30ms, so the count here is what decides whether the row repaints in one
# frame or visibly cascades.
FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)"
VISIBLE="$(aerospace list-workspaces --monitor all --visible 2>/dev/null)"
OCCUPIED="$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)"
# workspace|nsscreen-id — the nsscreen id is the one that lines up with
# sketchybar's own `display=` index; monitor-id does not.
MONITORS="$(aerospace list-workspaces --monitor all \
  --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)"

args=()

for sid in "${WS_IDS[@]}"; do
  display="$(printf '%s\n' "$MONITORS" | awk -F'|' -v w="$sid" '$1 == w {print $2; exit}')"
  [ -z "$display" ] && display=1

  if [ "$sid" = "$FOCUSED" ]; then
    args+=(--set space.$sid display="$display"
      icon.color=$ACCENT
      background.drawing=on)

  elif printf '%s\n' "$VISIBLE" | grep -qx "$sid"; then
    # Showing on a monitor that doesn't hold focus. With one display this
    # never fires; with two, it is what stops the unfocused monitor's bar
    # from marking nothing at all.
    args+=(--set space.$sid display="$display"
      icon.color=$TEXT
      background.drawing=off)

  elif printf '%s\n' "$OCCUPIED" | grep -qx "$sid"; then
    args+=(--set space.$sid display="$display"
      icon.color=$DIM
      background.drawing=off)

  else
    args+=(--set space.$sid display="$display"
      icon.color=$EMPTY
      background.drawing=off)
  fi
done

sketchybar --animate sin 12 "${args[@]}"
