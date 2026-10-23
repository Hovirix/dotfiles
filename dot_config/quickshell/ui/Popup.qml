import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// Native layer-shell centered popup. Transparent full-screen surface that
// catches outside clicks to dismiss; the card swallows its own clicks.
// No compositor window rules needed.
PanelWindow {
    id: root

    property var actions: ({})
    readonly property real cardTop: card.y
    property alias content: loader.sourceComponent
    readonly property int contentHeight: item ? item.menuHeight : Theme.buttonHeight
    readonly property int contentPadding: menuStyle ? Theme.menuPadding : Theme.dialogPadding
    readonly property int contentTop: item && item.cardTop !== undefined ? item.cardTop : -1
    readonly property int contentWidth: item ? item.menuWidth : Theme.popupWidthStandard
    readonly property alias item: loader.item
    readonly property bool menuStyle: item && item.menuStyle === true
    readonly property real screenH: screen ? screen.height : 0
    readonly property real screenW: screen ? screen.width : 0

    function activate(name: string): void {
        if (actions[name])
            actions[name]();
    }

    function close(): void {
        loader.sourceComponent = null;
    }

    function open(component: Component): void {
        loader.sourceComponent = component;
    }

    function toggle(component: Component): void {
        loader.sourceComponent = loader.sourceComponent === component ? null : component;
    }

    // Menus hosted here are keyboard-driven: take exclusive keyboard focus
    // so keys (including q) never reach the app underneath. The hidden
    // window is unmapped and takes no focus.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]
    visible: loader.sourceComponent !== null

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

        onClicked: root.close()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.popover, 0.5)
        visible: root.menuStyle
    }

    Rectangle {
        id: card

        border.color: Theme.primary
        border.width: Theme.popupBorderWidth
        color: Theme.popover
        height: Math.min(root.contentHeight + border.width * 2, root.screenH - (root.menuStyle ? Theme.menuScreenMargin : Theme.dialogPadding) * 2)
        radius: Theme.radius
        width: Math.min(root.contentWidth, root.screenW - (root.menuStyle ? Theme.menuScreenMargin : Theme.dialogPadding) * 2)
        x: Math.round((root.screenW - width) / 2)
        y: root.contentTop >= 0 ? root.contentTop : Math.round((root.screenH - height) / 2)

        // Swallow card clicks so they never reach the dismiss area.
        MouseArea {
            acceptedButtons: Qt.AllButtons
            anchors.fill: parent
        }

        Loader {
            id: loader

            anchors.fill: parent
            anchors.margins: root.contentPadding + card.border.width

            onLoaded: item.focusMenu()
        }
    }
}
