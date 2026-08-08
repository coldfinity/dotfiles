import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

// One of the bar's three squared outlines.
//
// The waybar version of this was a CSS rule shared by #left, #center and
// #right. Here it is a real component, which is the first thing the move
// buys: the frame and its section dividers are one definition instead of a
// list of selectors that had to be kept in sync by hand.
//
// Children are laid out in a row; put an explicit Divider between the ones
// that need separating. That is deliberate rather than automatic — the
// centre frame's divider belongs to the media section so that it vanishes
// with it when nothing is playing, which an unconditional "rule before
// every child but the first" would get wrong.
Rectangle {
    id: frame

    // Row contents. `default` means children written inside a Frame land
    // here rather than as siblings of the layout.
    default property alias content: layout.data

    implicitWidth: layout.implicitWidth
    implicitHeight: Theme.barHeight

    color: Theme.fill
    border.color: Theme.edge
    border.width: 1
    radius: Theme.radius

    // Lifts the frame off the wallpaper. Soft and well spread rather than a
    // tight offset drop — the bar floats above the desktop, it does not sit
    // on a sheet of paper an inch below it.
    //
    // shadowScale slightly under 1 keeps the shadow inside the frame's own
    // footprint, so it reads as depth rather than as a dark halo leaking
    // out past the edges into Hyprland's blur region.
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.55)
        shadowBlur: 0.9
        shadowVerticalOffset: 2
        shadowHorizontalOffset: 0
        shadowScale: 0.98
    }

    // A brighter hairline along the top edge only.
    //
    // A uniform border draws an outline; real glass catches more light on
    // the edge facing the source and falls away below. One extra line is
    // enough to suggest that — the frame stops reading as a rectangle drawn
    // around some text and starts reading as a surface with a thickness.
    //
    // Inset by 1px on each side so it sits inside the border rather than
    // crossing it at the corners, where the radius curves away.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 1
        height: 1
        color: Qt.rgba(0.878, 0.871, 0.957, 0.10)
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 0
    }

    // Drops in at startup. Each frame is created at the same moment, so
    // without the small random delay all three would arrive as one block;
    // staggering them makes the bar assemble rather than blink on.
    //
    // The movement is a Translate transform, not the `y` property. Bar.qml
    // positions these with anchors.verticalCenter, which binds y — an
    // animation writing to y is overwritten by that binding on the next
    // evaluation and the slide silently does nothing. A transform is
    // applied at paint time and anchors never touch it.
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
