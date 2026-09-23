import QtQuick

// Drop-in key dispatcher for keyboard-driven menus. The menu keeps its own
// state machine (focusSection, selectedIndex, action rules); the
// boilerplate key handling lives here.
//
// Keys.priority: Keys.BeforeItem means this handler gets keys first, even
// when a descendant has activeFocus. When a menu has an inline editor the
// menu must set `blocked: editor.activeFocus` so keys pass through.
Item {
    id: root

    property bool blocked: false
    property bool vimNavigation: true
    property bool spaceActivates: true

    signal moveRequested(int dx, int dy)
    signal activateRequested()
    signal closeRequested()
    signal backspaceRequested()
    signal tabRequested(int direction)
    signal textKey(string text)

    focus: true
    Keys.priority: Keys.BeforeItem
    Keys.onPressed: function(event) {
        if (blocked)
            return

        if (event.key === Qt.Key_Q) {
            // Swallow the press; the panel closes on release below. Closing
            // on press would unmap the surface immediately, handing focus
            // back to the app before the release arrives — Mango delivers
            // each key event once, to the focused surface, so the app
            // would then observe a lone Q release.
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Backspace) {
            backspaceRequested()
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            tabRequested((event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab ? -1 : 1)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Down || (vimNavigation && event.text === "j")) {
            moveRequested(0, 1)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Up || (vimNavigation && event.text === "k")) {
            moveRequested(0, -1)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Right || (vimNavigation && event.text === "l")) {
            moveRequested(1, 0)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Left || (vimNavigation && event.text === "h")) {
            moveRequested(-1, 0)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateRequested()
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Space && spaceActivates) {
            activateRequested()
            event.accepted = true
            return
        }
        if (event.text && event.text.length === 1) {
            textKey(event.text)
        }
    }

    Keys.onReleased: function(event) {
        if (blocked)
            return

        if (event.key === Qt.Key_Q) {
            closeRequested()
            event.accepted = true
        }
    }
}
