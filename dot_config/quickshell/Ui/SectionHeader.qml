import QtQuick
import "../Appearance" as A

// Small-caps-style label introducing a menu section.
Text {
    property color foreground: A.Appearance.mutedForeground
    property string fontFamily: A.Appearance.fontFamily
    property real fontSize: A.Appearance.fontSizeBody

    textFormat: Text.PlainText
    color: foreground
    font.family: fontFamily
    font.pixelSize: fontSize
    font.weight: A.Appearance.fontWeightMedium

    renderType: Text.NativeRendering
}
