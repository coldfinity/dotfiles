#!/bin/bash
#
# Rosé Pine — the same scheme wezterm runs, and the same palette waybar
# carries on the Linux box (see waybar/style.css, which this is a direct
# translation of). Values are 0xAARRGGBB; the CSS equivalent is in the
# comment beside each one.
#
# COLOUR ENCODES STATE, NOT IDENTITY.
#
# Grey is the resting position for everything on the bar. A module only takes
# on colour when it has something to say, and the same colour means the same
# thing everywhere:
#
#   GREY    normal / resting — the default for every module
#   ACCENT  active, focused, connected
#   ORANGE  elevated — a load threshold has been crossed
#   RED     critical, or a destructive control under the cursor
#   DIM     off, muted, disconnected, unfocused
#
# The earlier revision of this file gave modules their own hues off an icy
# blue accent (0xff7aa2f7). That was decoration: it coloured things you could
# already tell apart by their labels, and left nothing to escalate to when
# something actually needed attention. ORANGE and RED are the only colours
# here that mean "look at me", and nothing wears them at rest.

##### Text #####
export TEXT=0xffe0def4       # #e0def4              primary labels
export GREY=0xff908caa       # #908caa              icons / secondary text — the default
export DIM=0x73e0def4        # rgba(224,222,244,.45) off / muted / unfocused

# A step below DIM, for persistent workspaces holding no windows. They are
# listed so the row keeps a stable width, but they are the least important
# thing on the bar and shouldn't compete with the ones you are using.
export EMPTY=0x40e0def4      # rgba(224,222,244,.25)

##### State #####
export ACCENT=0xffc4a7e7     # #c4a7e7  iris  active, focused, connected
export ORANGE=0xfff6c177     # #f6c177  gold  elevated
export RED=0xffeb6f92        # #eb6f92  love  critical / destructive

##### Bar surfaces #####
# The bar itself is transparent; each frame draws its own surface.
export BAR_COLOR=0x00000000

# The frame is the border, not the fill — 2px-radius outlines rather than the
# filled capsules this used to draw.
#
# THE FILL IS LOW AND THE TEXT CARRIES A SHADOW. Those two go together; do
# not change one without the other.
#
# Waybar can afford a 30% fill because hyprland blurs the backdrop behind
# it: the `layerrule = blur, waybar` line darkens whatever is behind the bar
# into the near-black surface rose pine's greys were picked against. macOS
# has no equivalent. Sketchybar's own blur_radius is a property of the BAR,
# not of a bracket, so it blurs the whole bar rectangle including the gaps
# between frames — which would destroy the three separate floating surfaces
# this design is built on.
#
# Raising the fill to compensate works, and is what this did for a while at
# 85%, but it makes the bar a solid dark strip rather than glass. The fill
# is the wrong lever: the problem was never the surface, it was that the
# text had nothing to sit against. TEXT_SHADOW below gives every glyph its
# own dark ground, one character wide, so contrast survives a bright
# wallpaper at a fill low enough to still read as transparent.
#
# Alpha reference if you want to retune: .25 = 0x40, .35 = 0x59,
# .45 = 0x73, .60 = 0x99, .75 = 0xbf, .85 = 0xd9.
export FRAME_BG=0x59191724      # rgba(25,23,36,.35)
export FRAME_BORDER=0x2ee0def4  # rgba(224,222,244,.18)

# Sits behind every icon and label. Near-black and mostly opaque, at zero
# distance, so it reads as a soft halo tight around the glyph rather than as
# a drop shadow — the point is local contrast, not depth.
export TEXT_SHADOW=0xcc0d0c14

# Sketchybar has no border-left, so section rules inside a frame are drawn as
# 1px-wide items filled with this.
export DIVIDER=0x1fe0def4       # rgba(224,222,244,.12)

##### Focused block #####
# Worn by the focused workspace and the focused window in the taskbar, so the
# bar's two "this is current" markers read identically.
export ACCENT_FILL=0x2ec4a7e7   # rgba(196,167,231,.18)
export ACCENT_LINE=0x73c4a7e7   # rgba(196,167,231,.45)
