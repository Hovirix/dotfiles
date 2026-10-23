import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../.."

PanelWindow {
    id: window

    required property Main notifications

    WlrLayershell.layer: WlrLayer.Overlay
    anchors.top: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: stack.implicitHeight
    implicitWidth: Math.min(Theme.popupWidthStandard, screen ? screen.width : Theme.popupWidthStandard)
    margins.top: Theme.space4
    screen: Quickshell.screens[0]
    visible: notifications.trackedNotifications.values.length > 0

    Column {
        id: stack

        spacing: Theme.space2
        width: parent.width

        Repeater {
            model: window.notifications.trackedNotifications

            Toast {
                required property Notification modelData

                notification: modelData
                width: stack.width

                onActivated: window.notifications.activate(notification)
            }
        }
    }
}
