#!/bin/bash
#
# $INFO on front_app_switched is just the app name. On the initial
# `sketchybar --update` at startup there is no event behind the call, so
# $INFO is empty — fall back to asking System Events directly just this
# once rather than sitting blank until the first app switch.

if [ -n "$INFO" ]; then
  APP="$INFO"
else
  APP="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)"
fi

sketchybar --set "$NAME" label="$APP"
