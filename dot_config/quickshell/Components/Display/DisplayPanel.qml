pragma ComponentBehavior: Bound

import QtQuick

import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    required property var controller
    property bool cursorActive: false
    required property Service display
    property bool editingSetting: false
    property string focusArea: "outputs"
    readonly property int menuHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2

    // Content for the shared menu window (see BatteryPanel for the contract).
    readonly property int menuWidth: A.Appearance.popupWidthWorkspace
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
        optionIndex = Math.max(0, options.indexOf(settingCurrentValue()));
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
        if (value === "normal")
            return qsTr("normal");
        return value;
    }

    function settingCurrentValue(): string {
        return settingValue(settingIndex);
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
                if (modes[j].resolution === selectedOutput.resolution)
                    list.push(`${modes[j].refresh} Hz`);
            }
        } else if (settingIndex === 2) {
            list = ["1", "1.25", "1.5", "2"];
        } else if (settingIndex === 3) {
            list = ["normal", "90", "180", "270"];
        } else {
            list = ["Extend right", "Extend left", "Mirror"];
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
        return selectedOutput.position === "0,0" ? "Mirror" : "Extend right";
    }

    function toggleSelectedOutput(): void {
        if (selectedOutput)
            display.toggleOutput(selectedOutput);
    }

    Ui.KeyCatcher {
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
                if (root.editingSetting) {
                    root.editingSetting = false;
                } else if (root.focusArea === "outputs") {
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

            spacing: A.Appearance.space4
            width: parent.width

            // Hero: glyph · bold title · uppercase status, like audio.
            Item {
                height: implicitHeight
                implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)
                width: parent.width

                Text {
                    id: heroIcon

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.foreground
                    font.family: A.Appearance.iconFontFamily
                    font.pixelSize: A.Appearance.heroGlyphSize
                    renderType: Text.NativeRendering
                    text: "󰍹"
                }

                Column {
                    id: heroLabels

                    anchors.left: heroIcon.right
                    anchors.leftMargin: A.Appearance.space3
                    anchors.verticalCenter: parent.verticalCenter
                    height: implicitHeight
                    spacing: A.Appearance.space05

                    Text {
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                        text: qsTr("Displays")
                    }

                    Text {
                        color: A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.letterSpacing: 1.2
                        font.pixelSize: A.Appearance.fontSizeBody
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                        text: (root.display.loading ? qsTr("Refreshing…") : root.display.outputs.length === 0 ? qsTr("No outputs") : qsTr("%1 of %2 on").arg(root.display.enabledCount).arg(root.display.outputs.length)).toUpperCase()
                    }
                }
            }

            Ui.Separator {
                width: parent.width
            }

            Ui.SectionHeader {
                foreground: A.Appearance.foreground
                text: qsTr("OUTPUTS")
            }

            Text {
                color: A.Appearance.mutedForeground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
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
                foreground: A.Appearance.foreground
                text: qsTr("SETTINGS")
            }

            Column {
                spacing: A.Appearance.space05
                width: parent.width

                Repeater {
                    model: 5

                    Column {
                        required property int index
                        readonly property int setting: index

                        spacing: A.Appearance.space05
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
    // clicking a value applies it immediately.
    component OptionMenu: Rectangle {
        id: menu

        property var options: []
        property int selected: 0
        readonly property var shownOptions: options.slice(start, start + 6)
        readonly property int start: Math.max(0, Math.min(selected - 2, Math.max(0, options.length - 6)))
        property string title: ""

        border.color: A.Appearance.subtleRing
        border.width: A.Appearance.borderWidth
        color: A.Appearance.popover
        height: shownOptions.length * A.Appearance.rowHeight + A.Appearance.rowHeight + A.Appearance.space1 * 2
        radius: A.Appearance.radius
        width: parent.width - A.Appearance.space2 * 2
        x: A.Appearance.space2

        Column {
            anchors.fill: parent
            anchors.margins: A.Appearance.space1
            spacing: 0

            Item {
                height: A.Appearance.rowHeight
                width: parent.width

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                    text: qsTr("Choose %1").arg(menu.title)
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    renderType: Text.NativeRendering
                    text: `${menu.selected + 1}/${menu.options.length}`
                }
            }

            Repeater {
                model: menu.shownOptions

                Ui.SelectRow {
                    id: optionRow

                    required property int index
                    required property string modelData
                    readonly property int optionNumber: menu.start + index

                    contentPadding: 0
                    hasCursor: root.optionIndex === optionNumber
                    height: A.Appearance.rowHeight
                    width: parent.width

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: A.Appearance.space3
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.optionIndex === optionRow.optionNumber ? A.Appearance.primary : A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        font.weight: root.optionIndex === optionRow.optionNumber ? A.Appearance.fontWeightMedium : A.Appearance.fontWeightNormal
                        renderType: Text.NativeRendering
                        text: root.optionLabel(optionRow.modelData)
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: A.Appearance.space2
                        anchors.verticalCenter: parent.verticalCenter
                        color: A.Appearance.primary
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: A.Appearance.iconSize
                        renderType: Text.NativeRendering
                        text: "󰄬"
                        visible: root.optionIndex === optionRow.optionNumber
                    }

                    TapHandler {
                        onTapped: {
                            root.optionIndex = optionRow.optionNumber;
                            root.applySetting();
                        }
                    }
                }
            }
        }
    }
    component OutputRow: Ui.SelectRow {
        id: outputRow

        required property var output
        required property int rowIndex

        hasCursor: root.cursorActive && root.selectedIndex === rowIndex
        height: A.Appearance.rowHeightLarge

        Text {
            id: outputGlyph

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: A.Appearance.foreground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.fontSizeTitle
            opacity: outputRow.output.enabled ? 1.0 : 0.5
            renderType: Text.NativeRendering
            text: "󰍹"
        }

        Column {
            anchors.left: outputGlyph.right
            anchors.leftMargin: A.Appearance.space2
            anchors.right: outputSwitch.left
            anchors.rightMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            spacing: A.Appearance.space05

            Text {
                color: A.Appearance.foreground
                elide: Text.ElideRight
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                font.weight: root.selectedIndex === outputRow.rowIndex ? A.Appearance.fontWeightMedium : A.Appearance.fontWeightNormal
                opacity: outputRow.output.enabled ? 1.0 : 0.5
                renderType: Text.NativeRendering
                text: outputRow.output.model || outputRow.output.description || outputRow.output.name
                width: parent.width
            }

            Text {
                color: A.Appearance.mutedForeground
                elide: Text.ElideRight
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                renderType: Text.NativeRendering
                text: `${outputRow.output.name} · ${String(outputRow.output.resolution || "").replace("x", " × ")} @ ${outputRow.output.refresh || ""}${outputRow.rowIndex === 0 ? " · " + qsTr("Primary") : ""}`
                width: parent.width
            }
        }

        Ui.Switch {
            id: outputSwitch

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: outputRow.output.enabled
            hasCursor: outputRow.hasCursor

            onHovered: function (on) {
                if (on) {
                    root.cursorActive = true;
                    root.selectedIndex = outputRow.rowIndex;
                }
            }
            onToggled: root.display.toggleOutput(outputRow.output)
        }

        HoverHandler {
            onHoveredChanged: if (hovered) {
                root.cursorActive = true;
                root.selectedIndex = outputRow.rowIndex;
            }
        }
    }
    component SettingRow: Ui.SelectRow {
        id: settingRow

        property bool editing: false
        required property string icon
        required property string label
        required property string value

        height: A.Appearance.rowHeight
        width: parent.width

        Text {
            id: settingIcon

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: settingRow.editing ? A.Appearance.primary : A.Appearance.mutedForeground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.iconSize
            renderType: Text.NativeRendering
            text: settingRow.icon
        }

        Text {
            anchors.left: settingIcon.right
            anchors.leftMargin: A.Appearance.space2
            anchors.verticalCenter: parent.verticalCenter
            color: A.Appearance.foreground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.fontSizeBody
            renderType: Text.NativeRendering
            text: settingRow.label
        }

        Text {
            id: settingValue

            anchors.right: settingArrow.left
            anchors.rightMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            color: settingRow.editing ? A.Appearance.primary : A.Appearance.foreground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.fontSizeBody
            font.weight: A.Appearance.fontWeightMedium
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
            text: settingRow.value
        }

        Text {
            id: settingArrow

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: A.Appearance.mutedForeground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.iconSize
            renderType: Text.NativeRendering
            text: "󰅂"
        }
    }
}
