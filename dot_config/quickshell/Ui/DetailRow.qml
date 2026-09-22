import QtQuick
import "../Appearance" as A

// Fixed icon column keeps every row aligned regardless of glyph width.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""

    property color iconColor: A.Appearance.mutedForeground
    property color labelColor: A.Appearance.mutedForeground
    property color valueColor: A.Appearance.foreground

    implicitHeight: A.Appearance.rowHeight
    height: implicitHeight

    // Fixed icon column.
    Item {
        id: iconBox

        width: A.Appearance.iconColumnWidth
        height: parent.height

        anchors.left: parent.left

        Text {
            anchors.centerIn: parent

            text: root.icon

            color: root.iconColor

            font.family: A.Appearance.fontFamily
            font.pixelSize: A.Appearance.iconSize
            font.weight: Font.Normal

            renderType: Text.NativeRendering

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Label.
    Text {
        anchors.left: iconBox.right
        anchors.leftMargin: A.Appearance.iconLabelGap
        anchors.verticalCenter: parent.verticalCenter

        text: root.label

        color: root.labelColor

        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeLabel
        font.weight: A.Appearance.fontWeightNormal

        renderType: Text.NativeRendering
    }

    // Value.
    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: root.value

        color: root.valueColor

        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeValue
        font.weight: A.Appearance.fontWeightNormal

        renderType: Text.NativeRendering

        horizontalAlignment: Text.AlignRight
    }
}
