import QtQuick
import "../Appearance" as A

// Bare on/off switch, Lyra square geometry. The caller owns the value:
// bind `checked` to real state and flip it in response to `toggled()`.
Item {
    id: root

    property bool checked: false
    property bool busy: false
    property bool interactive: true
    property bool hasCursor: false

    property color foreground: A.Appearance.foreground

    signal toggled()
    signal hovered(bool isHovered)

    readonly property alias containsMouse: mouse.containsMouse
    readonly property bool hot: hasCursor || mouse.containsMouse

    property int trackWidth: 32
    property int trackHeight: 18
    property int knobSize: 12
    property int knobInset: 3

    implicitWidth: trackWidth
    implicitHeight: trackHeight

    Rectangle {
        anchors.fill: parent
        visible: root.hot
        color: "transparent"
        radius: A.Appearance.radius
        border.width: A.Appearance.borderWidth
        border.color: A.Appearance.primary
    }

    Rectangle {
        id: track

        width: root.trackWidth
        height: root.trackHeight
        anchors.centerIn: parent
        radius: A.Appearance.radius
        color: root.checked ? A.Appearance.primary : A.Appearance.input
        border.width: A.Appearance.borderWidth
        border.color: root.checked ? A.Appearance.primary : A.Appearance.border

        Behavior on color {
            ColorAnimation {
                duration: A.Appearance.durationFast
                easing.type: A.Appearance.easingOut
            }
        }

        Rectangle {
            width: root.knobSize
            height: root.knobSize
            radius: A.Appearance.radius
            x: root.checked ? track.width - width - root.knobInset : root.knobInset
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked ? A.Appearance.primaryForeground : A.Appearance.foreground

            Behavior on x {
                NumberAnimation {
                    duration: A.Appearance.durationFast
                    easing.type: A.Appearance.easingOut
                }
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered(containsMouse)
        onClicked: if (!root.busy) root.toggled()
    }
}
