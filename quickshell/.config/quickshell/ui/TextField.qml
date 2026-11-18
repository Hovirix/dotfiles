import QtQuick
import QtQuick.Controls.Basic as Controls
import ".."

Controls.TextField {
    id: root

    property bool invalid: false

    implicitHeight: Theme.menuRowHeight
    padding: Theme.space3
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBody
    color: Theme.foreground
    placeholderTextColor: Theme.mutedForeground
    selectionColor: Theme.primary
    selectedTextColor: Theme.primaryForeground
    selectByMouse: true
    Accessible.name: placeholderText
    background: Rectangle {
        color: Theme.normalFill
        border.width: Theme.borderWidth
        border.color: root.invalid ? Theme.destructive : root.activeFocus ? Theme.primary : Theme.normalBorder
        radius: Theme.radius
    }
}
