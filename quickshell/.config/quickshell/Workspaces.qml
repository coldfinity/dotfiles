import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Workspace indicators, CJK numerals, one row per monitor.
//
// The list is static per output, mirroring the workspace→monitor pinning in
// hyprland.conf — the same job waybar's `persistent-workspaces` did. It has
// to be static: Hyprland only reports workspaces that currently exist, so
// driving the row straight off Hyprland.workspaces would make the row
// change width as you open and close things.
//
// ONE INDICATOR, NOT FIVE.
//
// Every chip used to animate its own width, so switching read as one box
// shrinking while another grew — two things moving in opposite directions
// for what is really a single thing changing place. Now the chips are fixed
// and a single accent block slides between them. Because the row is uniform
// the block's position is just index × pitch, with no measuring.
Item {
    id: root

    required property string screenName

    readonly property var ids: screenName === "DP-1" ? [1, 2, 3, 4, 5] : [6, 7, 8, 9]

    readonly property var numerals: ({
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "6": "六",
            "7": "七",
            "8": "八",
            "9": "九"
        })

    readonly property int chipWidth: 28
    readonly property int chipSpacing: 2
    readonly property int pitch: chipWidth + chipSpacing

    // Which slot the indicator sits over, or -1 when this monitor holds
    // nothing focused.
    readonly property int focusedIndex: {
        const focused = Hyprland.focusedWorkspace;
        if (!focused)
            return -1;
        return ids.indexOf(focused.id);
    }

    // The workspace showing on THIS monitor while focus is elsewhere. With
    // two outputs one bar is always in this state, and waybar gave it no
    // styling at all — .active goes only to the globally focused workspace,
    // so the unfocused monitor's bar highlighted nothing.
    readonly property int visibleIndex: {
        const list = Hyprland.workspaces.values;
        for (var i = 0; i < list.length; i++) {
            const ws = list[i];
            if (ws.active && ws.monitor && ws.monitor.name === root.screenName) {
                const idx = ids.indexOf(ws.id);
                if (idx !== focusedIndex)
                    return idx;
            }
        }
        return -1;
    }

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + 8

    Item {
        id: row
        anchors.centerIn: parent
        implicitWidth: root.ids.length * root.pitch - root.chipSpacing
        implicitHeight: 22

        // ── the sliding block ────────────────────────────────────────
        // Drawn under the numerals. OutBack overshoots a few pixels and
        // settles, which is what makes it read as a physical thing being
        // moved rather than a rectangle being repainted somewhere else.
        Rectangle {
            id: indicator
            visible: root.focusedIndex >= 0
            width: root.chipWidth
            height: parent.height
            radius: Theme.radius
            x: Math.max(0, root.focusedIndex) * root.pitch

            color: Theme.accentFill
            border.width: 1
            border.color: Theme.accentEdge

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    // Default overshoot is far too springy for a bar you
                    // look at all day; this is just enough to register.
                    easing.overshoot: 1.1
                }
            }
        }

        // The same block, outlined rather than filled, for the workspace
        // showing on a monitor that does not have focus.
        Rectangle {
            visible: root.visibleIndex >= 0
            width: root.chipWidth
            height: parent.height
            radius: Theme.radius
            x: Math.max(0, root.visibleIndex) * root.pitch
            color: "transparent"
            border.width: 1
            border.color: Theme.edge

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }

        // ── the numerals ─────────────────────────────────────────────
        Repeater {
            model: root.ids

            delegate: Item {
                id: chip

                required property int modelData
                required property int index

                x: index * root.pitch
                width: root.chipWidth
                height: parent.height

                readonly property var ws: {
                    const list = Hyprland.workspaces.values;
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].id === chip.modelData)
                            return list[i];
                    }
                    return null;
                }

                readonly property bool focused: index === root.focusedIndex
                readonly property int windowCount: ws === null ? 0 : ws.toplevels.values.length
                readonly property bool empty: windowCount === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -2
                    text: root.numerals[String(chip.modelData)] ?? chip.modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.weight
                    font.letterSpacing: Theme.tracking

                    color: {
                        if (chip.ws !== null && chip.ws.urgent)
                            return Theme.love;
                        if (chip.focused)
                            return Theme.iris;
                        if (chip.index === root.visibleIndex)
                            return Theme.subtle;
                        if (chip.empty)
                            return Theme.faint;
                        return Theme.dim;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animMs
                        }
                    }

                    // Urgent workspaces pulse rather than just turning red,
                    // because a static colour on a bar you have stopped
                    // looking at is easy to miss.
                    SequentialAnimation on opacity {
                        running: chip.ws !== null && chip.ws.urgent
                        loops: Animation.Infinite
                        alwaysRunToEnd: true

                        NumberAnimation {
                            to: 0.35
                            duration: 600
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 600
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Occupancy. One dot per window, up to three, then a wider
                // bar for "more than that" — a row of six dots stops being
                // countable at a glance and becomes texture.
                //
                // Sits under the numeral rather than beside it so the row
                // keeps its fixed pitch; the sliding indicator's position
                // is index × pitch and depends on that staying uniform.
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    spacing: 2
                    visible: chip.windowCount > 0

                    Repeater {
                        model: Math.min(chip.windowCount, 3)

                        delegate: Rectangle {
                            width: chip.windowCount > 3 ? 3 : 3
                            height: 3
                            radius: 1.5
                            color: chip.focused ? Theme.iris : Theme.dim

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animMs
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: chip.windowCount > 3
                        width: 6
                        height: 3
                        radius: 1.5
                        color: chip.focused ? Theme.iris : Theme.dim
                    }
                }

                MouseArea {
                    id: chipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + chip.modelData)
                }

                // The dropdown listing this workspace's windows.
                //
                // Held open while the cursor is on the chip OR inside the
                // popup itself: without the second half, moving down to
                // click an entry would close the thing you were reaching
                // for, since the cursor leaves the chip on the way.
                WorkspacePopup {
                    id: popup
                    anchorItem: chip
                    workspace: chip.ws
                    open: chip.ws !== null && (chipMouse.containsMouse || popupHover.hovered)

                    HoverHandler {
                        id: popupHover
                    }
                }
            }
        }
    }
}
