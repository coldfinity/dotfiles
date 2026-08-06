#!/bin/bash
#
# Samples CPU, RAM and GPU and writes all four items — the anchor and the
# three popup rows — in one batched sketchybar call.
#
# All three share one ramp, so a loaded machine reads the same way whichever
# resource is loaded:
#
#   GREY    below 70%   — a number sitting at 9% has nothing to report
#   ORANGE  70-89%      — elevated
#   RED     90%+        — critical
#
# The anchor takes the worst of the three, which is what lets the collapsed
# group still signal load. Waybar's stats.sh does the same.

source "$CONFIG_DIR/colors.sh"

# Mouse events only toggle the popup — no point resampling because the
# pointer moved, and `ps` on every hover would make the popup slow to open.
case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" popup.drawing=on
    exit 0
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
esac

##### CPU #####
# ps rather than `top -l 2`, which needs a full sample interval and would
# block this script for a second on every tick. ps gives each process's share
# of one core, so the sum has to be divided by the thread count.
CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU=$(ps -eo pcpu | awk -v c="$CORE_COUNT" \
  '{ sum += $1 } END { printf "%.0f", sum / c }')
CPU=${CPU:-0}
# ps reports per-core percentages that can briefly sum past the core count on
# a busy machine; clamp so the ramp can't be handed a 103.
[ "$CPU" -gt 100 ] && CPU=100

##### RAM #####
# A percentage, not the GB figure this used to print. The bar's escalation
# ramp needs a number it can threshold, and "12.4GB" means nothing without
# knowing the machine.
#
# active + wired + compressed, over hw.memsize. This is what macOS itself
# calls memory used; it excludes the inactive pages the kernel will hand back
# on demand, the same reason waybar's Linux side reads MemAvailable rather
# than MemFree.
RAM=$(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
  /page size of/            { gsub(/[^0-9]/, "", $8); psize = $8 }
  /Pages active/            { gsub(/\./, "", $3); active = $3 }
  /Pages wired down/        { gsub(/\./, "", $4); wired = $4 }
  /Pages occupied by compressor/ { gsub(/\./, "", $5); comp = $5 }
  END {
    if (psize == 0) psize = 4096
    printf "%.0f", (active + wired + comp) * psize * 100 / total
  }')
RAM=${RAM:-0}

##### GPU #####
# Apple Silicon reports this through IOAccelerator. No driver, or a machine
# that doesn't expose it, reads 0 rather than erroring the item out — same
# fallback waybar's nvidia-smi branch takes.
GPU=$(ioreg -r -d 1 -w 0 -c IOAccelerator 2>/dev/null \
  | grep -o '"Device Utilization %"=[0-9]*' \
  | awk -F'=' '{ print $2 }' \
  | head -1)
GPU=${GPU:-0}

##### The shared ramp #####
ramp() {
  if [ "$1" -ge 90 ]; then
    echo $RED
  elif [ "$1" -ge 70 ]; then
    echo $ORANGE
  else
    echo $GREY
  fi
}

WORST=$CPU
[ "$RAM" -gt "$WORST" ] && WORST=$RAM
[ "$GPU" -gt "$WORST" ] && WORST=$GPU

sketchybar --set "$NAME" icon.color="$(ramp "$WORST")" \
  --set stats.cpu label="${CPU}%" label.color="$(ramp "$CPU")" icon.color="$(ramp "$CPU")" \
  --set stats.ram label="${RAM}%" label.color="$(ramp "$RAM")" icon.color="$(ramp "$RAM")" \
  --set stats.gpu label="${GPU}%" label.color="$(ramp "$GPU")" icon.color="$(ramp "$GPU")"
