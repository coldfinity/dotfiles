#!/bin/sh
# waybar — the collapsed stats drawer's anchor.
#
# group/stats is a drawer: at rest it is this one glyph, and CPU/RAM/GPU
# only slide out when the cursor enters it. That means the resting bar has
# nowhere to show a number, so the anchor carries the state instead — it
# takes the warning/critical class from whichever of the three is worst,
# and the tooltip gives all three without expanding anything.
#
# Emits JSON (return-type: json in config.jsonc) because a plain-text
# custom module has no way to signal a class, the same reason custom/gpu
# is JSON.

# CPU has to be sampled — /proc/stat is a monotonic counter, so a single
# read gives usage since boot, which is a flat and useless number. Two
# reads a quarter-second apart give the instantaneous figure the built-in
# cpu module shows. The sleep is why this is a script and not an inline
# exec: it needs to hold state between the two reads.
cpu_snapshot() {
    awk '/^cpu /{ idle = $5; total = 0; for (i = 2; i <= NF; i++) total += $i; print idle, total }' /proc/stat
}

set -- $(cpu_snapshot); idle1=$1; total1=$2
sleep 0.25
set -- $(cpu_snapshot); idle2=$1; total2=$2

d_idle=$((idle2 - idle1))
d_total=$((total2 - total1))
if [ "$d_total" -gt 0 ]; then
    cpu=$(((100 * (d_total - d_idle)) / d_total))
else
    cpu=0
fi

# MemAvailable rather than MemFree: free excludes the page cache, which the
# kernel will hand back on demand, so it reads alarmingly low on a healthy
# machine. This matches what waybar's memory module reports.
mem=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)

# Same source as custom/gpu. Absent driver or no nvidia card reads as 0
# rather than erroring the module out.
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0)
[ -n "$gpu" ] || gpu=0

# The anchor reports the worst of the three, on the same thresholds the
# individual modules use. A machine under load should colour the bar
# whichever resource is the one under load.
worst=$cpu
[ "$mem" -gt "$worst" ] && worst=$mem
[ "$gpu" -gt "$worst" ] && worst=$gpu

if [ "$worst" -ge 90 ]; then
    class=critical
elif [ "$worst" -ge 70 ]; then
    class=warning
else
    class=""
fi

printf '{"text":"󰓅","tooltip":"CPU %s%%   RAM %s%%   GPU %s%%","class":"%s"}\n' \
    "$cpu" "$mem" "$gpu" "$class"
