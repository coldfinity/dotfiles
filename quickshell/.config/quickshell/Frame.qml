import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

// A group of modules. No longer a frame in any visual sense — the name is
// kept because it is still what groups a side of the bar.
//
// NO CONTAINERS.
//
// This used to draw a squared outline: a hairline border, a 0.30 fill, a
// lit top edge and a drop shadow. That was four kinds of line for a handful
// of numbers, and the material contradicted itself — a surface 30% opaque
// claiming both a light source above and a shadow below. A thing that
// transparent does not cast a shadow.
//
// The grouping was redundant anyway. The three groups sit roughly 900px
// apart on a 2560px bar; position had already separated them long before a
// border said anything about it.
//
// What replaces it is nothing, plus two things that were already there:
// Hyprland blurs the strip (see the layerrule in hyprland.conf, whose
// ignore_alpha is now 0 precisely because there is no fill left to exceed
// a threshold), and the shadow below keeps glyphs legible over the bright
// patches of the wallpaper.
Item {
    id: frame

    default property alias content: layout.data

    implicitWidth: layout.implicitWidth
    implicitHeight: Theme.barHeight

    // Generous, because there is no longer a rule or an edge marking where
    // one cluster ends and the next begins. Spacing is the only separator
    // left, so it has to be unambiguous.
    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 14
    }

    // A soft shadow cast by the glyphs themselves, not by a box.
    //
    // The layer is generated from this item's own alpha — which, with no
    // background, is exactly the text and icons. So each glyph gets its own
    // dark halo and stays readable when the wallpaper behind it is bright,
    // without anything being drawn around the group.
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.85)
        shadowBlur: 0.55
        shadowVerticalOffset: 1
        shadowHorizontalOffset: 0
    }

    // Fades in at startup, staggered so the bar assembles rather than
    // blinking on. The movement is a Translate transform, not `y`: Bar.qml
    // anchors these with verticalCenter, and that binding overwrites any
    // animation written to y.
    opacity: 0

    transform: Translate {
        id: drop
        y: -10
    }

    Component.onCompleted: intro.start()

    SequentialAnimation {
        id: intro

        PauseAnimation {
            duration: 60 + Math.random() * 90
        }

        ParallelAnimation {
            NumberAnimation {
                target: frame
                property: "opacity"
                from: 0
                to: 1
                duration: 260
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: drop
                property: "y"
                from: -10
                to: 0
                duration: 340
                easing.type: Easing.OutCubic
            }
        }
    }
}
