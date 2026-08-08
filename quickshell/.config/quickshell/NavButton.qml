import QtQuick

// A small square button for the dashboard: month paging and transport.
//
// `enabled` is honoured rather than hiding the button, so the transport row
// keeps a stable width when a player reports it cannot skip — a row of
// controls that reflows as tracks change is worse than one with a greyed
// button in it.
Rectangle {
    id: root

    required property string glyph
    signal activated

    width: 24
    height: 24
    radius: Theme.radius
    color: mouse.containsMouse && enabled ? Theme.hover : "transparent"

    Text {
        anchors.centerIn: parent
        text: root.glyph
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.enabled ? (mouse.containsMouse ? Theme.text : Theme.subtle) : Theme.faint
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
