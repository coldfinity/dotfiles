import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// One bar, on one monitor. Instantiated per screen by shell.qml.
PanelWindow {
    id: bar

    // Bound by Variants to the screen this instance belongs to.
    required property var modelData
    screen: modelData

    // Anchored to three edges so the frames sit inset from the screen edge,
    // exactly as waybar's margin-top/left/right did. Not anchored bottom,
    // so the window is only as tall as the bar.
    anchors {
        top: true
        left: true
        right: true
    }

    // TEMPORARY, for side-by-side comparison while waybar is still live.
    // Flip `top` to false and `bottom` to true above to put this at the
    // bottom of the screen instead. See the switchover note in shell.qml.
    margins {
        top: Theme.gap
        left: Theme.inset
        right: Theme.inset
    }

    implicitHeight: Theme.barHeight

    // The window itself draws nothing — the frames are the only visible
    // surface, the same arrangement as `window#waybar { background:
    // transparent }`. Hyprland's layerrule blurs what is behind them.
    color: "transparent"

    // Reserve the bar's height so tiled windows do not slide under it.
    exclusiveZone: Theme.barHeight + Theme.gap

    // Named so hyprland.conf can target it with a layerrule. The waybar
    // rule matches the namespace "waybar"; this one needs its own.
    WlrLayershell.namespace: "quickshell-bar"

    // ── left: where your work is ─────────────────────────────────────
    Frame {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        // No taskbar section any more. The open windows are not a
        // permanent fixture on the bar — each workspace chip lists its own
        // on hover, which puts the windows next to the workspace they
        // belong to instead of in a flat row that loses that association.
        Workspaces {
            screenName: bar.modelData.name
        }
    }

    // ── centre: time, and what is playing ────────────────────────────
    Frame {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Clock {
            screenName: bar.modelData.name
        }
        // Media carries its own leading divider, so both vanish together
        // when nothing is playing.
        Media {}
    }

    // ── right: machine state ─────────────────────────────────────────
    Frame {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Stats {}
        Divider {}
        Status {}
        Divider {}
        InputMode {}
        Divider {}
        PowerButton {}
    }
}
