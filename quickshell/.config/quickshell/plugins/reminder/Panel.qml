import QtQuick
import QtQuick.Controls.Basic as Controls
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../ui" as Ui

Ui.Panel {
    id: root

    required property var controller
    property alias minutes: minutesInput.text
    property alias message: messageInput.text
    property bool busy: false
    property string error: ""
    property string validationError: ""
    property string invalidField: ""
    readonly property bool validMinutes: /^[1-9][0-9]*$/.test(minutes.trim())
    readonly property string dueTime: {
        if (!validMinutes)
            return "";
        const due = new Date(clock.date.getTime() + Number(minutes.trim()) * 60000);
        if (!Number.isFinite(due.getTime()))
            return "";
        const format = due.toDateString() === clock.date.toDateString() ? "HH:mm" : "ddd, MMM d · HH:mm";
        return Qt.formatDateTime(due, format);
    }
    title: qsTr("Reminder")
    signal submitted(string minutes, string message)

    function focusMenu(): void {
        Qt.callLater(() => messageInput.forceActiveFocus());
    }

    function submit(): void {
        if (busy)
            return;
        validationError = "";
        invalidField = "";
        if (!validMinutes) {
            validationError = qsTr("Enter a positive whole number of minutes.");
            invalidField = "minutes";
            minutesInput.forceActiveFocus();
        } else if (!message.trim()) {
            validationError = qsTr("Enter a reminder message.");
            invalidField = "message";
            messageInput.forceActiveFocus();
        } else {
            submitted(minutes.trim(), message.trim());
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Keys.priority: Keys.BeforeItem
    Keys.onEscapePressed: event => {
        if (busy)
            return;
        if (messageInput.activeFocus && message)
            message = "";
        else if (minutesInput.activeFocus && minutes)
            minutes = "";
        else
            controller.back();
        event.accepted = true;
    }

    Controls.ScrollView {
        id: formScroll
        anchors.fill: parent
        contentWidth: availableWidth
        contentHeight: Math.max(availableHeight, form.implicitHeight)
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AlwaysOff
        clip: true

        Item {
            width: formScroll.availableWidth
            height: formScroll.contentHeight

            Column {
                id: form
                objectName: "reminderForm"
                anchors.centerIn: parent
                width: Math.min(520, parent.width)
                spacing: Theme.space4

                Ui.TextField {
                    id: messageInput
                    objectName: "reminderMessage"
                    width: parent.width
                    placeholderText: qsTr("What should I remind you about?")
                    enabled: !root.busy
                    invalid: root.invalidField === "message"
                    Accessible.name: qsTr("Reminder message")
                    onAccepted: root.submit()
                    KeyNavigation.tab: minutesInput
                    KeyNavigation.backtab: minutesInput
                }

                RowLayout {
                    objectName: "reminderTiming"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(implicitWidth, parent.width)
                    spacing: Theme.space2

                    Controls.Label {
                        text: qsTr("Remind in")
                    }
                    Ui.TextField {
                        id: minutesInput
                        objectName: "reminderMinutes"
                        Layout.preferredWidth: 64
                        text: "10"
                        placeholderText: qsTr("Minutes")
                        horizontalAlignment: Text.AlignHCenter
                        inputMethodHints: Qt.ImhDigitsOnly
                        enabled: !root.busy
                        invalid: root.invalidField === "minutes"
                        Accessible.name: qsTr("Minutes")
                        onAccepted: root.submit()
                        KeyNavigation.tab: messageInput
                        KeyNavigation.backtab: messageInput
                    }
                    Controls.Label {
                        Layout.fillWidth: true
                        text: Number(root.minutes.trim()) === 1 ? qsTr("minute at %1").arg(root.dueTime || "—") : qsTr("minutes at %1").arg(root.dueTime || "—")
                        color: Theme.mutedForeground
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }

                Controls.Label {
                    width: parent.width
                    text: root.validationError || root.error
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.destructive
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    Accessible.role: Accessible.AlertMessage
                }
                Controls.Label {
                    width: parent.width
                    text: qsTr("Setting reminder…")
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.mutedForeground
                    visible: root.busy
                }
            }
        }
    }
}
