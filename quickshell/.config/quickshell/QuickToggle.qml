import QtQuick

// One quick-settings tile.
//
// The reference shells draw these as filled cards that light up bright blue
// when active. Here "on" is the accent block the bar already uses for the
// focused workspace and the active window — the same marker meaning the
// same thing, so the dashboard needs no separate vocabulary.
//
// Off is not red. A radio you switched off is a state you chose, not a
// fault, and red on this desktop means something needs acting on.
Rectangle {
    id: root

    required property string glyph
    required property string label
    property string detail: ""
    property bool active: false

    signal toggled

    radius: Theme.radius
    color: active ? Theme.accentFill : (mouse.containsMouse ? Theme.hover : "transparent")
    border.width: 1
    border.color: active ? Theme.accentEdge : Theme.divider

    Behavior on color {
        ColorAnimation {
            duration: Theme.animMs
        }
    }

    Behavior on border.color {
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
        spacing: 3

        Text {
            text: root.glyph
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
            color: root.active ? Theme.iris : Theme.subtle

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animMs
                }
            }
        }

        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.DemiBold
            color: root.active ? Theme.text : Theme.subtle
        }

        // The connected network, the paired device — the detail line is
        // what makes a tile worth having over a plain switch.
        Text {
            visible: root.detail !== ""
            width: parent.width
            elide: Text.ElideRight
            text: root.detail
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            color: root.active ? Theme.subtle : Theme.faint
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
