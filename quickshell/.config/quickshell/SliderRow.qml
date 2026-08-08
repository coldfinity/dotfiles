import QtQuick

// A labelled slider: glyph, track, percentage.
//
// Built from rectangles rather than QtQuick.Controls' Slider, which drags a
// whole style along with it and would have to be fought back into this
// palette.
//
// `live` is the difference between the two users of this. Volume applies on
// every drag frame because Pipewire is a local call. Brightness goes over
// DDC/CI to the monitor and costs ~600ms a call, so it applies once on
// release — dragging with live updates would queue a second of stale writes
// behind every gesture.
Item {
    id: root

    required property string glyph

    // Owned by the caller, as a binding to the real thing (Pipewire's
    // volume, the queried brightness). This component must never assign to
    // it.
    property real value: 0
    property bool live: true

    // Where the handle is while you are dragging. Writing to `value`
    // instead — which is what this did — destroys the caller's binding the
    // first time you touch the slider. After that the volume bar stopped
    // following volume changed from anywhere else, and the brightness bar
    // stopped picking up the value re-queried when the panel reopens. The
    // slider silently became a display of its own last drag.
    property real dragValue: 0

    readonly property real display: mouse.pressed ? dragValue : value

    signal moved(real value)
    signal released(real value)

    implicitHeight: 26

    Text {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.subtle
    }

    Rectangle {
        id: track
        anchors.left: icon.right
        anchors.right: readout.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 4
        radius: 2
        color: Theme.hover

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.display))
            height: parent.height
            radius: parent.radius
            color: Theme.iris
        }

        // The handle only appears under the cursor. At rest this is a bar,
        // not a control — which keeps the panel calm until you reach for it.
        Rectangle {
            visible: mouse.containsMouse || mouse.pressed
            x: parent.width * Math.max(0, Math.min(1, root.display)) - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            radius: Theme.radius
            color: Theme.iris
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            // The track is 4px, which is far too thin to hit reliably.
            anchors.topMargin: -9
            anchors.bottomMargin: -9
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function fraction(x) {
                return Math.max(0, Math.min(1, x / track.width));
            }

            onPressed: mouseEvent => {
                root.dragValue = fraction(mouseEvent.x);
                if (root.live)
                    root.moved(root.dragValue);
            }

            onPositionChanged: mouseEvent => {
                if (!pressed)
                    return;
                root.dragValue = fraction(mouseEvent.x);
                if (root.live)
                    root.moved(root.dragValue);
            }

            onReleased: root.released(root.dragValue)
        }
    }

    Text {
        id: readout
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        horizontalAlignment: Text.AlignRight
        text: Math.round(root.display * 100) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        color: Theme.subtle
    }
}
