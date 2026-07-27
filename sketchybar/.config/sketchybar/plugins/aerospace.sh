#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Workspace id: passed as $1, fall back to the item name (space.<id>).
sid="$1"
[ -z "$sid" ] && sid="${NAME#space.}"

# Query directly so styling is correct on timer ticks too (not just events).
FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)"

# Build the strip of app icons for the apps open in this workspace.
apps="$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | sort -u)"
icons=""
if [ -n "$apps" ]; then
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    glyph="$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app")"
    glyph="${glyph% }" # official map appends a trailing space
    if [ -z "$icons" ]; then
      icons="$glyph"
    else
      icons="$icons $glyph"
    fi
  done <<EOF
$apps
EOF
fi

# With apps: show the logos (sketchybar-app-font label), hide the dash.
# Empty: show a dim dash placeholder instead.
if [ -n "$icons" ]; then
  draw="off"
  dash=""
  label="$icons"
else
  draw="on"
  dash="—"
  label=""
fi

if [ "$sid" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    icon.drawing=$draw icon="$dash" icon.color=$FOCUSED_WS_COLOR \
    label="$label" label.color=$FOCUSED_WS_COLOR \
    background.drawing=on \
    background.color=$ACCENT_GLASS \
    background.corner_radius=0 \
    background.height=22
else
  sketchybar --set "$NAME" \
    icon.drawing=$draw icon="$dash" icon.color=$UNFOCUSED_WS_COLOR \
    label="$label" label.color=$UNFOCUSED_WS_COLOR \
    background.drawing=off
fi
