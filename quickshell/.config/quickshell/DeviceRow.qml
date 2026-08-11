import QtQuick

// A selectable row in one of the dashboard's device lists: an audio output,
// a wifi network, a bluetooth device.
//
// All three answer the same question — "which one is active, and what else
// could be" — so they share one row rather than each inventing a layout. The
// active one takes the accent block the bar uses for the focused workspace,
// which means the panel needs no separate vocabulary for "this is current".
Rectangle {
    id: root

    required property string label
    property string detail: ""
    property bool active: false

    signal picked

    height: 30
    radius: Theme.radius
    color: active ? Theme.accentFill : (hover.hovered ? Theme.hover : "transparent")

    Behavior on color {
        ColorAnimation {
            duration: Theme.animQuick
        }
    }

    Text {
        id: main
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.right: side.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Theme.weight
        color: root.active ? Theme.text : Theme.subtle
    }

    // Signal strength, battery, "default" — whatever qualifies the row.
    Text {
        id: side
        anchors.right: parent.right
        anchors.rightMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: root.detail
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 4
        color: root.active ? Theme.subtle : Theme.faint
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.picked()
    }
}
