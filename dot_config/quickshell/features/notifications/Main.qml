import QtQuick
import QtQml.Models
import Quickshell.Services.Notifications

NotificationServer {
    id: root

    property Instantiator expiry: Instantiator {
        model: root.trackedNotifications

        delegate: Timer {
            required property Notification modelData

            // shortcut: replacements keep their original expiry; add signal restarts if needed.
            interval: Math.min(30000, Math.max(modelData.urgency === NotificationUrgency.Low ? 5000 : 8000, modelData.expireTimeout * 1000))
            running: modelData.urgency !== NotificationUrgency.Critical

            onTriggered: modelData.expire()
        }
    }
    property Panel window: Panel {
        notifications: root
    }

    function activate(notification: Notification): string {
        var action = notification.actions.find(function (action) {
            return action.identifier === "default";
        });
        try {
            if (action) {
                action.invoke();
                return "activated";
            }
            return "dismissed";
        } catch (error) {
            console.warn("Could not activate notification:", error);
            return "dismissed";
        } finally {
            if (trackedNotifications.indexOf(notification) >= 0)
                notification.dismiss();
        }
    }

    function activateNewest(): string {
        var values = trackedNotifications.values;
        return values.length ? activate(values[values.length - 1]) : "none";
    }

    actionsSupported: true
    keepOnReload: false

    onNotification: function (notification) {
        // Bound memory even when a sender floods us with critical alerts.
        if (trackedNotifications.values.length >= 100)
            trackedNotifications.values[0].expire();
        notification.tracked = true;
    }
}
