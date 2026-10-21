pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    readonly property int calendarCells: firstWeekday(shownMonth) + daysInMonth(shownMonth) <= 35 ? 35 : 42
    required property var controller
    readonly property int menuHeight: panel.implicitHeight + A.Appearance.dialogPadding * 2
    readonly property int menuWidth: A.Appearance.popupWidthCalendar
    property date shownMonth: new Date()

    function calendarDate(index: int): date {
        return new Date(shownMonth.getFullYear(), shownMonth.getMonth(), index - firstWeekday(shownMonth) + 1);
    }

    function changeMonth(delta: int): void {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1);
    }

    function daysInMonth(date: date): int {
        return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
    }

    function firstWeekday(date: date): int {
        return (monthStart(date).getDay() + 6) % 7;
    }

    function focusMenu(): void {
        root.shownMonth = root.monthStart(clock.date);
        Qt.callLater(function () {
            keys.forceActiveFocus();
        });
    }

    function isToday(date: date): bool {
        return date.getFullYear() === clock.date.getFullYear() && date.getMonth() === clock.date.getMonth() && date.getDate() === clock.date.getDate();
    }

    function monthStart(date: date): date {
        return new Date(date.getFullYear(), date.getMonth(), 1);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Ui.KeyCatcher {
        id: keys

        anchors.fill: parent

        onCloseRequested: root.controller.close()
        onMoveRequested: function (dx, dy) {
            if (dx !== 0)
                root.changeMonth(dx);
        }

        Column {
            id: panel

            spacing: A.Appearance.dialogPadding
            width: parent.width

            Column {
                spacing: A.Appearance.space2
                width: parent.width

                Text {
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeHero
                    font.weight: A.Appearance.fontWeightStrong
                    horizontalAlignment: Text.AlignHCenter
                    renderType: Text.NativeRendering
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    width: parent.width
                }

                Text {
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeTitle
                    font.weight: A.Appearance.fontWeightMedium
                    horizontalAlignment: Text.AlignHCenter
                    renderType: Text.NativeRendering
                    text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
                    width: parent.width
                }
            }

            Ui.Separator {
                width: parent.width
            }

            Item {
                height: 38
                width: parent.width

                Text {
                    anchors.centerIn: parent
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeDisplaySmall
                    font.weight: A.Appearance.fontWeightMedium
                    renderType: Text.NativeRendering
                    text: Qt.formatDateTime(root.shownMonth, "MMMM yyyy")
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: leftTap.pressed ? A.Appearance.primary : A.Appearance.mutedForeground
                    font.family: A.Appearance.iconFontFamily
                    font.pixelSize: 24
                    renderType: Text.NativeRendering
                    text: "󰅁"

                    TapHandler {
                        id: leftTap

                        onTapped: root.changeMonth(-1)
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: rightTap.pressed ? A.Appearance.primary : A.Appearance.mutedForeground
                    font.family: A.Appearance.iconFontFamily
                    font.pixelSize: 24
                    renderType: Text.NativeRendering
                    text: "󰅂"

                    TapHandler {
                        id: rightTap

                        onTapped: root.changeMonth(1)
                    }
                }
            }

            Grid {
                columnSpacing: A.Appearance.space1
                columns: 7
                rowSpacing: A.Appearance.space1
                width: parent.width

                Repeater {
                    model: [qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat"), qsTr("Sun")]

                    Text {
                        required property int index
                        required property string modelData

                        color: index >= 5 ? A.Appearance.primary : A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeBody
                        font.weight: A.Appearance.fontWeightMedium
                        height: 28
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                        text: modelData
                        verticalAlignment: Text.AlignVCenter
                        width: (parent.width - A.Appearance.space1 * 6) / 7
                    }
                }

                Repeater {
                    model: root.calendarCells

                    Item {
                        id: dayCell

                        readonly property date cellDate: root.calendarDate(dayCell.index)
                        readonly property bool inMonth: dayCell.cellDate.getMonth() === root.shownMonth.getMonth()
                        required property int index
                        readonly property bool today: root.isToday(dayCell.cellDate)
                        readonly property bool weekend: index % 7 >= 5

                        height: 42
                        width: (parent.width - A.Appearance.space1 * 6) / 7

                        Rectangle {
                            anchors.centerIn: parent
                            color: parent.today ? A.Appearance.primary : "transparent"
                            height: 38
                            width: 38
                        }

                        Text {
                            anchors.centerIn: parent
                            color: parent.today ? A.Appearance.primaryForeground : (!parent.inMonth ? A.Appearance.mutedForeground : (parent.weekend ? A.Appearance.primary : A.Appearance.foreground))
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            font.weight: parent.today ? A.Appearance.fontWeightStrong : A.Appearance.fontWeightNormal
                            horizontalAlignment: Text.AlignHCenter
                            opacity: parent.inMonth || parent.today ? 1 : 0.65
                            renderType: Text.NativeRendering
                            text: parent.cellDate.getDate()
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
