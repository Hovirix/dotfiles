import QtQuick
import Quickshell
import Quickshell.Wayland
import "../.."

PanelWindow {
    id: window

    required property Main notifications

    WlrLayershell.layer: WlrLayer.Overlay
    anchors.top: true
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: false
    implicitHeight: Math.min(stack.implicitHeight, screen ? Math.max(1, screen.height - Theme.space4 * 2) : Theme.popupMaxHeight)
    implicitWidth: Math.min(Theme.popupWidthStandard, screen ? Math.max(1, screen.width - Theme.space4 * 2) : Theme.popupWidthStandard)
    margins.top: Theme.space4
    // Keep an existing stack still; a disconnected output falls back to focus.
    screen: Quickshell.screens.find(output => output.name === notifications.targetMonitor)
        || Quickshell.screens.find(output => output.name === notifications.focusedMonitor)
        || Quickshell.screens[0] || null
    visible: notifications.count > 0
    contentItem.clip: true

    mask: Region {
    }

    Column {
        id: stack

        spacing: Theme.space2
        width: parent.width

        Repeater {
            // Preserve stack order while creating only each group's visible toast.
            model: window.notifications.groups.slice().sort((a, b) => a.index - b.index)

            Toast {
                required property var modelData

                notification: modelData.notification
                groupCount: modelData.count
                width: stack.width
            }
        }
    }
}
