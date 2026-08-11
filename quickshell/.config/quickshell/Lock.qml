import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQuick

// A native lock screen, built from the same components as the rest of the
// shell.
//
// NOT WHAT ACTUALLY LOCKS THIS MACHINE. hyprlock is still what runs at boot
// (exec-once in hyprland.conf), on idle (hypridle's listener) and from the
// bar's power menu. This is opened deliberately, with `qs ipc call lock
// lock`, so it can be tried without betting the session on it.
//
// The reason for that caution is structural rather than a lack of
// confidence in the code. hyprlock is a separate, dedicated process: if
// quickshell has a QML error, hyprlock still locks the screen. Moving the
// lock inside the shell means an unrelated binding error somewhere else in
// this config becomes a lock that will not engage, or worse, one that will
// not release. That is a different category of failure from a bar that
// renders wrong.
//
// WlSessionLock is the compositor-level primitive: while `locked` is true
// the compositor shows only these surfaces and will not let anything else
// take input, so this is a real lock and not a fullscreen window pretending.
Scope {
    id: root

    property bool locked: false
    property string response: ""

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.locked = true;
        }
    }

    onLockedChanged: {
        response = "";
        if (locked)
            pam.start();
        else
            pam.abort();
    }

    PamContext {
        id: pam

        // "login" is the default and is right here: it is the stack that
        // already authenticates this user at a TTY, so it needs no new
        // pam.d file to be installed for the lock to work.
        config: "login"

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.locked = false;
            } else {
                // Restarted rather than left dead. PAM ends its
                // conversation on failure, and without a new session the
                // field would accept typing and never check it again.
                root.response = "";
                pam.start();
            }
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: root.locked

        WlSessionLockSurface {
            color: "transparent"

            // The wallpaper, blurred by nothing — there is no compositor
            // blur available to a lock surface, so this is a flat dark
            // ground rather than a frosted one.
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.055, 0.051, 0.078, 1.0)
            }

            Column {
                anchors.centerIn: parent
                spacing: 10
                width: 360

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(lockClock.date, "HH:mm")
                    font.family: Theme.fontFamily
                    font.pixelSize: 96
                    font.weight: Font.Thin
                    color: Theme.text
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.locale("zh_CN").toString(lockClock.date, "dddd  MM月dd日")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.letterSpacing: Theme.tracking
                    color: Theme.subtle
                    bottomPadding: 22
                }

                // ── password ─────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 40
                    color: Theme.hover
                    radius: Theme.radius
                    border.width: 1
                    border.color: pam.messageIsError ? Theme.love : (field.activeFocus ? Theme.accentEdge : Theme.divider)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.animQuick
                        }
                    }

                    TextInput {
                        id: field
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter

                        text: root.response
                        onTextChanged: root.response = text

                        echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                        enabled: pam.responseRequired

                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: Theme.text
                        clip: true

                        focus: true
                        Component.onCompleted: forceActiveFocus()

                        Keys.onReturnPressed: pam.respond(root.response)
                        Keys.onEnterPressed: pam.respond(root.response)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: field.text === ""
                            text: "Password"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.faint
                        }
                    }
                }

                // PAM's own message. On a wrong password this is where
                // "Authentication failure" lands, which is the only feedback
                // a lock screen can honestly give.
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                    text: pam.message
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    color: pam.messageIsError ? Theme.love : Theme.faint
                }
            }

            SystemClock {
                id: lockClock
                precision: SystemClock.Minutes
            }
        }
    }
}
