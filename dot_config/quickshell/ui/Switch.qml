import QtQuick
import QtQuick.Controls as Controls
import ".."

Item {
    id: root

    property bool checked: false
    property bool hasCursor: false

    signal hovered(bool isHovered)
    signal toggled

    implicitHeight: Theme.switchHeight + Theme.space15 * 2
    implicitWidth: Math.round(Theme.switchHeight * 1.9) + Theme.space15 * 2

    Controls.Switch {
        id: control

        anchors.fill: parent
        checked: root.checked
        implicitHeight: root.implicitHeight
        implicitWidth: root.implicitWidth
        padding: Theme.space15

        background: Rectangle {
            border.color: root.hasCursor || control.hovered ? Theme.cursorBorder : "transparent"
            border.width: Theme.borderWidth
            color: "transparent"
        }
        indicator: Rectangle {
            border.color: Theme.normalBorder
            border.width: control.checked ? 0 : Theme.borderWidth
            color: control.checked ? Theme.currentFill : Theme.normalFill
            height: Theme.switchHeight
            width: control.availableWidth
            x: control.leftPadding
            y: (control.height - height) / 2

            Rectangle {
                readonly property int inset: Math.max(1, Math.round((parent.height - height) / 2))

                color: control.checked ? Theme.foreground : Qt.darker(Theme.foreground, 1.25)
                height: width
                width: Math.round(Theme.switchHeight * 0.72)
                x: control.visualPosition * (parent.width - width - inset * 2) + inset
                y: inset
            }
        }

        onHoveredChanged: root.hovered(hovered)
        onToggled: root.toggled()
    }
}
