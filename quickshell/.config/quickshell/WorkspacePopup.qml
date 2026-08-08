import Quickshell.Hyprland
import QtQuick

// The list of windows open on one workspace, shown while the cursor is on
// that workspace's chip.
//
// This is the thing GTK3 could not do. waybar's only popup surface was a
// tooltip, which meant a plain string in a box the theme could not reach —
// so the open windows had to live permanently on the bar as an icon strip,
// detached from the workspace they belonged to. Here they are a real
// surface, styled like the rest of the shell, appearing next to the thing
// they describe.
//
// Titles rather than icons: an icon tells you Zen is open somewhere, a
// title tells you which page. That is the information you actually want
// when deciding whether to switch.
ShellPopup {
    id: popup

    required property var workspace

    readonly property var windows: workspace ? workspace.toplevels.values : []

    gap: 4
    implicitWidth: 260
    implicitHeight: column.implicitHeight + 16

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 2

        Repeater {
            model: popup.windows

            delegate: Rectangle {
                id: entry

                required property var modelData

                width: column.width
                height: 24
                radius: Theme.radius
                color: hover.hovered ? Theme.hover : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animMs
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    // Hyprland's own IPC carries the title; the wlr toplevel
                    // behind it carries the app id, which is the better
                    // label when a window has no title yet.
                    text: entry.modelData.title || (entry.modelData.wayland ? entry.modelData.wayland.appId : "—")
                    elide: Text.ElideRight

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    color: entry.modelData.activated ? Theme.iris : Theme.subtle
                }

                HoverHandler {
                    id: hover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        // Focus the window directly rather than just
                        // switching workspace — you picked a specific one
                        // out of the list.
                        if (entry.modelData.wayland)
                            entry.modelData.wayland.activate();
                        else
                            Hyprland.dispatch("workspace " + popup.workspace.id);
                    }
                }
            }
        }

        // An empty workspace still gets a popup rather than nothing at all,
        // so hovering never feels like it failed to respond.
        Text {
            visible: popup.windows.length === 0
            width: column.width
            horizontalAlignment: Text.AlignHCenter
            text: "empty"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.italic: true
            color: Theme.faint
        }
    }
}
