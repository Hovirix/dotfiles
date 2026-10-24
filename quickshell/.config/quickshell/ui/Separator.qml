import QtQuick
import ".."

Rectangle {
    color: Theme.border
    height: Theme.borderWidth
    implicitHeight: Theme.borderWidth
    implicitWidth: 100
    width: parent ? parent.width : implicitWidth
}
