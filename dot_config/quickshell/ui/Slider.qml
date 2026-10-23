import QtQuick
import QtQuick.Controls as Controls
import ".."

Item {
    id: root

    readonly property bool dragging: control.pressed
    readonly property real liveValue: control.value
    property alias maximum: control.to
    property alias minimum: control.from
    property alias step: control.stepSize
    property alias value: control.value

    signal moved(real value)
    signal rightClicked

    implicitHeight: Theme.sliderHeight
    implicitWidth: Theme.sliderWidth

    Controls.Slider {
        id: control

        anchors.fill: parent
        from: 0
        padding: 0
        stepSize: 0.05
        to: 1
        wheelEnabled: true

        background: Rectangle {
            color: Theme.currentFill
            height: Theme.progressHeight
            radius: height / 2
            width: control.availableWidth
            x: control.leftPadding
            y: (control.height - height) / 2

            Rectangle {
                color: Theme.foreground
                height: parent.height
                radius: parent.radius
                width: parent.width * control.position
                x: control.mirrored ? parent.width - width : 0
            }
        }
        handle: Rectangle {
            border.color: Theme.popover
            border.width: Theme.popupBorderWidth
            color: Theme.foreground
            height: width
            radius: width / 2
            scale: control.hovered || control.pressed ? 1.15 : 1
            width: Theme.sliderKnobSize
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: (control.height - height) / 2
        }

        onMoved: root.moved(value)

        TapHandler {
            acceptedButtons: Qt.RightButton

            onTapped: root.rightClicked()
        }
    }
}
