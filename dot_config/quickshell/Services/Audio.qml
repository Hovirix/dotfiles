import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var output: Pipewire.defaultAudioSink
    readonly property var input: Pipewire.defaultAudioSource
    readonly property real outputVolume: output && output.audio ? output.audio.volume : 0
    readonly property bool outputMuted: output && output.audio ? output.audio.muted : false
    readonly property real inputVolume: input && input.audio ? input.audio.volume : 0
    readonly property var outputs: Pipewire.nodes.values.filter(node => node && !node.isStream && node.isSink && node.audio)
    readonly property var inputs: Pipewire.nodes.values.filter(node => node && !node.isStream && !node.isSink && node.audio)

    property var bindingTracker: PwObjectTracker {
        objects: [root.output, root.input]
    }

    function toggleMute(): void {
        if (output && output.audio)
            output.audio.muted = !output.audio.muted
    }

    function volumeUp(): void {
        if (output && output.audio)
            output.audio.volume = Math.max(0, Math.min(1, output.audio.volume + 0.05))
    }

    function volumeDown(): void {
        if (output && output.audio)
            output.audio.volume = Math.max(0, Math.min(1, output.audio.volume - 0.05))
    }

    function setOutput(node: var): void {
        Pipewire.preferredDefaultAudioSink = node
    }

    function setInput(node: var): void {
        Pipewire.preferredDefaultAudioSource = node
    }
}
