pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../../Appearance" as A

PanelWindow {
    id: window

    required property Service notifications

    // Battery charging cards carry a battery-state hint so title and
    // border share the success color; everything else follows urgency.
    // Null-safe: delegates evaluate while hidden and during resets.
    function batteryState(notification: Notification): string {
        if (!notification || !notification.hints)
            return "";
        var state = notification.hints["battery-state"];
        return typeof state === "string" ? state : "";
    }

    function iconSource(notification: Notification): string {
        var source = String(notification.image || notification.appIcon || "");
        if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0)
            return source;
        if (source.charAt(0) === "/")
            return "file://" + source;
        return source ? Quickshell.iconPath(source, true) : "";
    }

    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: stack.implicitHeight
    implicitWidth: A.Appearance.notificationWidth
    screen: Quickshell.screens[0]
    visible: notifications.items.length > 0

    anchors {
        left: true
        top: true
    }

    margins {
        left: (screen.width - width) / 2
        top: A.Appearance.space4
    }

    Column {
        id: stack

        spacing: A.Appearance.space2
        width: parent.width

        Repeater {
            model: window.notifications.items

            Rectangle {
                id: card

                readonly property bool isCharging: window.batteryState(modelData) === "charging"
                required property Notification modelData
                readonly property string notificationIconSource: window.iconSource(modelData)
                readonly property int padding: A.Appearance.space3

                border.color: card.modelData.urgency === NotificationUrgency.Critical ? A.Appearance.destructive : (card.isCharging ? A.Appearance.success : (card.modelData.urgency === NotificationUrgency.Low ? A.Appearance.subtleRing : A.Appearance.primary))
                border.width: A.Appearance.popupBorderWidth
                color: A.Appearance.popover
                height: implicitHeight
                implicitHeight: contentColumn.height + padding * 2
                radius: A.Appearance.radius
                width: window.width

                Connections {
                    function onClosed() {
                        window.notifications.remove(card.modelData);
                    }

                    target: card.modelData
                }

                // Keep notifications from becoming permanent desktop overlays.
                // Some clients mark informational warnings as resident even
                // though they provide no useful interaction.
                Timer {
                    interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : A.Appearance.notificationTimeout
                    running: true

                    onTriggered: card.modelData.expire()
                }

                Column {
                    id: contentColumn

                    spacing: A.Appearance.space2
                    width: card.width - card.padding * 2
                    x: card.padding
                    y: card.padding

                    Item {
                        id: contentRow

                        height: Math.max(iconBox.height, notificationText.implicitHeight)
                        width: parent.width

                        Item {
                            id: iconBox

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            height: A.Appearance.notificationIconSize
                            width: A.Appearance.notificationIconSize

                            IconImage {
                                anchors.fill: parent
                                asynchronous: true
                                implicitSize: A.Appearance.notificationIconSize
                                source: card.notificationIconSource
                            }

                            Text {
                                anchors.centerIn: parent
                                color: A.Appearance.primary
                                font.family: A.Appearance.iconFontFamily
                                font.pixelSize: A.Appearance.notificationGlyphSize
                                renderType: Text.NativeRendering
                                text: "󰂚"
                                visible: card.notificationIconSource === ""
                            }
                        }

                        Column {
                            id: notificationText

                            anchors.left: iconBox.right
                            anchors.leftMargin: A.Appearance.space3
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: A.Appearance.space05

                            Text {
                                color: card.modelData.urgency === NotificationUrgency.Critical ? A.Appearance.destructive : (card.isCharging ? A.Appearance.success : A.Appearance.foreground)
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeTitle
                                font.weight: A.Appearance.fontWeightMedium
                                linkColor: A.Appearance.link
                                renderType: Text.NativeRendering
                                text: card.modelData.summary
                                textFormat: Text.StyledText
                                width: parent.width
                                wrapMode: Text.Wrap

                                onLinkActivated: function (link) {
                                    Qt.openUrlExternally(link);
                                }
                            }

                            Text {
                                color: A.Appearance.mutedForeground
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeBody
                                linkColor: A.Appearance.link
                                renderType: Text.NativeRendering
                                text: card.modelData.body
                                textFormat: Text.StyledText
                                visible: text !== ""
                                width: parent.width
                                wrapMode: Text.Wrap

                                onLinkActivated: function (link) {
                                    Qt.openUrlExternally(link);
                                }
                            }
                        }
                    } // contentRow
                }
            }
        }
    }
}
