import QtQuick
import QtQuick.Layouts

// The hairline rule between two sections of a frame.
//
// Inset vertically rather than running the full height: a rule that met the
// frame's own top and bottom borders would read as the frame being cut in
// two, instead of one object with divisions in it.
Rectangle {
    Layout.preferredWidth: 1
    Layout.fillHeight: true
    Layout.topMargin: 7
    Layout.bottomMargin: 7
    color: Theme.divider
}
