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
// The application name first, the window title under it.
//
// This showed only the title to begin with, on the argument that an icon
// tells you Zen is open somewhere while a title tells you which page. True
// as far as it went, but it threw away the more important half: "herdr"
// does not tell you that is a terminal, and a list of window titles with no
// applications attached is a list of things you have to decode.
//
// The name comes from the desktop entry via AppIndex, so it is the name the
// application's author chose rather than a Wayland app-id like
// "org.wezfurlong.wezterm".
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
                height: 38
                radius: Theme.radius
                color: hover.hovered ? Theme.hover : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animMs
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 0

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: AppIndex.nameFor(entry.modelData.wayland ? entry.modelData.wayland.appId : "")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Font.DemiBold
                        color: entry.modelData.activated ? Theme.iris : Theme.text
                    }

                    // The title, secondary. Hidden when it merely repeats
                    // the application name, which browsers and terminals do
                    // on a fresh window.
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        visible: text !== ""
                        text: {
                            const t = entry.modelData.title || "";
                            const app = AppIndex.nameFor(entry.modelData.wayland ? entry.modelData.wayland.appId : "");
                            return t === app ? "" : t;
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                        color: Theme.faint
                    }
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
