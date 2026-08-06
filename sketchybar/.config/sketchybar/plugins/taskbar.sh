#!/bin/bash
#
# Fills the taskbar slots with the windows on the focused workspace.
#
# The focused window wears the same ACCENT_FILL block the focused workspace
# chip does, so the bar's two "this is current" markers read identically —
# waybar does the same with #taskbar button.active.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"

WINDOWS="$(aerospace list-windows --workspace focused \
  --format '%{window-id}|%{app-name}' 2>/dev/null)"
FOCUSED_WIN="$(aerospace list-windows --focused \
  --format '%{window-id}' 2>/dev/null | head -1)"

args=()
slot=0

while IFS='|' read -r win_id app_name; do
  [ -z "$win_id" ] && continue
  slot=$((slot + 1))
  [ "$slot" -gt "$TASKBAR_SLOTS" ] && break

  glyph="$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app_name")"
  glyph="${glyph% }" # the official map appends a trailing space

  if [ "$win_id" = "$FOCUSED_WIN" ]; then
    icon_color=$ACCENT
    bg_draw=on
  else
    icon_color=$DIM
    bg_draw=off
  fi

  # Click focuses the window. Deliberately no close binding: waybar puts that
  # on middle-click and off left-click, and sketchybar's click_script has no
  # button discrimination without subscribing to mouse.clicked and reading
  # $BUTTON — not worth it for a destructive action on a row of small icons.
  args+=(--set taskbar.$slot
    drawing=on
    icon="$glyph"
    icon.color=$icon_color
    background.drawing=$bg_draw
    background.color=$ACCENT_FILL
    click_script="aerospace focus --window-id $win_id")
done <<EOF
$WINDOWS
EOF

# Blank the rest of the pool.
for i in $(seq $((slot + 1)) $TASKBAR_SLOTS); do
  args+=(--set taskbar.$i drawing=off)
done

# The divider that separates the taskbar from the workspaces belongs to the
# taskbar and goes with it, so an empty workspace leaves no stray rule —
# waybar handles this with the window#waybar.empty #taskbar rule.
if [ "$slot" -gt 0 ]; then
  args+=(--set divider.taskbar drawing=on)
else
  args+=(--set divider.taskbar drawing=off)
fi

sketchybar "${args[@]}"
