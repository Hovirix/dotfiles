import QtQuick
import Quickshell

// The only OSD window: bottom-center, auto-dismissing, non-focusable.
// showVolume()/showBrightness() flip `kind`; the card binds title and
// value to the matching live service. No compositor rules needed.
PanelWindow {
    id: window

    required property var audio
    required property var brightness
    property string kind: "volume"
    property bool shown: false

    readonly property bool isVolume: kind === "volume"

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

    function showVolume(): void {
        kind = "volume"
        shown = true
        dismiss.restart()
    }

    function showBrightness(): void {
        kind = "brightness"
        shown = true
        dismiss.restart()
    }

    Timer {
        id: dismiss
        interval: 1250
        onTriggered: window.shown = false
    }

    Osd {
        id: card
        title: window.isVolume ? "Volume" : "Brightness"
        valueText: window.isVolume
            ? (window.audio.outputMuted ? "Muted" : `${Math.round(window.audio.outputVolume * 100)}%`)
            : `${Math.round(window.brightness.value * 100)}%`
        value: window.isVolume
            ? (window.audio.outputMuted ? 0 : window.audio.outputVolume)
            : window.brightness.value
    }
}
