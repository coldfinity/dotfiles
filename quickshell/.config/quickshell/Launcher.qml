import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

// The application launcher, replacing rofi on SUPER+Space.
//
// rofi worked, but it was a separate program with its own theme file, its
// own font setting and its own idea of what a list looks like — so the one
// piece of UI you touch most often was the one that looked least like the
// rest of the desktop. This is built from the same Theme and the same
// motion tokens as everything else.
//
// The app list comes from scripts/apps.sh rather than Quickshell's
// DesktopEntries, which returns an empty database on this system. See that
// script.
Scope {
    id: root

    // The app list lives in AppIndex now, shared with the workspace
    // dropdown rather than parsed twice.
    readonly property var apps: AppIndex.apps
    property string query: ""
    property int index: 0
    property bool open: false

    // Ranked, not just filtered.
    //
    // A plain substring match puts "Advanced Network Configuration" above
    // "Files" when you type "fi", because it matches earlier in the
    // alphabet. Ranking by WHERE the match lands fixes that: a prefix beats
    // a word start, which beats a match buried mid-string, which beats a
    // description-only match.
    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "")
            return apps.slice(0, 40);

        const scored = [];
        for (var i = 0; i < apps.length; i++) {
            const app = apps[i];
            const name = app.name.toLowerCase();
            const pos = name.indexOf(q);

            let score = -1;
            if (pos === 0)
                score = 0;
            else if (pos > 0 && name.charAt(pos - 1) === " ")
                score = 1;
            else if (pos > 0)
                score = 2;
            else if ((app.comment || "").toLowerCase().indexOf(q) !== -1)
                score = 3;

            if (score >= 0)
                scored.push({
                    app: app,
                    score: score
                });
        }

        scored.sort((a, b) => a.score - b.score || a.app.name.localeCompare(b.app.name));
        return scored.slice(0, 40).map(e => e.app);
    }

    onResultsChanged: index = 0

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            if (root.open) {
                root.close();
            } else {
                root.query = "";
                root.index = 0;
                root.open = true;
            }
        }
    }

    function close() {
        open = false;
        query = "";
        index = 0;
    }

    function launch() {
        const app = results[index];
        if (!app)
            return;
        close();

        // Terminal=true entries are TUI programs with no window of their
        // own — btop, vim, info. Launching them bare would fork a process
        // with nowhere to draw.
        if (app.terminal)
            Quickshell.execDetached(["wezterm", "start", "--", "sh", "-c", app.exec]);
        else
            Quickshell.execDetached(["sh", "-c", app.exec]);
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: root.open && Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-launcher"
            WlrLayershell.layer: WlrLayer.Overlay

            // Exclusive, unlike every other surface in this shell. A
            // launcher is modal by nature — it exists to receive typing,
            // and anything less than exclusive leaves keystrokes going to
            // whatever was focused underneath.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            color: "transparent"

            // Click anywhere outside to dismiss. This works here where it
            // failed for the dashboard, because a layer surface with
            // keyboard focus can simply cover the screen and take the
            // click — no xdg_popup grab involved.
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.4)
            }

            Rectangle {
                id: panel

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 180

                width: 620
                height: Math.min(header.height + list.contentHeight + 20, 520)

                color: Qt.rgba(0.098, 0.090, 0.141, 0.97)
                border.color: Theme.edge
                border.width: 1
                radius: Theme.radius

                opacity: root.open ? 1 : 0
                scale: root.open ? 1 : 0.98

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

                // Swallows clicks so hitting the panel does not dismiss it
                // through the backdrop underneath.
                MouseArea {
                    anchors.fill: parent
                }

                // ── search ───────────────────────────────────────────
                Item {
                    id: header
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 54

                    Text {
                        id: prompt
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: Theme.iris
                    }

                    TextInput {
                        id: input
                        anchors.left: prompt.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.verticalCenter: parent.verticalCenter

                        text: root.query
                        onTextChanged: root.query = text

                        // Refocused every time the launcher opens. The item
                        // persists between invocations, so focus has to be
                        // re-taken rather than assumed.
                        focus: true
                        Connections {
                            target: root
                            function onOpenChanged() {
                                if (root.open) {
                                    input.text = "";
                                    input.forceActiveFocus();
                                }
                            }
                        }

                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        color: Theme.text
                        selectionColor: Theme.accentFill
                        selectedTextColor: Theme.text
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: "Search"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 2
                            color: Theme.faint
                        }

                        Keys.onEscapePressed: root.close()
                        Keys.onReturnPressed: root.launch()
                        Keys.onEnterPressed: root.launch()

                        Keys.onDownPressed: if (root.results.length > 0)
                            root.index = (root.index + 1) % root.results.length
                        Keys.onUpPressed: if (root.results.length > 0)
                            root.index = (root.index - 1 + root.results.length) % root.results.length

                        // Tab cycles too, matching how the rest of the
                        // desktop treats it.
                        Keys.onTabPressed: if (root.results.length > 0)
                            root.index = (root.index + 1) % root.results.length
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: header.bottom
                    height: 1
                    color: Theme.divider
                }

                // ── results ──────────────────────────────────────────
                ListView {
                    id: list
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: header.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8

                    clip: true
                    model: root.results
                    currentIndex: root.index

                    // Keeps the selection on screen when arrowing past the
                    // bottom of the visible list.
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: Theme.animQuick

                    delegate: Rectangle {
                        id: row

                        required property var modelData
                        required property int index

                        width: list.width
                        height: 44
                        color: index === root.index ? Theme.accentFill : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animQuick
                            }
                        }

                        // Two-step icon resolution, the same as the bar's:
                        // the theme first, then an absolute path from the
                        // desktop entry. Tarball and snap installs point
                        // Icon= at a file rather than a theme name.
                        readonly property string iconSource: {
                            const ic = row.modelData.icon || "";
                            if (ic === "")
                                return "";
                            if (ic.startsWith("/"))
                                return "file://" + ic;
                            return Quickshell.iconPath(ic, true);
                        }

                        IconImage {
                            id: rowIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 26
                            visible: row.iconSource !== ""
                            source: row.iconSource
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            height: 26
                            radius: Theme.radius
                            visible: row.iconSource === ""
                            color: Theme.hover

                            Text {
                                anchors.centerIn: parent
                                text: (row.modelData.name || "?").charAt(0).toUpperCase()
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                color: Theme.subtle
                            }
                        }

                        Text {
                            anchors.left: rowIcon.right
                            anchors.leftMargin: 14
                            anchors.right: parent.right
                            anchors.rightMargin: 18
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            text: row.modelData.name
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.weight
                            color: index === root.index ? Theme.text : Theme.subtle
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.index = row.index
                            onClicked: root.launch()
                        }
                    }
                }

                // Nothing matched. Says so rather than showing an empty
                // box, which reads as the launcher having broken.
                Text {
                    anchors.centerIn: list
                    visible: root.results.length === 0
                    text: "no matches"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.italic: true
                    color: Theme.faint
                }
            }
        }
    }
}
