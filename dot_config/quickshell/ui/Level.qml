import QtQuick
import ".."

Item {
    id: root

    property real maximum: 1
    property real minimum: 0
    property real value: 0

    implicitHeight: Theme.sliderHeight
    implicitWidth: Theme.sliderWidth

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.currentFill
        height: Theme.progressHeight
        radius: height / 2
        width: parent.width

        Rectangle {
            color: Theme.foreground
            height: parent.height
            radius: parent.radius
            width: parent.width * Math.max(0, Math.min(1, (root.value - root.minimum) / Math.max(0.0001, root.maximum - root.minimum)))
        }
    }
}
