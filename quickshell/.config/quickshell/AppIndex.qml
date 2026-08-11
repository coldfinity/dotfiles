pragma Singleton

import Quickshell
import Quickshell.Io

// The installed-application database, shared by the launcher and by
// anything that needs to turn a Wayland app-id into a name a human wrote.
//
// This was local to Launcher.qml. It moved here when the workspace dropdown
// needed the same thing: turning "org.wezfurlong.wezterm" into "WezTerm" is
// exactly what a desktop entry is for, and parsing the whole set twice for
// two consumers would be silly.
//
// See scripts/apps.sh for why this is parsed at all rather than read from
// Quickshell's DesktopEntries, which returns an empty database here.
Singleton {
    id: root

    property var apps: []

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/apps.sh")]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.apps = JSON.parse(text);
                } catch (e) {
                    root.apps = [];
                }
            }
        }
    }

    // app-id → the name the application's author chose.
    //
    // Wayland app-ids and .desktop file names agree often enough to match
    // directly but not always, so this tries the obvious forms in order and
    // falls back to the raw id. The fallback matters: an unmatched window
    // should still say something, and "zen" beats an empty row.
    function nameFor(appId) {
        if (!appId)
            return "";

        const wanted = appId.toLowerCase();

        for (var i = 0; i < apps.length; i++) {
            const id = (apps[i].id || "").toLowerCase();
            if (id === wanted + ".desktop")
                return apps[i].name;
        }

        // Some app-ids are the tail of a reverse-DNS entry id, and some
        // entries carry a vendor prefix the window never reports.
        for (var j = 0; j < apps.length; j++) {
            const id2 = (apps[j].id || "").toLowerCase().replace(".desktop", "");
            if (id2.endsWith("." + wanted) || wanted.endsWith("." + id2))
                return apps[j].name;
        }

        return appId;
    }
}
