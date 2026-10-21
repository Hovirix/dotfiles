import QtQuick
import "../Appearance" as A

// Left-drag moves, wheel steps, right-click is the caller's secondary
// action (audio uses it to mute the channel).
Item {
    id: root

    property real dragValue: 0
    property bool dragging: false
    readonly property bool hot: mouseArea.containsMouse || root.dragging
    readonly property real knobSize: A.Appearance.sliderKnobSize
    readonly property real liveValue: dragging ? dragValue : value
    property real maximum: 1
    property real minimum: 0
    readonly property bool mirrored: LayoutMirroring.enabled
    readonly property real progress: Math.max(0, Math.min(1, (liveValue - minimum) / range))
    readonly property real range: Math.max(0.0001, maximum - minimum)
    property real step: 0.05
    property real value: 0

    signal moved(real value)
    signal rightClicked

    implicitHeight: A.Appearance.sliderHeight
    implicitWidth: A.Appearance.sliderWidth

    Rectangle {
        id: track

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: A.Appearance.currentFill
        height: A.Appearance.progressHeight
        radius: height / 2
    }

    Rectangle {
        anchors.left: track.left
        anchors.verticalCenter: track.verticalCenter
        color: A.Appearance.foreground
        height: track.height
        radius: track.radius
        width: track.width * root.progress

        Behavior on width {
            enabled: !root.dragging

            NumberAnimation {
                duration: A.Appearance.durationFast
                easing.type: A.Appearance.easingOut
            }
        }
    }

    Rectangle {
        anchors.verticalCenter: track.verticalCenter
        border.color: A.Appearance.popover
        border.width: A.Appearance.popupBorderWidth
        color: A.Appearance.foreground
        height: root.knobSize
        radius: height / 2
        scale: root.hot ? 1.15 : 1
        width: root.knobSize
        x: Math.max(0, Math.min(track.width - width, track.width * (root.mirrored ? 1 - root.progress : root.progress) - width / 2))

        Behavior on scale {
            NumberAnimation {
                duration: A.Appearance.durationControl
            }
        }
        Behavior on x {
            enabled: !root.dragging

            NumberAnimation {
                duration: A.Appearance.durationFast
                easing.type: A.Appearance.easingOut
            }
        }
    }

    MouseArea {
        id: mouseArea

        function valueFromX(x: real): real {
            var clamped = Math.max(0, Math.min(track.width, root.mirrored ? track.width - x : x));
            return track.width > 0 ? Math.max(root.minimum, Math.min(root.maximum, root.minimum + clamped / track.width * root.range)) : root.minimum;
        }

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
        }
        onPositionChanged: function (mouse) {
            if (!root.dragging)
                return;
            var next = valueFromX(mouse.x);
            root.dragValue = next;
            root.moved(next);
        }
        onPressed: function (mouse) {
            if (mouse.button !== Qt.LeftButton)
                return;
            root.dragging = true;
            var next = valueFromX(mouse.x);
            root.dragValue = next;
            root.moved(next);
        }
        onReleased: function (mouse) {
            if (mouse.button !== Qt.LeftButton)
                return;
            root.dragging = false;
        }
        onWheel: function (wheel) {
            var delta = wheel.angleDelta.y > 0 ? root.step : -root.step;
            var next = Math.max(root.minimum, Math.min(root.maximum, root.liveValue + delta));
            root.moved(next);
        }
    }
}
