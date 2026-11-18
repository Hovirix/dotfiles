pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import "../.."
import "../../ui" as Ui
import "outputs.js" as Utils

Ui.Panel {
    id: root

    required property var controller
    required property var display
    title: qsTr("Displays")
    property string selectedName: ""
    readonly property var selectedOutput: display.outputs.find(output => output.name === selectedName) || display.outputs[0] || null
    readonly property int selectedIndex: display.outputs.indexOf(selectedOutput)
    property string focusArea: "outputs"
    property int settingIndex: 0
    property bool editingSetting: false
    property bool applySelected: true
    property int optionIndex: 0
    readonly property var options: Utils.settingOptions(selectedOutput, settingIndex, display.enabledCount)
    readonly property var labels: [qsTr("Resolution"), qsTr("Refresh rate"), qsTr("Scale"), qsTr("Rotation"), qsTr("Position")]
    readonly property bool canToggle: !!selectedOutput && !display.loading && !display.pending && (!selectedOutput.enabled || display.enabledCount > 1)

    function focusMenu(): void {
        Qt.callLater(() => keys.forceActiveFocus());
    }

    function back(): void {
        if (display.pending)
            display.revert();
        else if (editingSetting)
            editingSetting = false;
        else
            controller.back();
    }

    function activate(): void {
        if (display.pending) {
            if (applySelected)
                display.keep();
            else
                display.revert();
        } else if (editingSetting) {
            if (applySelected)
                applySetting();
            else
                back();
        } else if (focusArea === "outputs") {
            focusArea = "settings";
        } else if (settingIndex === -1) {
            toggleOutput();
        } else {
            beginSettingEdit(settingIndex);
        }
    }

    function tab(): void {
        if (editingSetting || display.pending)
            applySelected = !applySelected;
        else
            focusArea = focusArea === "outputs" ? "settings" : "outputs";
    }

    function selectOutput(index: int): void {
        if (index < 0 || index >= display.outputs.length)
            return;
        editingSetting = false;
        selectedName = display.outputs[index].name;
        focusArea = "outputs";
        outputs.positionViewAtIndex(index, ListView.Contain);
    }

    function beginSettingEdit(index: int): void {
        if (!selectedOutput || !selectedOutput.enabled || display.loading || display.pending || !Utils.settingOptions(selectedOutput, index, display.enabledCount).length)
            return;
        settingIndex = index;
        focusArea = "settings";
        optionIndex = Math.max(0, options.indexOf(Utils.settingValue(selectedOutput, index, display.outputs)));
        editingSetting = true;
        applySelected = true;
        Qt.callLater(() => settings.positionViewAtIndex(index, ListView.Contain));
    }

    function moveOption(delta: int): void {
        optionIndex = Math.max(0, Math.min(options.length - 1, optionIndex + delta));
    }

    function applySetting(): void {
        var option = options[optionIndex];
        if (!editingSetting || !selectedOutput || display.loading || option === undefined)
            return;
        if (settingIndex === 0)
            display.setMode(selectedOutput, option);
        else if (settingIndex === 1)
            display.setMode(selectedOutput, `${selectedOutput.resolution}@${option.replace(" Hz", "")}`);
        else if (settingIndex === 2)
            display.setScale(selectedOutput, option);
        else if (settingIndex === 3)
            display.setTransform(selectedOutput, option);
        else
            display.setLayout(selectedOutput, option);
        editingSetting = false;
    }

    function toggleOutput(): void {
        if (canToggle)
            display.toggleOutput(selectedOutput);
    }

    function valueLabel(value: string, index: int): string {
        if (!value)
            return "—";
        if (index === 0)
            return value.replace("x", " × ");
        if (index === 2)
            return `${Math.round(Number(value) * 100)}%`;
        if (index === 3)
            return value === "normal" ? "0°" : value + "°";
        if (index === 4)
            return Utils.layoutLabel(value, selectedOutput, display.outputs);
        return value;
    }

    onSelectedOutputChanged: editingSetting = false
    onSettingIndexChanged: if (settingIndex >= 0)
        settings.positionViewAtIndex(settingIndex, ListView.Contain)
    Connections {
        target: root.display
        function onPendingChanged(): void {
            root.editingSetting = false;
            root.applySelected = false;
        }
    }

    Ui.Navigation {
        id: keys
        anchors.fill: parent
        onCloseRequested: root.back()
        onActivateRequested: root.activate()
        onMoveRequested: (dx, dy) => {
            if (root.display.pending)
                root.applySelected = dx > 0 || dy > 0 ? false : true;
            else if (root.editingSetting)
                root.moveOption(dx || dy);
            else if (dy && root.focusArea === "outputs")
                root.selectOutput(Math.max(0, Math.min(root.display.outputs.length - 1, root.selectedIndex + dy)));
            else if (dy)
                root.settingIndex = Math.max(-1, Math.min(4, root.settingIndex + dy));
            else if (dx)
                root.focusArea = dx > 0 ? "settings" : "outputs";
        }
        onTabRequested: root.tab()
        onTextKey: text => {
            if (!root.editingSetting && text.toLowerCase() === "r")
                root.display.refresh();
            else if (!root.editingSetting && text.toLowerCase() === "m")
                root.toggleOutput();
        }

        Column {
            anchors.fill: parent
            spacing: Theme.space3

            Row {
                width: parent.width
                height: Math.max(0, parent.height - (confirmation.visible ? confirmation.implicitHeight + Theme.space3 : 0))
                spacing: Theme.space3

                ListView {
                    id: outputs
                    width: Math.min(208, parent.width * 0.34)
                    height: parent.height
                    clip: true
                    spacing: Theme.space1
                    model: root.display.outputs
                    Controls.Label {
                        anchors.centerIn: parent
                        text: root.display.loading ? qsTr("Updating displays…") : qsTr("No displays detected")
                        color: Theme.mutedForeground
                        visible: !root.display.outputs.length
                    }
                    delegate: Ui.CursorSurface {
                        id: outputRow
                        required property int index
                        required property var modelData
                        width: outputs.width
                        height: 68
                        hasCursor: root.selectedIndex === index

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.space2
                            spacing: Theme.space1
                            Controls.Label {
                                width: parent.width
                                text: Utils.displayName(outputRow.modelData)
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                font.weight: Theme.fontWeightMedium
                            }
                            Controls.Label {
                                width: parent.width
                                text: outputRow.modelData.name + " · " + (outputRow.modelData.enabled ? qsTr("On") : qsTr("Off"))
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                color: Theme.mutedForeground
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectOutput(outputRow.index)
                        }
                    }
                }

                Rectangle {
                    width: Theme.borderWidth
                    height: parent.height
                    color: Theme.border
                }

                Column {
                    width: parent.width - outputs.width - Theme.borderWidth - Theme.space3 * 2
                    height: parent.height
                    spacing: Theme.space2
                    visible: !!root.selectedOutput

                    Item {
                        width: parent.width
                        height: Theme.menuRowHeight
                        Column {
                            anchors.left: parent.left
                            anchors.right: displaySwitch.left
                            anchors.rightMargin: Theme.space3
                            spacing: Theme.space1
                            Controls.Label {
                                width: parent.width
                                text: Utils.displayName(root.selectedOutput)
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                font.weight: Theme.fontWeightMedium
                            }
                            Controls.Label {
                                width: parent.width
                                text: root.selectedOutput ? root.selectedOutput.name : ""
                                textFormat: Text.PlainText
                                color: Theme.mutedForeground
                                font.pixelSize: Theme.fontSizeBodySmall
                            }
                        }
                        Ui.ToggleIndicator {
                            id: displaySwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: !!root.selectedOutput && root.selectedOutput.enabled
                            hasCursor: root.focusArea === "settings" && root.settingIndex === -1
                            Accessible.name: qsTr("Display enabled")
                            Accessible.description: !root.canToggle && root.selectedOutput && root.selectedOutput.enabled ? qsTr("At least one display must remain enabled") : ""
                            enabled: root.canToggle
                            onClicked: root.toggleOutput()
                        }
                    }

                    ListView {
                        id: settings
                        width: parent.width
                        height: Math.max(0, parent.height - Theme.menuRowHeight - Theme.space2)
                        clip: true
                        model: 5
                        spacing: Theme.space1
                        delegate: Ui.CursorSurface {
                            id: settingRow
                            required property int index
                            readonly property int setting: index
                            readonly property bool editing: root.editingSetting && root.settingIndex === setting
                            readonly property bool editable: !!root.selectedOutput && root.selectedOutput.enabled && !root.display.loading && !root.display.pending && Utils.settingOptions(root.selectedOutput, setting, root.display.enabledCount).length > 0
                            width: settings.width
                            height: editing ? Theme.menuRowHeight * 2 + Theme.space1 : Theme.menuRowHeight
                            hasCursor: root.focusArea === "settings" && root.settingIndex === setting
                            Accessible.role: Accessible.Button
                            Accessible.name: root.labels[setting]
                            Accessible.onPressAction: root.beginSettingEdit(settingRow.setting)

                            HoverHandler {
                                id: rowHover
                                enabled: settingRow.editable
                                cursorShape: Qt.PointingHandCursor
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.focusArea = "settings";
                                    root.settingIndex = settingRow.setting;
                                    root.beginSettingEdit(settingRow.setting);
                                }
                            }
                            Controls.Label {
                                id: settingLabel
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.space2
                                y: (Theme.menuRowHeight - height) / 2
                                width: 112
                                text: root.labels[settingRow.setting]
                                elide: Text.ElideRight
                            }
                            Controls.Label {
                                anchors.left: settingLabel.right
                                anchors.leftMargin: Theme.space1
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.space2
                                y: (Theme.menuRowHeight - height) / 2
                                elide: Text.ElideRight
                                visible: !settingRow.editing
                                horizontalAlignment: Text.AlignRight
                                text: root.valueLabel(String(Utils.settingValue(root.selectedOutput, settingRow.setting, root.display.outputs)), settingRow.setting)
                                color: Theme.mutedForeground
                            }
                            Controls.ComboBox {
                                id: optionPicker
                                objectName: "displayOption"
                                anchors.left: settingLabel.right
                                anchors.leftMargin: Theme.space1
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.space2
                                height: Theme.menuRowHeight
                                visible: settingRow.editing
                                focusPolicy: Qt.NoFocus
                                model: settingRow.editing ? root.options : []
                                currentIndex: root.optionIndex
                                displayText: root.valueLabel(currentText, settingRow.setting)
                                onActivated: index => root.optionIndex = index
                                Accessible.name: root.labels[settingRow.setting]
                                Accessible.description: qsTr("Use left and right to choose a value")
                                contentItem: Controls.Label {
                                    text: optionPicker.displayText
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                    rightPadding: optionPicker.indicator.width + Theme.space2
                                    leftPadding: Theme.space2
                                }
                                background: Rectangle {
                                    color: Theme.normalFill
                                    border.width: Theme.borderWidth
                                    border.color: Theme.primary
                                }
                            }
                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.space1
                                y: Theme.menuRowHeight + Theme.space1
                                visible: settingRow.editing
                                spacing: Theme.space1
                                Ui.IconButton {
                                    source: Qt.resolvedUrl("../../ui/icons/chevron-left.svg")
                                    label: qsTr("Previous value")
                                    enabled: root.optionIndex > 0 && !root.display.loading
                                    onClicked: root.moveOption(-1)
                                }
                                Ui.IconButton {
                                    source: Qt.resolvedUrl("../../ui/icons/chevron-right.svg")
                                    label: qsTr("Next value")
                                    enabled: root.optionIndex < root.options.length - 1 && !root.display.loading
                                    onClicked: root.moveOption(1)
                                }
                                Ui.Button {
                                    text: qsTr("Apply")
                                    primary: root.applySelected
                                    flat: !primary
                                    Accessible.name: qsTr("Apply %1").arg(root.labels[settingRow.setting] || "")
                                    enabled: !root.display.loading
                                    onClicked: root.applySetting()
                                }
                                Ui.Button {
                                    text: qsTr("Revert")
                                    primary: !root.applySelected
                                    flat: !primary
                                    onClicked: root.back()
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: confirmation
                width: parent.width
                spacing: Theme.space2
                visible: root.display.pending || !!root.display.error
                Controls.Label {
                    width: parent.width
                    text: root.display.error || qsTr("Keep these settings? Reverting in %1 seconds.").arg(root.display.secondsRemaining)
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: root.display.error ? Theme.destructive : Theme.mutedForeground
                }
                Row {
                    anchors.right: parent.right
                    spacing: Theme.space2
                    visible: root.display.pending
                    Ui.Button {
                        text: qsTr("Keep")
                        primary: root.applySelected
                        flat: !primary
                        enabled: !root.display.loading
                        onClicked: root.display.keep()
                    }
                    Ui.Button {
                        text: qsTr("Revert")
                        primary: !root.applySelected
                        flat: !primary
                        enabled: !root.display.loading
                        onClicked: root.display.revert()
                    }
                }
            }
        }
    }
}
