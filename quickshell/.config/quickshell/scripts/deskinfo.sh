#!/bin/sh
# Detail for the desktop widgets — deliberately everything the bar does NOT
# show.
#
# The bar has room for three percentages and a clock, so it carries CPU, RAM
# and GPU utilisation and nothing else. Repeating those on the wallpaper
# produced a desktop that said the same thing twice. This is the other half:
# temperatures, what the GPU is actually drawing, how full the disk and the
# VRAM are, and how much is moving over the network — none of which fits in
# a strip 36 pixels tall.

interval=2
iface=$(ip -4 route show default 2>/dev/null | awk '{print $5; exit}')
[ -n "$iface" ] || iface=lo

# Network is a rate, not a total, so it needs two reads like the CPU sample.
read_bytes() {
    awk -v want="$iface:" '$1 == want { print $2, $10 }' /proc/net/dev
}

set -- $(read_bytes)
rx_prev=${1:-0}
tx_prev=${2:-0}

while :; do
    sleep "$interval"

    set -- $(read_bytes)
    rx=${1:-0}
    tx=${2:-0}
    rx_rate=$(((rx - rx_prev) / interval))
    tx_rate=$(((tx - tx_prev) / interval))
    rx_prev=$rx
    tx_prev=$tx
    [ "$rx_rate" -lt 0 ] && rx_rate=0
    [ "$tx_rate" -lt 0 ] && tx_rate=0

    # x86_pkg_temp is the package sensor — the one that reflects the whole
    # die rather than acpitz, which on this board reads the chassis and sits
    # around 27C whatever the CPU is doing.
    cpu_temp=0
    for zone in /sys/class/thermal/thermal_zone*/; do
        if [ "$(cat "$zone/type" 2>/dev/null)" = "x86_pkg_temp" ]; then
            cpu_temp=$(($(cat "$zone/temp" 2>/dev/null || echo 0) / 1000))
            break
        fi
    done

    # One nvidia-smi call for every GPU field. Four separate invocations
    # would cost four process spawns every two seconds for data that comes
    # from one query.
    gpu=$(nvidia-smi --query-gpu=temperature.gpu,power.draw,memory.used,memory.total \
        --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
    gpu_temp=$(echo "$gpu" | cut -d, -f1)
    gpu_watt=$(echo "$gpu" | cut -d, -f2 | cut -d. -f1)
    vram_used=$(echo "$gpu" | cut -d, -f3)
    vram_total=$(echo "$gpu" | cut -d, -f4)
    [ -n "$gpu_temp" ] || gpu_temp=0
    [ -n "$gpu_watt" ] || gpu_watt=0
    [ -n "$vram_used" ] || vram_used=0
    [ -n "$vram_total" ] || vram_total=1

    set -- $(df -BG --output=used,size / 2>/dev/null | tail -1 | tr -d 'G')
    disk_used=${1:-0}
    disk_total=${2:-1}

    printf '{"cpuTemp":%s,"gpuTemp":%s,"gpuWatt":%s,"vramUsed":%s,"vramTotal":%s,"diskUsed":%s,"diskTotal":%s,"rx":%s,"tx":%s}\n' \
        "$cpu_temp" "$gpu_temp" "$gpu_watt" "$vram_used" "$vram_total" \
        "$disk_used" "$disk_total" "$rx_rate" "$tx_rate"
done
