import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "../../Appearance" as A

Item {
    id: root

    required property Notification notification

    signal activated

    implicitHeight: card.implicitHeight

    Rectangle {
        id: card
        width: parent.width
        height: implicitHeight
        implicitHeight: Math.max(icon.height, content.implicitHeight) + A.Appearance.space3 * 2
        color: A.Appearance.popover
        border.color: root.notification.urgency === NotificationUrgency.Critical ? A.Appearance.destructive : A.Appearance.primary
        border.width: A.Appearance.popupBorderWidth

        Item {
            id: icon
            x: A.Appearance.space3
            anchors.verticalCenter: parent.verticalCenter
            width: A.Appearance.notificationImageSize
            height: width

            IconImage {
                id: image
                anchors.fill: parent
                // Only theme names: sender-controlled file paths are not loaded.
                source: /^[a-zA-Z0-9_.-]{1,256}$/.test(root.notification.appIcon) ? Quickshell.iconPath(root.notification.appIcon, true) : ""
                asynchronous: true
            }
            Text {
                anchors.centerIn: parent
                visible: image.status !== Image.Ready
                text: "󰂚"
                color: A.Appearance.primary
                font.family: A.Appearance.iconFontFamily
                font.pixelSize: A.Appearance.heroGlyphSize
            }
        }

        Column {
            id: content
            x: icon.x + icon.width + A.Appearance.space3
            y: A.Appearance.space3
            width: card.width - x - A.Appearance.space3
            spacing: A.Appearance.space05

            Text {
                width: parent.width
                text: root.notification.appName.slice(0, 256)
                textFormat: Text.PlainText
                color: A.Appearance.mutedForeground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeCaption
                elide: Text.ElideRight
                visible: text !== ""
            }
            Text {
                width: parent.width
                text: root.notification.summary.slice(0, 2048)
                textFormat: Text.PlainText
                color: root.notification.urgency === NotificationUrgency.Critical ? A.Appearance.destructive : A.Appearance.foreground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeTitle
                font.weight: A.Appearance.fontWeightMedium
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: root.notification.body.slice(0, 32768)
                textFormat: Text.PlainText
                color: A.Appearance.mutedForeground
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: function (mouse) {
                if (mouse.button === Qt.MiddleButton)
                    root.notification.dismiss();
                else
                    root.activated();
            }
        }
    }
}
