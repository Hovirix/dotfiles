import QtQuick
import Quickshell
import "../Appearance" as A
import "../Components/Audio" as Audio
import "../Components/Brightness" as Brightness

// The only OSD window: bottom-center, auto-dismissing, non-focusable.
// showVolume()/showBrightness() flip `kind`; the card binds title and
// value to the matching live service. No compositor rules needed.
PanelWindow {
    id: window

    required property Audio.Service audio
    required property Brightness.Service brightness
    readonly property bool isVolume: kind === "volume"
    property string kind: "volume"
    property bool shown: false

    function showBrightness(): void {
        kind = "brightness";
        shown = true;
        dismiss.restart();
    }

    function showVolume(): void {
        kind = "volume";
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

        icon: !window.isVolume ? "󰍹" : window.audio.outputMuted ? "" : ""
        value: window.isVolume ? (window.audio.outputMuted ? 0 : window.audio.outputVolume) : window.brightness.value
        valueText: `${Math.round(value * 100)}%`
    }
}
