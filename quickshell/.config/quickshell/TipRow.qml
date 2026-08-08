import QtQuick

// One line inside a tooltip: a faint label and its value.
//
// The two-column shape is what makes these readable at a glance —
// waybar's tooltips were newline-joined format strings, so "SSID (81%)"
// and an IP ran together with nothing marking which was which.
Row {
    id: root

    required property string label
    required property string value

    spacing: 8

    Text {
        width: 62
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        color: Theme.faint
    }

    Text {
        text: root.value
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Font.DemiBold
        color: Theme.subtle
    }
}
