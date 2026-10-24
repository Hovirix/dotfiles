import QtQuick
import Quickshell
import "../../ui" as Ui

Scope {
    id: root

    required property var items
    readonly property Component panel: Component {
        Panel {
            controller: root.popup
            files: fileSearch
            items: root.items
            popup: root.popup
        }
    }
    required property Ui.Popup popup

    Files {
        id: fileSearch
    }

    function open(mode: string): void {
        popup.open(panel);
        popup.item.open(mode);
    }
}
