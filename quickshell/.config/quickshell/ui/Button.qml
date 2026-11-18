import QtQuick
import QtQuick.Controls.Basic as Controls
import ".."

Controls.Button {
    id: root

    property bool primary: false

    implicitWidth: Math.max(Theme.menuHeaderHeight, Math.ceil(implicitContentWidth) + leftPadding + rightPadding)
    implicitHeight: Theme.menuHeaderHeight
    padding: Theme.space2
    horizontalPadding: Theme.space2
    focusPolicy: Qt.NoFocus
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBody
    opacity: enabled ? 1 : 0.4

    contentItem: Text {
        text: root.text
        textFormat: Text.PlainText
        font: root.font
        color: root.primary ? Theme.primaryForeground : Theme.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        color: root.primary ? (root.down ? Qt.darker(Theme.primary, 1.1) : Theme.primary) : root.down || root.hovered ? Theme.cursorFill : root.flat ? "transparent" : Theme.normalFill
        border.width: Theme.borderWidth
        border.color: root.visualFocus ? Theme.primary : root.flat || root.primary ? "transparent" : Theme.normalBorder
        radius: Theme.radius
    }
}
