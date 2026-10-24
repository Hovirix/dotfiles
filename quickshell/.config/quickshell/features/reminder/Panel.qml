import QtQuick
import QtQuick.Controls as Controls
import Quickshell.Io
import "../.."
import "../../ui" as Ui

Ui.Panel {
    id: root

    required property var controller
    property string minutes: ""
    property string error: ""
    readonly property int menuWidth: Theme.popupWidthStandard
    readonly property int menuHeight: fields.implicitHeight + Theme.dialogPadding * 2

    function focusMenu(): void {
        input.forceActiveFocus();
    }

    function submit(): void {
        if (schedule.running)
            return;
        error = "";
        if (!minutes) {
            if (!/^[1-9][0-9]*$/.test(input.text)) {
                error = qsTr("Enter a positive whole number of minutes.");
                return;
            }
            minutes = input.text;
            input.text = "";
        } else if (input.text.trim()) {
            schedule.command = ["hx-reminder", minutes, input.text];
            schedule.running = true;
        }
    }

    Process {
        id: schedule

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.controller.close();
            else
                root.error = qsTr("Could not set reminder. Try again.");
        }
    }

    Column {
        id: fields

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.space3

        Ui.SearchField {
            id: input

            width: parent.width
            enabled: !schedule.running
            onAccepted: root.submit()
            Keys.onEscapePressed: root.controller.close()

            Controls.Label {
                anchors.fill: parent
                text: root.minutes ? qsTr("Reminder message…") : qsTr("Remind in minutes…")
                color: Theme.mutedForeground
                visible: !input.text
                verticalAlignment: Text.AlignVCenter
            }
        }

        Controls.Label {
            text: root.error
            color: Theme.destructive
            visible: root.error !== ""
            width: parent.width
            wrapMode: Text.Wrap
        }
    }
}
