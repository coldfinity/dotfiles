#!/bin/bash
#
# Rosé Pine — the same scheme wezterm runs. Values are 0xAARRGGBB; the CSS
# equivalent is in the comment beside each one.
#
# COLOUR ENCODES STATE, NOT IDENTITY.
#
# Grey is the resting position for everything on the bar. A module only takes
# on colour when it has something to say, and the same colour means the same
# thing everywhere:
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
# The bar draws no frames now, so text sits almost directly on the wallpaper
# and has to hold its own. TEXT is the resting colour rather than the dimmer
# GREY the framed design used — GREY is kept for the things that genuinely
# are secondary, like stat icons and the sparklines.
export TEXT=0xffe0def4       # #e0def4              labels, values
export GREY=0xff908caa       # #908caa              icons, secondary marks
export DIM=0x73e0def4        # rgba(224,222,244,.45) off / muted / unfocused
export EMPTY=0x40e0def4      # rgba(224,222,244,.25) workspace with no windows

##### State #####
export ACCENT=0xffc4a7e7     # #c4a7e7  iris  active, focused, connected
export ORANGE=0xfff6c177     # #f6c177  gold  elevated
export RED=0xffeb6f92        # #eb6f92  love  critical / destructive

##### Bar #####
# FULLY TRANSPARENT. The dark band in the reference screenshot is that
# machine's wallpaper, not the bar — quickshell is drawing onto a dark image,
# so the bar itself contributes nothing. Tinting here to imitate it would put
# a permanent dark strip over a wallpaper that may be bright.
#
# TEXT_SHADOW is what keeps the text readable with no surface at all, and is
# now load-bearing rather than a refinement.
#
# If you do want a tint, the alpha byte is the first pair: .25 = 0x40,
# .35 = 0x59, .50 = 0x80, .75 = 0xbf. e.g. 0x59191724.
export BAR_COLOR=0x00000000

# Sits behind every icon and label. With no frames to sit on, the text needs
# its own ground or it disappears over a bright patch of wallpaper. Near
# black, mostly opaque, at zero distance — a halo tight around the glyph
# rather than a drop shadow. This is what lets BAR_COLOR stay low.
export TEXT_SHADOW=0xcc0d0c14

##### Focused workspace #####
# An outlined rounded box with an accent bar under the numeral. Nothing else
# on the bar is boxed, so the outline alone marks focus.
export WS_BOX_BORDER=0x73c4a7e7  # rgba(196,167,231,.45)
export WS_BOX_FILL=0x1ac4a7e7    # rgba(196,167,231,.10)

##### Sparklines #####
# Deliberately faint. The number is the reading; the plot is context, and it
# sits under the text where it must not compete with it.
export GRAPH_LINE=0x66908caa
export GRAPH_FILL=0x1a908caa
