import QtQuick
import QtQuick.Layouts

// The bar's notification bell, and the way into the history panel.
//
// Follows the bar's rule that nothing wears colour at rest: the bell is grey
// with no unread, and takes the accent only when something is waiting. The
// glyph itself changes too, so the state is legible without relying on
// colour alone.
Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: label.implicitWidth + (badge.visible ? badge.width + 4 : 0) + 18

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Theme.ease
        }
    }

    Text {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter

        // 󰂚 with unread, 󰂜 without. Do-not-disturb is not reflected here —
        // that lives in the dashboard's toggle, and duplicating it would be
        // two controls for one fact.
        text: Notifications.unread > 0 ? "󰂚" : "󰂜"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: hover.hovered ? Theme.text : (Notifications.unread > 0 ? Theme.iris : Theme.subtle)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }

        // A single shake when something arrives. Enough to catch the eye in
        // peripheral vision without being the kind of animation you end up
        // resenting on the twentieth notification.
        SequentialAnimation {
            id: nudge
            NumberAnimation {
                target: label
                property: "rotation"
                to: -12
                duration: 70
            }
            NumberAnimation {
                target: label
                property: "rotation"
                to: 9
                duration: 90
            }
            NumberAnimation {
                target: label
                property: "rotation"
                to: 0
                duration: 110
                easing.type: Easing.OutBack
            }
        }

        Connections {
            target: Notifications
            function onHistoryChanged() {
                if (Notifications.unread > 0)
                    nudge.restart();
            }
        }
    }

    Text {
        id: badge
        anchors.left: label.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        visible: Notifications.unread > 0
        text: Notifications.unread
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Theme.weight
        color: Theme.iris
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: centre.toggle()
    }

    NotificationCentre {
        id: centre
        anchorItem: root
        open: false
    }
}
