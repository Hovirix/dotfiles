import QtQuick
import "../Appearance" as A

// Shared chrome for keyboard-and-mouse-navigable menu rows. Visuals derive
// only from `hasCursor` / `current` — never from containsMouse — so a
// single highlight exists on screen across both input methods.
Rectangle {
    id: root

    // `data` (not `children`) so rows can also host non-visual children
    // such as HoverHandler alongside their visual content.
    default property alias content: inner.data

    property bool hasCursor: false
    property bool current: false
    property int contentPadding: A.Appearance.space2

    radius: A.Appearance.radius
    color: hasCursor ? A.Appearance.accent : (current ? Qt.rgba(A.Appearance.primary.r, A.Appearance.primary.g, A.Appearance.primary.b, 0.12) : "transparent")

    Behavior on color {
        ColorAnimation {
            duration: A.Appearance.durationFast
        }
    }

    Item {
        id: inner

        anchors.fill: parent
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding
    }
}
