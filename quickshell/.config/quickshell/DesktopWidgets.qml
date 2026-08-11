import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

// Widgets on the wallpaper.
//
// DELIBERATELY NOT WHAT THE BAR SHOWS.
//
// The first version of this put a clock, CPU/RAM/GPU percentages and the
// current track on the desktop — every one of which is already in the bar,
// four inches away. That is not a second surface, it is the same surface
// twice, and it makes the desktop feel redundant rather than additional.
//
// A bar is 36px tall, so it can only carry a few short numbers: utilisation
// percentages and a clock. Everything that does not fit in that shape lives
// here instead — temperatures, what the GPU is actually drawing, how full
// the disk and VRAM are, what is moving over the network. The two surfaces
// answer different questions.
//
// The clock is the one deliberate repetition. It reads across the room,
// which the bar's 15px version does not, and it anchors the composition.
//
// These live on the BACKGROUND layer, which is what makes them work on a
// tiling desktop: above the wallpaper, below every window, so a tiled
// window simply covers them and they reappear when the workspace empties.
// Nothing has to track whether anything is open.
Scope {
    id: root

    SystemClock {
        id: wallClock
        precision: SystemClock.Minutes
    }

    property int cpuTemp: 0
    property int gpuTemp: 0
    property int gpuWatt: 0
    property int vramUsed: 0
    property int vramTotal: 1
    property int diskUsed: 0
    property int diskTotal: 1
    property real rx: 0
    property real tx: 0

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/deskinfo.sh")]

        stdout: SplitParser {
            onRead: line => {
                try {
                    const d = JSON.parse(line);
                    root.cpuTemp = d.cpuTemp;
                    root.gpuTemp = d.gpuTemp;
                    root.gpuWatt = d.gpuWatt;
                    root.vramUsed = d.vramUsed;
                    root.vramTotal = d.vramTotal;
                    root.diskUsed = d.diskUsed;
                    root.diskTotal = d.diskTotal;
                    root.rx = d.rx;
                    root.tx = d.tx;
                } catch (e)
                // A partial line during shutdown is not worth logging.
                {}
            }
        }
    }

    function rate(bytes) {
        if (bytes > 1048576)
            return (bytes / 1048576).toFixed(1) + " MB/s";
        if (bytes > 1024)
            return Math.round(bytes / 1024) + " KB/s";
        return bytes + " B/s";
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            // Only the wide monitor. The Dell is 1080p and usually full of
            // windows, so widgets there would be permanently covered.
            visible: modelData.name === "DP-1"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Reserves nothing and takes no input. Without the mask this
            // full-screen surface would swallow every click meant for the
            // desktop beneath it.
            exclusiveZone: 0
            mask: Region {}

            WlrLayershell.namespace: "quickshell-desktop"
            WlrLayershell.layer: WlrLayer.Background

            color: "transparent"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 90
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40
                spacing: 4

                // ── time ─────────────────────────────────────────────
                // Thin and very large. At this size a normal weight turns
                // into a wall and the wallpaper stops showing through the
                // composition.
                Text {
                    text: Qt.formatDateTime(wallClock.date, "HH:mm")
                    font.family: Theme.fontFamily
                    font.pixelSize: 132
                    font.weight: Font.Thin
                    color: Theme.text

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0, 0, 0, 0.7)
                        shadowBlur: 0.7
                        shadowVerticalOffset: 2
                    }
                }

                Text {
                    text: Qt.locale("zh_CN").toString(wallClock.date, "dddd  MM月dd日")
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    font.weight: Theme.weight
                    font.letterSpacing: Theme.tracking
                    color: Theme.subtle

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0, 0, 0, 0.7)
                        shadowBlur: 0.6
                        shadowVerticalOffset: 1
                    }
                }

                Item {
                    width: 1
                    height: 34
                }

                // ── the machine, in the detail a bar cannot hold ──────
                Grid {
                    columns: 2
                    columnSpacing: 46
                    rowSpacing: 9

                    DeskStat {
                        label: "cpu"
                        value: root.cpuTemp + "°"
                        // Temperature, not utilisation. The bar already says
                        // how busy it is; this says whether that is costing
                        // anything.
                        warn: root.cpuTemp >= 80
                    }
                    DeskStat {
                        label: "gpu"
                        value: root.gpuTemp + "°   " + root.gpuWatt + "W"
                        warn: root.gpuTemp >= 80
                    }
                    DeskStat {
                        label: "vram"
                        value: (root.vramUsed / 1024).toFixed(1) + " / " + (root.vramTotal / 1024).toFixed(0) + " GB"
                        warn: root.vramUsed > root.vramTotal * 0.9
                    }
                    DeskStat {
                        label: "disk"
                        value: root.diskUsed + " / " + root.diskTotal + " GB"
                        warn: root.diskUsed > root.diskTotal * 0.9
                    }
                    DeskStat {
                        label: "down"
                        value: root.rate(root.rx)
                    }
                    DeskStat {
                        label: "up"
                        value: root.rate(root.tx)
                    }
                }
            }
        }
    }
}
