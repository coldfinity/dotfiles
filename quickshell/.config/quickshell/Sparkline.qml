import QtQuick

// A thin history trace, drawn under a stat's number.
//
// The point is to make load legible as a shape rather than as a number that
// happens to differ from the one you last looked at. "16" tells you nothing
// about whether the machine is climbing, settling, or has been pinned for a
// minute; the trace tells you all three at a glance.
//
// Canvas rather than a Repeater of Rectangles. Thirty-two bars per stat,
// three stats, two monitors is 192 items rebuilt every two seconds — a
// Canvas is one item that repaints a path.
Canvas {
    id: root

    // Newest sample last.
    required property var values
    required property color stroke

    // Redraw whenever the samples or the colour change. `values` is
    // reassigned rather than mutated upstream precisely so this fires.
    onValuesChanged: requestPaint()
    onStrokeChanged: requestPaint()

    opacity: 0.75

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        const n = values.length;
        if (n < 2)
            return;

        // Fixed scale, not auto-ranged — but square-rooted.
        //
        // Auto-ranging is out: it makes idle noise between 2% and 4% look
        // identical to a machine swinging between 20% and 90%, because the
        // shape fills the box either way. The trace has to stay comparable
        // between one glance and the next.
        //
        // But a linear 0-100 scale in an 8px strip puts everyday load one
        // pixel off the floor and the line effectively disappears — honest
        // and worthless. sqrt keeps the ordering exact and every value in
        // its correct relative position, while spending more of the height
        // on the low end where this machine actually lives: 16% lands at
        // 40% of the height, 90% at 95%.
        const stepX = width / (root.historyLength - 1);

        function scaled(v) {
            const clamped = Math.max(0, Math.min(100, v));
            return Math.sqrt(clamped / 100);
        }

        // Right-aligned, so the newest sample is always at the right edge
        // and the trace grows leftward while filling up rather than
        // stretching to fit.
        const startIndex = root.historyLength - n;

        // Filled area as well as the line. At this size a 1px stroke alone
        // reads as noise; the fill gives the shape enough body to register
        // in peripheral vision, which is the only way this gets looked at.
        ctx.beginPath();
        ctx.moveTo(startIndex * stepX, height);
        for (var i = 0; i < n; i++) {
            const x = (startIndex + i) * stepX;
            const y = height - scaled(values[i]) * height;
            ctx.lineTo(x, y);
        }
        ctx.lineTo((startIndex + n - 1) * stepX, height);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(root.stroke.r, root.stroke.g, root.stroke.b, 0.22);
        ctx.fill();

        ctx.beginPath();
        for (var j = 0; j < n; j++) {
            const px = (startIndex + j) * stepX;
            const py = height - scaled(values[j]) * height;
            if (j === 0)
                ctx.moveTo(px, py);
            else
                ctx.lineTo(px, py);
        }

        ctx.strokeStyle = root.stroke;
        ctx.lineWidth = 1;
        ctx.lineJoin = "round";
        ctx.stroke();
    }

    // Kept in sync with SysInfo so the x-scale matches the buffer the
    // samples come from.
    readonly property int historyLength: SysInfo.historyLength
}
