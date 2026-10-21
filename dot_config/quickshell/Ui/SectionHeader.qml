import QtQuick
import "../Appearance" as A

// Small-caps-style label introducing a menu section.
Text {
    property color foreground: A.Appearance.foreground

    color: Qt.darker(foreground, 1.4)
    font.bold: true
    font.family: A.Appearance.fontFamily
    font.pixelSize: A.Appearance.fontSizeCaption
    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    topPadding: Math.ceil(font.pixelSize * 0.15)
}
