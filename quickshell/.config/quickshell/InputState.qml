pragma Singleton

import Quickshell
import Quickshell.Io

// fcitx5 input mode, polled once for the whole shell.
//
// Same reason SysInfo is a singleton: InputMode is instantiated once per
// monitor, so owning the Process there meant two copies of fcitx5.sh
// running — two shells asking one daemon the same question every second,
// and two answers that can never differ, since the input mode is global.
Singleton {
    id: root

    property string mode: "EN"
    readonly property bool active: mode !== "EN"

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/fcitx5.sh")]

        stdout: SplitParser {
            onRead: line => root.mode = line.trim()
        }
    }
}
