import Quickshell
import QtQuick

// The base every popup in this shell is built on: dashboard, power menu,
// tooltips, workspace dropdowns.
//
// It exists to fix a specific bug. PopupSurface animates on `shown`, but
// the popups used to drive PopupWindow.visible directly — and a Wayland
// popup unmaps the moment visible goes false, so the fade-out had no frames
// to render into. Opening looked smooth and closing was an instant blink.
//
// The fix is to separate the two. `open` is what callers bind to; `visible`
// is held true until the close animation has actually finished, then
// dropped. Reopening mid-close cancels the pending unmap, so a fast
// hover-out-hover-in does not blink either.
PopupWindow {
    id: root

    // Bind this instead of `visible`.
    property bool open: false

    required property Item anchorItem

    // Content goes inside the animated surface, not the bare window.
    default property alias content: surface.content

    // How far below the anchor the popup hangs. The bar's frames have a
    // border of their own, and a popup flush against it reads as growing
    // out of the bar rather than as a separate surface.
    property int gap: 6

    anchor.item: anchorItem
    anchor.rect.y: anchorItem.height + gap
    anchor.rect.x: anchorItem.width / 2
    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Bottom

    color: "transparent"
    visible: false

    onOpenChanged: {
        if (open) {
            // Cancel any unmap still pending from a previous close.
            unmap.stop();
            visible = true;
        } else {
            unmap.restart();
        }
    }

    // Slightly longer than PopupSurface's longest exit animation (200ms),
    // so the window is never pulled out from under a frame still being
    // drawn.
    Timer {
        id: unmap
        interval: 240
        onTriggered: root.visible = false
    }

    PopupSurface {
        id: surface
        anchors.fill: parent
        shown: root.open
    }
}
