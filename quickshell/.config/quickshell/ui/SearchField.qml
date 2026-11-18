import QtQuick
import ".."

// TextInput receives input-method commits that a Keys-driven Text cannot.
TextInput {
    id: root

    property Item keyHandler: null
    property string placeholderText: ""

    Keys.forwardTo: keyHandler ? [keyHandler] : []
    Keys.priority: Keys.BeforeItem
    Keys.enabled: !inputMethodComposing
    clip: true
    color: Theme.foreground
    focus: true
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBody
    verticalAlignment: Text.AlignVCenter
    Accessible.name: placeholderText

    Text {
        anchors.fill: parent
        text: root.placeholderText
        textFormat: Text.PlainText
        font: root.font
        color: Theme.mutedForeground
        verticalAlignment: Text.AlignVCenter
        visible: !root.text && !root.preeditText
    }
}
