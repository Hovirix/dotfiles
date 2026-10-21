import QtQuick
import "../Appearance" as A

// Shared progress track.
Item {
    id: root

    property int barHeight: A.Appearance.progressHeight
    property color fillColor: A.Appearance.primary
    property real value: 0

    height: implicitHeight
    implicitHeight: barHeight

    Rectangle {
        anchors.fill: parent
        color: A.Appearance.muted
        radius: A.Appearance.radius
    }

    Rectangle {
        color: root.fillColor
        height: parent.height
        radius: A.Appearance.radius
        width: parent.width * Math.max(0, Math.min(1, root.value))

        Behavior on width {
            NumberAnimation {
                duration: A.Appearance.durationFast
                easing.type: A.Appearance.easingOut
            }
        }
    }
}
