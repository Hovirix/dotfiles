import QtQuick
import ".."

// Fixed icon column keeps every row aligned regardless of glyph width.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""

    height: implicitHeight
    implicitHeight: Theme.rowHeight

    // Fixed icon column.
    Item {
        id: iconBox

        anchors.left: parent.left
        height: parent.height
        width: Theme.iconColumnWidth

        Text {
            anchors.centerIn: parent
            color: Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.iconSize
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
        anchors.leftMargin: Theme.iconLabelGap
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBody
        font.weight: Theme.fontWeightNormal
        renderType: Text.NativeRendering
        text: root.label
    }

    // Value.
    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBody
        font.weight: Theme.fontWeightNormal
        horizontalAlignment: Text.AlignRight
        renderType: Text.NativeRendering
        text: root.value
    }
}
