import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import Quickshell.Wayland
import QtQuick

// The polkit authentication agent.
//
// Replaces hyprpolkitagent. Whenever something needs root — gnome-disks,
// timeshift, the software updater, anything behind pkexec — a dialog asks
// for your password. That dialog used to be a GTK window that looked
// nothing like the rest of the desktop, and it is one of the few things
// that appears unprompted and demands attention, so it was a conspicuous
// exception.
//
// ONLY ONE AGENT CAN REGISTER. polkit accepts a single agent per session,
// so hyprpolkitagent is not started any more — see hyprland.conf. If this
// fails to register, `isRegistered` stays false and every privileged action
// on the machine fails with no prompt at all, which is worse than an ugly
// dialog. The fallback is uncommenting that line.
Scope {
    id: root

    PolkitAgent {
        id: agent
    }

    readonly property var flow: agent.flow

    // The typed response lives here, not in the TextInput.
    //
    // The field is inside the per-screen delegate, so the Scope cannot see
    // it — referencing `input` from out here threw a ReferenceError and
    // took submit() down with it, which would have made the dialog collect
    // a password and then fail to send it.
    property string response: ""

    // Cleared whenever a new request starts, so a failed attempt does not
    // leave the previous password sitting in the field.
    onFlowChanged: response = ""

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: agent.isActive && Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-polkit"
            WlrLayershell.layer: WlrLayer.Overlay

            // Exclusive: this is a password field, and anything less would
            // leave keystrokes going to whatever was focused underneath —
            // which is how a password ends up typed into a chat window.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            // No click-outside-to-dismiss. Cancelling an authentication is
            // a decision, and a stray click should not make it for you.
            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                anchors.centerIn: parent
                width: 460
                implicitHeight: body.implicitHeight + 36
                height: implicitHeight

                color: Qt.rgba(0.098, 0.090, 0.141, 0.98)
                border.color: Theme.edge
                border.width: 1
                radius: Theme.radius

                Column {
                    id: body
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 10

                    Text {
                        text: "󰌾  Authentication required"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        font.letterSpacing: Theme.tracking
                        color: Theme.faint
                    }

                    // What is actually being asked for. polkit's message is
                    // written for the user by whoever defined the action.
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: root.flow ? root.flow.message : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    // The action id, small. Useful when the message is vague
                    // about which program is asking.
                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        visible: text !== ""
                        text: root.flow ? root.flow.actionId : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                        color: Theme.faint
                    }

                    // PAM's own message — "Password:", or "Authentication
                    // failure" after a wrong attempt. Errors take love, the
                    // same as everywhere else.
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                        text: root.flow ? root.flow.supplementaryMessage : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        color: (root.flow && root.flow.supplementaryIsError) ? Theme.love : Theme.subtle
                    }

                    // ── input ────────────────────────────────────────
                    Rectangle {
                        width: parent.width
                        height: 38
                        visible: root.flow ? root.flow.isResponseRequired : false
                        color: Theme.hover
                        radius: Theme.radius
                        border.width: 1
                        border.color: input.activeFocus ? Theme.accentEdge : Theme.divider

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Theme.animQuick
                            }
                        }

                        TextInput {
                            id: input
                            anchors.fill: parent

                            text: root.response
                            onTextChanged: root.response = text

                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: TextInput.AlignVCenter

                            // responseVisible is false for passwords, which
                            // is the whole reason it exists — a PAM prompt
                            // for a one-time code sets it true and should
                            // not be masked.
                            echoMode: (root.flow && root.flow.responseVisible) ? TextInput.Normal : TextInput.Password

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.text
                            selectionColor: Theme.accentFill
                            selectedTextColor: Theme.text
                            clip: true

                            focus: true
                            Component.onCompleted: forceActiveFocus()
                            Connections {
                                target: agent
                                function onIsActiveChanged() {
                                    if (agent.isActive)
                                        input.forceActiveFocus();
                                }
                            }

                            Keys.onReturnPressed: root.submit()
                            Keys.onEnterPressed: root.submit()
                            Keys.onEscapePressed: root.cancel()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: input.text === ""
                                text: root.flow ? (root.flow.inputPrompt || "Password") : "Password"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                color: Theme.faint
                            }
                        }
                    }

                    // ── buttons ──────────────────────────────────────
                    Row {
                        anchors.right: parent.right
                        spacing: 8
                        topPadding: 2

                        Rectangle {
                            width: 92
                            height: 32
                            radius: Theme.radius
                            color: cancelHover.hovered ? Qt.rgba(0.922, 0.435, 0.573, 0.14) : Theme.hover

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animQuick
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Cancel"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                color: cancelHover.hovered ? Theme.love : Theme.subtle
                            }

                            HoverHandler {
                                id: cancelHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: root.cancel()
                            }
                        }

                        Rectangle {
                            width: 116
                            height: 32
                            radius: Theme.radius
                            color: okHover.hovered ? Theme.accentFill : Theme.hover
                            border.width: 1
                            border.color: okHover.hovered ? Theme.accentEdge : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animQuick
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Authenticate"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                font.weight: Theme.weight
                                color: okHover.hovered ? Theme.text : Theme.subtle
                            }

                            HoverHandler {
                                id: okHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: root.submit()
                            }
                        }
                    }
                }
            }
        }
    }

    function submit() {
        if (!flow)
            return;
        flow.submit(response);
        // Not cleared here. PAM may come back with "try again", and the
        // field is reset by onFlowChanged when a genuinely new request
        // starts rather than on every attempt.
    }

    function cancel() {
        if (flow)
            flow.cancelAuthenticationRequest();
    }
}
