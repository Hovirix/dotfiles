import QtQuick
import ".."

Item {
    id: root

    property bool checked: false
    property bool hasCursor: false

    implicitHeight: Theme.switchHeight + Theme.space15 * 2
    implicitWidth: Math.round(Theme.switchHeight * 1.9) + Theme.space15 * 2

    Rectangle {
        anchors.fill: parent
        border.color: root.hasCursor ? Theme.cursorBorder : "transparent"
        border.width: Theme.borderWidth
        color: "transparent"
    }

    Rectangle {
        anchors.centerIn: parent
        border.color: Theme.normalBorder
        border.width: root.checked ? 0 : Theme.borderWidth
        color: root.checked ? Theme.primary : Theme.normalFill
        height: Theme.switchHeight
        width: Math.round(Theme.switchHeight * 1.9)

        Rectangle {
            readonly property int inset: Math.max(1, Math.round((parent.height - height) / 2))

            color: root.checked ? Theme.primaryForeground : Qt.darker(Theme.foreground, 1.25)
            height: width
            width: Math.round(Theme.switchHeight * 0.72)
            x: (root.checked !== LayoutMirroring.enabled ? parent.width - width - inset : inset)
            y: inset
        }
    }
}
