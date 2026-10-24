pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../.."
import "../../ui" as Ui
import "outputs.js" as Utils

Ui.Panel {
    id: root

    required property var controller
    property bool cursorActive: false
    required property Main display
    property bool editingSetting: false
    property string focusArea: "outputs"
    readonly property int menuHeight: panelColumn.implicitHeight + Theme.dialogPadding * 2

    // Content for the shell's shared popup.
    readonly property int menuWidth: Theme.popupWidthWorkspace
    property int optionIndex: 0
    property int selectedIndex: 0
    readonly property var selectedOutput: selectedIndex >= 0 && selectedIndex < display.outputs.length ? display.outputs[selectedIndex] : null
    property int settingIndex: 0

    function applySetting(): void {
        var options = settingOptions();
        var option = options[optionIndex];
        if (!selectedOutput || option === undefined)
            return;
        if (settingIndex === 0) {
            display.setMode(selectedOutput, option);
        } else if (settingIndex === 1) {
            display.setMode(selectedOutput, `${selectedOutput.resolution}@${option.replace(" Hz", "")}`);
        } else if (settingIndex === 2) {
            display.setScale(selectedOutput, option);
        } else if (settingIndex === 3) {
            display.setTransform(selectedOutput, option);
        } else {
            display.setLayout(selectedOutput, option);
        }
        editingSetting = false;
    }

    function beginSettingEdit(): void {
        var options = settingOptions();
        if (options.length === 0)
            return;
        editingSetting = true;
        optionIndex = Math.max(0, options.indexOf(settingValue(settingIndex)));
    }

    function focusMenu(): void {
        root.selectedIndex = 0;
        root.cursorActive = false;
        root.editingSetting = false;
        root.focusArea = "outputs";
        Qt.callLater(function () {
            keyCatcher.forceActiveFocus();
        });
    }

    function moveCursor(delta: int): void {
        if (display.outputs.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(display.outputs.length - 1, selectedIndex + delta));
    }

    // Keep translated labels out of the values sent to wlr-randr.
    function optionLabel(value: string): string {
        if (value === "Extend right")
            return qsTr("Extend right");
        if (value === "Extend left")
            return qsTr("Extend left");
        if (value === "Mirror")
            return qsTr("Mirror");
        if (value === "Custom")
            return qsTr("Custom");
        if (value === "normal")
            return qsTr("normal");
        return value;
    }

    function settingOptions(): list<string> {
        if (!selectedOutput)
            return [];
        var modes = selectedOutput.modes || [];
        var list = [];
        if (settingIndex === 0) {
            for (var i = 0; i < modes.length; i++) {
                if (list.indexOf(modes[i].resolution) < 0)
                    list.push(modes[i].resolution);
            }
        } else if (settingIndex === 1) {
            for (var j = 0; j < modes.length; j++) {
                if (modes[j].resolution === selectedOutput.resolution && list.indexOf(`${modes[j].refresh} Hz`) < 0)
                    list.push(`${modes[j].refresh} Hz`);
            }
        } else if (settingIndex === 2) {
            list = ["1", "1.25", "1.5", "2"];
        } else if (settingIndex === 3) {
            list = ["normal", "90", "180", "270"];
        } else {
            list = selectedOutput.enabled && display.enabledCount > 1 ? ["Extend right", "Extend left", "Mirror"] : [];
        }
        return list;
    }

    function settingValue(index: int): string {
        if (!selectedOutput)
            return "";
        if (index === 0)
            return selectedOutput.resolution;
        if (index === 1)
            return selectedOutput.refresh;
        if (index === 2)
            return selectedOutput.scale;
        if (index === 3)
            return selectedOutput.transform;
        return Utils.layout(selectedOutput, display.outputs);
    }

    function toggleSelectedOutput(): void {
        if (selectedOutput)
            display.toggleOutput(selectedOutput);
    }

    Ui.Navigation {
        id: keyCatcher

        anchors.fill: parent

        onActivateRequested: {
            if (root.editingSetting)
                root.applySetting();
            else if (root.focusArea === "outputs")
                root.toggleSelectedOutput();
            else
                root.beginSettingEdit();
        }
        onCloseRequested: {
            if (root.editingSetting) {
                root.editingSetting = false;
            } else {
                root.controller.close();
            }
        }
        onMoveRequested: function (dx, dy) {
            if (root.focusArea === "outputs" && dx !== 0) {
                root.cursorActive = true;
                root.toggleSelectedOutput();
            } else if (root.editingSetting && (dx !== 0 || dy !== 0)) {
                var options = root.settingOptions();
                root.optionIndex = Math.max(0, Math.min(options.length - 1, root.optionIndex + (dx !== 0 ? dx : dy)));
            } else if (dy !== 0) {
                root.cursorActive = true;
                if (root.focusArea === "outputs") {
                    root.moveCursor(dy);
                } else {
                    root.settingIndex = Math.max(0, Math.min(4, root.settingIndex + dy));
                }
            }
        }
        onTabRequested: function (direction) {
            if (root.editingSetting)
                return;
            root.focusArea = root.focusArea === "outputs" ? "settings" : "outputs";
            root.cursorActive = true;
        }
        onTextKey: function (text) {
            if (text === "r" || text === "R")
                root.display.refresh();
        }

        Column {
            id: panelColumn

            spacing: Theme.space4
            width: parent.width

            // Hero: glyph · bold title · uppercase status, like audio.
            Item {
                height: implicitHeight
                implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)
                width: parent.width

                Controls.Label {
                    id: heroIcon

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.heroGlyphSize
                    renderType: Text.NativeRendering
                    text: "󰍹"
                }

                Column {
                    id: heroLabels

                    anchors.left: heroIcon.right
                    anchors.leftMargin: Theme.space3
                    anchors.verticalCenter: parent.verticalCenter
                    height: implicitHeight
                    spacing: Theme.space05

                    Controls.Label {
                        font.pixelSize: Theme.fontSizeTitle
                        font.weight: Theme.fontWeightMedium
                        renderType: Text.NativeRendering
                        text: qsTr("Displays")
                    }

                    Controls.Label {
                        color: Theme.mutedForeground
                        font.letterSpacing: 1.2
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: Theme.fontWeightMedium
                        renderType: Text.NativeRendering
                        text: (root.display.loading ? qsTr("Refreshing…") : root.display.outputs.length === 0 ? qsTr("No outputs") : qsTr("%1 of %2 on").arg(root.display.enabledCount).arg(root.display.outputs.length)).toUpperCase()
                    }
                }
            }

            Ui.Separator {
                width: parent.width
            }

            Ui.SectionHeader {
                foreground: Theme.foreground
                text: qsTr("OUTPUTS")
            }

            Controls.Label {
                color: Theme.mutedForeground
                font.pixelSize: Theme.fontSizeBody
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                text: qsTr("No outputs reported by wlr-randr")
                visible: !root.display.loading && root.display.outputs.length === 0
                width: parent.width
            }

            Repeater {
                model: root.display.outputs

                OutputRow {
                    required property int index
                    required property var modelData

                    output: modelData
                    rowIndex: index
                    width: parent.width
                }
            }

            Ui.Separator {
                width: parent.width
            }

            Ui.SectionHeader {
                foreground: Theme.foreground
                text: qsTr("SETTINGS")
            }

            Column {
                spacing: Theme.space05
                width: parent.width

                Repeater {
                    model: 5

                    Column {
                        required property int index
                        readonly property int setting: index

                        spacing: Theme.space05
                        width: parent.width

                        SettingRow {
                            editing: root.editingSetting && root.settingIndex === parent.setting
                            hasCursor: root.cursorActive && root.focusArea === "settings" && root.settingIndex === parent.setting
                            icon: ["󰍹", "󰍺", "󰍽", "󰑖", "󰌟"][parent.setting]
                            label: [qsTr("Resolution"), qsTr("Refresh Rate"), qsTr("Scale"), qsTr("Rotation"), qsTr("Layout")][parent.setting]
                            value: {
                                if (!root.selectedOutput)
                                    return "--";
                                var isEditing = root.editingSetting && root.settingIndex === parent.setting;
                                var option = isEditing ? root.settingOptions()[root.optionIndex] : root.settingValue(parent.setting);
                                if (option === undefined || option === null)
                                    return "";
                                var preview = String(option);
                                if (parent.setting === 0)
                                    return isEditing ? preview.replace("x", " × ") : qsTr("%1 (Current)").arg(preview.replace("x", " × "));
                                if (parent.setting === 2)
                                    return `${Math.round(Number(preview) * 100)}%`;
                                return root.optionLabel(preview);
                            }
                        }

                        OptionMenu {
                            options: visible ? root.settingOptions() : []
                            selected: root.optionIndex
                            title: [qsTr("Resolution"), qsTr("Refresh Rate"), qsTr("Scale"), qsTr("Rotation"), qsTr("Layout")][parent.setting]
                            visible: root.editingSetting && root.settingIndex === parent.setting
                        }
                    }
                }
            }
        }
    }

    // Compact viewport over long mode lists. h/l moves the highlighted value;
    component OptionMenu: Rectangle {
        id: menu

        property var options: []
        property int selected: 0
        readonly property var shownOptions: options.slice(start, start + 6)
        readonly property int start: Math.max(0, Math.min(selected - 2, Math.max(0, options.length - 6)))
        property string title: ""

        border.color: Theme.subtleRing
        border.width: Theme.borderWidth
        color: Theme.popover
        height: shownOptions.length * Theme.rowHeight + Theme.rowHeight + Theme.space1 * 2
        radius: Theme.radius
        width: parent.width - Theme.space2 * 2
        x: Theme.space2

        Column {
            anchors.fill: parent
            anchors.margins: Theme.space1
            spacing: 0

            Item {
                height: Theme.rowHeight
                width: parent.width

                Controls.Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space2
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeBody
                    font.weight: Theme.fontWeightMedium
                    renderType: Text.NativeRendering
                    text: qsTr("Choose %1").arg(menu.title)
                }

                Controls.Label {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.mutedForeground
                    font.pixelSize: Theme.fontSizeBody
                    renderType: Text.NativeRendering
                    text: `${menu.selected + 1}/${menu.options.length}`
                }
            }

            Repeater {
                model: menu.shownOptions

                Ui.MenuRow {
                    id: optionRow

                    required property int index
                    required property string modelData
                    readonly property int optionNumber: menu.start + index

                    contentPadding: 0
                    hasCursor: root.optionIndex === optionNumber
                    height: Theme.rowHeight
                    width: parent.width

                    Controls.Label {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.space3
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.optionIndex === optionRow.optionNumber ? Theme.primary : Theme.foreground
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: root.optionIndex === optionRow.optionNumber ? Theme.fontWeightMedium : Theme.fontWeightNormal
                        renderType: Text.NativeRendering
                        text: root.optionLabel(optionRow.modelData)
                    }

                    Controls.Label {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.space2
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.primary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.iconSize
                        renderType: Text.NativeRendering
                        text: "󰄬"
                        visible: root.optionIndex === optionRow.optionNumber
                    }
                }
            }
        }
    }
    component OutputRow: Ui.MenuRow {
        id: outputRow

        required property var output
        required property int rowIndex

        hasCursor: root.cursorActive && root.selectedIndex === rowIndex
        height: Theme.rowHeightLarge

        Controls.Label {
            id: outputGlyph

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeTitle
            opacity: outputRow.output.enabled ? 1.0 : 0.5
            renderType: Text.NativeRendering
            text: "󰍹"
        }

        Column {
            anchors.left: outputGlyph.right
            anchors.leftMargin: Theme.space2
            anchors.right: outputSwitch.left
            anchors.rightMargin: Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space05

            Controls.Label {
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeBody
                font.weight: root.selectedIndex === outputRow.rowIndex ? Theme.fontWeightMedium : Theme.fontWeightNormal
                opacity: outputRow.output.enabled ? 1.0 : 0.5
                renderType: Text.NativeRendering
                text: outputRow.output.model || outputRow.output.description || outputRow.output.name
                width: parent.width
            }

            Controls.Label {
                color: Theme.mutedForeground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeBody
                renderType: Text.NativeRendering
                text: `${outputRow.output.name} · ${String(outputRow.output.resolution || "").replace("x", " × ")} @
${outputRow.output.refresh || ""}${outputRow.rowIndex === 0 ? " · " + qsTr("Primary") : ""}`
                width: parent.width
            }
        }

        Ui.ToggleIndicator {
            id: outputSwitch

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: outputRow.output.enabled
            hasCursor: outputRow.hasCursor
        }
    }
    component SettingRow: Ui.MenuRow {
        id: settingRow

        property bool editing: false
        required property string icon
        required property string label
        required property string value

        height: Theme.rowHeight
        width: parent.width

        Controls.Label {
            id: settingIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: settingRow.editing ? Theme.primary : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.iconSize
            renderType: Text.NativeRendering
            text: settingRow.icon
        }

        Controls.Label {
            anchors.left: settingIcon.right
            anchors.leftMargin: Theme.space2
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeBody
            renderType: Text.NativeRendering
            text: settingRow.label
        }

        Controls.Label {
            id: settingValue

            anchors.right: settingArrow.left
            anchors.rightMargin: Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            color: settingRow.editing ? Theme.primary : Theme.foreground
            font.pixelSize: Theme.fontSizeBody
            font.weight: Theme.fontWeightMedium
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
            text: settingRow.value
        }

        Controls.Label {
            id: settingArrow

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.iconSize
            renderType: Text.NativeRendering
            text: "󰅂"
        }
    }
}
