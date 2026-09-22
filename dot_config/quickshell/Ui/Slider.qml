import QtQuick
import "../Appearance" as A

// Lyra volume slider: thin track, square fill, compact square knob.
// Left-drag moves, wheel steps, right-click is the caller's secondary
// action (audio uses it to mute the channel).
Item {
    id: root

    property real value: 0
    property real minimum: 0
    property real maximum: 1
    property real step: 0.05
    property bool dragging: false
    property real liveValue: value

    signal moved(real value)
    signal released(real value)
    signal rightClicked()

    implicitWidth: 200
    implicitHeight: 22

    onValueChanged: if (!dragging) liveValue = value

    readonly property real range: Math.max(0.0001, maximum - minimum)
    readonly property real progress: Math.max(0, Math.min(1, (liveValue - minimum) / range))
    readonly property bool hot: mouseArea.containsMouse || root.dragging
    readonly property real knobSize: 10

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: A.Appearance.progressHeight
        radius: A.Appearance.radius
        color: A.Appearance.muted
    }

    Rectangle {
        anchors.verticalCenter: track.verticalCenter
        anchors.left: track.left
        height: track.height
        radius: A.Appearance.radius
        color: A.Appearance.primary
        width: track.width * root.progress

        Behavior on width {
            enabled: !root.dragging
            NumberAnimation {
                duration: A.Appearance.durationFast
            }
        }
    }

    Rectangle {
        width: root.knobSize
        height: root.knobSize
        radius: A.Appearance.radius
        color: root.hot ? A.Appearance.primary : A.Appearance.foreground
        anchors.verticalCenter: track.verticalCenter
        x: Math.max(0, Math.min(track.width - width, track.width * root.progress - width / 2))

        Behavior on x {
            enabled: !root.dragging
            NumberAnimation {
                duration: A.Appearance.durationFast
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        function valueFromX(x) {
            var clamped = Math.max(0, Math.min(track.width, x))
            return Math.max(root.minimum, Math.min(root.maximum, root.minimum + clamped / track.width * root.range))
        }

        onPressed: function(mouse) {
            if (mouse.button !== Qt.LeftButton)
                return
            root.dragging = true
            var next = valueFromX(mouse.x)
            root.liveValue = next
            root.moved(next)
        }
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                root.rightClicked()
        }
        onPositionChanged: function(mouse) {
            if (!root.dragging)
                return
            var next = valueFromX(mouse.x)
            root.liveValue = next
            root.moved(next)
        }
        onReleased: function(mouse) {
            if (mouse.button !== Qt.LeftButton)
                return
            root.dragging = false
            root.released(root.liveValue)
            root.liveValue = root.value
        }
        onWheel: function(wheel) {
            var delta = wheel.angleDelta.y > 0 ? root.step : -root.step
            var next = Math.max(root.minimum, Math.min(root.maximum, root.liveValue + delta))
            root.liveValue = next
            root.moved(next)
            root.released(next)
        }
    }
}
