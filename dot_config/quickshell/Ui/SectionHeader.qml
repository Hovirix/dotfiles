import QtQuick
import "../Appearance" as A

// Small-caps-style label introducing a menu section.
Text {
    property color foreground: A.Appearance.mutedForeground

    textFormat: Text.PlainText
    color: foreground
    font.family: A.Appearance.fontFamily
    font.pixelSize: A.Appearance.fontSizeBody
    font.weight: A.Appearance.fontWeightMedium

    renderType: Text.NativeRendering
}
