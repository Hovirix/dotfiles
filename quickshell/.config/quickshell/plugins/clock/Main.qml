import QtQuick
import Quickshell
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    readonly property var actions: [
        {
            id: "clock",
            label: qsTr("Calendar"),
            icon: "󰃭",
            run: () => popup.toggle(panel)
        }
    ]
    readonly property Component panel: Component {
        Panel {
            onCancelled: root.popup.back()
        }
    }
}
