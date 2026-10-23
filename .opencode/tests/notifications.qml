// Run: dbus-run-session -- quickshell -p .opencode/tests/notifications.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "file:///home/nixos/.local/share/chezmoi/dot_config/quickshell/features/notifications" as Notifications

ShellRoot {
    id: root

    property Notification first
    property int firstId: 0
    property int sent: 0
    property int step: 0

    function check(value, label) {
        if (!value)
            throw new Error(label);
    }

    function send(summary, actions, resident, replaces, urgency) {
        sender.command = ["busctl", "--user", "call", "--", "org.freedesktop.Notifications", "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "Notify", "susssasa{sv}i", "Native test", String(replaces || 0), "dialog-information", summary, "<b>plain text</b>", String(actions.length)].concat(actions, ["2", "urgency", "y", String(urgency === undefined ? 2 : urgency), "resident", "b", resident ? "true" : "false", "-1"]);
        sender.running = true;
    }

    Notifications.Main {
        id: service

        window.visible: false
    }

    Item {
        Repeater {
            model: service.trackedNotifications

            Notifications.Toast {
                required property Notification modelData

                notification: modelData
                width: 400
            }
        }
    }

    Timer {
        interval: 1
        running: true

        onTriggered: {
            root.check(service.activateNewest() === "none", "empty queue");
            root.send("first", [], false);
        }
    }

    Process {
        id: sender

        stderr: StdioCollector {
            onStreamFinished: if (text)
                console.error(text)
        }

        onExited: function (code) {
            if (code !== 0) {
                console.error("busctl failed", code);
                Qt.exit(1);
                return;
            }
            verify.restart();
        }
    }

    Timer {
        id: verify

        interval: 20

        onTriggered: {
            try {
                var values = service.trackedNotifications.values;
                switch (root.step++) {
                case 0:
                    root.check(values.length === 1 && values[0].body === "<b>plain text</b>", "native delivery");
                    root.check(!service.expiry.objectAt(0).running, "critical notifications persist");
                    root.first = values[0];
                    root.firstId = values[0].id;
                    root.send("second", ["default", "Open"], false);
                    break;
                case 1:
                    root.check(values.length === 2 && values[1].summary === "second", "native insertion ordering");
                    root.check(service.activateNewest() === "activated", "default action");
                    root.check(service.trackedNotifications.values.length === 1, "non-resident action auto-dismisses safely");
                    root.send("resident", ["default", "Open"], true);
                    break;
                case 2:
                    root.check(service.activateNewest() === "activated", "resident action");
                    root.check(service.trackedNotifications.values.length === 1, "resident explicitly dismissed");
                    root.send("replaced", [], false, root.firstId);
                    break;
                case 3:
                    root.check(values.length === 1 && values[0] === root.first && root.first.summary === "replaced", "replacement updates native object");
                    root.check(service.activateNewest() === "dismissed" && service.trackedNotifications.values.length === 0, "no action dismisses");
                    root.send("other action", ["other", "Other"], false);
                    break;
                case 4:
                    root.check(service.activateNewest() === "dismissed", "non-default action ignored");
                    root.send("low urgency", [], false, 0, 0);
                    break;
                case 5:
                    root.check(service.expiry.objectAt(0).running && service.expiry.objectAt(0).interval === 5000, "low urgency expiry timer");

                    service.expiry.objectAt(0).interval = 1;
                    verify.restart();
                    break;
                case 6:
                    root.check(values.length === 0, "native expiry removes notification");
                    root.send("flood", [], false);
                    break;
                case 7:
                    if (++root.sent < 101) {
                        root.step = 7;
                        root.send("flood", [], false);
                        break;
                    }
                    root.check(values.length === 100, "native model queue bounded");
                    while (service.trackedNotifications.values.length)
                        service.trackedNotifications.values[0].dismiss();
                    console.log("Native notification checks passed");
                    Qt.quit();
                    break;
                }
            } catch (error) {
                console.error(error);
                Qt.exit(1);
            }
        }
    }
}
