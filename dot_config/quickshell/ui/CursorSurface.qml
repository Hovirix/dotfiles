import QtQuick
import ".."

Rectangle {
    property bool current: false
    property bool hasCursor: false
    property bool menuStyle: false

    border.color: Theme.cursorBorder
    border.width: hasCursor && !menuStyle ? Theme.borderWidth : 0
    color: hasCursor ? Theme.cursorFill : current ? Theme.currentFill : "transparent"
    radius: Theme.radius

    Behavior on color {
        ColorAnimation {
            duration: Theme.durationCursor
        }
    }
}
