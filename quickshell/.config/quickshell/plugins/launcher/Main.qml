import QtQuick
import Quickshell
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    required property var apps
    required property var files
    required property var actions
    readonly property var searchActions: [
        {
            id: "files",
            label: qsTr("Search files"),
            icon: "󰈙",
            run: () => root.open("open")
        }
    ].concat(actions)
    readonly property Component panel: Component {
        Panel {
            popup: root.popup
            apps: root.apps
            files: root.files
            actions: root.searchActions
        }
    }
    readonly property Component filePanel: Component {
        Panel {
            popup: root.popup
            apps: root.apps
            files: root.files
            actions: root.searchActions
            fileMenu: true
            Component.onCompleted: root.files.refresh()
        }
    }

    function open(mode: string): void {
        popup.open(mode === "open" || mode === "files" ? filePanel : panel);
        popup.item.setQuery("");
    }
}
