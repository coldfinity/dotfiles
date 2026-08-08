import Quickshell
import QtQuick
import QtQuick.Layouts

// The one destructive control on the bar. Left grey on purpose, taking
// colour only when the cursor is actually on it.
//
// Opens a native menu now. It used to shell out to
// waybar/.config/waybar/power-menu.sh, which meant this package could not
// stand on its own — the button depended on a script in the waybar package
// and on rofi's dmenu theme.
Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: 40

    Text {
        id: glyph
        anchors.centerIn: parent
        text: "⏻"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: (mouse.containsMouse || menu.visible) ? Theme.love : Theme.subtle

        // A slight lift under the cursor. Small enough not to shift the
        // bar's layout — scale is a paint-time transform, so it does not
        // feed back into the row's width.
        scale: mouse.containsMouse ? 1.15 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: menu.visible = !menu.visible
    }

    PowerMenu {
        id: menu
        anchorItem: root
        visible: false
    }
}
