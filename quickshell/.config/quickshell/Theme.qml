pragma Singleton

import Quickshell
import QtQuick

// Rosé Pine, the same palette waybar/rofi/mako/hyprlock use and the scheme
// wezterm runs (.wezterm.lua sets color_scheme = "rose-pine").
//
// This is a Quickshell Singleton rather than a plain QML singleton, which
// means no qmldir is needed — quickshell registers it by filename, so
// `Theme.iris` works from any file in this directory.
//
// COLOUR ENCODES STATE, NOT IDENTITY — carried over from the waybar
// stylesheet verbatim, because it is the rule that made that bar readable:
//
//   subtle  normal / resting — the default for every module
//   iris    active, focused, connected
//   gold    elevated — a load threshold has been crossed
//   love    critical, or a destructive control under the cursor
//   dim     off, muted, disconnected, unfocused
//
// Nothing wears colour at rest.
Singleton {
    // ── palette ──────────────────────────────────────────────────────
    readonly property color base: "#191724"
    readonly property color text: "#e0def4"
    readonly property color subtle: "#908caa"
    readonly property color iris: "#c4a7e7"
    readonly property color gold: "#f6c177"
    readonly property color love: "#eb6f92"

    // Derived from text rather than pure white, which is what stopped the
    // old bar reading blue-grey next to a rose-pine terminal.
    readonly property color dim: Qt.rgba(0.878, 0.871, 0.957, 0.45)
    readonly property color faint: Qt.rgba(0.878, 0.871, 0.957, 0.25)

    // ── surfaces ─────────────────────────────────────────────────────
    // The frame is the border, not the fill.
    //
    // 0.30 rather than 0: hyprland.conf's layerrule for this surface uses
    // ignore_alpha, and a fill below that threshold stops being blurred
    // along with the gaps between frames — the text ends up on raw
    // wallpaper. Lowest value that still reads as empty while staying on
    // the blurred side of the cutoff.
    readonly property color fill: Qt.rgba(0.098, 0.090, 0.141, 0.30)
    readonly property color edge: Qt.rgba(0.878, 0.871, 0.957, 0.18)
    readonly property color divider: Qt.rgba(0.878, 0.871, 0.957, 0.12)
    readonly property color hover: Qt.rgba(0.878, 0.871, 0.957, 0.08)
    readonly property color accentFill: Qt.rgba(0.769, 0.655, 0.906, 0.18)
    readonly property color accentEdge: Qt.rgba(0.769, 0.655, 0.906, 0.45)

    // ── geometry ─────────────────────────────────────────────────────
    // 2px, not 0. A true right angle aliases into a ragged corner pixel at
    // this size; 2px draws clean and does not read as "rounded".
    readonly property int radius: 2
    readonly property int barHeight: 34
    readonly property int gap: 6
    readonly property int inset: 10

    // ── type ─────────────────────────────────────────────────────────
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int animMs: 200

    // The shared load ramp. All three stats use it, so a loaded machine
    // reads the same way whichever resource is the one under load.
    function loadColour(pct) {
        if (pct >= 90)
            return love;
        if (pct >= 70)
            return gold;
        return subtle;
    }
}
