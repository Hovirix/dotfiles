import QtQuick
import "../Appearance" as A
import "../Ui" as Ui
import "../Services" as Services

Item {
    id: root

    required property var controller
    required property Services.Battery battery

    readonly property real displayPercent:
        Math.max(0, Math.min(100, battery.percentage))
    readonly property bool charging: battery.state === "Charging"
    readonly property color chargeColor: A.Appearance.batteryColor(
        displayPercent, charging
    )

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
        visible: root.controller.current === "battery"
        contentHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()

        Column {
            id: panelColumn
            width: parent.width
            spacing: 14

            Item {
                width: parent.width
                height: 58

                Text {
                    id: batteryGlyph

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.batteryIcon()
                    color: root.chargeColor
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: 30
                    renderType: Text.NativeRendering
                }

                Column {
                    anchors.left: batteryGlyph.right
                    anchors.leftMargin: A.Appearance.space3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: A.Appearance.space05

                    Text {
                        text: "Battery"
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: root.battery.available
                            ? root.battery.state
                            : "Unavailable"
                        color: A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.battery.available
                        ? `${Math.round(root.displayPercent)}%`
                        : "--"
                    color: root.chargeColor
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeDisplaySmall
                    font.weight: A.Appearance.fontWeightStrong
                    renderType: Text.NativeRendering
                }
            }

            Ui.Separator {
                width: parent.width
            }

            Item {
                width: parent.width
                height: 18

                Rectangle {
                    id: chargeTrack

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: A.Appearance.progressHeight
                    color: A.Appearance.muted
                }

                Rectangle {
                    anchors.left: chargeTrack.left
                    anchors.verticalCenter: chargeTrack.verticalCenter
                    width: chargeTrack.width * root.displayPercent / 100
                    height: chargeTrack.height
                    color: root.chargeColor

                    Behavior on width {
                        NumberAnimation { duration: A.Appearance.durationFast }
                    }
                }
            }

            Ui.DetailRow {
                width: parent.width

                icon: root.battery.discharging ? "󰌪" : "󰚥"
                label: "Power source"

                value: root.battery.available
                    ? (root.battery.discharging ? "Battery" : "AC adapter")
                    : "Unavailable"
                valueColor: root.chargeColor
            }

            Ui.DetailRow {
                width: parent.width

                icon: "󰥔"
                label: root.battery.discharging ? "Remaining" : "Until full"

                value: root.battery.available
                    ? (
                        root.battery.timeShort(
                            root.battery.timeRemaining
                        ) || "Unavailable"
                    )
                    : "Unavailable"
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
                    : "Unavailable"
            }

            Ui.DetailRow {
                width: parent.width
                visible: root.battery.energyFull > 0

                icon: "󰇥"
                label: "Capacity"

                value: `${root.battery.energy.toFixed(1)} / ${root.battery.energyFull.toFixed(1)} Wh`
            }
        }
    }
}
