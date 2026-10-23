import QtQuick
import QtQuick.Controls as Controls
import ".."

Controls.ToolButton {
    id: root

    font.family: Theme.iconFontFamily
    font.pixelSize: Theme.heroGlyphSize
    palette.buttonText: down ? Theme.primary : Theme.mutedForeground

    background: Item {
    }
}
