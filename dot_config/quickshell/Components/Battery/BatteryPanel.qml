import QtQuick
import "../../Appearance" as A
import "../../Ui" as Ui

// Lyra card: header (title + description, percentage in the action slot),
// progress block (label row + h-1 track), separator, detail rows.
// Spacing, type, and geometry come only from Appearance tokens.
Item {
    id: root

    required property var controller
    required property Service battery

    readonly property real displayPercent:
        Math.max(0, Math.min(100, battery.percentage))
    readonly property bool charging: battery.state === "Charging"
    readonly property color chargeColor: A.Appearance.batteryColor(
        displayPercent, charging
    )
    readonly property string timeText: {
        if (!root.battery.available)
            return "—"
        return root.battery.timeShort(root.battery.timeRemaining) || "—"
    }
    // Header description: state with time folded in ("Discharging · 49m left").
    readonly property string headerDescription: {
        if (!root.battery.available)
            return "Unavailable"
        const state = root.battery.state
        if (root.timeText === "—")
            return state
        if (root.battery.discharging)
            return `${state} · ${root.timeText} left`
        return `${state} · ${root.timeText} to full`
    }

    function batteryIcon() {
        if (!battery.available)
            return "󰂑"
        if (battery.state === "Fully charged")
            return "󰂅"
        if (charging)
            return "󰂆"
        if (displayPercent <= 10)
            return "󰂃"
        if (displayPercent <= 30)
            return "󰁺"
        if (displayPercent <= 60)
            return "󰁾"
        return "󰁹"
    }

    Ui.Popup {
        shown: root.controller.current === "battery"
        contentHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()
        onVisibleChanged: if (visible) {
            Qt.callLater(function() { keys.forceActiveFocus() })
        }

        Ui.KeyCatcher {
            id: keys
            anchors.fill: parent
            onCloseRequested: root.controller.close()

            Column {
                id: panelColumn
                width: parent.width
                spacing: A.Appearance.space4

            // CardHeader: glyph + title/description on the left,
            // percentage in the action slot on the right.
            Item {
                width: parent.width
                implicitHeight: Math.max(
                    batteryGlyph.height,
                    headerLabels.height,
                    headerPercent.height
                )
                height: implicitHeight

                Text {
                    id: batteryGlyph

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.batteryIcon()
                    color: root.chargeColor
                    font.family: A.Appearance.iconFontFamily
                    font.pixelSize: A.Appearance.batteryGlyphSize
                    renderType: Text.NativeRendering
                }

                Column {
                    id: headerLabels

                    anchors.left: batteryGlyph.right
                    anchors.leftMargin: A.Appearance.space3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: A.Appearance.space1
                    height: implicitHeight

                    Text {
                        text: "Battery"
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: root.headerDescription
                        color: A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    id: headerPercent

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.battery.available
                        ? `${Math.round(root.displayPercent)}%`
                        : "—"
                    color: root.chargeColor
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeTitle
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                }
            }

            // Charge and time already live in the header,
            // so the bar doubles as the section divider.
            Ui.Progress {
                width: parent.width
                value: root.displayPercent / 100
                fillColor: root.chargeColor
            }

            Ui.DetailRow {
                width: parent.width
                visible: root.battery.healthPercentage > 0

                icon: "󰏖"
                label: "Health"

                value: `${Math.round(root.battery.healthPercentage)}%`
            }

            Ui.DetailRow {
                width: parent.width

                icon: "󰚰"
                label: "Power"

                value: root.battery.available
                    ? `${root.battery.powerUsage.toFixed(1)} W`
                    : "—"
            }

            Ui.DetailRow {
                width: parent.width
                visible: root.battery.energyCapacity > 0

                icon: "󰇥"
                label: "Capacity"

                value: `${root.battery.energy.toFixed(1)} / ${root.battery.energyCapacity.toFixed(1)} Wh`
            }
        }
        }
    }
}
