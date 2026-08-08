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

    // Rolling history for the sparklines. Every sample was already arriving
    // and being thrown away — only the latest value was kept — so a trace
    // costs nothing but the array.
    //
    // 32 samples at one every 2s is roughly a minute of history, which is
    // the useful window: long enough to see a build spike rise and decay,
    // short enough that it is still about now.
    readonly property int historyLength: 32

    property var cpuHistory: []
    property var memHistory: []
    property var gpuHistory: []

    // Reassigned rather than mutated. QML only re-evaluates bindings on a
    // `var` property when the property itself is written, so pushing into
    // the existing array would update the data and never repaint anything.
    function push(history, value) {
        const next = history.slice(history.length >= historyLength ? 1 : 0);
        next.push(value);
        return next;
    }

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

                    root.cpuHistory = root.push(root.cpuHistory, d.cpu);
                    root.memHistory = root.push(root.memHistory, d.mem);
                    root.gpuHistory = root.push(root.gpuHistory, d.gpu);
                } catch (e)
                // A partial line during shutdown is not worth logging.
                {}
            }
        }
    }
}
