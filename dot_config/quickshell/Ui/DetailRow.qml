import QtQuick
import "../Appearance" as A

// Fixed icon column keeps every row aligned regardless of glyph width.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""

    height: implicitHeight
    implicitHeight: A.Appearance.rowHeight

    // Fixed icon column.
    Item {
        id: iconBox

        anchors.left: parent.left
        height: parent.height
        width: A.Appearance.iconColumnWidth

        Text {
            anchors.centerIn: parent
            color: A.Appearance.mutedForeground
            font.family: A.Appearance.iconFontFamily
            font.pixelSize: A.Appearance.iconSize
            font.weight: Font.Normal
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
            text: root.icon
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Label.
    Text {
        anchors.left: iconBox.right
        anchors.leftMargin: A.Appearance.iconLabelGap
        anchors.verticalCenter: parent.verticalCenter
        color: A.Appearance.mutedForeground
        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeBody
        font.weight: A.Appearance.fontWeightNormal
        renderType: Text.NativeRendering
        text: root.label
    }

    // Value.
    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: A.Appearance.foreground
        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeBody
        font.weight: A.Appearance.fontWeightNormal
        horizontalAlignment: Text.AlignRight
        renderType: Text.NativeRendering
        text: root.value
    }
}
