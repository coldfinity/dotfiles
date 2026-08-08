pragma Singleton

import Quickshell
import Quickshell.Io

// CPU / RAM / GPU / uptime, read once for the whole shell.
//
// This started out inside Stats.qml, which was a bug: Variants builds one
// Bar per monitor, so the stats module was instantiated twice and ran two
// copies of sysinfo.sh — two shell loops, two nvidia-smi calls every two
// seconds, for one machine's worth of numbers. A singleton is instantiated
// once no matter how many screens are attached.
Singleton {
    id: root

    property int cpu: 0
    property int mem: 0
    property int gpu: 0
    property string uptime: ""

    readonly property int worst: Math.max(cpu, mem, gpu)

    Process {
        running: true
        command: [Quickshell.shellPath("scripts/sysinfo.sh")]

        stdout: SplitParser {
            onRead: line => {
                try {
                    const d = JSON.parse(line);
                    root.cpu = d.cpu;
                    root.mem = d.mem;
                    root.gpu = d.gpu;
                    root.uptime = d.uptime;
                } catch (e)
                // A partial line during shutdown is not worth logging.
                {}
            }
        }
    }
}
