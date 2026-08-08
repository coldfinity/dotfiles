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
        scale: root.shown ? 1 : 0.99
        y: root.shown ? 0 : -4

        // Deliberately quick.
        //
        // The window itself maps in under 2ms — measured — so any lag you
        // feel opening one of these is entirely this animation. The
        // original 130/200ms with a scale from 0.97 read as sluggish on a
        // panel you click: you had already looked at where the content
        // would be before it finished arriving.
        //
        // The scale starts at 0.99 rather than 0.97 for the same reason. At
        // 0.97 you watch it grow; at 0.99 it just resolves. The motion is
        // there to soften the appearance, not to be seen.
        Behavior on opacity {
            NumberAnimation {
                duration: 90
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutCubic
            }
        }
    }
}
