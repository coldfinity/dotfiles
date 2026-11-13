#!/bin/bash
# Apply the visual layout after creating items; event scripts own live values.
panel() {
  local name="$1"
  shift
  sketchybar --add bracket "$name" "$@" \
    --set "$name" background.drawing=on background.color=$SURFACE \
    background.border_color=$SURFACE_BORDER background.border_width=1 \
    background.height=32 background.corner_radius=10
}

sketchybar --set apple icon.color=$ACCENT icon.font="SF Pro:Medium:19.0" \
  icon.padding_left=12 icon.padding_right=12
for sid in "${WS_IDS[@]}"; do
  sketchybar --set space.$sid icon.padding_left=9 icon.padding_right=9 \
    background.height=24 background.corner_radius=7 background.color=$ACCENT
done
sketchybar --set window_title label.padding_left=12 label.padding_right=12 \
  label.color=$TEXT padding_left=0
panel navigation apple '/space\..*/'
panel application window_title

# Icon and label padding is internal; gap items separate the panels.
sketchybar --set clock label.padding_left=12 label.padding_right=12 \
  label.font="SF Pro:Semibold:13.0" label.color=$ACCENT padding_left=0
panel date_time clock
sketchybar --set battery icon.padding_left=12 label.padding_right=12 padding_left=0
sketchybar --set input_source label.padding_left=10 label.padding_right=0 \
  --set volume icon.padding_left=10 icon.padding_right=4 \
  --set bluetooth icon.padding_left=10 icon.padding_right=0 \
  --set network icon.padding_left=12 icon.padding_right=4 padding_left=0
panel controls network bluetooth volume input_source battery
sketchybar --set cpu icon.padding_left=12 padding_left=0 \
  --set ram icon.padding_left=12 \
  --set gpu icon.padding_left=12 label.padding_right=12
panel resources cpu ram gpu
# Media can disappear, so give the item itself its surface.
sketchybar --set media padding_left=8 icon.padding_left=12 label.padding_right=12 \
  background.drawing=on background.color=$PILL_FILL background.height=32 \
  background.corner_radius=10 background.border_width=1 background.border_color=$PILL_BORDER
