import QtQuick
import Quickshell
import "../../ui" as Ui

Scope {
    id: root

    required property var items
    readonly property Component panel: Component {
        Panel {
            controller: root.popup
            items: root.items
            popup: root.popup
        }
    }
    required property Ui.Popup popup

    function open(mode: string): void {
        popup.open(panel);
        popup.item.open(mode);
    }
}
