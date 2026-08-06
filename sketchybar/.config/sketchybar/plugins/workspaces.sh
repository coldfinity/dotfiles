#!/bin/bash
#
# Repaints every workspace chip in one batched sketchybar call.
#
# Four states, matching waybar's #workspaces button rules:
#
#   focused    ACCENT text on an ACCENT_FILL block with an ACCENT_LINE outline
#   visible    GREY text, outline only, no fill — showing on some monitor, but
#              not the one holding keyboard focus
#   occupied   DIM  — has windows, not on screen
#   empty      EMPTY — listed only so the row keeps a stable width
#
# The block morphs rather than just recolouring: chips are narrow at rest and
# the wide states stretch, animated. This is the sketchybar analogue of
# waybar's `min-width 250ms cubic-bezier` transition.
#
# Width comes from the icon padding rather than from `width`, so the numeral
# stays centred in the block at both sizes — see items/workspaces.sh for why
# forcing a width does not work here. NARROW/WIDE are per-side padding, so
# the chip measures roughly 2*PAD plus the glyph.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"

# Per-side icon padding. The CJK numerals are full-width glyphs, roughly 14px
# at SemiBold 13, so these land the chip at about 26px and 46px — the two
# widths waybar's #workspaces button uses.
NARROW=6
WIDE=16

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
      icon.padding_left=$WIDE icon.padding_right=$WIDE
      icon.color=$ACCENT
      background.drawing=on
      background.color=$ACCENT_FILL
      background.border_color=$ACCENT_LINE)

  elif printf '%s\n' "$VISIBLE" | grep -qx "$sid"; then
    # Showing on a monitor that doesn't hold focus. With one display this
    # never fires; with two, it is what stops the unfocused monitor's bar
    # from highlighting nothing at all. Outlined rather than filled: this is
    # where you are, not what you are typing into.
    args+=(--set space.$sid display="$display"
      icon.padding_left=$WIDE icon.padding_right=$WIDE
      icon.color=$GREY
      background.drawing=on
      background.color=0x00000000
      background.border_color=$FRAME_BORDER)

  elif printf '%s\n' "$OCCUPIED" | grep -qx "$sid"; then
    args+=(--set space.$sid display="$display"
      icon.padding_left=$NARROW icon.padding_right=$NARROW
      icon.color=$DIM
      background.drawing=off)

  else
    args+=(--set space.$sid display="$display"
      icon.padding_left=$NARROW icon.padding_right=$NARROW
      icon.color=$EMPTY
      background.drawing=off)
  fi
done

sketchybar --animate sin 15 "${args[@]}"
