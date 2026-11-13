#!/bin/bash
#
# EN at rest, 中 in accent when a pinyin engine is engaged.
#
# This follows the bar's colour rule exactly: latin input is the resting
# state and wears no colour, and the mode that changes what your keystrokes
# do is the one worth signalling. Waybar's custom/fcitx5 does the same with
# fcitx5-remote's 1/2 exit codes.
#
# macOS has no fcitx5-remote equivalent, so the current source is read out of
# HIToolbox's preferences. cfprefsd serves these live, so a `defaults read`
# reflects a switch immediately rather than on the next preference sync.

source "$CONFIG_DIR/colors.sh"

if [ "$1" = "cycle" ]; then
  # There is no supported CLI for selecting an input source, so this is
  # ctrl-space synthesised through System Events — the same shortcut the
  # menu bar's own item is bound to.
  #
  # Requires sketchybar to hold Accessibility permission (System Settings ->
  # Privacy & Security -> Accessibility). Without it this silently does
  # nothing, which is why the click is a convenience and the indicator is
  # the point.
  osascript -e 'tell application "System Events" to keystroke space using control down' 2>/dev/null
  exit 0
fi

SELECTED="$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null)"

# Matched on the Chinese IME bundle ids specifically rather than on "is this
# any keyboard input method". The generic rule would also catch Japanese and
# Korean engines, and label them 中 — wrong, and worse than not reporting
# them. SCIM is simplified pinyin, TCIM traditional.
case "$SELECTED" in
  *inputmethod.SCIM*|*inputmethod.TCIM*) LABEL="中"; COLOR=$ACCENT ;;
  *inputmethod.Kotoeri*) LABEL="日"; COLOR=$ACCENT ;;
  *inputmethod.Korean*) LABEL="한"; COLOR=$ACCENT ;;
  *'"KeyboardLayout Name" = ABC;'*|*'"KeyboardLayout Name" = U.S.;'*|*'"KeyboardLayout Name" = British;'*)
    LABEL="EN"; COLOR=$TEXT ;;
  *) LABEL="⌨"; COLOR=$GREY ;;
esac
sketchybar --set "$NAME" label="$LABEL" label.color=$COLOR
