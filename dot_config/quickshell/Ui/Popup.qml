import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Appearance" as A

// Native layer-shell centered popup. Transparent full-screen surface that
// catches outside clicks to dismiss; the card swallows its own clicks.
// No compositor window rules needed.
PanelWindow {
    id: root

    default property alias content: holder.children

    property int contentWidth: A.Appearance.popupWidthStandard
    property int contentHeight: 200
    property bool shown: false

    signal closeRequested()

    screen: Quickshell.screens[0]
    visible: shown
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    // Menus hosted here are keyboard-driven: take exclusive keyboard focus
    // so keys (including q) never reach the app underneath. The hidden
    // window is unmapped and takes no focus.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    readonly property real screenW: screen ? screen.width : 0
    readonly property real screenH: screen ? screen.height : 0

    // Outside clicks dismiss. Disabled while hidden with the window.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: root.closeRequested()
    }

    Rectangle {
        id: card

        x: Math.round((root.screenW - root.contentWidth) / 2)
        y: Math.round((root.screenH - root.contentHeight) / 2)
        width: root.contentWidth
        height: root.contentHeight
        color: A.Appearance.popover
        border.width: A.Appearance.borderWidth
        border.color: A.Appearance.primary
        radius: A.Appearance.radius

        // Swallow card clicks so they never reach the dismiss area.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Item {
            id: holder

            anchors.fill: parent
            anchors.margins: A.Appearance.dialogPadding
        }
    }
}
