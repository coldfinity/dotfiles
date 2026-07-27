#!/bin/bash

##### Base grayscale #####
export WHITE=0xffffffff      # primary labels
export GREY=0xffb4b4c0       # icons / secondary text
export DIM=0x80ffffff        # unfocused / muted

##### Accent (icy blue) #####
export ACCENT=0xff7aa2f7
export RED=0xfff7768e        # low-battery warning

##### Bar + frosted glass #####
export BAR_COLOR=0x00000000        # transparent -> floating islands
export GLASS_BG=0x26000000         # faint translucent dark pill fill
export GLASS_BORDER=0x33ffffff     # subtle glass edge highlight
export ACCENT_GLASS=0x267aa2f7     # accent-tinted pill behind focused workspace

##### Back-compat aliases used by item/plugin scripts #####
export PILL_BG=$GLASS_BG
export FOCUSED_WS_COLOR=$ACCENT
export UNFOCUSED_WS_COLOR=$DIM
export ACCENT_COLOR=$ACCENT
export ITEM_BG_COLOR=0xff333333
