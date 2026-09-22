import QtQuick
import QtQuick.Controls
import "../Appearance" as A

// Small hover hint. Declare inside the hovered item, bind `visible`.
ToolTip {
  id: root

  property color tipForeground: A.Appearance.foreground
    property color tipBackground: A.Appearance.popover
    property string fontFamily: A.Appearance.fontFamily
    property real fontSize: A.Appearance.fontSizeBody

    delay: 400
    padding: 0

    background: Rectangle {
        color: tipBackground
        border.width: A.Appearance.borderWidth
        border.color: A.Appearance.border
        radius: A.Appearance.radius
    }

    contentItem: Text {
        textFormat: Text.PlainText
        text: root.text
        color: tipForeground
        font.family: fontFamily
        font.pixelSize: fontSize
        leftPadding: A.Appearance.space2
        rightPadding: A.Appearance.space2
        topPadding: A.Appearance.space1Half
        bottomPadding: A.Appearance.space1Half
        renderType: Text.NativeRendering
    }
}
