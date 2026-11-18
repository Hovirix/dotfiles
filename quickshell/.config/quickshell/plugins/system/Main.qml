import QtQuick
import Quickshell
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    readonly property var actions: [
        {
            id: "network",
            label: qsTr("Network"),
            icon: "",
            run: () => root.run(["foot", "--app-id", "tui", "-e", "impala"])
        },
        {
            id: "bluetooth",
            label: qsTr("Bluetooth"),
            icon: "󰂯",
            run: () => root.run(["foot", "--app-id", "tui", "-e", "bluetui"])
        },
        {
            id: "lock",
            label: qsTr("Lock"),
            icon: "",
            run: () => root.run(["hx-lock"])
        },
        {
            id: "suspend",
            label: qsTr("Suspend"),
            icon: "󰒲",
            run: () => root.run(["hx-suspend"])
        },
        {
            id: "reboot",
            label: qsTr("Reboot"),
            icon: "",
            run: () => root.run(["systemctl", "reboot"])
        },
        {
            id: "shutdown",
            label: qsTr("Shutdown"),
            icon: "",
            run: () => root.run(["systemctl", "poweroff"])
        },
        {
            id: "idle",
            label: qsTr("Toggle idle inhibition"),
            icon: "󰒲",
            run: () => root.run(["hx-idle-toggle"])
        },
        {
            id: "keyboardLayout",
            label: qsTr("Toggle keyboard layout"),
            icon: "󰌌",
            run: () => root.run(["keyboard-layout-toggle"])
        }
    ]

    function run(command: list<string>): void {
        popup.close();
        Quickshell.execDetached(command);
    }
}
