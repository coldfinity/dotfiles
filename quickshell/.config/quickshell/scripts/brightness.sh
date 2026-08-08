#!/bin/sh
# Monitor brightness over DDC/CI.
#
#   brightness.sh get <connector>
#   brightness.sh set <connector> <0-100>
#
# This machine is a desktop: /sys/class/backlight is empty and there is no
# battery, so the usual backlight path does not exist. Both panels are
# external and support DDC/CI, which is the only way to reach their
# brightness — ddcutil talks to the monitor over the I2C lines in the
# DisplayPort cable.
#
# ddcutil works here without being in the i2c group, and without sudo.
#
# Every call costs roughly 600ms: the bus lookup is one round trip and the
# get/set is another. That is a hardware limit, not something to optimise
# away — which is why the slider in the dashboard applies on release rather
# than while dragging.

action=$1
connector=$2
value=$3

# Resolve the I2C bus from the DRM connector rather than hardcoding it.
# Bus numbers are assigned by probe order and move when hardware changes;
# the connector name (DP-1, DP-3) is the stable identifier and is what
# hyprland.conf already uses to name the outputs.
bus=$(ddcutil detect --brief 2>/dev/null | awk -v want="card1-$connector" '
    /I2C bus:/ { b = $3 }
    /DRM connector:/ { if ($3 == want) { sub("/dev/i2c-", "", b); print b; exit } }
')

[ -n "$bus" ] || exit 1

case "$action" in
get)
    # --brief prints "VCP 10 C <current> <max>"; field 4 is the current
    # value and field 5 the maximum, which is not always 100.
    ddcutil --bus "$bus" getvcp 10 --brief 2>/dev/null |
        awk '/^VCP/ { if ($5 > 0) printf "%d\n", ($4 * 100) / $5; else print $4 }'
    ;;
set)
    ddcutil --bus "$bus" setvcp 10 "$value" 2>/dev/null
    ;;
*)
    echo "usage: brightness.sh get|set <connector> [value]" >&2
    exit 2
    ;;
esac
