import QtQuick

// A panel inside the dashboard.
//
// Same material as the bar's frames — square, hairline, almost no fill —
// rather than the raised rounded cards the Material shells use. The
// dashboard should read as more of the bar, not as a different application
// that happened to open.
Rectangle {
    id: card

    default property alias content: inner.data
    property string title: ""

    color: Qt.rgba(0.878, 0.871, 0.957, 0.03)
    border.color: Theme.divider
    border.width: 1
    radius: Theme.radius

    // Section label in the same understated register as the bar's resting
    // text: small, faint, uppercase. It names the panel without competing
    // with what is in it.
    Text {
        id: heading
        visible: card.title !== ""
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        text: card.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.letterSpacing: 1.2
        font.weight: Font.DemiBold
        color: Theme.faint
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: 10
        anchors.topMargin: card.title !== "" ? heading.height + 16 : 10
    }
}
