#!/bin/sh
# fcitx5 input mode as a line of text, once a second.
#
# fcitx5-remote exits printing the state as a number: 1 is inactive (plain
# latin), 2 is an active input engine (pinyin). It is polled because
# fcitx5-remote is a query tool with no watch mode.
#
# A loop rather than a Timer re-running the command, for the same reason as
# sysinfo.sh: one process for the life of the bar.
while :; do
    s=$(fcitx5-remote 2>/dev/null || echo 1)
    if [ "$s" = 2 ]; then
        echo "中"
    else
        echo "EN"
    fi
    sleep 1
done
