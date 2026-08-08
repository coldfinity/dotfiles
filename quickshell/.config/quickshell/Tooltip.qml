import QtQuick

// A hover tooltip.
//
// In waybar this was a config key — `tooltip-format` — that rendered a
// plain string into an unstyleable GTK box. There is no equivalent here,
// and none is needed: a tooltip is just a small popup on hover, the same
// machinery every other surface in this shell uses. That means these can
// hold structured content and match the theme, rather than being the one
// surface it could not reach.
//
// Sizes itself to its content, so callers just declare rows.
ShellPopup {
    id: tip

    default property alias rows: column.data

    implicitWidth: Math.max(140, column.implicitWidth + 24)
    implicitHeight: column.implicitHeight + 20

    Column {
        id: column
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 3
    }
}
