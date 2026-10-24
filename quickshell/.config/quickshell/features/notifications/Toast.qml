import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "../.."
import "../../ui" as Ui
import "helpers.js" as Utils

Ui.Panel {
    id: root

    required property Notification notification
    property int groupCount: 1
    readonly property string app: Utils.bounded(notification.appName, 256) || Utils.iconName(notification.desktopEntry) || "Notification"
    readonly property var entry: DesktopEntries.heuristicLookup(Utils.iconName(notification.desktopEntry) || app)
    readonly property string iconSource: {
        var names = [notification.appIcon, Utils.iconName(notification.image), notification.desktopEntry, app,
                     app.toLowerCase().replace(/\s+/g, "-")];
        for (var i = 0; i < names.length; i++) {
            var name = Utils.iconName(names[i]);
            var path = name ? Quickshell.iconPath(name, true) : "";
            if (path)
                return path;
        }
        return entry ? Utils.localImage(entry.icon) || (Utils.iconName(entry.icon) ? Quickshell.iconPath(entry.icon, true) : "") : "";
    }
    readonly property string pictureSource: Utils.imageSource(notification.image) || Utils.localImage(notification.appIcon)
    property bool pictureFailed: false
    onPictureSourceChanged: pictureFailed = false
    readonly property bool battery: notification.appName === "Battery"
    readonly property color accent: battery && notification.hints["battery-state"] === "charging" ? Theme.success
        : notification.urgency === 2 ? Theme.destructive : notification.urgency === 0 ? Theme.mutedForeground : Theme.primary
    readonly property int peek: Math.max(0, Math.min(2, groupCount - 1)) * Theme.space1

    implicitHeight: card.implicitHeight + peek

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        border.color: root.accent
        border.width: Theme.borderWidth
        color: Theme.popover
        height: card.height
        visible: root.peek > 0
        width: parent.width - Theme.space2
    }

    Rectangle {
        id: card

        border.color: root.accent
        border.width: Theme.popupBorderWidth
        color: Theme.popover
        height: implicitHeight
        implicitHeight: Math.max(icon.height, content.implicitHeight) + Theme.space3 * 2
        width: parent.width

        Item {
            id: icon

            height: width
            width: Theme.notificationImageSize
            x: Theme.space3
            y: Theme.space3

            IconImage {
                id: image

                anchors.fill: parent
                asynchronous: true
                source: root.pictureSource && !root.pictureFailed ? root.pictureSource : root.iconSource
                onStatusChanged: if (status === Image.Error) root.pictureFailed = true
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
            y: bodyText.visible ? Theme.space3 : (card.height - height) / 2

            Controls.Label {
                color: root.battery || root.notification.urgency === 2 ? root.accent : Theme.foreground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeTitle
                font.weight: Theme.fontWeightMedium
                maximumLineCount: 3
                text: Utils.bounded(root.notification.summary, 2048) + (root.groupCount > 1 ? " · " + root.groupCount : "")
                textFormat: Text.PlainText
                width: parent.width
                wrapMode: Text.Wrap
            }

            Controls.Label {
                id: bodyText

                color: Theme.mutedForeground
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeBody
                maximumLineCount: 4
                text: Utils.render(root.notification.body)
                textFormat: Text.StyledText
                visible: text !== ""
                width: parent.width
                wrapMode: Text.Wrap
            }

        }
    }
}
