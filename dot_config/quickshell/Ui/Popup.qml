import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Appearance" as A

// Native layer-shell centered popup. Transparent full-screen surface that
// catches outside clicks to dismiss; the card swallows its own clicks.
// No compositor window rules needed.
PanelWindow {
    id: root

    readonly property real cardTop: card.y
    default property alias content: holder.children
    property int contentHeight: 200
    property int contentPadding: A.Appearance.dialogPadding
    property int contentTop: -1
    property int contentWidth: A.Appearance.popupWidthStandard
    property bool menuStyle: false
    readonly property real screenH: screen ? screen.height : 0
    readonly property real screenW: screen ? screen.width : 0
    property bool shown: false

    signal closeRequested

    // Menus hosted here are keyboard-driven: take exclusive keyboard focus
    // so keys (including q) never reach the app underneath. The hidden
    // window is unmapped and takes no focus.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]
    visible: shown

    anchors {
        bottom: true
        left: true
        right: true
        top: true
    }

    // Outside clicks dismiss. Disabled while hidden with the window.
    MouseArea {
        acceptedButtons: Qt.AllButtons
        anchors.fill: parent

        onClicked: root.closeRequested()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(A.Appearance.popover, 0.5)
        visible: root.menuStyle
    }

    Rectangle {
        id: card

        border.color: A.Appearance.primary
        border.width: A.Appearance.popupBorderWidth
        color: A.Appearance.popover
        height: Math.min(root.contentHeight + border.width * 2, root.screenH - (root.menuStyle ? A.Appearance.menuScreenMargin : A.Appearance.dialogPadding) * 2)
        radius: A.Appearance.radius
        width: Math.min(root.contentWidth, root.screenW - (root.menuStyle ? A.Appearance.menuScreenMargin : A.Appearance.dialogPadding) * 2)
        x: Math.round((root.screenW - width) / 2)
        y: root.contentTop >= 0 ? root.contentTop : Math.round((root.screenH - height) / 2)

        // Swallow card clicks so they never reach the dismiss area.
        MouseArea {
            acceptedButtons: Qt.AllButtons
            anchors.fill: parent
        }

        Item {
            id: holder

            anchors.fill: parent
            anchors.margins: root.contentPadding + card.border.width
        }
    }
}
