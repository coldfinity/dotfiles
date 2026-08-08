import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import QtQuick

// The panel that drops out of the clock.
//
// Same idea as the Material shells' control centres, in this desktop's own
// register: square hairline cards instead of raised rounded ones, rose-pine
// instead of bright blue, and colour only where it means something. Nothing
// here is decorative — the accent marks what is on, and everything at rest
// is grey.
//
// The tile set is chosen for THIS machine, not copied from the reference:
//
//   - No battery card. /sys/class/power_supply is empty; it is a desktop.
//   - No night-light toggle. Neither hyprsunset nor wlsunset is installed,
//     so the tile would be a switch wired to nothing.
//   - No caffeine/idle toggle. hyprland.conf deliberately never starts
//     hypridle, so there is no idle daemon to inhibit.
//   - Brightness IS here, but over DDC/CI rather than a backlight file —
//     both panels are external. See scripts/brightness.sh.
ShellPopup {
    id: dash

    required property string screenName

    implicitWidth: 880
    implicitHeight: 400

    onOpenChanged: {
        if (!open)
            return;
        calendar.reset();
        // Brightness is only read when the panel opens. Each DDC/CI round
        // trip costs ~600ms, so polling it would mean a slow I2C
        // conversation running forever for a number that changes only when
        // you change it.
        brightnessProc.running = true;
    }

    // Same playerctld filtering as the bar's media section — the proxy
    // duplicates a real player and errors on every read when idle.
    readonly property var player: {
        const players = Mpris.players.values;
        for (var i = 0; i < players.length; i++) {
            if (players[i].identity !== "playerctld")
                return players[i];
        }
        return null;
    }

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [dash.sink]
    }

    property real brightness: 1.0

    Process {
        id: brightnessProc
        command: [Quickshell.shellPath("scripts/brightness.sh"), "get", dash.screenName]
        stdout: SplitParser {
            onRead: line => {
                const v = parseInt(line.trim());
                if (!isNaN(v))
                    dash.brightness = v / 100;
            }
        }
    }

    Process {
        id: brightnessSet
    }

    // ── mako do-not-disturb ──────────────────────────────────────────
    property bool dnd: false

    Process {
        id: dndQuery
        command: ["makoctl", "mode"]
        stdout: SplitParser {
            onRead: line => dash.dnd = line.indexOf("do-not-disturb") !== -1
        }
    }

    Process {
        id: dndToggle
        command: ["makoctl", "mode", "-t", "do-not-disturb"]
        onRunningChanged: if (!running)
            dndQuery.running = true
    }

    Timer {
        running: dash.open
        interval: 2000
        repeat: true
        triggeredOnStart: true
        onTriggered: dndQuery.running = true
    }

    // ShellPopup carries the fill, the border and the open animation. Its
    // 0.98 alpha is not a style choice: this is an xdg_popup, not a layer
    // surface, so no hyprland layerrule blurs what is behind it — at 0.94 a
    // bright terminal underneath showed its text through the calendar.
    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // ── left column ──────────────────────────────────────────
        Column {
            width: 230
            height: parent.height
            spacing: 12

            DashCard {
                width: parent.width
                height: 92

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Yudi Wu"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 3
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: "󰣇  Hyprland · Ubuntu 26.04"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.subtle
                    }

                    Text {
                        text: "󰅐  " + SysInfo.uptime
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.faint
                    }
                }
            }

            DashCard {
                width: parent.width
                height: parent.height - 92 - 12

                Calendar {
                    id: calendar
                    width: parent.width
                }
            }
        }

        // ── centre column ────────────────────────────────────────
        Column {
            width: 340
            height: parent.height
            spacing: 12

            DashCard {
                width: parent.width
                height: 128

                // The big clock. Hours in text colour, minutes in
                // accent — the reference splits them the same way, and
                // it is the one place on this desktop where the accent
                // is used for emphasis rather than for state. It earns
                // it: this is the thing you opened the panel to see.
            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    id: hours
                    text: Qt.formatDateTime(dashClock.date, "HH")
                    font.family: Theme.fontFamily
                    font.pixelSize: 64
                    font.weight: Font.Light
                    color: Theme.text
                }

                Text {
                    anchors.baseline: hours.baseline
                    text: Qt.formatDateTime(dashClock.date, "mm")
                    font.family: Theme.fontFamily
                    font.pixelSize: 64
                    font.weight: Font.Light
                    color: Theme.iris
                }

                // Sat on the same baseline as the big digits rather
                // than floating at their mid-height. A Row only
                // manages x, so vertical placement is anchors' job
                // and `baseline` is the one that tracks the font
                // instead of guessing a margin.
                Text {
                    anchors.baseline: hours.baseline
                    text: Qt.formatDateTime(dashClock.date, "ss")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.faint
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: Qt.locale("zh_CN").toString(dashClock.date, "dddd MM月dd日")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                color: Theme.subtle
            }
        }

        MediaCard {
            width: parent.width
            height: parent.height - 128 - 12
            player: dash.player
        }
    }

    // ── right column ─────────────────────────────────────────
    Column {
        width: 250
        height: parent.height
        spacing: 12

        DashCard {
            width: parent.width
            height: 104
            title: "OUTPUT"

            Column {
                width: parent.width
                spacing: 10

                SliderRow {
                    width: parent.width
                    glyph: "󰕾"
                    // Pipewire is a local call, so this can apply on
                    // every drag frame.
                    live: true
                    value: dash.sink && dash.sink.audio ? dash.sink.audio.volume : 0
                    onMoved: v => {
                        if (dash.sink && dash.sink.audio)
                            dash.sink.audio.volume = v;
                    }
                }

                SliderRow {
                    width: parent.width
                    glyph: "󰃞"
                    // DDC/CI costs ~600ms a call, so this applies
                    // once on release instead of per frame.
                    live: false
                    value: dash.brightness
                    onReleased: v => {
                        // Update our own copy as well as issuing the write.
                        //
                        // SliderRow shows `dragValue` while you are dragging
                        // and `value` once you let go, and `value` is bound
                        // to dash.brightness — which is only ever written by
                        // the query that runs when the panel opens. Without
                        // this line the handle tracks your drag and then
                        // snaps straight back to the last queried number.
                        dash.brightness = v;

                        brightnessSet.command = [Quickshell.shellPath("scripts/brightness.sh"), "set", dash.screenName, String(Math.round(v * 100))];
                        brightnessSet.running = true;
                    }
                }
            }
        }

        DashCard {
            width: parent.width
            height: parent.height - 104 - 12
            title: "QUICK SETTINGS"

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                readonly property real cellW: (width - columnSpacing) / 2

                QuickToggle {
                    width: parent.cellW
                    height: 62
                    glyph: ""
                    label: "Wi-Fi"
                    active: Networking.wifiEnabled
                    detail: {
                        const devices = Networking.devices.values;
                        for (var i = 0; i < devices.length; i++) {
                            if (devices[i].type !== DeviceType.Wifi)
                                continue;
                            const nets = devices[i].networks.values;
                            for (var j = 0; j < nets.length; j++) {
                                if (nets[j].connected)
                                    return nets[j].name;
                            }
                        }
                        return "";
                    }
                    onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                }

                QuickToggle {
                    width: parent.cellW
                    height: 62
                    glyph: ""
                    label: "Bluetooth"
                    active: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                    detail: {
                        const adapter = Bluetooth.defaultAdapter;
                        if (!adapter)
                            return "";
                        const devices = adapter.devices.values;
                        for (var i = 0; i < devices.length; i++) {
                            if (devices[i].connected)
                                return devices[i].name;
                        }
                        return "";
                    }
                    onToggled: {
                        if (Bluetooth.defaultAdapter)
                            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                    }
                }

                QuickToggle {
                    width: parent.cellW
                    height: 62
                    glyph: "󰂛"
                    label: "Do Not Disturb"
                    active: dash.dnd
                    detail: dash.dnd ? "silenced" : ""
                    onToggled: dndToggle.running = true
                }

                QuickToggle {
                    width: parent.cellW
                    height: 62
                    glyph: dash.sink && dash.sink.audio && dash.sink.audio.muted ? "󰖁" : "󰕾"
                    label: "Mute"
                    active: dash.sink && dash.sink.audio ? dash.sink.audio.muted : false
                    onToggled: {
                        if (dash.sink && dash.sink.audio)
                            dash.sink.audio.muted = !dash.sink.audio.muted;
                    }
                }
            }
        }
    }
}

    SystemClock {
        id: dashClock
        precision: SystemClock.Seconds
        // Only ticking while the panel is open. The bar has its own clock;
        // this one shows seconds, and waking once a second for a surface
        // nobody is looking at is pure waste.
        enabled: dash.open
    }
}
