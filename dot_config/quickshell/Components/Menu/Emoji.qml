import QtQuick
import Quickshell
import Quickshell.Io
import "EmojiSearch.js" as Search

Item {
    id: root

    property var allItems: []
    readonly property var entries: Search.filterEmojis(allItems, query, 1000)
    property string query: ""

    function copy(item: string): void {
        Quickshell.execDetached(["wl-copy", item]);
    }

    FileView {
        path: Qt.resolvedUrl("emojis.json")

        onLoaded: root.allItems = Search.parseEmojis(text())
    }
}
