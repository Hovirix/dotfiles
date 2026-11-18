import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Notifications
import "helpers.js" as Utils

NotificationServer {
    id: root

    property int lowTimeout: 2000
    property int normalTimeout: 3000
    property int criticalTimeout: 4000
    required property string focusedMonitor
    property string targetMonitor: ""
    required property var apps
    property var arrivalOrder: ({})
    property int sequence: 0
    readonly property var groups: {
        sequence;
        return Utils.groups(trackedNotifications.values, arrivalOrder);
    }
    readonly property int count: trackedNotifications.values.length
    onCountChanged: if (count === 0)
        targetMonitor = ""

    property Instantiator expiry: Instantiator {
        model: root.trackedNotifications

        delegate: Timer {
            id: lifetime
            required property Notification modelData

            interval: Utils.duration(modelData.urgency, root.lowTimeout, root.normalTimeout, root.criticalTimeout)

            function refresh(): void {
                root.arrivalOrder[modelData.id] = root.sequence + 1;
                root.sequence++;
                restart();
            }

            property Timer update: Timer {
                interval: 0
                onTriggered: lifetime.refresh()
            }
            property Connections changes: Connections {
                // shortcut: identical replacements expose no Qt signal and retain expiry; revisit when Quickshell adds one.
                target: lifetime.modelData
                function onSummaryChanged() {
                    lifetime.update.restart();
                }
                function onBodyChanged() {
                    lifetime.update.restart();
                }
                function onAppNameChanged() {
                    lifetime.update.restart();
                }
                function onAppIconChanged() {
                    lifetime.update.restart();
                }
                function onDesktopEntryChanged() {
                    lifetime.update.restart();
                }
                function onImageChanged() {
                    lifetime.update.restart();
                }
                function onUrgencyChanged() {
                    lifetime.update.restart();
                }
                function onExpireTimeoutChanged() {
                    lifetime.update.restart();
                }
                function onHintsChanged() {
                    lifetime.update.restart();
                }
                function onActionsChanged() {
                    lifetime.update.restart();
                }
                function onClosed() {
                    delete root.arrivalOrder[lifetime.modelData.id];
                }
            }

            Component.onCompleted: refresh()
            onTriggered: {
                if (update.running) {
                    update.stop();
                    refresh();
                } else {
                    modelData.expire();
                }
            }
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
            var url = Utils.firstUrl(notification.summary + "\n" + notification.body);
            if (url && Qt.openUrlExternally(url))
                return "activated";
            var entry = DesktopEntries.heuristicLookup(Utils.iconName(notification.desktopEntry) || notification.appName);
            if (entry && apps.focusExisting(entry))
                return "activated";
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
        if (!groups.length)
            return "none";
        return activate(groups[0].notification);
    }

    actionsSupported: true
    bodyMarkupSupported: true
    imageSupported: true
    keepOnReload: false

    onNotification: function (notification) {
        if (count === 0)
            targetMonitor = focusedMonitor;
        // Bound memory even when a sender floods us with critical alerts.
        if (!notification.tracked && count >= 100)
            trackedNotifications.values[0].expire();
        notification.tracked = true;
    }
}
