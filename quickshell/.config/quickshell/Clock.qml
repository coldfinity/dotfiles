import Quickshell
import QtQuick
import QtQuick.Layouts

// Chinese date and 24-hour time, matching the waybar format exactly:
// 星期四 08月06日 17:47
//
// The libfmt quirks that format had to work around in waybar are gone.
// There is no `L` flag to remember and no `%-d` that silently blanks the
// module, because this is Qt's own locale-aware formatting rather than a
// format string handed to a C++ chrono library.
//
// 24-hour on purpose, as before: glibc's zh_CN renders %p as a literal
// "PM" rather than 上午/下午, so a 12-hour format left an English fragment
// in an otherwise Chinese string. Qt would do the same.
Item {
    id: root

    Layout.fillHeight: true
    implicitWidth: label.implicitWidth + 22

    // Ticks once a second. `precision` is what decides how often the
    // binding re-evaluates — asking for Seconds on a display that only
    // shows minutes would wake the process 60 times more than needed.
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: label
        anchors.centerIn: parent

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.weight
        font.letterSpacing: Theme.tracking

        text: Qt.locale("zh_CN").toString(clock.date, "dddd MM月dd日 HH:mm")

        // GREY at rest, not full text colour: this is the longest run of
        // text on the bar and at full strength it read as highlighted next
        // to the grey stats. Brightens while the dashboard is open, so the
        // clock reads as the thing that opened it rather than as unrelated
        // text sitting above a panel.
        color: (DashboardState.open || clockHover.hovered) ? Theme.text : Theme.subtle

        Behavior on color {
            ColorAnimation {
                duration: Theme.animMs
            }
        }
    }

    // Click, not hover. The dashboard is something you interact with —
    // paging months, dragging the volume — so it must not vanish the
    // moment the cursor strays off the way a hover popup would.
    HoverHandler {
        id: clockHover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: DashboardState.toggle()
    }

}
