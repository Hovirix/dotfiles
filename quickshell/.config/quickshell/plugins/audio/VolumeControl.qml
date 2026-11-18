import QtQuick
import QtQuick.Controls.Basic as Controls
import "../.."
import "../../ui" as Ui

Item {
    id: root

    required property string label
    required property real value
    property bool muted: false
    property real maximum: 1
    property alias font: valueLabel.font
    property bool editing: false
    readonly property var numberLocale: Qt.locale()
    readonly property string percent: Number(Math.round(value * 100)).toLocaleString(numberLocale, "f", 0)

    implicitWidth: Math.max(76, valueLabel.implicitWidth + Theme.space2 * 2)
    implicitHeight: Theme.menuRowHeight
    Accessible.role: Accessible.Button
    Accessible.name: qsTr("Edit %1 volume").arg(label)
    Accessible.onPressAction: edit()

    signal volumeRequested(real value)
    signal activated
    signal finished

    function edit(): void {
        if (!enabled)
            return;
        editing = true;
        editor.text = percent;
        editor.forceActiveFocus();
        editor.selectAll();
        activated();
    }

    function cancel(): void {
        editing = false;
        finished();
    }

    function request(value: real): void {
        if (!Number.isFinite(value))
            return;
        volumeRequested(Math.max(0, Math.min(maximum, value)));
        editing = false;
        finished();
    }

    function submit(): void {
        if (editor.acceptableInput)
            request(Number.fromLocaleString(numberLocale, editor.text) / 100);
    }

    Controls.Label {
        id: valueLabel
        anchors.fill: parent
        rightPadding: Theme.space2
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: root.muted ? qsTr("%1% · Muted").arg(root.percent) : root.percent + "%"
        color: Theme.mutedForeground
        visible: !root.editing
        MouseArea {
            anchors.fill: parent
            onClicked: root.edit()
        }
    }
    Ui.TextField {
        id: editor
        objectName: "volumePercent"
        anchors.fill: parent
        visible: root.editing
        leftPadding: Theme.space2
        rightPadding: Theme.space2 + Theme.fontSizeBody
        horizontalAlignment: Text.AlignRight
        inputMethodHints: Qt.ImhDigitsOnly
        invalid: activeFocus && !acceptableInput
        validator: IntValidator {
            bottom: 0
            top: Math.round(root.maximum * 100)
            locale: root.numberLocale.name
        }
        Accessible.name: qsTr("%1 volume percent").arg(root.label)
        onActiveFocusChanged: if (!activeFocus)
            root.editing = false
        onAccepted: root.submit()
        Keys.onEscapePressed: root.cancel()
        Keys.onTabPressed: root.submit()
        Keys.onBacktabPressed: root.submit()
        Controls.Label {
            anchors.right: parent.right
            anchors.rightMargin: Theme.space2
            anchors.verticalCenter: parent.verticalCenter
            text: "%"
            color: Theme.mutedForeground
            Accessible.ignored: true
        }
    }
    Binding {
        target: editor
        property: "text"
        value: root.percent
        when: !root.editing
        restoreMode: Binding.RestoreNone
    }
}
