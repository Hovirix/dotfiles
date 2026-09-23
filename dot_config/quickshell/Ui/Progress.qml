import QtQuick
import "../Appearance" as A

// Lyra progress track: muted track, square fill.
Item {
    id: root

    property real value: 0
    property color fillColor: A.Appearance.primary
    property int barHeight: A.Appearance.progressHeight

    implicitHeight: barHeight
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        color: A.Appearance.muted
        radius: A.Appearance.radius
    }

    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.value))
        height: parent.height
        color: root.fillColor
        radius: A.Appearance.radius

        Behavior on width {
            NumberAnimation {
                duration: A.Appearance.durationFast
                easing.type: A.Appearance.easingOut
            }
        }
    }
}
