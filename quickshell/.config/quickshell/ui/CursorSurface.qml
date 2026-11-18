import QtQuick
import ".."

Rectangle {
    property bool hasCursor: false

    color: hasCursor ? Theme.cursorFill : hover.hovered ? Theme.normalFill : "transparent"
    radius: Theme.radius
    border.width: hasCursor ? Theme.borderWidth : 0
    border.color: Theme.cursorBorder

    HoverHandler {
        id: hover
    }
}
