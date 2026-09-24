import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var output: Pipewire.defaultAudioSink
    readonly property real outputVolume: output && output.audio ? output.audio.volume : 0
    readonly property bool outputMuted: output && output.audio ? output.audio.muted : false

    property var outputTracker: PwObjectTracker {
        objects: [root.output]
    }

    function toggleMute(): void {
        if (output && output.audio)
            output.audio.muted = !output.audio.muted
    }

    function volumeUp(): void {
        if (output && output.audio)
            output.audio.volume = Math.max(0, Math.min(1, output.audio.volume + 0.02))
    }

    function volumeDown(): void {
        if (output && output.audio)
            output.audio.volume = Math.max(0, Math.min(1, output.audio.volume - 0.02))
    }

}
