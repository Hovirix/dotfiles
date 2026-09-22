import QtQuick
import Quickshell
import "../Ui" as Ui
import "../Services" as Services

// Native layer-shell OSD card, bottom-center. No compositor rules needed.
PanelWindow {
    id: window

    required property Services.Audio audio
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
        title: "Volume"
        valueText: window.audio.outputMuted ? "Muted" : `${Math.round(window.audio.outputVolume * 100)}%`
        value: window.audio.outputMuted ? 1 : window.audio.outputVolume
    }
}
