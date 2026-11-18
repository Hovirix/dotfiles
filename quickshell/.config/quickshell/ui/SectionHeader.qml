import QtQuick
import ".."

// Secondary label introducing a section.
Text {
    property color foreground: Theme.foreground

    color: Qt.darker(foreground, 1.4)
    font.weight: Theme.fontWeightMedium
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBodySmall
    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    topPadding: Math.ceil(font.pixelSize * 0.15)
}
