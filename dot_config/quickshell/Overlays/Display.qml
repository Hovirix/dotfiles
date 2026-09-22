import QtQuick

import "../Appearance" as A
import "../Ui" as Ui
import "../Services" as Services

Item {
    id: root

    required property var controller
    required property Services.Display display
    required property Services.Brightness brightness

    property int selectedIndex: 0
    property bool cursorActive: false
    property bool editingOutput: false
    property int actionIndex: 0
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

    function beginEdit() {
        if (!selectedOutput)
            return
        editingOutput = true
        actionIndex = selectedOutput.enabled ? 0 : 1
    }

    function applySelectedAction() {
        if (!selectedOutput)
            return
        display.setOutputEnabled(selectedOutput, actionIndex !== 1)
        editingOutput = false
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

    component SettingRow: Item {
        required property string icon
        required property string label
        required property string value
        property bool hasCursor: false
        property bool editing: false

        width: parent.width
        height: 38

        Rectangle {
            anchors.fill: parent
            color: parent.hasCursor ? A.Appearance.accent : "transparent"
        }

        Text {
            id: settingIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.icon
            color: A.Appearance.mutedForeground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.iconSize
            renderType: Text.NativeRendering
        }
        Text {
            anchors.left: settingIcon.right
            anchors.leftMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            color: parent.editing ? A.Appearance.primary : A.Appearance.foreground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.fontSizeTitle
            renderType: Text.NativeRendering
        }
        Text {
            id: settingValue
            anchors.right: settingArrow.left
            anchors.rightMargin: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            color: A.Appearance.foreground
            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.fontSizeTitle
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
        }
        Text {
            id: settingArrow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅂"
            color: A.Appearance.mutedForeground
            font.family: A.Appearance.fontFamily
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

        width: parent.width - A.Appearance.space4 * 2
        x: A.Appearance.space4
        height: shownOptions.length * 32 + 34 + A.Appearance.space1 * 2
        color: A.Appearance.background
        border.width: A.Appearance.borderWidth
        border.color: A.Appearance.primary

        Column {
            anchors.fill: parent
            anchors.margins: A.Appearance.space1
            spacing: 0

            Item {
                width: parent.width
                height: 34

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    text: `Choose ${menu.title}`
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeLabel
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: A.Appearance.space2
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${menu.selected + 1}/${menu.options.length}`
                    color: A.Appearance.primary
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeLabel
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
                    height: 32

                    Rectangle {
                        anchors.fill: parent
                        color: root.optionIndex === optionNumber
                            ? Qt.rgba(A.Appearance.primary.r, A.Appearance.primary.g,
                                A.Appearance.primary.b, 0.18) : "transparent"
                    }
                    Rectangle {
                        visible: root.optionIndex === optionNumber
                        width: 3
                        height: parent.height
                        color: A.Appearance.primary
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
                        font.family: A.Appearance.fontFamily
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

    Ui.Popup {
        visible: root.controller.current === "display"
        contentWidth: A.Appearance.popupWidthWorkspace
        contentHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()
        onVisibleChanged: if (visible) {
            root.selectedIndex = 0
            root.cursorActive = false
            root.editingOutput = false
            root.editingSetting = false
            root.focusArea = "outputs"
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
        }

        Ui.KeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onMoveRequested: function(dx, dy) {
                if (root.focusArea === "outputs" && dx !== 0) {
                    // Output actions are immediately keyboard-addressable:
                    // choose a monitor, then h/l stages On/Off/Auto.
                    if (!root.editingOutput)
                        root.beginEdit()
                    root.actionIndex = Math.max(0, Math.min(2, root.actionIndex + dx))
                } else if (root.editingSetting && (dx !== 0 || dy !== 0)) {
                    var options = root.settingOptions()
                    root.optionIndex = Math.max(0, Math.min(options.length - 1,
                        root.optionIndex + (dx !== 0 ? dx : dy)))
                } else if (dy !== 0) {
                    root.cursorActive = true
                    if (root.editingOutput || root.editingSetting) {
                        root.editingOutput = false
                        root.editingSetting = false
                    } else if (root.focusArea === "outputs") {
                        root.moveCursor(dy)
                    } else {
                        root.settingIndex = Math.max(0, Math.min(4, root.settingIndex + dy))
                    }
                }
            }
            onActivateRequested: {
                    if (root.editingOutput)
                        root.applySelectedAction()
                else if (root.editingSetting)
                    root.applySetting()
                else if (root.focusArea === "outputs")
                    root.beginEdit()
                else
                    root.beginSettingEdit()
            }
            onCloseRequested: {
                if (root.editingOutput || root.editingSetting) {
                    root.editingOutput = false
                    root.editingSetting = false
                } else {
                    root.controller.close()
                }
            }
            onTabRequested: function(direction) {
                if (root.editingOutput || root.editingSetting)
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
                spacing: A.Appearance.space3

                Item {
                    width: parent.width
                    height: 58

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Displays"
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: 28
                        font.weight: A.Appearance.fontWeightStrong
                        renderType: Text.NativeRendering
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: A.Appearance.space3

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Brightness"
                            color: A.Appearance.mutedForeground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            font.weight: A.Appearance.fontWeightMedium
                            renderType: Text.NativeRendering
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: `${Math.round(root.brightness.value * 100)}%`
                            color: A.Appearance.foreground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            renderType: Text.NativeRendering
                        }
                        Rectangle {
                            width: 220
                            height: 14
                            anchors.verticalCenter: parent.verticalCenter
                            color: A.Appearance.muted
                            border.width: A.Appearance.borderWidth
                            border.color: A.Appearance.border

                            Rectangle {
                                width: parent.width * root.brightness.value
                                height: parent.height
                                color: A.Appearance.primary
                            }
                        }
                    }
                }

                Ui.Separator { width: parent.width }

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

                    Item {
                        required property var modelData
                        required property int index
                        readonly property int rowIndex: index

                        width: parent.width
                        height: 98

                        Rectangle {
                            anchors.fill: parent
                            color: root.cursorActive && root.selectedIndex === rowIndex
                                ? A.Appearance.accent
                                : (modelData.enabled ? Qt.rgba(A.Appearance.primary.r, A.Appearance.primary.g, A.Appearance.primary.b, 0.08) : "transparent")
                            border.width: A.Appearance.borderWidth
                            border.color: root.selectedIndex === rowIndex
                                ? A.Appearance.primary : A.Appearance.border
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            anchors.left: parent.left
                            anchors.leftMargin: A.Appearance.space3
                            anchors.verticalCenter: parent.verticalCenter
                            color: modelData.enabled ? A.Appearance.primary : A.Appearance.secondary

                            Text {
                                anchors.centerIn: parent
                                text: rowIndex + 1
                                color: modelData.enabled ? A.Appearance.primaryForeground : A.Appearance.foreground
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeDisplaySmall
                                font.weight: A.Appearance.fontWeightStrong
                                renderType: Text.NativeRendering
                            }
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 60
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: A.Appearance.space05

                            Text {
                                text: modelData.model || modelData.description || modelData.name
                                color: A.Appearance.foreground
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: 22
                                font.weight: A.Appearance.fontWeightStrong
                                renderType: Text.NativeRendering
                            }
                            Text {
                                text: `${modelData.name}${rowIndex === 0 ? "  (Primary)" : ""}`
                                color: modelData.enabled ? A.Appearance.primary : A.Appearance.mutedForeground
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeBody
                                font.weight: A.Appearance.fontWeightMedium
                                renderType: Text.NativeRendering
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: A.Appearance.space3
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: A.Appearance.space1

                            Ui.Button {
                                width: 104
                                height: 42
                                text: "On"
                                active: root.editingOutput && root.selectedIndex === rowIndex
                                    ? root.actionIndex === 0 : modelData.enabled
                                bordered: true
                                foreground: (root.editingOutput && root.selectedIndex === rowIndex
                                    ? root.actionIndex === 0 : modelData.enabled)
                                    ? A.Appearance.primary : A.Appearance.foreground
                                onClicked: root.display.setOutputEnabled(modelData, true)
                            }
                            Ui.Button {
                                width: 104
                                height: 42
                                text: "Off"
                                active: root.editingOutput && root.selectedIndex === rowIndex
                                    ? root.actionIndex === 1 : !modelData.enabled
                                bordered: true
                                foreground: (root.editingOutput && root.selectedIndex === rowIndex
                                    ? root.actionIndex === 1 : !modelData.enabled)
                                    ? A.Appearance.primary : A.Appearance.foreground
                                onClicked: root.display.setOutputEnabled(modelData, false)
                            }
                            Ui.Button {
                                width: 104
                                height: 42
                                text: "Auto"
                                active: root.editingOutput && root.selectedIndex === rowIndex
                                    && root.actionIndex === 2
                                bordered: true
                                onClicked: root.display.setOutputEnabled(modelData, true)
                            }
                        }

                        HoverHandler {
                            onHoveredChanged: if (hovered) {
                                root.cursorActive = true
                                root.selectedIndex = rowIndex
                            }
                        }
                    }
                }

                Ui.Separator { width: parent.width }

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

                Ui.Separator { width: parent.width }

                Text {
                    width: parent.width
                    text: root.editingOutput
                        ? "h/l choose action  ·  enter apply  ·  j/k cancel"
                        : (root.editingSetting
                            ? "j/k or h/l choose value  ·  enter apply  ·  esc cancel"
                            : (root.focusArea === "settings"
                                ? "j/k select setting  ·  enter edit  ·  tab outputs"
                                : "j/k or hover output  ·  h/l choose action  ·  enter apply  ·  tab settings"))
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    horizontalAlignment: Text.AlignRight
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
