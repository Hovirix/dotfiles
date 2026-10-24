import QtQuick

// Drop-in key dispatcher for keyboard-driven menus. The menu keeps its own
// state machine (focusSection, selectedIndex, action rules); the
// boilerplate key handling lives here.
//
// Keys.priority: Keys.BeforeItem means this handler gets keys first, even
// when a descendant has activeFocus.
Item {
    id: root

    property bool qCloses: true
    property bool spaceActivates: true
    property bool textInputBackspace: false
    property bool textInputEdits: false
    property bool vimNavigation: true

    signal activateRequested
    signal backspaceRequested
    signal clearTextRequested
    signal closeRequested
    signal moveRequested(int dx, int dy)
    signal pageRequested(int direction)
    signal tabRequested(int direction)
    signal textKey(string text)

    Keys.priority: Keys.BeforeItem
    focus: true

    Keys.onPressed: function (event) {
        if (textInputEdits && event.key === Qt.Key_U && event.modifiers === Qt.ControlModifier) {
            clearTextRequested();
            event.accepted = true;
            return;
        }
        if (textInputEdits && (event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown)) {
            pageRequested(event.key === Qt.Key_PageUp ? -1 : 1);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Escape) {
            closeRequested();
            event.accepted = true;
            return;
        }
        if (qCloses && event.key === Qt.Key_Q) {
            // Swallow the press; the panel closes on release below. Closing
            // on press would unmap the surface immediately, handing focus
            // back to the app before the release arrives — Mango delivers
            // each key event once, to the focused surface, so the app
            // would then observe a lone Q release.
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Backspace) {
            if (textInputBackspace) {
                event.accepted = false;
                return;
            }
            backspaceRequested();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            tabRequested((event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab ? -1 : 1);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Down || (vimNavigation && event.text === "j")) {
            moveRequested(0, 1);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Up || (vimNavigation && event.text === "k")) {
            moveRequested(0, -1);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Right || (vimNavigation && event.text === "l")) {
            moveRequested(1, 0);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Left || (vimNavigation && event.text === "h")) {
            moveRequested(-1, 0);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateRequested();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Space && spaceActivates) {
            activateRequested();
            event.accepted = true;
            return;
        }
        if (event.text && event.text.length === 1) {
            if (textInputEdits)
                event.accepted = false;
            else
                textKey(event.text);
        }
    }
    Keys.onReleased: function (event) {
        if (qCloses && event.key === Qt.Key_Q) {
            closeRequested();
            event.accepted = true;
        }
    }
}
