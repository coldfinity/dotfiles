#!/bin/bash

RAM_USED=$(vm_stat | awk '
/Pages active/     { active=$3+0 }
/Pages wired/      { wired=$4+0 }
/Pages occupied/   { occupied=$5+0 }
END { printf "%.1f", (active + wired + occupied) * 4096 / 1073741824 }
')

sketchybar --set $NAME icon.drawing=off label="RAM ${RAM_USED}GB"
