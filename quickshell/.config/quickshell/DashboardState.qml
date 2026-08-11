pragma Singleton

import Quickshell

// Whether the dashboard is open.
//
// A singleton because the dashboard has four different ways to open and
// they cannot all reach the same object otherwise: clicking the clock (which
// exists once per monitor), a keybind through IPC, the hot edge at the top
// of the screen, and Escape to close.
//
// The dashboard used to be a popup anchored to the clock, which meant it
// was instantiated per-bar and there was no single thing for a keybind to
// address. Splitting the state out is what makes every route work.
Singleton {
    property bool open: false

    function toggle() {
        open = !open;
    }
}
