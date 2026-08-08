#!/bin/sh
# CPU, RAM and GPU utilisation as a JSON line every two seconds.
#
# A long-running loop rather than a command quickshell re-runs on a Timer:
# one process for the life of the bar instead of three forks every tick,
# and the CPU sample needs to span an interval anyway.
#
# The waybar version of this (waybar/.config/waybar/stats.sh) reported only
# the worst of the three, because a collapsed drawer had nowhere to show a
# number. This prints all three and lets the QML decide — the drawer's
# anchor takes the maximum, and the expanded sections take their own.

interval=2

cpu_snapshot() {
    awk '/^cpu /{ idle = $5; total = 0; for (i = 2; i <= NF; i++) total += $i; print idle, total }' /proc/stat
}

set -- $(cpu_snapshot)
idle_prev=$1
total_prev=$2

while :; do
    sleep "$interval"

    set -- $(cpu_snapshot)
    idle=$1
    total=$2

    d_idle=$((idle - idle_prev))
    d_total=$((total - total_prev))
    idle_prev=$idle
    total_prev=$total

    # /proc/stat is a monotonic counter, so usage is only meaningful as a
    # delta between two reads. The first iteration's delta spans from
    # process start, which is why the snapshot above happens before the
    # loop rather than inside it.
    if [ "$d_total" -gt 0 ]; then
        cpu=$(((100 * (d_total - d_idle)) / d_total))
    else
        cpu=0
    fi

    # MemAvailable, not MemFree: free excludes the page cache, which the
    # kernel hands back on demand, so it reads alarmingly low on a healthy
    # machine.
    mem=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)

    gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0)
    [ -n "$gpu" ] || gpu=0

    # Uptime rides along on the same line rather than getting its own
    # process. The dashboard is the only thing that shows it and it changes
    # once a minute, so a second poller for it would be waste.
    up=$(uptime -p | sed 's/^up //')

    printf '{"cpu":%s,"mem":%s,"gpu":%s,"uptime":"%s"}\n' "$cpu" "$mem" "$gpu" "$up"
done
