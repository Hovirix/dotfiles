pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "search.js" as Utils
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    property url dataSource: Qt.resolvedUrl("emojis.json")
    property string searchPlaceholder: qsTr("Search emojis…")
    property string actionId: "emoji"
    property string actionLabel: qsTr("Emoji")
    property string actionIcon: ""
    property var items: []
    readonly property var actions: [
        {
            id: actionId,
            label: actionLabel,
            icon: actionIcon,
            run: () => popup.toggle(panel)
        }
    ]
    readonly property Component panel: Component {
        Panel {
            title: root.actionLabel
            items: root.items
            placeholderText: root.searchPlaceholder
            onSelected: value => {
                Quickshell.execDetached(["sh", "-c", 'wl-copy "$1" && notify-send "Copied to clipboard" "$1"', "sh", value]);
                root.popup.close();
            }
            onCancelled: root.popup.back()
        }
    }

    FileView {
        path: root.dataSource
        preload: root.popup.content === root.panel
        onLoaded: root.items = Utils.parseEmojis(text())
    }
}
