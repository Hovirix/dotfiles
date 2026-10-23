import QtQuick
import Quickshell
import "../Appearance" as A

// The only OSD window: bottom-center, auto-dismissing, non-focusable.
// The shell supplies presentation properties; this window only owns dismissal.
PanelWindow {
    id: window

    property string icon: ""
    property real value: 0
    property string valueText: ""
    property bool shown: false

    function show(): void {
        shown = true;
        dismiss.restart();
    }

    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: card.implicitHeight
    implicitWidth: card.implicitWidth
    screen: Quickshell.screens[0]
    visible: shown

    mask: Region {
    }

    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: A.Appearance.osdBottomMargin
        left: (screen.width - width) / 2
    }

    Timer {
        id: dismiss

        interval: A.Appearance.osdTimeout

        onTriggered: window.shown = false
    }

    Osd {
        id: card

        icon: window.icon
        value: window.value
        valueText: window.valueText
    }
}
