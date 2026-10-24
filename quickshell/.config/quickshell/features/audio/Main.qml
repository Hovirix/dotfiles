import QtQuick
import "../../ui" as Ui
import Quickshell.Services.Mpris
import "labels.js" as Utils
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property bool active: popup.content === panel

    // Only inspect bound audio objects; snapshot after removal signals settle.
    readonly property var audioSinks: {
        var list = candidateSinks.slice();
        if (output && list.indexOf(output) < 0)
            list.unshift(output);
        return list;
    }
    readonly property var audioSources: {
        var list = candidateSources.slice();
        if (source && list.indexOf(source) < 0)
            list.unshift(source);
        return list;
    }
    readonly property var audioStreams: {
        var list = [];
        for (var i = 0; i < candidateStreams.length; i++)
            if (candidateStreams[i].audio)
                list.push(candidateStreams[i]);
        return list;
    }
    readonly property var candidateSinks: {
        if (!active)
            return [];
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (n && n.isSink && !n.isStream)
                list.push(n);
        }
        return list;
    }
    readonly property var candidateSources: {
        if (!active)
            return [];
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (n && !n.isSink && !n.isStream && Utils.isAudioSource(n)) {
                var name = n.name || "";
                if (name === "quickshell")
                    continue;
                list.push(n);
            }
        }
        return list;
    }
    readonly property var candidateStreams: {
        if (!active)
            return [];
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (!n || !n.isStream || !Utils.isPlaybackStream(n))
                continue;
            list.push(n);
        }
        return list;
    }
    property var displayAudioSinks: []
    property var displayAudioSources: []
    property var displayAudioStreams: []
    readonly property bool inputMuted: active && source && source.audio ? source.audio.muted : false
    readonly property real inputPeak: inputPeakMonitor.peak
    readonly property real inputVolume: active && source && source.audio ? source.audio.volume : 0
    readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property PwNode output: Pipewire.defaultAudioSink
    readonly property bool outputMuted: output && output.audio ? output.audio.muted : false
    readonly property real outputPeak: outputPeakMonitor.peak
    property PwObjectTracker outputTracker: PwObjectTracker {
        objects: [root.output]
    }
    readonly property real outputVolume: output && output.audio ? output.audio.volume : 0
    readonly property Component panel: Component {
        Panel {
            audio: root
            controller: root.popup
        }
    }
    required property Ui.Popup popup
    readonly property PwNode source: Pipewire.defaultAudioSource

    signal modelsChanged

    function clearDisplayAudioModels(): void {
        audioModelRefreshTimer.stop();
        displayAudioSinks = [];
        displayAudioSources = [];
        displayAudioStreams = [];
    }

    function refreshDisplayAudioModels(): void {
        if (!active)
            return;
        displayAudioSinks = audioSinks.slice();
        displayAudioSources = audioSources.slice();
        displayAudioStreams = audioStreams.slice();
        modelsChanged();
    }

    function scheduleDisplayAudioModelRefresh(): void {
        if (!active)
            return;
        audioModelRefreshTimer.restart();
    }

    function setDefaultSink(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    function setInputVolume(v: real): void {
        if (!source || !source.audio)
            return;
        source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function setOutputVolume(v: real): real {
        if (!output || !output.audio)
            return outputVolume;
        var volume = Math.max(0, Math.min(1, v));
        output.audio.volume = volume;
        return volume;
    }

    function setStreamVolume(node: PwNode, volume: real): void {
        if (node && node.audio)
            node.audio.volume = Math.max(0, Math.min(1.5, volume));
    }

    function streamLabel(node: PwNode): string {
        return Utils.streamLabel(node, mprisPlayers, displayAudioStreams);
    }

    function toggleInputMute(): void {
        if (source && source.audio)
            source.audio.muted = !source.audio.muted;
    }

    function toggleMute(): void {
        if (output && output.audio)
            output.audio.muted = !output.audio.muted;
    }

    function toggleStreamMute(node: PwNode): void {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    function volumeDown(): void {
        setOutputVolume(outputVolume - 0.02);
    }

    function volumeUp(): void {
        setOutputVolume(outputVolume + 0.02);
    }

    Component.onCompleted: if (active)
        refreshDisplayAudioModels()
    onActiveChanged: {
        if (active)
            refreshDisplayAudioModels();
        else
            clearDisplayAudioModels();
    }
    onAudioSinksChanged: scheduleDisplayAudioModelRefresh()
    onAudioSourcesChanged: scheduleDisplayAudioModelRefresh()
    onAudioStreamsChanged: scheduleDisplayAudioModelRefresh()

    PwObjectTracker {
        objects: root.candidateSinks
    }

    PwObjectTracker {
        objects: root.candidateSources
    }

    PwObjectTracker {
        objects: root.candidateStreams
    }

    PwObjectTracker {
        objects: root.active ? [root.source] : []
    }

    PwNodePeakMonitor {
        id: inputPeakMonitor

        enabled: root.active && !!root.source
        node: root.source
    }

    PwNodePeakMonitor {
        id: outputPeakMonitor

        enabled: root.active && !!root.output
        node: root.output
    }

    Timer {
        id: audioModelRefreshTimer

        interval: 75
        repeat: false

        onTriggered: root.refreshDisplayAudioModels()
    }
}
