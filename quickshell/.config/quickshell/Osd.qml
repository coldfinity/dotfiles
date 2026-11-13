import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick

// The on-screen display for volume and brightness.
//
// Pressing the volume keys used to give no feedback at all, and the
// brightness keys did nothing whatsoever — they called brightnessctl, and
// /sys/class/backlight is empty on this desktop, so the only device it
// could find was the wifi LED.
//
// Volume needs no keybinding to work. It watches the Pipewire sink
// directly, so it appears whether the change came from the media keys, the
// dashboard slider, or another application entirely. Brightness cannot work
// that way — there is nothing to watch, since DDC/CI is a request-response
// conversation with the monitor — so the keys route through IPC instead.
Scope {
    id: root

    // "" when hidden. Also selects which glyph and value to draw.
    property string kind: ""

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [root.sink]
    }

    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    property real brightness: 1.0

    // Suppresses the OSD during startup.
    //
    // Every one of these properties fires its change handler once as the
    // bindings first resolve, which would flash the OSD on screen every
    // time the shell restarts. This stays false until that has settled.
    property bool ready: false

    Timer {
        running: true
        interval: 1500
        onTriggered: root.ready = true
    }

    onVolumeChanged: if (ready)
        show("volume")
    onMutedChanged: if (ready)
        show("volume")

    function show(what) {
        kind = what;
        hide.restart();
    }

    Timer {
        id: hide
        interval: 1600
        onTriggered: root.kind = ""
    }

    // ── brightness ───────────────────────────────────────────────────
    // The OSD moves immediately and the monitor catches up.
    //
    // Each DDC/CI write costs ~250ms with the bus cached, so writing on
    // every key press would queue a backlog behind a held key and the bar
    // would still be applying changes seconds after you stopped. The
    // displayed value is authoritative for the UI and a debounce collapses
    // a burst of presses into one write.
    Process {
        id: brightnessWrite
    }

    Timer {
        id: brightnessDebounce
        interval: 180
        onTriggered: {
            const monitor = Hyprland.focusedMonitor;
            if (!monitor)
                return;
            brightnessWrite.command = [Quickshell.shellPath("scripts/brightness.sh"), "set", monitor.name, String(Math.round(root.brightness * 100))];
            brightnessWrite.running = true;
        }
    }

    // Read once at startup so the first key press moves from the real
    // value rather than from an assumed 100%.
    Process {
        id: brightnessRead
        running: true
        command: [Quickshell.shellPath("scripts/brightness.sh"), "get", "DP-1"]
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line.trim());
                if (!isNaN(v))
                    root.brightness = v / 100;
            }
        }
    }

    IpcHandler {
        target: "osd"

        function brightnessUp(): void {
            root.step(0.05);
        }
        function brightnessDown(): void {
            root.step(-0.05);
        }
    }

    function step(delta) {
        brightness = Math.max(0, Math.min(1, brightness + delta));
        show("brightness");
        brightnessDebounce.restart();
    }

    readonly property real level: kind === "brightness" ? brightness : volume

    readonly property string glyph: {
        if (kind === "brightness")
            return "󰃞";
        if (muted)
            return "󰖁";
        if (volume < 0.34)
            return "󰕿";
        if (volume < 0.67)
            return "󰖀";
        return "󰕾";
    }

    // ── the overlay ──────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData

            // Only on the monitor you are working on. Showing it on both
            // would mean two of them appearing for one key press.
            readonly property bool onThisScreen: Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

            // Stays mapped through the fade-out, so the OSD does not vanish
            // mid-animation the way an unmapped popup would.
            visible: (root.kind !== "" || fading.running) && onThisScreen

            anchors {
                left: true
                right: true
                bottom: true
            }
            margins.bottom: 90

            implicitHeight: 56
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-osd"
            WlrLayershell.layer: WlrLayer.Overlay

            color: "transparent"

            // Kept alive briefly after kind clears, so the exit animation
            // has frames to render into.
            Timer {
                id: fading
                interval: 220
            }

            Connections {
                target: root
                function onKindChanged() {
                    if (root.kind === "")
                        fading.restart();
                }
            }

            Rectangle {
                id: body

                anchors.centerIn: parent
                width: 260
                height: 44

                color: Qt.rgba(0.098, 0.090, 0.141, 0.94)
                border.color: Theme.edge
                border.width: 1
                radius: Theme.radius

                opacity: root.kind !== "" ? 1 : 0
                scale: root.kind !== "" ? 1 : 0.97

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    id: osdGlyph
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.glyph
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 2
                    color: root.muted && root.kind === "volume" ? Theme.dim : Theme.text
                }

                Rectangle {
                    id: track
                    anchors.left: osdGlyph.right
                    anchors.right: readout.left
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    height: 4
                    radius: 2
                    color: Theme.hover

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.level))
                        height: parent.height
                        radius: parent.radius
                        color: root.muted && root.kind === "volume" ? Theme.dim : Theme.iris

                        // The fill slides rather than snapping, which is
                        // what makes a held key read as a continuous ramp
                        // instead of a series of jumps.
                        Behavior on width {
                            NumberAnimation {
                                duration: 110
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    id: readout
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: 38
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.level * 100)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.weight
                    color: Theme.subtle
                }
            }
        }
    }
}
