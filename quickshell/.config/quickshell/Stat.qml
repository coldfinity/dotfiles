import QtQuick

// One resource reading: glyph, percentage, and a history trace beneath.
//
// Glyphs are Material Design icons from the Nerd Font patch — 󰘙 chip,
// 󰍛 memory, 󰢮 expansion card. All verified present in JetBrainsMono Nerd
// Font before use; the font has large unmapped stretches and an absent
// codepoint renders as tofu rather than failing loudly.
Item {
    id: root

    required property string glyph
    required property int value
    required property var history

    // No percent sign. The glyph already says what the number is, and five
    // of them across the right-hand side was the same mark repeated five
    // times for no added meaning.
    //
    // The displayed number trails the real one. `shown` is bound to value,
    // so every change starts an animation from wherever the last one got
    // to — a jump from 4 to 13 rolls through the numbers between rather
    // than swapping the text.
    property real shown: value

    Behavior on shown {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    implicitWidth: label.implicitWidth + 16

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // Nudged up to make room for the trace without growing the bar.
        anchors.verticalCenterOffset: -3
        text: root.glyph + " " + Math.round(root.shown)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.weight
        font.letterSpacing: Theme.tracking

        // Each stat takes its own colour from the shared ramp, so the one
        // that is actually loaded is the one that changes. The colour keys
        // off the real value, not the animating one — a threshold crossing
        // should not be delayed by the number roll.
        color: hover.hovered ? Theme.text : Theme.loadColour(root.value)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }
    }

    Sparkline {
        anchors.left: label.left
        anchors.right: label.right
        anchors.top: label.bottom
        anchors.topMargin: 1
        height: 8
        values: root.history
        stroke: Theme.loadColour(root.value)
    }

    HoverHandler {
        id: hover
    }
}
