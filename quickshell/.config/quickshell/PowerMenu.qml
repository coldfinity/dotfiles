import Quickshell
import QtQuick

// The power menu, native.
//
// Replaces waybar/.config/waybar/power-menu.sh, which piped five lines into
// rofi and matched the answer with a case statement. That worked, but it
// meant the quickshell package depended on a script in the waybar package
// and on rofi's dmenu theme — so the bar could not be moved or the old
// package retired without breaking this button.
//
// The five actions and their commands are carried over unchanged.
//
// Destructive items sit at the bottom and take love on hover; lock and
// sleep are recoverable and stay grey. Same rule as the bar: colour marks
// the thing that deserves a second's thought.
ShellPopup {
    id: menu

    implicitWidth: 190
    implicitHeight: 214

    readonly property var actions: [
        {
            glyph: "󰌾",
            label: "Lock",
            command: ["hyprlock"],
            danger: false
        },
        {
            glyph: "󰒲",
            label: "Sleep",
            command: ["systemctl", "suspend"],
            danger: false
        },
        {
            glyph: "󰗽",
            label: "Log out",
            command: ["hyprctl", "dispatch", "exit"],
            danger: true
        },
        {
            glyph: "󰜉",
            label: "Restart",
            command: ["systemctl", "reboot"],
            danger: true
        },
        {
            glyph: "󰐥",
            label: "Shut down",
            command: ["systemctl", "poweroff"],
            danger: true
        }
    ]

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        Repeater {
            model: menu.actions

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                width: parent.width
                height: 38
                radius: Theme.radius
                color: hover.hovered ? (modelData.danger ? Qt.rgba(0.922, 0.435, 0.573, 0.14) : Theme.hover) : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animMs
                    }
                }

                // Each row slides in a beat after the one above it, so the
                // menu unfolds rather than appearing all at once.
                //
                // Driven off `menu.open`, not Component.onCompleted. The
                // delegates are built once when the shell starts and then
                // persist — so onCompleted played this exactly once, into a
                // window that was not on screen, and every real opening of
                // the menu after that had no animation at all.
                opacity: 0

                Connections {
                    target: menu
                    function onOpenChanged() {
                        if (menu.open)
                            entry.restart();
                    }
                }

                SequentialAnimation {
                    id: entry

                    // The stagger the comment above promised. It was never
                    // implemented — every row animated at once.
                    PauseAnimation {
                        duration: row.index * 30
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            target: row
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 160
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: row
                            property: "x"
                            from: -8
                            to: 0
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Text {
                    id: glyph
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.glyph
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 1
                    color: hover.hovered ? (row.modelData.danger ? Theme.love : Theme.text) : Theme.subtle

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animMs
                        }
                    }
                }

                Text {
                    anchors.left: glyph.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.label
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.weight
                    font.letterSpacing: Theme.tracking
                    color: hover.hovered ? (row.modelData.danger ? Theme.love : Theme.text) : Theme.subtle

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animMs
                        }
                    }
                }

                HoverHandler {
                    id: hover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        menu.open = false;
                        // execDetached, not Process: these outlive the shell
                        // that launched them, and half of them end the
                        // session that owns it.
                        Quickshell.execDetached(row.modelData.command);
                    }
                }
            }
        }
    }
}
