pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../ui" as Ui

Ui.Panel {
    id: root

    title: qsTr("Calendar")
    property date shownMonth: new Date()
    readonly property bool isCurrentMonth: shownMonth.getFullYear() === clock.date.getFullYear() && shownMonth.getMonth() === clock.date.getMonth()
    signal cancelled

    function changeMonth(delta: int): void {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1);
    }

    function goToday(): void {
        shownMonth = new Date(clock.date);
    }

    function focusMenu(): void {
        goToday();
        Qt.callLater(() => keys.forceActiveFocus());
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Ui.Navigation {
        id: keys
        anchors.fill: parent
        onCloseRequested: root.cancelled()
        onMoveRequested: (dx, dy) => {
            if (dx)
                root.changeMonth(dx);
        }
        onTextKey: text => {
            if (text.toLowerCase() === "t")
                root.goToday();
        }

        ColumnLayout {
            id: content
            spacing: Theme.space2
            anchors.fill: parent

            Label {
                Layout.fillWidth: true
                font.pixelSize: 32
                font.weight: Theme.fontWeightStrong
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
            }

            Label {
                Layout.fillWidth: true
                color: Theme.mutedForeground
                font.pixelSize: Theme.fontSizeTitle
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
            }

            Ui.Separator {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: Theme.menuHeaderHeight
                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.space2
                    Ui.IconButton {
                        source: Qt.resolvedUrl("../../ui/icons/chevron-left.svg")
                        label: qsTr("Previous month")
                        onClicked: root.changeMonth(-1)
                    }
                    Label {
                        Layout.preferredWidth: 200
                        font.pixelSize: Theme.fontSizeHeading
                        font.weight: Theme.fontWeightMedium
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDateTime(root.shownMonth, "MMMM yyyy")
                    }
                    Ui.IconButton {
                        source: Qt.resolvedUrl("../../ui/icons/chevron-right.svg")
                        label: qsTr("Next month")
                        onClicked: root.changeMonth(1)
                    }
                }
                Ui.Button {
                    objectName: "calendarToday"
                    anchors.right: parent.right
                    flat: true
                    text: qsTr("Today")
                    visible: !root.isCurrentMonth
                    onClicked: root.goToday()
                }
            }

            DayOfWeekRow {
                Layout.fillWidth: true
                locale: Qt.locale("en_GB")
                delegate: Label {
                    required property int day
                    required property string shortName
                    color: Theme.mutedForeground
                    font.pixelSize: Theme.fontSizeBodySmall
                    horizontalAlignment: Text.AlignHCenter
                    text: shortName
                }
            }

            MonthGrid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                locale: Qt.locale("en_GB")
                month: root.shownMonth.getMonth()
                year: root.shownMonth.getFullYear()
                delegate: Label {
                    id: dayCell
                    required property var model
                    color: model.today ? Theme.primaryForeground : model.month !== root.shownMonth.getMonth() ? Theme.mutedForeground : Theme.foreground
                    font.pixelSize: Theme.fontSizeBody
                    horizontalAlignment: Text.AlignHCenter
                    opacity: model.month === root.shownMonth.getMonth() ? 1 : 0.65
                    text: model.day
                    verticalAlignment: Text.AlignVCenter
                    background: Item {
                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(Theme.rowHeight, parent.width, parent.height)
                            height: width
                            radius: width / 2
                            color: Theme.primary
                            visible: dayCell.model.today
                        }
                    }
                }
            }
        }
    }
}
