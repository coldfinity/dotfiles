#!/bin/bash
#
# Samples CPU, RAM and GPU, writes all three readings and pushes all three
# sparklines in one batched sketchybar call.
#
# All three share one ramp, so a loaded machine reads the same way whichever
# resource is loaded:
#
#   TEXT    below 70%   — a number sitting at 9% has nothing to report
#   ORANGE  70-89%      — elevated
#   RED     90%+        — critical
#
# The icons stay GREY throughout. Only the number escalates: the icon says
# which resource this is, which is not a fact that changes under load.

source "$CONFIG_DIR/colors.sh"

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
# active + wired + compressed, over hw.memsize. This is what macOS itself
# calls memory used; it excludes the inactive pages the kernel will hand back
# on demand.
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
# Apple Silicon reports this through IOAccelerator. A machine that doesn't
# expose it reads 0 rather than erroring the item out.
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
    echo $TEXT
  fi
}

sketchybar \
  --set cpu label="$CPU" label.color="$(ramp "$CPU")" \
  --set ram label="$RAM" label.color="$(ramp "$RAM")" \
  --set gpu label="$GPU" label.color="$(ramp "$GPU")"

