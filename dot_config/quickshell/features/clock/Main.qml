pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../ui" as Ui

Scope {
    id: feature

    readonly property Component panel: Component {
        Ui.Panel {
            id: root

            readonly property int menuHeight: content.implicitHeight + Theme.dialogPadding * 2
            readonly property int menuWidth: Theme.popupWidthCalendar
            property date shownMonth: new Date()

            function changeMonth(delta: int): void {
                shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + delta, 1);
            }

            function focusMenu(): void {
                shownMonth = new Date();
                Qt.callLater(function () {
                    keys.forceActiveFocus();
                });
            }

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

            Ui.Navigation {
                id: keys

                anchors.fill: parent

                onCloseRequested: feature.popup.close()
                onMoveRequested: function (dx, dy) {
                    if (dx)
                        root.changeMonth(dx);
                }

                ColumnLayout {
                    id: content

                    spacing: Theme.dialogPadding
                    width: parent.width

                    Label {
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontSizeHero
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

                    RowLayout {
                        Layout.fillWidth: true

                        Ui.IconButton {
                            text: "󰅁"

                            onClicked: root.changeMonth(-1)
                        }

                        Label {
                            Layout.fillWidth: true
                            font.pixelSize: Theme.fontSizeDisplaySmall
                            horizontalAlignment: Text.AlignHCenter
                            text: Qt.formatDateTime(root.shownMonth, "MMMM yyyy")
                        }

                        Ui.IconButton {
                            text: "󰅂"

                            onClicked: root.changeMonth(1)
                        }
                    }

                    DayOfWeekRow {
                        Layout.fillWidth: true
                        locale: Qt.locale("en_GB")

                        delegate: Label {
                            required property int day
                            required property string shortName

                            color: day >= 6 ? Theme.primary : Theme.mutedForeground
                            horizontalAlignment: Text.AlignHCenter
                            text: shortName
                        }
                    }

                    MonthGrid {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42 * 6
                        locale: Qt.locale("en_GB")
                        month: root.shownMonth.getMonth()
                        year: root.shownMonth.getFullYear()

                        delegate: Label {
                            required property var model

                            color: model.today ? Theme.primaryForeground : model.month !== root.shownMonth.getMonth() ? Theme.mutedForeground : model.date.getDay() === 0 || model.date.getDay() === 6 ? Theme.primary : Theme.foreground
                            font.pixelSize: Theme.fontSizeTitle
                            horizontalAlignment: Text.AlignHCenter
                            opacity: model.month === root.shownMonth.getMonth() ? 1 : 0.65
                            text: model.day
                            verticalAlignment: Text.AlignVCenter

                            background: Rectangle {
                                color: parent.model.today ? Theme.primary : "transparent"
                            }
                        }
                    }
                }
            }
        }
    }
    required property Ui.Popup popup
}
