import QtQuick
import QtQuick.Controls.Basic as Controls
import ".."

Controls.Switch {
    id: root
    property bool hasCursor: false

    implicitWidth: Math.round(Theme.switchHeight * 1.9) + Theme.space2
    implicitHeight: Theme.menuHeaderHeight
    focusPolicy: Qt.NoFocus
    padding: 0
    opacity: enabled ? 1 : 0.4
    contentItem: Item {}

    indicator: Rectangle {
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        implicitWidth: Math.round(Theme.switchHeight * 1.9)
        implicitHeight: Theme.switchHeight
        radius: height / 2
        color: root.checked ? Theme.primary : Theme.normalFill
        border.width: Theme.borderWidth
        border.color: root.checked ? Theme.primary : Theme.normalBorder

        Rectangle {
            width: parent.height - Theme.space15
            height: width
            radius: width / 2
            x: root.checked ? parent.width - width - Theme.space15 / 2 : Theme.space15 / 2
            y: (parent.height - height) / 2
            color: root.checked ? Theme.primaryForeground : Theme.foreground
        }
    }
    background: Rectangle {
        color: "transparent"
        border.width: Theme.borderWidth
        border.color: root.hasCursor ? Theme.cursorBorder : "transparent"
    }
}
