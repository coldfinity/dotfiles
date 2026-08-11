pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

// The notification daemon, replacing mako.
//
// mako worked and was themed to match, but it could only ever draw a static
// box: no history, no actions, no interaction. A notification you missed was
// gone permanently, which is the actual problem — the styling was already
// fine.
//
// ONLY ONE DAEMON CAN EXIST. org.freedesktop.Notifications is a single
// well-known bus name, so this and mako cannot both run; `exec-once = mako`
// is removed from hyprland.conf. If this server ever fails to start, nothing
// implements the interface and every notification on the system is silently
// discarded — which is exactly the state the machine was in before mako was
// added in the first place.
Singleton {
    id: root

    // Newest first, which is the order a list should be read in.
    property var history: []

    readonly property int unread: {
        let n = 0;
        for (var i = 0; i < history.length; i++) {
            if (!history[i].seen)
                n++;
        }
        return n;
    }

    // Live notifications, still on screen as toasts.
    readonly property var active: server.trackedNotifications

    function markAllSeen() {
        const copy = history.slice();
        for (var i = 0; i < copy.length; i++)
            copy[i].seen = true;
        history = copy;
    }

    function clearHistory() {
        history = [];
    }

    NotificationServer {
        id: server

        // Advertised capabilities. These are not decoration — an
        // application asks what the daemon supports and adjusts what it
        // sends, so claiming actions here is what makes a client attach
        // buttons rather than flattening them into the body text.
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        // Notifications survive a shell reload rather than vanishing when
        // the config is edited.
        keepOnReload: true

        onNotification: notification => {
            // Without this the server drops it immediately — tracking is
            // opt-in, and an untracked notification never reaches
            // trackedNotifications at all.
            notification.tracked = true;

            // A plain object rather than a reference to the Notification.
            // The originals are destroyed when dismissed, and a history
            // list holding freed objects is a crash waiting to happen.
            const entry = {
                summary: notification.summary || "",
                body: notification.body || "",
                appName: notification.appName || "",
                image: notification.image || "",
                urgency: notification.urgency,
                time: new Date(),
                seen: false
            };

            const next = [entry].concat(root.history);
            // Capped. History is for "what did I miss", not an archive, and
            // an unbounded list grows for as long as the shell runs.
            root.history = next.slice(0, 50);
        }
    }
}
