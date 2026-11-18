import QtQuick
import Quickshell
import Quickshell.Io
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    property string error: ""
    readonly property var actions: [
        {
            id: "reminder",
            label: qsTr("Reminder"),
            icon: "󰃭",
            run: () => {
                root.error = "";
                popup.open(panel);
            }
        }
    ]
    readonly property Component panel: Component {
        Panel {
            controller: root.popup
            busy: schedule.running
            error: root.error
            onSubmitted: (minutes, message) => {
                root.error = "";
                schedule.exec(["hx-reminder", minutes, message]);
            }
        }
    }

    Process {
        id: schedule
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                if (root.popup.content === root.panel)
                    root.popup.close();
            } else {
                root.error = qsTr("Could not set reminder. Try again.");
            }
        }
    }
}
