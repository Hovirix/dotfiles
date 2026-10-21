import QtQuick
import "../Appearance" as A

// The caller owns the value:
// bind `checked` to real state and flip it in response to `toggled()`.
Item {
    id: root

    property bool checked: false
    property bool hasCursor: false
    readonly property bool hot: hasCursor || mouse.containsMouse
    property int knobInset: Math.max(1, Math.round((trackHeight - knobSize) / 2))
    property int knobSize: Math.max(6, Math.round(trackHeight * 0.72))
    readonly property bool mirrored: LayoutMirroring.enabled
    property int trackHeight: A.Appearance.switchHeight
    property int trackWidth: Math.round(trackHeight * 1.9)

    signal hovered(bool isHovered)
    signal toggled

    implicitHeight: trackHeight + A.Appearance.space15 * 2
    implicitWidth: trackWidth + A.Appearance.space15 * 2

    Rectangle {
        anchors.fill: parent
        border.color: A.Appearance.cursorBorder
        border.width: A.Appearance.borderWidth
        color: "transparent"
        radius: A.Appearance.radius
        visible: root.hot
    }

    Rectangle {
        id: track

        anchors.centerIn: parent
        border.color: A.Appearance.normalBorder
        border.width: root.checked ? 0 : A.Appearance.borderWidth
        color: root.checked ? A.Appearance.currentFill : A.Appearance.normalFill
        height: root.trackHeight
        radius: A.Appearance.radius
        width: root.trackWidth

        Behavior on color {
            ColorAnimation {
                duration: A.Appearance.durationControl
                easing.type: A.Appearance.easingOut
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked ? A.Appearance.foreground : Qt.darker(A.Appearance.foreground, 1.25)
            height: root.knobSize
            radius: A.Appearance.radius
            width: root.knobSize
            x: root.checked !== root.mirrored ? track.width - width - root.knobInset : root.knobInset

            Behavior on x {
                NumberAnimation {
                    duration: A.Appearance.durationControl
                    easing.type: A.Appearance.easingOut
                }
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.toggled()
        onContainsMouseChanged: root.hovered(containsMouse)
    }
}
