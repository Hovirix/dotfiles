import QtQuick

import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    required property var controller
    required property Service display

    property int selectedIndex: 0
    property bool cursorActive: false
    property string focusArea: "outputs"
    property int settingIndex: 0
    property bool editingSetting: false
    property int optionIndex: 0
    readonly property var selectedOutput: selectedIndex >= 0 && selectedIndex < display.outputs.length
        ? display.outputs[selectedIndex] : null

    function open() {
        controller.toggle("display")
        if (controller.current === "display")
            display.refresh()
    }

    function moveCursor(delta) {
        if (display.outputs.length === 0)
            return
        selectedIndex = Math.max(0, Math.min(display.outputs.length - 1, selectedIndex + delta))
    }

    function toggleSelectedOutput() {
        if (selectedOutput)
            display.toggleOutput(selectedOutput)
    }

    function settingOptions() {
        if (!selectedOutput)
            return []
        var modes = selectedOutput.modes || []
        var list = []
        if (settingIndex === 0) {
            for (var i = 0; i < modes.length; i++) {
                if (list.indexOf(modes[i].resolution) < 0)
                    list.push(modes[i].resolution)
            }
        } else if (settingIndex === 1) {
            for (var j = 0; j < modes.length; j++) {
                if (modes[j].resolution === selectedOutput.resolution)
                    list.push(`${modes[j].refresh} Hz`)
            }
        } else if (settingIndex === 2) {
            list = ["1", "1.25", "1.5", "2"]
        } else if (settingIndex === 3) {
            list = ["normal", "90", "180", "270"]
        } else {
            list = ["Extend right", "Extend left", "Mirror"]
        }
        return list
    }

    function beginSettingEdit() {
        var options = settingOptions()
        if (options.length === 0)
            return
        editingSetting = true
        optionIndex = Math.max(0, options.indexOf(settingCurrentValue()))
    }

    function settingCurrentValue() {
        return settingValue(settingIndex)
    }

    function settingValue(index) {
        if (!selectedOutput)
            return ""
        if (index === 0) return selectedOutput.resolution
        if (index === 1) return selectedOutput.refresh
        if (index === 2) return selectedOutput.scale
        if (index === 3) return selectedOutput.transform
        return selectedOutput.position === "0,0" ? "Mirror" : "Extend right"
    }

    function applySetting() {
        var options = settingOptions()
        var option = options[optionIndex]
        if (!selectedOutput || option === undefined)
            return
        if (settingIndex === 0) {
            display.setMode(selectedOutput, option)
        } else if (settingIndex === 1) {
            display.setMode(selectedOutput,
                            `${selectedOutput.resolution}@${option.replace(" Hz", "")}`)
        } else if (settingIndex === 2) {
            display.setScale(selectedOutput, option)
        } else if (settingIndex === 3) {
            display.setTransform(selectedOutput, option)
        } else {
            display.setLayout(selectedOutput, option)
        }
        editingSetting = false
    }

    component SettingRow: Ui.SelectRow {
        id: settingRow
        required property string icon
        required property string label
        required property string value
        property bool editing: false

        width: parent.width
        height: A.Appearance.rowHeight

        Text {
            id: settingIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: settingRow.icon
            color: settingRow.editing ? A.Appearance.primary : A.Appearance.mutedForeground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.iconSize
            renderType: Text.NativeRendering
        }
        Text {
            anchors.left: settingIcon.right
            anchors.leftMargin: A.Appearance.space2
            anchors.verticalCenter: parent.verticalCenter
            text: settingRow.label
            color: A.Appearance.foreground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.fontSizeBody
            renderType: Text.NativeRendering
        }
        Text {
            id: settingValue
            anchors.right: settingArrow.left
            anchors.rightMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
                            text: settingRow.value
                            color: settingRow.editing ? A.Appearance.primary : A.Appearance.foreground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            font.weight: A.Appearance.fontWeightMedium
                            horizontalAlignment: Text.AlignRight
                            renderType: Text.NativeRendering
        }
        Text {
            id: settingArrow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅂"
            color: A.Appearance.mutedForeground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.iconSize
            renderType: Text.NativeRendering
        }
    }

    // Compact viewport over long mode lists. h/l moves the highlighted value;
    // clicking a value applies it immediately.
    component OptionMenu: Rectangle {
        id: menu
        property string title: ""
        property var options: []
        property int selected: 0
        readonly property int start: Math.max(0, Math.min(selected - 2,
            Math.max(0, options.length - 6)))
        readonly property var shownOptions: options.slice(start, start + 6)

        width: parent.width - A.Appearance.space2 * 2
        x: A.Appearance.space2
        height: shownOptions.length * A.Appearance.rowHeight + A.Appearance.rowHeight + A.Appearance.space1 * 2
        color: A.Appearance.popover
        border.width: A.Appearance.borderWidth
        border.color: A.Appearance.subtleRing
        radius: A.Appearance.radius

        Column {
            anchors.fill: parent
            anchors.margins: A.Appearance.space1
            spacing: 0

            Item {
                width: parent.width
                height: A.Appearance.rowHeight

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    text: `Choose ${menu.title}`
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${menu.selected + 1}/${menu.options.length}`
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    renderType: Text.NativeRendering
                }
            }

            Repeater {
                model: parent.parent.shownOptions

                Item {
                    required property string modelData
                    required property int index
                    readonly property int optionNumber: parent.parent.start + index

                    width: parent.width
                    height: A.Appearance.rowHeight

                    Rectangle {
                        anchors.fill: parent
                        color: root.optionIndex === optionNumber
                            ? Qt.rgba(A.Appearance.selection.r, A.Appearance.selection.g, A.Appearance.selection.b, 0.3) : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: A.Appearance.durationFast }
                        }
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: A.Appearance.space3
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: root.optionIndex === optionNumber
                            ? A.Appearance.primary : A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        font.weight: root.optionIndex === optionNumber
                            ? A.Appearance.fontWeightMedium : A.Appearance.fontWeightNormal
                        renderType: Text.NativeRendering
                    }
                    Text {
                        visible: root.optionIndex === optionNumber
                        anchors.right: parent.right
                        anchors.rightMargin: A.Appearance.space2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰄬"
                        color: A.Appearance.primary
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: A.Appearance.iconSize
                        renderType: Text.NativeRendering
                    }
                    TapHandler {
                        onTapped: {
                            root.optionIndex = optionNumber
                            root.applySetting()
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

        height: A.Appearance.rowHeightLarge
        hasCursor: root.cursorActive && root.selectedIndex === rowIndex

        Text {
            id: outputGlyph
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍹"
            color: A.Appearance.foreground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.fontSizeTitle
            renderType: Text.NativeRendering
            opacity: outputRow.output.enabled ? 1.0 : 0.5
        }

        Column {
            anchors.left: outputGlyph.right
            anchors.leftMargin: A.Appearance.space2
            anchors.right: outputSwitch.left
            anchors.rightMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            spacing: A.Appearance.space05

            Text {
                width: parent.width
                text: outputRow.output.model || outputRow.output.description || outputRow.output.name
                color: A.Appearance.foreground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                font.weight: root.selectedIndex === outputRow.rowIndex
                    ? A.Appearance.fontWeightMedium : A.Appearance.fontWeightNormal
                elide: Text.ElideRight
                renderType: Text.NativeRendering
                opacity: outputRow.output.enabled ? 1.0 : 0.5
            }
            Text {
                width: parent.width
                text: `${outputRow.output.name} · ${String(outputRow.output.resolution || "").replace("x", " × ")} @ ${outputRow.output.refresh || ""}${outputRow.rowIndex === 0 ? " · Primary" : ""}`
                color: A.Appearance.mutedForeground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        Ui.Switch {
            id: outputSwitch
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: outputRow.output.enabled
            hasCursor: outputRow.hasCursor
            onHovered: function(on) {
                if (on) {
                    root.cursorActive = true
                    root.selectedIndex = outputRow.rowIndex
                }
            }
            onToggled: root.display.toggleOutput(outputRow.output)
        }

        HoverHandler {
            onHoveredChanged: if (hovered) {
                root.cursorActive = true
                root.selectedIndex = outputRow.rowIndex
            }
        }
    }

    Ui.Popup {
        shown: root.controller.current === "display"
        contentWidth: A.Appearance.popupWidthWorkspace
        contentHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()
        onVisibleChanged: if (visible) {
            root.selectedIndex = 0
            root.cursorActive = false
            root.editingSetting = false
            root.focusArea = "outputs"
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
        }

        Ui.KeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onMoveRequested: function(dx, dy) {
                if (root.focusArea === "outputs" && dx !== 0) {
                    root.cursorActive = true
                    root.toggleSelectedOutput()
                } else if (root.editingSetting && (dx !== 0 || dy !== 0)) {
                    var options = root.settingOptions()
                    root.optionIndex = Math.max(0, Math.min(options.length - 1,
                        root.optionIndex + (dx !== 0 ? dx : dy)))
                } else if (dy !== 0) {
                    root.cursorActive = true
                    if (root.editingSetting) {
                        root.editingSetting = false
                    } else if (root.focusArea === "outputs") {
                        root.moveCursor(dy)
                    } else {
                        root.settingIndex = Math.max(0, Math.min(4, root.settingIndex + dy))
                    }
                }
            }
            onActivateRequested: {
                if (root.editingSetting)
                    root.applySetting()
                else if (root.focusArea === "outputs")
                    root.toggleSelectedOutput()
                else
                    root.beginSettingEdit()
            }
            onCloseRequested: {
                if (root.editingSetting) {
                    root.editingSetting = false
                } else {
                    root.controller.close()
                }
            }
            onTabRequested: function(direction) {
                if (root.editingSetting)
                    return
                root.focusArea = root.focusArea === "outputs" ? "settings" : "outputs"
                root.cursorActive = true
            }
            onTextKey: function(text) {
                if (text === "r" || text === "R")
                    root.display.refresh()
            }

            Column {
                id: panelColumn
                width: parent.width
                spacing: A.Appearance.space4

                // Hero: glyph · bold title · uppercase status, like audio.
                Item {
                    width: parent.width
                    implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)
                    height: implicitHeight

                    Text {
                        id: heroIcon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍹"
                        color: A.Appearance.foreground
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: A.Appearance.heroGlyphSize
                        renderType: Text.NativeRendering
                    }

                    Column {
                        id: heroLabels
                        anchors.left: heroIcon.right
                        anchors.leftMargin: A.Appearance.space3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: A.Appearance.space05
                        height: implicitHeight

                        Text {
                            text: "Displays"
                            color: A.Appearance.foreground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            font.weight: A.Appearance.fontWeightMedium
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: (root.display.loading ? "Refreshing…"
                                : root.display.outputs.length === 0 ? "No outputs"
                                : `${root.display.enabledCount} of ${root.display.outputs.length} on`).toUpperCase()
                            color: A.Appearance.mutedForeground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            font.weight: A.Appearance.fontWeightMedium
                            font.letterSpacing: 1.2
                            renderType: Text.NativeRendering
                        }
                    }
                }

                Ui.Separator { width: parent.width }

                Ui.SectionHeader {
                    text: "OUTPUTS"
                    foreground: A.Appearance.foreground
                    fontFamily: A.Appearance.fontFamily
                }

                Text {
                    visible: !root.display.loading && root.display.outputs.length === 0
                    width: parent.width
                    text: "No outputs reported by wlr-randr"
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    horizontalAlignment: Text.AlignHCenter
                    renderType: Text.NativeRendering
                }

                Repeater {
                    model: root.display.outputs

                    OutputRow {
                        required property var modelData
                        required property int index
                        width: parent.width
                        output: modelData
                        rowIndex: index
                    }
                }

                Ui.Separator { width: parent.width }

                Ui.SectionHeader {
                    text: "SETTINGS"
                    foreground: A.Appearance.foreground
                    fontFamily: A.Appearance.fontFamily
                }

                Column {
                    width: parent.width
                    spacing: A.Appearance.space05

                    Repeater {
                        model: 5

                        Column {
                            required property int index
                            readonly property int setting: index

                            width: parent.width
                            spacing: A.Appearance.space05

                            SettingRow {
                                icon: ["󰍹", "󰍺", "󰍽", "󰑖", "󰌟"][parent.setting]
                                label: ["Resolution", "Refresh Rate", "Scale", "Rotation", "Layout"][parent.setting]
                                hasCursor: root.cursorActive && root.focusArea === "settings"
                                    && root.settingIndex === parent.setting
                                editing: root.editingSetting && root.settingIndex === parent.setting
                                value: {
                                    if (!root.selectedOutput) return "--"
                                    var isEditing = root.editingSetting && root.settingIndex === parent.setting
                                    var preview = isEditing
                                        ? root.settingOptions()[root.optionIndex]
                                        : root.settingValue(parent.setting)
                                    if (parent.setting === 0)
                                        return `${preview.replace("x", " × ")}${isEditing ? "" : " (Current)"}`
                                    if (parent.setting === 2)
                                        return `${Math.round(Number(preview) * 100)}%`
                                    return preview
                                }
                            }

                            OptionMenu {
                                visible: root.editingSetting && root.settingIndex === parent.setting
                                title: ["Resolution", "Refresh Rate", "Scale", "Rotation", "Layout"][parent.setting]
                                options: visible ? root.settingOptions() : []
                                selected: root.optionIndex
                            }
                        }
                    }
                }
            }
        }
    }
}
