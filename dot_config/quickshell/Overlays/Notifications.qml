import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../Appearance" as A
import "../Services" as Services

PanelWindow {
    id: window

    required property Services.Notifications notifications

    screen: Quickshell.screens[0]
    visible: notifications.items.length > 0
    focusable: false
    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: A.Appearance.notificationWidth
    implicitHeight: stack.implicitHeight

    anchors {
        top: true
        left: true
    }

    margins {
        top: A.Appearance.space4
        left: (screen.width - width) / 2
    }

    function iconSource(notification) {
        var source = String(notification.image || notification.appIcon || "")
        if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0)
            return source
        if (source.charAt(0) === "/")
            return "file://" + source
        return source ? Quickshell.iconPath(source, true) : ""
    }

    Column {
        id: stack
        width: parent.width
        spacing: A.Appearance.space2

        Repeater {
            model: window.notifications.items

            Rectangle {
                id: card
                required property var modelData
                readonly property string notificationIconSource: window.iconSource(modelData)
                readonly property int padding: A.Appearance.space3

                width: window.width
                implicitHeight: contentRow.height + padding * 2
                height: implicitHeight
                color: A.Appearance.popover
                border.width: A.Appearance.borderWidth
                border.color: A.Appearance.subtleRing
                radius: A.Appearance.radius

                Connections {
                    target: card.modelData
                    function onClosed() { window.notifications.remove(card.modelData) }
                }

                Timer {
                    interval: card.modelData.expireTimeout > 0
                        ? card.modelData.expireTimeout * 1000
                        : A.Appearance.notificationTimeout
                    running: !card.modelData.resident
                        && card.modelData.urgency !== NotificationUrgency.Critical
                    onTriggered: card.modelData.expire()
                }

                Item {
                    id: contentRow
                    x: card.padding
                    y: card.padding
                    width: card.width - card.padding * 2
                    height: Math.max(iconBox.height, notificationText.implicitHeight)

                    Item {
                        id: iconBox
                        width: A.Appearance.notificationIconSize
                        height: A.Appearance.notificationIconSize
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        IconImage {
                            anchors.fill: parent
                            source: card.notificationIconSource
                            implicitSize: A.Appearance.notificationIconSize
                            asynchronous: true
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: card.notificationIconSource === ""
                            text: "󰂚"
                            color: A.Appearance.primary
                            font.family: A.Appearance.iconFontFamily
                            font.pixelSize: A.Appearance.notificationGlyphSize
                            renderType: Text.NativeRendering
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
                            width: parent.width
                            text: card.modelData.summary
                            color: card.modelData.urgency === NotificationUrgency.Critical
                                ? A.Appearance.destructive
                                : A.Appearance.foreground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            font.weight: A.Appearance.fontWeightMedium
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                        }

                        Text {
                            visible: text !== ""
                            width: parent.width
                            text: card.modelData.body
                            color: A.Appearance.mutedForeground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.modelData.dismiss()
                }
            }
        }
    }
}
