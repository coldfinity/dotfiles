pragma Singleton

import Quickshell
import QtQuick

// The one physical monitor everything keys off. A Quickshell Singleton,
// same pattern as Theme.qml — auto-registered by filename, so `Monitors.main`
// works from any file in this directory without a qmldir.
//
// This can't just read hyprland.conf's $mainMonitor: that variable is
// substituted by Hyprland's own parser and never reaches anything outside
// that file. Keep this value in sync with $mainMonitor by hand when the
// monitor changes.
Singleton {
    readonly property string main: "DP-3"
}
