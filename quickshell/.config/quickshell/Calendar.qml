import QtQuick

// Month grid, Monday-first, today marked with the same accent block the
// bar uses for the focused workspace.
Column {
    id: cal

    property date shown: new Date()
    readonly property date today: new Date()

    spacing: 8

    function reset() {
        shown = new Date();
    }

    // ── month header ─────────────────────────────────────────────────
    Item {
        width: parent.width
        height: 22

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.locale("zh_CN").toString(cal.shown, "yyyy年 MM月")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            color: Theme.text
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            NavButton {
                glyph: "‹"
                onActivated: cal.shown = new Date(cal.shown.getFullYear(), cal.shown.getMonth() - 1, 1)
            }
            NavButton {
                glyph: "·"
                onActivated: cal.reset()
            }
            NavButton {
                glyph: "›"
                onActivated: cal.shown = new Date(cal.shown.getFullYear(), cal.shown.getMonth() + 1, 1)
            }
        }
    }

    // ── weekday row ──────────────────────────────────────────────────
    Row {
        width: parent.width

        Repeater {
            model: ["一", "二", "三", "四", "五", "六", "日"]

            delegate: Text {
                required property string modelData
                width: cal.width / 7
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                color: Theme.faint
            }
        }
    }

    // ── the grid ─────────────────────────────────────────────────────
    Grid {
        width: parent.width
        columns: 7

        // 42 cells is six weeks, the most any month can span. Days outside
        // the month render blank rather than showing the neighbouring
        // month's numbers, which would need their own dimmer state and buy
        // nothing.
        Repeater {
            model: 42

            delegate: Item {
                id: cell

                required property int index

                // getDay() is 0=Sunday, but this grid starts on Monday to
                // match the 一…日 row above, so the offset rotates Sunday
                // to the end.
                readonly property int firstDay: {
                    const d = new Date(cal.shown.getFullYear(), cal.shown.getMonth(), 1).getDay();
                    return (d + 6) % 7;
                }

                // Day 0 of the next month is the last day of this one.
                readonly property int daysInMonth: new Date(cal.shown.getFullYear(), cal.shown.getMonth() + 1, 0).getDate()

                readonly property int day: index - firstDay + 1
                readonly property bool inMonth: day >= 1 && day <= daysInMonth

                readonly property bool isToday: inMonth && day === cal.today.getDate() && cal.shown.getMonth() === cal.today.getMonth() && cal.shown.getFullYear() === cal.today.getFullYear()

                width: cal.width / 7
                height: 26

                Rectangle {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    radius: Theme.radius
                    visible: cell.isToday
                    color: Theme.accentFill
                    border.width: 1
                    border.color: Theme.accentEdge
                }

                Text {
                    anchors.centerIn: parent
                    visible: cell.inMonth
                    text: cell.day
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: cell.isToday ? Font.DemiBold : Font.Normal
                    color: cell.isToday ? Theme.iris : Theme.subtle
                }
            }
        }
    }
}
