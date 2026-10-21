import QtQuick
import "../Appearance" as A

// Shared chrome for keyboard-and-mouse-navigable menu rows. Visuals derive
// only from `hasCursor` / `current` — never from containsMouse — so a
// single highlight exists on screen across both input methods.
CursorSurface {
    id: root

    // `data` (not `children`) so rows can also host non-visual children
    // such as HoverHandler alongside their visual content.
    default property alias content: inner.data
    property int contentPadding: A.Appearance.space2

    Item {
        id: inner

        anchors.fill: parent
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding
    }
}
