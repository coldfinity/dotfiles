import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick

// Notification toasts, top-right.
//
// Same position mako used, so the muscle memory of where notifications
// appear survives the change. What is new: actions are real buttons, the
// body can be marked up, and dismissing one here does not lose it — it
// stays in Notifications.history for the centre.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData
        screen: modelData

        // Only on the focused monitor. Duplicating every notification
        // across two screens is noise, not redundancy.
        visible: Notifications.active.values.length > 0 && Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

        anchors {
            top: true
            right: true
        }

        // Clears the bar: 6px margin + 36px bar + 6px gap.
        margins.top: 48
        margins.right: 12

        implicitWidth: 390
        implicitHeight: Math.max(1, stack.implicitHeight)
        exclusiveZone: 0

        WlrLayershell.namespace: "quickshell-toasts"
        WlrLayershell.layer: WlrLayer.Overlay

        color: "transparent"

        Column {
            id: stack
            anchors.right: parent.right
            anchors.top: parent.top
            width: parent.width
            spacing: 8

            Repeater {
                model: Notifications.active

                delegate: Rectangle {
                    id: toast

                    required property var modelData

                    width: parent.width
                    implicitHeight: content.implicitHeight + 24
                    height: implicitHeight

                    color: Qt.rgba(0.098, 0.090, 0.141, 0.97)
                    border.width: 1
                    // Critical notifications are the only ones that get
                    // colour, matching the bar's rule. Everything else is
                    // the same hairline as any other surface.
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.love : Theme.edge
                    radius: Theme.radius

                    // Slides in from the right rather than fading in place.
                    // A notification arriving from off-screen reads as
                    // something new having happened; a fade reads as
                    // something that was always there becoming visible.
                    opacity: 0
                    transform: Translate {
                        id: slide
                        x: 30
                    }

                    Component.onCompleted: entry.start()

                    ParallelAnimation {
                        id: entry
                        NumberAnimation {
                            target: toast
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: Theme.animQuick
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: slide
                            property: "x"
                            from: 30
                            to: 0
                            duration: Theme.animSlow
                            easing.type: Theme.ease
                        }
                    }

                    Column {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 4

                        Row {
                            width: parent.width
                            spacing: 8

                            IconImage {
                                implicitSize: 18
                                visible: toast.modelData.image !== ""
                                source: toast.modelData.image
                            }

                            Text {
                                width: parent.width - 40
                                elide: Text.ElideRight
                                text: toast.modelData.appName
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 4
                                font.letterSpacing: Theme.tracking
                                color: Theme.faint
                            }
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            visible: text !== ""
                            text: toast.modelData.summary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.DemiBold
                            color: toast.modelData.urgency === NotificationUrgency.Critical ? Theme.love : Theme.text
                        }

                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: toast.modelData.body
                            // The server advertises markup support, so the
                            // body arrives as pango-ish rich text and has
                            // to be rendered as such rather than shown raw.
                            textFormat: Text.StyledText
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.subtle
                        }

                        // Actions, which mako could not draw at all.
                        Row {
                            spacing: 6
                            visible: toast.modelData.actions.length > 0
                            topPadding: 4

                            Repeater {
                                model: toast.modelData.actions

                                delegate: Rectangle {
                                    required property var modelData

                                    implicitWidth: actionLabel.implicitWidth + 20
                                    height: 26
                                    radius: Theme.radius
                                    color: actionHover.hovered ? Theme.accentFill : Theme.hover

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.animQuick
                                        }
                                    }

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                        color: actionHover.hovered ? Theme.text : Theme.subtle
                                    }

                                    HoverHandler {
                                        id: actionHover
                                        cursorShape: Qt.PointingHandCursor
                                    }

                                    TapHandler {
                                        onTapped: modelData.invoke()
                                    }
                                }
                            }
                        }
                    }

                    // Click anywhere else on the toast to dismiss it. It
                    // stays in history — dismissing is "stop showing me
                    // this", not "delete it".
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        z: -1
                        onClicked: toast.modelData.dismiss()
                    }
                }
            }
        }
    }
}
