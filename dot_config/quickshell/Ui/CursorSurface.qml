import QtQuick
import "../Appearance" as A

Rectangle {
    property bool current: false
    property bool hasCursor: false
    property bool menuStyle: false

    border.color: A.Appearance.cursorBorder
    border.width: hasCursor && !menuStyle ? A.Appearance.borderWidth : 0
    color: hasCursor ? A.Appearance.cursorFill : current ? A.Appearance.currentFill : "transparent"
    radius: A.Appearance.radius

    Behavior on color {
        ColorAnimation {
            duration: A.Appearance.durationCursor
        }
    }
}
