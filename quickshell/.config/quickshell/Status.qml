import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

// Network, bluetooth and volume — the state of the devices attached to
// this machine. All three visible at once; the hover drawer that used to
// hide two of them behind the network glyph is gone.
//
// All three are event-driven here. waybar polled network and bluetooth on
// a 5-second interval because its modules had no other option; these come
// off NetworkManager and BlueZ over DBus and update when the state
// actually changes.
RowLayout {
    id: root

    spacing: 0

    // The connected wifi network, if any. Networking exposes devices, each
    // with the networks it can see, so the active one is the connected
    // entry on a wifi device.
    readonly property var wifi: {
        const devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            const device = devices[i];
            if (device.type !== DeviceType.Wifi)
                continue;
            const networks = device.networks.values;
            for (var j = 0; j < networks.length; j++) {
                if (networks[j].connected)
                    return networks[j];
            }
        }
        return null;
    }

    readonly property var sink: Pipewire.defaultAudioSink

    // Pipewire objects are not bound until something declares interest in
    // them — without this tracker the sink's volume and muted properties
    // stay at their defaults forever.
    PwObjectTracker {
        objects: [root.sink]
    }

    // The wifi device itself, for the interface name. Kept separate from
    // `wifi` above, which is the connected network on it.
    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    // ── network ──────────────────────────────────────────────────────
    Item {
        id: net

        // Every module acknowledges the cursor now. Brightening to full
        // text colour is enough — the bar has no backgrounds left to
        // highlight, so the text itself has to be the affordance.
        HoverHandler {
            id: netModuleHover
        }
        Layout.fillHeight: true
        implicitWidth: netLabel.implicitWidth + 18

        property string ip: ""

        // The IP has to come from `ip`, not from quickshell. NetworkDevice
        // exposes an `address` property, but NMDevice::address() returns the
        // DBus service name — there is no IPv4 anywhere in the Networking
        // API. waybar got {ipaddr}/{cidr} straight from its module, so this
        // is the one place the port needs an external command to match it.
        //
        // Runs when the tooltip opens rather than on a timer: an address
        // changes when you join a network, and you are not looking at it
        // the rest of the time.
        Process {
            id: ipQuery
            stdout: SplitParser {
                onRead: line => net.ip = line.trim()
            }
        }

        // The command is assembled here rather than bound as a property.
        // A binding is evaluated when the component is created, and at that
        // point Networking has not finished enumerating devices — so the
        // interface name was empty, `ip -4 -o addr show` listed every
        // interface, and awk took the first line: 127.0.0.1/8. Building it
        // at the moment of the query means the device is known.
        function lookupIp() {
            if (!root.wifiDevice)
                return;
            ipQuery.command = ["sh", "-c", "ip -4 -o addr show " + root.wifiDevice.name + " 2>/dev/null | awk '{print $4; exit}'"];
            ipQuery.running = true;
        }

        Text {
            id: netLabel
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.weight
            font.letterSpacing: Theme.tracking

            // Connected is NOT accent-worthy. It is true essentially all
            // the time, so colouring it spent the one accent colour on a
            // non-event and left the bar permanently lit. Connected is now
            // the resting grey; the accent is reserved for things that
            // actually changed.
            //
            // A weak link does escalate, because that IS news — it is the
            // reason your connection feels bad, and nothing else on the bar
            // would tell you.
            color: {
                if (netModuleHover.hovered)
                    return Theme.text;
                if (!root.wifi)
                    return Theme.dim;
                if (root.wifi.signalStrength < 0.35)
                    return Theme.gold;
                return Theme.subtle;
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animMs
                }
            }

            // signalStrength is a qreal in 0..1, not a percentage — reading
            // it raw showed "1%" on an 84% link. waybar's {signalStrength}
            // was already scaled, which is why this needs the multiply.
            //
            // Wifi and bluetooth use \u escapes because they sit inside
            // the BMP (U+F1EB, U+F293). The volume and stats glyphs are
            // Material Design icons above U+FFFF, which a 4-digit \u
            // escape cannot reach, so those stay literal.
            text: root.wifi ? "\uf1eb " + Math.round(root.wifi.signalStrength * 100) : "\uf1eb off"
        }

        HoverHandler {
            id: netHover
            onHoveredChanged: if (hovered)
                net.lookupIp()
        }

        Tooltip {
            anchorItem: net
            open: netHover.hovered

            TipRow {
                label: "network"
                value: root.wifi ? root.wifi.name : "disconnected"
            }
            TipRow {
                visible: root.wifi !== null
                label: "signal"
                value: root.wifi ? Math.round(root.wifi.signalStrength * 100) + "%" : ""
            }
            TipRow {
                visible: root.wifiDevice !== null
                label: "interface"
                value: root.wifiDevice ? root.wifiDevice.name : ""
            }
            TipRow {
                visible: net.ip !== ""
                label: "address"
                value: net.ip
            }
        }
    }

    // ── bluetooth ────────────────────────────────────────────────────
    Item {
        id: bt
        Layout.fillHeight: true
        implicitWidth: btLabel.implicitWidth + 16

        readonly property var adapter: Bluetooth.defaultAdapter

        readonly property var connectedDevice: {
            if (!adapter)
                return null;
            const devices = adapter.devices.values;
            for (var i = 0; i < devices.length; i++) {
                if (devices[i].connected)
                    return devices[i];
            }
            return null;
        }

        Text {
            id: btLabel
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.weight
            font.letterSpacing: Theme.tracking

            color: btHover.hovered ? Theme.text : (bt.connectedDevice ? Theme.subtle : (bt.adapter && bt.adapter.enabled ? Theme.dim : Theme.faint))

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animMs
                }
            }

            text: bt.connectedDevice ? "\uf293 " + bt.connectedDevice.name : "\uf293"
        }

        HoverHandler {
            id: btHover
        }

        Tooltip {
            anchorItem: bt
            open: btHover.hovered

            TipRow {
                label: "adapter"
                value: bt.adapter ? bt.adapter.name : "none"
            }
            TipRow {
                label: "state"
                value: bt.adapter ? (bt.adapter.enabled ? "on" : "off") : "unavailable"
            }

            // Every paired device, not just the connected one — "which of
            // my headphones does this machine know about" is the question
            // you actually open this for.
            Repeater {
                model: bt.adapter ? bt.adapter.devices : null

                delegate: TipRow {
                    required property var modelData
                    visible: modelData.paired || modelData.connected
                    label: modelData.connected ? "connected" : "paired"
                    value: {
                        var v = modelData.name;
                        if (modelData.batteryAvailable)
                            v += "  " + Math.round(modelData.battery * 100) + "%";
                        return v;
                    }
                }
            }
        }
    }

    // ── volume ───────────────────────────────────────────────────────
    Item {
        id: vol
        Layout.fillHeight: true
        implicitWidth: volLabel.implicitWidth + 16

        readonly property bool muted: root.sink && root.sink.audio ? root.sink.audio.muted : false
        readonly property int volume: root.sink && root.sink.audio ? Math.round(root.sink.audio.volume * 100) : 0

        Text {
            id: volLabel
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.weight
            font.letterSpacing: Theme.tracking

            // Audible is the resting state, so grey. Muted dims, and drops
            // the number: the level a muted sink would return to is not
            // information you need while it is silent.
            color: volHover.hovered ? Theme.text : (vol.muted ? Theme.dim : Theme.subtle)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animMs
                }
            }
            text: vol.muted ? "󰖁" : "󰕾 " + vol.volume
        }

        HoverHandler {
            id: volHover
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.sink && root.sink.audio)
                    root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }
}
