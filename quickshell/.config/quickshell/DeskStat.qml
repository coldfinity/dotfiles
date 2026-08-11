import QtQuick
import QtQuick.Effects

// One labelled reading on the desktop.
//
// A label above the value, rather than the bar's glyph-plus-number. The bar
// has no room for words so it uses icons and you learn what they mean; on
// the wallpaper there is space to just say it, and a written label needs no
// learning at all.
Column {
    id: root

    required property string label
    required property string value
    property bool warn: false

    spacing: 1

    Text {
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.letterSpacing: 1.4
        color: Theme.faint

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.7)
            shadowBlur: 0.6
        }
    }

    Text {
        text: root.value
        font.family: Theme.fontFamily
        font.pixelSize: 17
        font.weight: Theme.weight
        // Same rule as the bar: nothing wears colour at rest, and a
        // threshold crossing is the only thing worth colouring.
        color: root.warn ? Theme.gold : Theme.subtle

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.7)
            shadowBlur: 0.6
        }
    }
}
