import QtQuick
import "utils.js" as Utils
import Quickshell.Services.UPower
import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    required property Service battery
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
    required property var controller
    readonly property real displayPercent: Math.max(0, Math.min(100, battery.percentage))
    readonly property int menuHeight: panelColumn.implicitHeight + A.Appearance.dialogPadding * 2
    readonly property int menuWidth: A.Appearance.popupWidthStandard
    // When UPower has no runtime estimate, use the current discharge rate.
    readonly property real runtimeSeconds: battery.timeRemaining > 0 ? battery.timeRemaining : (battery.discharging && battery.energy > 0 && battery.powerUsage > 0 ? battery.energy / battery.powerUsage * 3600 : 0)
    readonly property string runtimeText: Utils.timeShort(runtimeSeconds)
    readonly property bool showingPower: battery.available && battery.powerUsage > 0 && (battery.discharging || charging)
    readonly property color stateColor: A.Appearance.batteryStatusColor(displayPercent, battery.available, battery.discharging)

    function batteryIcon(): string {
        if (!battery.available)
            return "󰂑";
        if (battery.state === UPowerDeviceState.FullyCharged)
            return "󰁹";
        if (charging)
            return "󰂄";
        if (displayPercent <= 10)
            return "󰂃";
        if (displayPercent <= 30)
            return "󰁼";
        if (displayPercent <= 60)
            return "󰁿";
        if (displayPercent <= 90)
            return "󰂂";
        return "󰁹";
    }

    function focusMenu(): void {
        Qt.callLater(function () {
            keys.forceActiveFocus();
        });
    }

    Ui.KeyCatcher {
        id: keys

        anchors.fill: parent

        onCloseRequested: root.controller.close()

        Column {
            id: panelColumn

            spacing: A.Appearance.space4
            width: parent.width

            Item {
                height: Math.max(batteryGlyph.implicitHeight, headerLabels.implicitHeight, headerPercent.implicitHeight)
                width: parent.width

                Text {
                    id: batteryGlyph

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.stateColor
                    font.family: A.Appearance.iconFontFamily
                    font.pixelSize: A.Appearance.batteryGlyphSize
                    renderType: Text.NativeRendering
                    text: root.batteryIcon()
                }

                Column {
                    id: headerLabels

                    anchors.left: batteryGlyph.right
                    anchors.leftMargin: A.Appearance.space3
                    anchors.right: headerPercent.left
                    anchors.rightMargin: A.Appearance.space3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: A.Appearance.space1

                    Text {
                        color: A.Appearance.foreground
                        elide: Text.ElideRight
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                        text: qsTr("Battery")
                        width: parent.width
                    }

                    Text {
                        color: root.stateColor
                        elide: Text.ElideRight
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        renderType: Text.NativeRendering
                        text: root.battery.available ? root.battery.stateText : qsTr("No battery detected")
                        width: parent.width
                    }
                }

                Text {
                    id: headerPercent

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.stateColor
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeTitle
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                    text: root.battery.available ? `${Math.round(root.displayPercent)}%` : "—"
                }
            }

            Ui.Separator {
                visible: root.battery.available
            }

            Column {
                spacing: A.Appearance.space1
                visible: root.battery.available
                width: parent.width

                Ui.DetailRow {
                    icon: root.battery.discharging ? "󰁹" : "󰚥"
                    label: qsTr("Power source")
                    value: root.battery.discharging ? qsTr("Battery") : qsTr("AC")
                    width: parent.width
                }

                Ui.DetailRow {
                    icon: "󱧥"
                    label: root.battery.discharging ? qsTr("Time left") : qsTr("To full")
                    value: (root.battery.timeRemaining > 0 ? "" : "~") + root.runtimeText
                    visible: root.runtimeText !== ""
                    width: parent.width
                }

                Ui.DetailRow {
                    icon: "󱈏"
                    label: qsTr("Health")
                    value: `${Math.round(root.battery.healthPercentage)}%`
                    visible: root.battery.healthPercentage > 0
                    width: parent.width
                }

                Ui.DetailRow {
                    icon: "󰉁"
                    label: root.battery.discharging ? qsTr("Power draw") : qsTr("Charge rate")
                    value: `${root.battery.powerUsage.toFixed(1)} W`
                    visible: root.showingPower
                    width: parent.width
                }

                Ui.DetailRow {
                    icon: "󰂎"
                    label: qsTr("Stored / full")
                    value: root.battery.energy > 0 && root.battery.energyCapacity > 0 ? `${root.battery.energy.toFixed(1)} / ${root.battery.energyCapacity.toFixed(1)} Wh` : ""
                    visible: root.battery.energy > 0 && root.battery.energyCapacity > 0
                    width: parent.width
                }

                Ui.DetailRow {
                    icon: "󱟣"
                    label: qsTr("Design capacity")
                    // Quickshell exposes health and full capacity, but not design capacity.
                    value: root.battery.energyCapacity > 0 && root.battery.healthPercentage > 0 ? `~${(root.battery.energyCapacity * 100 / root.battery.healthPercentage).toFixed(1)} Wh` : ""
                    visible: root.battery.energyCapacity > 0 && root.battery.healthPercentage > 0
                    width: parent.width
                }
            }
        }
    }
}
