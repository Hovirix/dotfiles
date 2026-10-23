import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "../.."
import "../../ui" as Ui

Ui.Panel {
    id: root

    required property Notification notification

    signal activated

    implicitHeight: card.implicitHeight

    Rectangle {
        id: card

        border.color: root.notification.urgency === NotificationUrgency.Critical ? Theme.destructive : Theme.primary
        border.width: Theme.popupBorderWidth
        color: Theme.popover
        height: implicitHeight
        implicitHeight: Math.max(icon.height, content.implicitHeight) + Theme.space3 * 2
        width: parent.width

        Item {
            id: icon

            anchors.verticalCenter: parent.verticalCenter
            height: width
            width: Theme.notificationImageSize
            x: Theme.space3

            IconImage {
                id: image

                anchors.fill: parent
                asynchronous: true
                // Only theme names: sender-controlled file paths are not loaded.
                source: /^[a-zA-Z0-9_.-]{1,256}$/.test(root.notification.appIcon) ? Quickshell.iconPath(root.notification.appIcon, true) : ""
            }

            Controls.Label {
                anchors.centerIn: parent
                color: Theme.primary
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.heroGlyphSize
                text: "󰂚"
                visible: image.status !== Image.Ready
            }
        }

        Column {
            id: content

            spacing: Theme.space05
            width: card.width - x - Theme.space3
            x: icon.x + icon.width + Theme.space3
            y: Theme.space3

            Controls.Label {
                color: Theme.mutedForeground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeCaption
                text: root.notification.appName.slice(0, 256)
                textFormat: Text.PlainText
                visible: text !== ""
                width: parent.width
            }

            Controls.Label {
                color: root.notification.urgency === NotificationUrgency.Critical ? Theme.destructive : Theme.foreground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeTitle
                font.weight: Theme.fontWeightMedium
                maximumLineCount: 3
                text: root.notification.summary.slice(0, 2048)
                textFormat: Text.PlainText
                width: parent.width
                wrapMode: Text.Wrap
            }

            Controls.Label {
                color: Theme.mutedForeground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeBody
                maximumLineCount: 4
                text: root.notification.body.slice(0, 32768)
                textFormat: Text.PlainText
                visible: text !== ""
                width: parent.width
                wrapMode: Text.Wrap
            }
        }

        MouseArea {
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            z: -1

            onClicked: function (mouse) {
                if (mouse.button === Qt.MiddleButton)
                    root.notification.dismiss();
                else
                    root.activated();
            }
        }
    }
}
