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

    // Sized for the CJK numerals, which come from Noto Sans CJK by
    // fontconfig fallback — Iosevka has no CJK coverage. They are
    // full-width glyphs, so they need noticeably more room than the type
    // size alone suggests.
    readonly property int chipWidth: 32
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
        implicitHeight: 26

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
                    duration: Theme.animSlow
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
                    duration: Theme.animSlow
                    easing.type: Theme.ease
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
                readonly property bool empty: ws === null || ws.toplevels.values.length === 0

                Text {
                    // Filled and aligned rather than centred as an item.
                    //
                    // anchors.centerIn centres the Text's box, and that box
                    // is sized from the primary font's latin metrics — the
                    // CJK glyph draws lower inside it, so the numerals sat
                    // visibly below the middle of their chip. Letting the
                    // text fill the chip and align within it makes Qt use
                    // the line box instead, which the glyph is centred in.
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: root.numerals[String(chip.modelData)] ?? chip.modelData
                    font.family: Theme.fontFamily

                    // A point larger and a weight heavier than the rest of
                    // the bar. CJK glyphs carry far more strokes in the same
                    // em than a latin digit, so at the bar's size and weight
                    // 二三四五 thinned out into near-illegible hairlines.
                    font.pixelSize: Theme.fontSize + 1
                    font.weight: Font.DemiBold

                    // No tracking, unlike everything else. letterSpacing
                    // adds space AFTER each character, so on a
                    // single-character string it widens the text box by a
                    // trailing gap and pushes the glyph off-centre to the
                    // left. That was the misalignment.
                    font.letterSpacing: 0

                    color: {
                        if (chip.ws !== null && chip.ws.urgent)
                            return Theme.love;
                        if (chip.focused)
                            return Theme.iris;
                        if (chip.index === root.visibleIndex)
                            return Theme.subtle;
                        // One tier brighter than the equivalent latin text
                        // would get. An empty workspace still has to be
                        // readable — it is a label, not decoration — and
                        // these glyphs lose far more to a low alpha than a
                        // digit does.
                        if (chip.empty)
                            return Theme.dim;
                        return Theme.subtle;
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
                            duration: Theme.animPulse
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: Theme.animPulse
                            easing.type: Easing.InOutQuad
                        }
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
