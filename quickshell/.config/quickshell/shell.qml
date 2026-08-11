// Quickshell — replacement for the waybar config in waybar/.
//
// Why the move: waybar's appearance is GTK3 CSS, which has no way to draw
// anything that is not a styled box. The hover drawers on the old bar
// existed only because waybar happens to ship a `drawer` group type, the
// tooltips were unstyleable GTK defaults, and anything richer — a volume
// slider, a calendar, a real popup — was simply unavailable. Quickshell is
// QtQuick, so the bar is a scene graph and all of that is ordinary QML.
//
// The design is carried over unchanged: square hairline frames, sections
// divided by rules rather than separate floating objects, rose-pine, and
// colour that encodes state rather than identity. See Theme.qml.
//
// Run manually with `qs -p ~/.config/quickshell` while waybar is still the
// live bar. hyprland.conf still starts waybar; switching over is one line.

import Quickshell

ShellRoot {
    // One bar per monitor. Variants instantiates its delegate once per
    // element of `model` with `modelData` bound to that element — the
    // quickshell idiom for per-screen surfaces, and the replacement for
    // waybar's implicit "one bar on every output".
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    // Volume and brightness overlay. One instance for the whole shell; its
    // per-screen windows live inside it.
    Osd {}

    // Clock, machine and now-playing on the wallpaper layer. Covered by any
    // window, so they need no visibility logic of their own.
    DesktopWidgets {}

    // Application launcher, on SUPER+Space. Replaces rofi.
    Launcher {}

    // The control centre. A shell-level overlay rather than a popup hanging
    // off the clock, so a keybind can open it too.
    Dashboard {}

    // Notification toasts. The daemon itself is the Notifications
    // singleton — this only draws what it is tracking.
    Toasts {}

    // Polkit authentication. Replaces hyprpolkitagent.
    PolkitDialog {}

    // A native lock screen, opened only on request — hyprlock is still what
    // locks this machine at boot and on idle. See Lock.qml.
    Lock {}

}
