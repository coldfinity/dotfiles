import QtQuick

// One resource reading inside the stats drawer: glyph, then percentage.
//
// Glyphs are Material Design icons from the Nerd Font patch — 󰘙 chip,
// 󰍛 memory, 󰢮 expansion card. All verified present in JetBrainsMono Nerd
// Font before use; the font has large unmapped stretches and an absent
// codepoint renders as tofu rather than failing loudly.
Item {
    id: root

    required property string glyph
    required property int value

    // The displayed number trails the real one. `shown` is bound to value,
    // so every change starts an animation from wherever the last one got
    // to — a jump from 4 to 13 rolls through the numbers between rather
    // than swapping the text. Purely cosmetic, but an instant swap is what
    // makes a bar read as a terminal readout.
    property real shown: value

    Behavior on shown {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    implicitWidth: label.implicitWidth + 20

    Text {
        id: label
        anchors.centerIn: parent
        text: root.glyph + " " + Math.round(root.shown) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Font.DemiBold

        // Each section takes its own colour from the shared ramp, so the
        // one that is actually loaded is the one that changes.
        color: Theme.loadColour(root.value)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }
    }
}
