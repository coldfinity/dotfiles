#!/bin/bash
#
# Charcoal Minimal — a dark neutral base. Colour is reserved for state and
# for telling related clusters of items apart at a glance; it never sits on
# the bar just to be colourful.
#
# COLOUR ENCODES STATE, NOT DECORATION.
#
#   TEXT    normal / resting — the default for every module
#   ACCENT  active, focused, connected
#   ORANGE  elevated — a load threshold has been crossed
#   RED     critical, or a destructive control under the cursor
#   DIM     off, muted, disconnected, unfocused
#
# ORANGE and RED are the only colours here that mean "look at me", and
# nothing wears them at rest.

##### Text #####
export TEXT=0xffe4e4e7       # #e4e4e7  off-white  labels, values
export GREY=0xff8a8a92       # #8a8a92  icons, secondary marks
export DIM=0x738a8a92        # rgba(138,138,146,.45)  off / muted / unfocused
export EMPTY=0x408a8a92      # rgba(138,138,146,.25)  workspace with no windows

##### State #####
export ACCENT=0xff7aa2f7     # #7aa2f7  blue   active, focused, connected
export ORANGE=0xffe0af68     # #e0af68  amber  elevated
export RED=0xfff7768e        # #f7768e  red    critical / destructive

##### Bar #####
# True vibrancy, not a flat tint — a translucent surface over
# `blur_radius` (set in sketchybarrc) so the desktop behind genuinely
# frosts, the way NSVisualEffectView does in the real menu bar. Opaque
# charcoal looked like a painted rectangle; this is the difference between
# "styled like macOS" and "actually is macOS's own material".
export SURFACE=0x99161616            # rgba(22,22,22,.60)
export SURFACE_BORDER=0x14ffffff     # rgba(255,255,255,.08)
export BAR_COLOR=$SURFACE

##### Group pills #####
# One neutral, monochrome highlight for every pill — the native menu bar
# never tints a grouping by hue, only by translucency. Colour stays
# reserved for state (ACCENT/ORANGE/RED), never for telling one cluster of
# icons from another.
export PILL_FILL=0x14ffffff          # rgba(255,255,255,.08)
export PILL_BORDER=0x1fffffff        # rgba(255,255,255,.12)
