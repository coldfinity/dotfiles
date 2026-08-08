import QtQuick
import QtQuick.Layouts

// CPU / RAM / GPU, always visible.
//
// These used to hide behind a hover drawer with a single gauge glyph
// standing in for all three. The drawer is gone: a number you have to hover
// to read is not a status display, and the gauge could only ever tell you
// that something was loaded, not which.
//
// The numbers come from the SysInfo singleton rather than a Process owned
// here — this component exists once per monitor, and the machine only
// needs sampling once.
RowLayout {
    spacing: 0

    Stat {
        glyph: "󰘙"
        value: SysInfo.cpu
        Layout.fillHeight: true
    }
    Stat {
        glyph: "󰍛"
        value: SysInfo.mem
        Layout.fillHeight: true
    }
    Stat {
        glyph: "󰢮"
        value: SysInfo.gpu
        Layout.fillHeight: true
    }
}
