import QtQuick
import ".."

// Small-caps-style label introducing a menu section.
Text {
    property color foreground: Theme.foreground

    color: Qt.darker(foreground, 1.4)
    font.bold: true
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeCaption
    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    topPadding: Math.ceil(font.pixelSize * 0.15)
}
