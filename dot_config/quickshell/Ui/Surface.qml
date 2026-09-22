import QtQuick
import "../Appearance" as A

// Lyra popover surface: square, thin peach ring, 100ms fade + zoom.
// Content is a Column so the surface sizes itself from its children.
Rectangle {
    id: root

    default property alias content: content.data

    property int contentPadding: A.Appearance.panelPadding
    property bool shown: true

    color: A.Appearance.popover

    border.width: A.Appearance.borderWidth
    border.color: A.Appearance.peach

    radius: A.Appearance.radius

    opacity: shown ? 1 : 0
    visible: opacity > 0.01
    scale: shown ? A.Appearance.normalScale : A.Appearance.enterScale
    transformOrigin: Item.Center

    Behavior on opacity {
        NumberAnimation {
            duration: A.Appearance.durationFast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: A.Appearance.durationFast
        }
    }

    implicitWidth: content.implicitWidth + contentPadding * 2
    implicitHeight: content.implicitHeight + contentPadding * 2

    Column {
        id: content

        x: root.contentPadding
        y: root.contentPadding
        width: root.width - root.contentPadding * 2
    }
}
