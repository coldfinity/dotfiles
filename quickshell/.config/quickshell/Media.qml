import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Now playing, in the centre frame after the clock.
//
// No playerctld here. waybar's mpris module defaults to attaching to the
// playerctld proxy, which is why it silently rendered nothing until that
// package was installed — quickshell talks to MPRIS on the session bus
// directly and sees every player without a proxy in between.
//
// Carries its own leading divider so that both disappear together when
// nothing is playing, rather than leaving the clock with a stray rule.
RowLayout {
    id: root

    spacing: 0

    // Prefer whatever is actually playing; fall back to the first player
    // present so a paused track still shows rather than blinking out.
    readonly property var player: {
        const players = Mpris.players.values;
        const real = [];

        for (var i = 0; i < players.length; i++) {
            // playerctld publishes itself on the bus as an MPRIS player,
            // proxying whichever real player was last active. waybar needed
            // it because its mpris module attaches to exactly one bus name;
            // quickshell watches them all, so here the proxy is a duplicate
            // of a player already in this list — and when nothing is
            // playing it answers every property read with
            // NoActivePlayer, filling the log with DBus errors.
            if (players[i].identity !== "playerctld")
                real.push(players[i]);
        }

        for (var j = 0; j < real.length; j++) {
            if (real[j].isPlaying)
                return real[j];
        }
        return real.length > 0 ? real[0] : null;
    }

    visible: player !== null

    Divider {}

    Item {
        Layout.fillHeight: true
        // Capped so a long title cannot shove the clock off centre. The
        // centre frame is centred against the bar, so every pixel the
        // title grows moves the clock half a pixel.
        implicitWidth: Math.min(label.implicitWidth + 24, 300)

        Text {
            id: label
            anchors.centerIn: parent
            width: parent.width - 24
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold

            // Ambient information, so grey like the clock beside it.
            // Paused dims further — the same treatment a muted sink gets,
            // because it is the same kind of fact: not doing anything now.
            color: (root.player && root.player.isPlaying) ? Theme.subtle : Theme.dim

            text: {
                if (!root.player)
                    return "";
                const icon = root.player.isPlaying ? "󰝚" : "󰏤";
                const title = root.player.trackTitle || "";
                const artist = root.player.trackArtist || "";
                return artist ? icon + " " + title + " — " + artist : icon + " " + title;
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animMs
                }
            }

            // Fade in on change rather than hard-cutting. A track change is
            // the one thing on this bar that rewrites a whole string at
            // once, and swapping it in place is jarring in peripheral
            // vision.
            onTextChanged: retitle.restart()

            NumberAnimation {
                id: retitle
                target: label
                property: "opacity"
                from: 0
                to: 1
                duration: 260
                easing.type: Easing.OutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            // Scroll-to-skip is deliberately unbound: far too easy to
            // trigger by accident on a bar you scroll past.
            onClicked: {
                if (root.player && root.player.canTogglePlaying)
                    root.player.togglePlaying();
            }
        }
    }
}
