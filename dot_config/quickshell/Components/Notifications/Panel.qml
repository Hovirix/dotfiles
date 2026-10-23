import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../Appearance" as A

PanelWindow {
    id: window

    required property Service notifications

    screen: Quickshell.screens[0]
    visible: notifications.trackedNotifications.values.length > 0
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: Math.min(A.Appearance.popupWidthStandard, screen ? screen.width : A.Appearance.popupWidthStandard)
    implicitHeight: stack.implicitHeight
    anchors.top: true
    margins.top: A.Appearance.space4

    Column {
        id: stack
        width: parent.width
        spacing: A.Appearance.space2

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
