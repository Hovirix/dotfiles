import QtQuick
import Quickshell
import "../Appearance" as A
import "../Ui" as Ui
import "../Services" as Services

// Native layer-shell OSD card, bottom-center. No compositor rules needed.
PanelWindow {
    id: window

    required property Services.Brightness brightness
    property bool shown: false

    screen: Quickshell.screens[0]
    visible: shown
    focusable: false
    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    anchors {
        left: true
        bottom: true
    }

    margins {
        left: (screen.width - width) / 2
        bottom: 72
    }

    function show(): void {
        shown = true
        dismiss.restart()
    }

    Timer {
        id: dismiss
        interval: 1250
        onTriggered: window.shown = false
    }

    Ui.Osd {
        id: card
        title: "Brightness"
        valueText: `${Math.round(window.brightness.value * 100)}%`
        value: window.brightness.value
    }
}
