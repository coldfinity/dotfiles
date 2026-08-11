import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

// The history panel behind the bar's bell.
//
// This is the half that makes keeping history worth anything. The daemon
// stores the last 50 notifications; without somewhere to read them the
// storage is just a number on a badge.
ShellPopup {
    id: centre

    // Grows leftward: the bell sits near the right end of the bar, and a
    // centred 400px panel would hang off the edge of the screen.
    growLeft: true

    implicitWidth: 400
    implicitHeight: Math.min(header.height + list.contentHeight + 18, 520)

    // Everything is read the moment the panel opens. Leaving them unread
    // while they are visibly on screen would make the badge lie.
    onOpenChanged: if (open)
        Notifications.markAllSeen()

    // ── header ───────────────────────────────────────────────────────
    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        height: 22

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "NOTIFICATIONS"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            font.letterSpacing: 1.4
            font.weight: Font.DemiBold
            color: Theme.faint
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: Notifications.history.length > 0
            text: "clear"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            color: clearHover.hovered ? Theme.love : Theme.faint

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animQuick
                }
            }

            HoverHandler {
                id: clearHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    Notifications.clearHistory();
                    centre.open = false;
                }
            }
        }
    }

    // ── history ──────────────────────────────────────────────────────
    ListView {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 6
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 10

        clip: true
        spacing: 2
        model: Notifications.history

        delegate: Rectangle {
            id: row

            required property var modelData

            width: list.width
            implicitHeight: rowBody.implicitHeight + 16
            height: implicitHeight
            radius: Theme.radius
            color: hover.hovered ? Theme.hover : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animQuick
                }
            }

            // Critical keeps its colour in history too. If it mattered
            // enough to be red on arrival it still matters when you come
            // back to find out what you missed.
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 4
                width: 2
                radius: 1
                visible: row.modelData.urgency === NotificationUrgency.Critical
                color: Theme.love
            }

            Column {
                id: rowBody
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                anchors.topMargin: 8
                spacing: 2

                Item {
                    width: parent.width
                    height: 14

                    Text {
                        anchors.left: parent.left
                        text: row.modelData.appName
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 5
                        font.letterSpacing: Theme.tracking
                        color: Theme.faint
                    }

                    // Relative, not absolute. "14:32" makes you do the
                    // arithmetic; "6m" is the thing you actually wanted to
                    // know when asking what you missed.
                    Text {
                        anchors.right: parent.right
                        text: centre.ago(row.modelData.time)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 5
                        color: Theme.faint
                    }
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    visible: text !== ""
                    text: row.modelData.summary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: row.modelData.urgency === NotificationUrgency.Critical ? Theme.love : Theme.text
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: row.modelData.body
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.subtle
                }
            }

            HoverHandler {
                id: hover
            }
        }
    }

    // Empty state. An empty panel with nothing in it reads as broken.
    Text {
        anchors.centerIn: parent
        visible: Notifications.history.length === 0
        text: "nothing yet"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.italic: true
        color: Theme.faint
    }

    // Coarse on purpose. Anything older than a day is "3d" — precision
    // stops being useful long before that.
    function ago(when) {
        if (!when)
            return "";
        const secs = Math.floor((Date.now() - when.getTime()) / 1000);
        if (secs < 60)
            return "now";
        if (secs < 3600)
            return Math.floor(secs / 60) + "m";
        if (secs < 86400)
            return Math.floor(secs / 3600) + "h";
        return Math.floor(secs / 86400) + "d";
    }
}
