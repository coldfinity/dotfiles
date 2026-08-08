import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects

// Now playing: album art behind, title and artist over it, transport and a
// progress bar.
//
// The art is dimmed hard and blurred rather than shown at full strength.
// Cover art is somebody else's colour scheme — at full saturation it fights
// everything else in the panel, which is why the reference shells end up
// looking like a different application per track.
Item {
    id: root

    required property var player

    readonly property bool hasArt: player && player.trackArtUrl && player.trackArtUrl !== ""

    // ── art ──────────────────────────────────────────────────────────
    // Blurred hard, darkened, and desaturated. Cover art is somebody else's
    // colour scheme — shown straight it fights everything else in the
    // panel, which is why the Material shells end up looking like a
    // different application per track. Blurring it to a wash keeps the
    // sense of the album without importing its palette.
    //
    // Requires qml6-module-qtquick-effects (MultiEffect). Without it this
    // file does not load at all — it is a hard dependency of the shell now,
    // not a graceful enhancement.
    Item {
        anchors.fill: parent
        // Square corners on the image would poke out past the card's 2px
        // radius, so the art is clipped to the card's shape.
        clip: true

        Image {
            id: art
            anchors.fill: parent
            source: root.hasArt ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            // Hidden: MultiEffect draws it, and leaving the source visible
            // would stack a sharp copy under the blurred one.
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: art
            visible: root.hasArt

            blurEnabled: true
            blur: 1.0
            // blurMax is the kernel size, and it is what actually decides
            // how soft this gets — `blur: 1.0` alone against the default
            // max is barely a smudge.
            blurMax: 48

            // Pulled well down so the text over it stays legible whatever
            // the cover happens to be, and desaturated so a vivid sleeve
            // does not tint the whole card.
            brightness: -0.5
            saturation: -0.35

            // Crossfades between covers instead of cutting, matching the
            // title fade on the bar.
            opacity: root.hasArt ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    // Base wash, so a track with no art is not a hole in the panel.
    Rectangle {
        anchors.fill: parent
        color: root.hasArt ? Qt.rgba(0.098, 0.090, 0.141, 0.45) : Qt.rgba(0.878, 0.871, 0.957, 0.03)
        border.color: Theme.divider
        border.width: 1
        radius: Theme.radius
    }

    // ── nothing playing ──────────────────────────────────────────────
    Text {
        anchors.centerIn: parent
        visible: root.player === null
        text: "nothing playing"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.italic: true
        color: Theme.faint
    }

    // ── track ────────────────────────────────────────────────────────
    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 2
        visible: root.player !== null

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.player ? (root.player.trackTitle || "") : ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 1
            font.weight: Font.DemiBold
            color: Theme.text
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.player ? (root.player.trackArtist || "") : ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            color: Theme.subtle
        }
    }

    // ── transport ────────────────────────────────────────────────────
    Row {
        id: transport
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: progress.top
        anchors.bottomMargin: 10
        spacing: 6
        visible: root.player !== null

        NavButton {
            glyph: "󰒮"
            enabled: root.player !== null && root.player.canGoPrevious
            onActivated: root.player.previous()
        }
        NavButton {
            glyph: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            enabled: root.player !== null && root.player.canTogglePlaying
            onActivated: root.player.togglePlaying()
        }
        NavButton {
            glyph: "󰒭"
            enabled: root.player !== null && root.player.canGoNext
            onActivated: root.player.next()
        }
    }

    // ── progress ─────────────────────────────────────────────────────
    Item {
        id: progress
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 14
        height: 14
        visible: root.player !== null && root.player.lengthSupported && root.player.length > 0

        // position is not a bound property — it has to be polled while
        // playing, which is why this ticks rather than binding directly.
        Timer {
            running: progress.visible && root.player && root.player.isPlaying
            interval: 1000
            repeat: true
            onTriggered: if (root.player)
                root.player.positionChanged()
        }

        readonly property real fraction: {
            if (!root.player || !root.player.length || root.player.length <= 0)
                return 0;
            return Math.max(0, Math.min(1, root.player.position / root.player.length));
        }

        function clock(seconds) {
            if (!seconds || seconds < 0)
                return "0:00";
            const m = Math.floor(seconds / 60);
            const s = Math.floor(seconds % 60);
            return m + ":" + (s < 10 ? "0" + s : s);
        }

        Text {
            id: elapsed
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: progress.clock(root.player ? root.player.position : 0)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            color: Theme.faint
        }

        Rectangle {
            anchors.left: elapsed.right
            anchors.right: total.left
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            height: 2
            color: Theme.hover

            Rectangle {
                width: parent.width * progress.fraction
                height: parent.height
                color: Theme.iris
            }
        }

        Text {
            id: total
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: progress.clock(root.player ? root.player.length : 0)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            color: Theme.faint
        }
    }
}
