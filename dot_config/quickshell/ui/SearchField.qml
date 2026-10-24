import QtQuick
import ".."

// TextInput receives input-method commits that a Keys-driven Text cannot.
TextInput {
    id: root

    property Item keyHandler: null

    Keys.forwardTo: keyHandler ? [keyHandler] : []
    Keys.priority: Keys.BeforeItem
    clip: true
    color: Theme.foreground
    focus: true
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeBody

    cursorDelegate: Item {
    }

    Keys.onPressed: function (event) {
        if (event.modifiers & (Qt.AltModifier | Qt.MetaModifier))
            event.accepted = true;
    }
    onCursorPositionChanged: if (cursorPosition !== length)
        cursorPosition = length
    onSelectedTextChanged: if (selectedText)
        deselect()
}
