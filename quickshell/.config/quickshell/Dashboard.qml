import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick

// The control centre.
//
// Same idea as the Material shells' control centres, in this desktop's own
// register: square hairline cards instead of raised rounded ones, rose-pine
// instead of bright blue, and colour only where it means something. Nothing
// here is decorative — the accent marks what is active, and everything at
// rest is grey.
//
// The tile set is chosen for THIS machine, not copied from the reference:
//
//   - No battery card. /sys/class/power_supply is empty; it is a desktop.
//   - No night-light toggle. Neither hyprsunset nor wlsunset is installed,
//     so the tile would be a switch wired to nothing.
//   - Brightness IS here, but over DDC/CI rather than a backlight file —
//     both panels are external. See scripts/brightness.sh.
//
// Four columns rather than three. The fourth exists because toggles are not
// enough: knowing bluetooth is on does not help when the question is which
// headphones to connect, and a wifi switch does not say what else is in
// range. The device lists are the difference between a status panel and one
// you can act on.
Scope {
    id: dash

    readonly property bool open: DashboardState.open

    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            DashboardState.toggle();
        }
        function close(): void {
            DashboardState.open = false;
        }
    }

    // The monitor the dashboard is showing on, which is the one whose
    // brightness the slider should read and write.
    readonly property string screenName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "DP-1"

    onOpenChanged: {
        if (!open)
            return;
        // Brightness is only read when the panel opens. Each DDC/CI round
        // trip costs ~250ms, so polling it would mean a slow I2C
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

    // ── audio ────────────────────────────────────────────────────────
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Hardware outputs only. isStream separates programs from devices, so
    // without it this list fills with every application currently playing
    // audio rather than the cards you can send it to.
    readonly property var outputs: {
        const found = [];
        const all = Pipewire.nodes.values;
        for (var i = 0; i < all.length; i++) {
            const n = all[i];
            if (n.audio && n.isSink && !n.isStream)
                found.push(n);
        }
        return found;
    }

    // Tracking keeps volume and mute readable. Pipewire objects stay unbound
    // until something declares interest, and an untracked node reports
    // defaults forever.
    PwObjectTracker {
        objects: {
            const list = [dash.sink, dash.source];
            for (var i = 0; i < dash.outputs.length; i++)
                list.push(dash.outputs[i]);
            return list;
        }
    }

    function deviceLabel(node) {
        if (!node)
            return "";
        return node.nickname || node.description || node.name || "";
    }

    // ── brightness ───────────────────────────────────────────────────
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

    // ── network / bluetooth ──────────────────────────────────────────
    // Both act through the Quickshell services directly. An earlier version
    // shelled out to nmcli and bluetoothctl on the assumption that the
    // services only reported state — they do not. Network has connect(),
    // disconnect() and forget(); BluetoothDevice has the same plus pair(),
    // and its `connected` property is writable. Going through the services
    // means no process spawn per click, and the UI reacts to the result
    // instead of firing a command and hoping.

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    // Strongest first, capped at six. An unranked scan is dozens of
    // neighbours' routers in arbitrary order, which is not a list anyone
    // picks from.
    readonly property var networks: {
        if (!wifiDevice)
            return [];
        const list = wifiDevice.networks.values.slice();
        list.sort((a, b) => (b.signalStrength || 0) - (a.signalStrength || 0));
        return list.slice(0, 6);
    }

    readonly property var btAdapter: Bluetooth.defaultAdapter

    // Paired or connected only. Every bluetooth device in range would put
    // strangers' earbuds in the list.
    readonly property var btDevices: {
        if (!btAdapter)
            return [];
        const all = btAdapter.devices.values;
        const found = [];
        for (var i = 0; i < all.length; i++) {
            if (all[i].paired || all[i].connected)
                found.push(all[i]);
        }
        return found;
    }

    // ── the panel ────────────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: dash.open && Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            color: "transparent"

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: DashboardState.open = false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: DashboardState.open = false
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.35)
            }

            Rectangle {
                id: panel

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 56

                // 1152, not a round number: the four columns are
                // 236+340+258+236, three 14px gaps and a 16px margin each
                // side — 1144. At 1120 the fourth column was clipped by the
                // panel's own edge.
                width: 1152
                height: 560

                // Opaque, unlike the bar. No hyprland layerrule blurs this,
                // so at 0.94 a bright terminal underneath showed its text
                // through the calendar.
                color: Qt.rgba(0.098, 0.090, 0.141, 0.98)
                border.color: Theme.edge
                border.width: 1
                radius: Theme.radius

                opacity: dash.open ? 1 : 0
                scale: dash.open ? 1 : 0.98

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animQuick
                        easing.type: Theme.ease
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animQuick
                        easing.type: Theme.ease
                    }
                }

                // Swallows clicks so using the panel does not dismiss it
                // through the backdrop behind.
                MouseArea {
                    anchors.fill: parent
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // ══ column 1: who and when ══════════════════════
                    Column {
                        width: 236
                        height: parent.height
                        spacing: 14

                        DashCard {
                            width: parent.width
                            height: 88

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                spacing: 4

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
                            height: parent.height - 88 - 14

                            Calendar {
                                id: calendar
                                width: parent.width

                                // Paging away and closing should not leave
                                // the panel stranded in March next time it
                                // opens. This lives here rather than in the
                                // Scope's onOpenChanged because `calendar`
                                // is only in scope inside the delegate —
                                // calling it from there threw a
                                // ReferenceError that also aborted the
                                // brightness read on the following line.
                                Connections {
                                    target: dash
                                    function onOpenChanged() {
                                        if (dash.open)
                                            calendar.reset();
                                    }
                                }
                            }
                        }
                    }

                    // ══ column 2: time and media ════════════════════
                    Column {
                        width: 340
                        height: parent.height
                        spacing: 14

                        DashCard {
                            width: parent.width
                            height: 132

                            // Hours in text colour, minutes in accent. The
                            // one place on this desktop where the accent is
                            // emphasis rather than state — it earns it,
                            // because this is what you opened the panel for.
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

                                // On the same baseline as the big digits. A
                                // Row only manages x, so vertical placement
                                // is anchors' job, and `baseline` tracks the
                                // font instead of guessing a margin.
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
                            height: parent.height - 132 - 14
                            player: dash.player
                        }
                    }

                    // ══ column 3: levels and toggles ════════════════
                    Column {
                        width: 258
                        height: parent.height
                        spacing: 14

                        DashCard {
                            width: parent.width
                            height: 154
                            title: "LEVELS"

                            Column {
                                width: parent.width
                                spacing: 12

                                SliderRow {
                                    width: parent.width
                                    glyph: "󰕾"
                                    live: true
                                    value: dash.sink && dash.sink.audio ? dash.sink.audio.volume : 0
                                    onMoved: v => {
                                        if (dash.sink && dash.sink.audio)
                                            dash.sink.audio.volume = v;
                                    }
                                }

                                // Microphone. New here — the bar has no room
                                // for an input level, and a muted mic you
                                // cannot see is how meetings start badly.
                                SliderRow {
                                    width: parent.width
                                    glyph: dash.source && dash.source.audio && dash.source.audio.muted ? "󰍭" : "󰍬"
                                    live: true
                                    value: dash.source && dash.source.audio ? dash.source.audio.volume : 0
                                    onMoved: v => {
                                        if (dash.source && dash.source.audio)
                                            dash.source.audio.volume = v;
                                    }
                                }

                                SliderRow {
                                    width: parent.width
                                    glyph: "󰃞"
                                    // DDC/CI costs ~250ms a call, so this
                                    // applies once on release rather than
                                    // per frame.
                                    live: false
                                    value: dash.brightness
                                    onReleased: v => {
                                        // Update our own copy too: the
                                        // slider shows `value` once the drag
                                        // ends, and nothing else writes
                                        // dash.brightness until the panel
                                        // reopens and re-queries.
                                        dash.brightness = v;
                                        brightnessSet.command = [Quickshell.shellPath("scripts/brightness.sh"), "set", dash.screenName, String(Math.round(v * 100))];
                                        brightnessSet.running = true;
                                    }
                                }
                            }
                        }

                        DashCard {
                            width: parent.width
                            height: parent.height - 154 - 14
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
                                    glyph: ""
                                    label: "Wi-Fi"
                                    active: Networking.wifiEnabled
                                    detail: {
                                        for (var i = 0; i < dash.networks.length; i++) {
                                            if (dash.networks[i].connected)
                                                return dash.networks[i].name;
                                        }
                                        return "";
                                    }
                                    onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                                }

                                QuickToggle {
                                    width: parent.cellW
                                    height: 62
                                    glyph: ""
                                    label: "Bluetooth"
                                    active: dash.btAdapter ? dash.btAdapter.enabled : false
                                    detail: {
                                        for (var i = 0; i < dash.btDevices.length; i++) {
                                            if (dash.btDevices[i].connected)
                                                return dash.btDevices[i].name;
                                        }
                                        return "";
                                    }
                                    onToggled: {
                                        if (dash.btAdapter)
                                            dash.btAdapter.enabled = !dash.btAdapter.enabled;
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

                    // ══ column 4: devices ═══════════════════════════
                    Column {
                        width: 236
                        height: parent.height
                        spacing: 14

                        DashCard {
                            width: parent.width
                            height: 150
                            title: "OUTPUT"

                            Column {
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: dash.outputs

                                    delegate: DeviceRow {
                                        required property var modelData
                                        width: parent.width
                                        label: dash.deviceLabel(modelData)
                                        active: dash.sink === modelData
                                        detail: dash.sink === modelData ? "󰄬" : ""
                                        // A hint, not a command — pipewire
                                        // honours it when it can.
                                        onPicked: Pipewire.preferredDefaultAudioSink = modelData
                                    }
                                }
                            }
                        }

                        DashCard {
                            width: parent.width
                            height: 178
                            title: "NETWORKS"

                            Column {
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: dash.networks

                                    delegate: DeviceRow {
                                        required property var modelData
                                        width: parent.width
                                        label: modelData.name
                                        active: modelData.connected
                                        // Signal strength, or the state while
                                        // it is changing. stateChanging is
                                        // what turns a click from a guess
                                        // into something with feedback.
                                        detail: {
                                            if (modelData.stateChanging)
                                                return "···";
                                            const pct = Math.round((modelData.signalStrength || 0) * 100) + "";
                                            // A dot marks a saved network,
                                            // so it is obvious which ones
                                            // will connect on one click and
                                            // which need a password.
                                            return modelData.known ? "· " + pct : pct;
                                        }

                                        onPicked: {
                                            if (modelData.connected)
                                                modelData.disconnect();
                                            else
                                                modelData.connect();
                                        }
                                    }
                                }
                            }
                        }

                        DashCard {
                            width: parent.width
                            height: parent.height - 150 - 178 - 28
                            title: "BLUETOOTH"

                            Column {
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: dash.btDevices

                                    delegate: DeviceRow {
                                        required property var modelData
                                        width: parent.width
                                        label: modelData.name
                                        active: modelData.connected
                                        detail: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : (modelData.connected ? "󰄬" : "")
                                        // `connected` is writable and is
                                        // documented as equivalent to
                                        // calling connect()/disconnect().
                                        onPicked: modelData.connected = !modelData.connected
                                    }
                                }

                                Text {
                                    visible: dash.btDevices.length === 0
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "nothing paired"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 4
                                    font.italic: true
                                    color: Theme.faint
                                }
                            }
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
