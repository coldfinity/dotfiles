import Quickshell
import QtQuick
import QtQuick.Layouts

// fcitx5 input mode. EN at rest, 中 in accent when a pinyin engine is
// engaged — latin is the resting state and wears no colour, and the mode
// that changes what your keystrokes do is the one worth signalling.
//
// Nothing reported this before the waybar version added it, so the way to
// find out which mode you were in was to type and see what came out.
//
// State comes from the InputState singleton: this component exists once
// per monitor, and the input mode is global.
Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: label.implicitWidth + 16

    // Width changes are animated, not jumped.
    //
    // This is the difference a polished bar has and an unpolished one does
    // not. Every number here changes width as it crosses a digit boundary —
    // CPU going 9 to 10, volume 100 to 99 — and every module to its left
    // shifts to absorb it. Unanimated, the whole right-hand side twitches
    // sideways several times a minute for no reason you can perceive.
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Theme.ease
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: InputState.mode
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.weight
        font.letterSpacing: Theme.tracking
        color: imHover.hovered ? Theme.text : (InputState.active ? Theme.iris : Theme.subtle)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }
    }

    HoverHandler {
        id: imHover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["fcitx5-remote", "-t"])
    }
}
