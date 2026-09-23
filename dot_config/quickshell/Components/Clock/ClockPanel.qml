import QtQuick
import Quickshell

import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    required property var controller

    property date shownMonth: new Date()

    function monthStart(date) {
        return new Date(date.getFullYear(), date.getMonth(), 1)
    }

    function firstWeekday(date) {
        return (monthStart(date).getDay() + 6) % 7
    }

    function daysInMonth(date) {
        return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
    }

    readonly property int calendarCells:
        firstWeekday(shownMonth) + daysInMonth(shownMonth) <= 35 ? 35 : 42

    function calendarDate(index) {
        return new Date(shownMonth.getFullYear(), shownMonth.getMonth(),
                        index - firstWeekday(shownMonth) + 1)
    }

    function changeMonth(delta) {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1)
    }

    function isToday(date) {
        return date.getFullYear() === clock.date.getFullYear()
            && date.getMonth() === clock.date.getMonth()
            && date.getDate() === clock.date.getDate()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Ui.Popup {
        shown: root.controller.current === "clock"
        contentWidth: A.Appearance.popupWidthStandard
        contentHeight: panel.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()
        onVisibleChanged: if (visible) {
            root.shownMonth = root.monthStart(clock.date)
            Qt.callLater(function() { keys.forceActiveFocus() })
        }

        Ui.KeyCatcher {
            id: keys
            anchors.fill: parent
            onMoveRequested: function(dx, dy) {
                if (dx !== 0) root.changeMonth(dx)
            }
            onCloseRequested: root.controller.close()

            Column {
                id: panel
                width: parent.width
                spacing: A.Appearance.dialogGap

                Column {
                    width: parent.width
                    spacing: A.Appearance.space2

                    Text {
                        width: parent.width
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeHero
                        font.weight: A.Appearance.fontWeightStrong
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
                        color: A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }
                }

                Ui.Separator { width: parent.width }

                Item {
                    width: parent.width
                    height: 38

                    Text {
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(root.shownMonth, "MMMM yyyy")
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeDisplaySmall
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅁"
                        color: leftTap.pressed ? A.Appearance.primary : A.Appearance.mutedForeground
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: 24
                        renderType: Text.NativeRendering

                        TapHandler {
                            id: leftTap
                            onTapped: root.changeMonth(-1)
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅂"
                        color: rightTap.pressed ? A.Appearance.primary : A.Appearance.mutedForeground
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: 24
                        renderType: Text.NativeRendering

                        TapHandler {
                            id: rightTap
                            onTapped: root.changeMonth(1)
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7
                    columnSpacing: A.Appearance.space1
                    rowSpacing: A.Appearance.space1

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                        Text {
                            required property string modelData
                            required property int index
                            width: (parent.width - A.Appearance.space1 * 6) / 7
                            height: 28
                            text: modelData
                            color: index >= 5 ? A.Appearance.primary : A.Appearance.mutedForeground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            font.weight: A.Appearance.fontWeightMedium
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            renderType: Text.NativeRendering
                        }
                    }

                    Repeater {
                        model: root.calendarCells

                        Item {
                            required property int index
                            readonly property date cellDate: root.calendarDate(index)
                            readonly property bool inMonth: cellDate.getMonth() === root.shownMonth.getMonth()
                            readonly property bool weekend: index % 7 >= 5
                            readonly property bool today: root.isToday(cellDate)

                            width: (parent.width - A.Appearance.space1 * 6) / 7
                            height: 42

                            Rectangle {
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                color: parent.today ? A.Appearance.primary : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.cellDate.getDate()
                                color: parent.today
                                    ? A.Appearance.primaryForeground
                                    : (!parent.inMonth
                                        ? A.Appearance.mutedForeground
                                        : (parent.weekend ? A.Appearance.primary : A.Appearance.foreground))
                                opacity: parent.inMonth || parent.today ? 1 : 0.65
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeTitle
                                font.weight: parent.today ? A.Appearance.fontWeightStrong : A.Appearance.fontWeightNormal
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
