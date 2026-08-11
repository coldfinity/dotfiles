import Quickshell
import QtQuick

// The base every popup in this shell is built on: dashboard, power menu,
// tooltips, workspace dropdowns.
//
// It separates `open` from `visible`. A Wayland popup unmaps the moment
// visible goes false, so a popup that drove `visible` directly had no
// frames left to render its fade-out into — opening looked smooth and
// closing was an instant blink. `open` is what callers bind to; `visible`
// is held true until the close animation has finished, then dropped.
// Reopening mid-close cancels the pending unmap, so a fast
// hover-out-hover-in does not blink either.
//
// NO FOCUS GRAB. This was tried and removed.
//
// Setting grabFocus on the click-opened popups gave click-anywhere-to-
// dismiss, and required Bar.qml to set keyboardFocus: OnDemand, since a
// grabbing popup must be parented to a surface that has received input.
// It never worked reliably here. In order, it produced:
//
//   1. A reopen race — clicking the anchor while open delivered both a
//      compositor dismissal and a click to the button underneath, so the
//      popup closed and immediately reopened.
//   2. A guard against that which was long enough to swallow a deliberate
//      second click, so the button appeared to ignore you.
//   3. A recreation loop — the compositor destroyed the surface while
//      `visible` was still true for the close animation, so quickshell
//      rebuilt the window, which was dismissed again, repeatedly. That is
//      the flashing.
//
// Each fix was reasoned rather than observed, because synthetic clicks do
// not reproduce any of it. Clicking the anchor again to close is what
// worked, so that is what this does. If click-away is worth another
// attempt, it needs to start from a way to actually test it.
PopupWindow {
    id: root

    // Bind this instead of `visible`.
    property bool open: false

    required property Item anchorItem

    // Content goes inside the animated surface, not the bare window.
    default property alias content: surface.content

    // How far below the anchor the popup hangs. A popup flush against the
    // bar reads as growing out of it rather than as a separate surface.
    property int gap: 6

    // Which way the popup grows from its anchor.
    //
    // Centred is right for anything near the middle of the bar, but a wide
    // popup hung off a module near the right edge runs off the screen —
    // the notification centre is 400px wide anchored a couple of hundred
    // pixels from the edge, and half of it was simply not on the display.
    // Left gravity keeps its right edge by the anchor and grows inward.
    property bool growLeft: false

    anchor.item: anchorItem
    anchor.rect.y: anchorItem.height + gap
    anchor.rect.x: growLeft ? anchorItem.width : anchorItem.width / 2
    anchor.gravity: growLeft ? (Edges.Bottom | Edges.Left) : Edges.Bottom
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

    // Slightly longer than PopupSurface's longest exit animation, so the
    // window is never pulled out from under a frame still being drawn.
    Timer {
        id: unmap
        interval: 170
        onTriggered: root.visible = false
    }

    // Kept as the callers' entry point rather than having them assign
    // `open` directly, so open/close policy stays in one place.
    function toggle() {
        open = !open;
    }

    PopupSurface {
        id: surface
        anchors.fill: parent
        shown: root.open
    }
}
