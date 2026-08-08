import QtQuick

// The animated body shared by every popup — dashboard, power menu, the
// workspace window lists.
//
// A PopupWindow's own geometry cannot be animated: the window is created at
// its implicit size and the compositor maps it in one step, so growing the
// window itself would fight the Wayland protocol. What animates is the
// content drawn inside it — fade, a small rise, and a scale that starts
// just under 1. The window is briefly there and empty, which nobody sees
// because the first frame is fully transparent.
//
// transformOrigin is Top so the scale opens downward, away from the bar,
// rather than expanding from the middle and appearing to push upward into
// the thing that spawned it.
Item {
    id: root

    default property alias content: body.data

    // Drive this from the PopupWindow's `visible`.
    property bool shown: false

    Rectangle {
        id: body

        anchors.fill: parent
        transformOrigin: Item.Top

        color: Qt.rgba(0.098, 0.090, 0.141, 0.98)
        border.color: Theme.edge
        border.width: 1
        radius: Theme.radius

        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.97
        y: root.shown ? 0 : -6

        // Opacity leads slightly and the movement trails, which reads as
        // the surface settling rather than sliding.
        Behavior on opacity {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
