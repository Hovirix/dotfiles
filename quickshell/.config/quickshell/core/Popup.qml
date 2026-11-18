import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../ui" as Ui

// One persistent surface; navigation only replaces the loaded content.
PanelWindow {
    id: root

    required property Component home
    property alias content: loader.sourceComponent
    readonly property alias item: loader.item
    readonly property bool canGoBack: content !== null && content !== home
    readonly property real screenH: screen ? screen.height : 0
    readonly property real screenW: screen ? screen.width : 0

    function close(): void {
        loader.sourceComponent = null;
    }

    function open(component: Component): void {
        loader.sourceComponent = component;
    }

    function back(): void {
        if (canGoBack)
            open(home);
        else
            close();
    }

    function toggle(component: Component): void {
        if (content === component)
            close();
        else
            open(component);
    }

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]
    implicitWidth: Math.max(1, Math.min(Theme.popupWidth, screenW - Theme.space4 * 2))
    implicitHeight: Math.max(1, Math.min(item && item.implicitHeight > 0 ? item.implicitHeight + loader.y + Theme.menuPadding : Theme.popupHeight, Theme.popupHeight, screenH - Theme.space4 * 2))
    visible: loader.sourceComponent !== null
    anchors.top: true
    anchors.left: true
    margins.top: Math.max(0, Math.round((screenH - height) / 2))
    margins.left: Math.max(0, Math.round((screenW - width) / 2))

    Rectangle {
        anchors.fill: parent
        border.color: Theme.primary
        border.width: Theme.popupBorderWidth
        color: Theme.popover
        radius: Theme.radius

        Item {
            id: header
            x: Theme.menuPadding
            y: Theme.menuPadding
            width: parent.width - Theme.menuPadding * 2
            height: Theme.menuHeaderHeight
            visible: root.canGoBack

            Ui.IconButton {
                id: backButton
                width: Theme.menuHeaderHeight
                height: parent.height
                source: Qt.resolvedUrl("../ui/icons/arrow-left.svg")
                label: qsTr("Back")
                onClicked: root.back()
            }

            Text {
                anchors.left: backButton.right
                anchors.leftMargin: Theme.space2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.item ? root.item.title : ""
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeading
                font.weight: Theme.fontWeightMedium
            }
        }

        Ui.Separator {
            x: Theme.menuPadding
            y: header.y + header.height + Theme.space2
            width: parent.width - Theme.menuPadding * 2
            visible: root.canGoBack
        }

        Loader {
            id: loader
            x: Theme.menuPadding
            y: root.canGoBack ? header.y + header.height + Theme.space4 + Theme.borderWidth : Theme.menuPadding
            width: Math.max(0, parent.width - Theme.menuPadding * 2)
            height: Math.max(0, parent.height - y - Theme.menuPadding)
            clip: true
            onLoaded: item.focusMenu()
        }
    }
}
