pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "../../Appearance" as A
import "../../Ui" as Ui
import "./audio-model.js" as Model

Item {
    id: root

    // Identify true playback streams without reading node.properties here:
    // PwNode.properties is invalid until the node is bound, and reading it while
    // capture streams are appearing (for example, when Voxtype starts recording)
    // can destabilize Quickshell's Pipewire service. Quickshell versions differ
    // in how `type` is exposed (media.class, enum name, or numeric enum), but
    // playback streams consistently accept audio input from clients and publish
    // `isSink: true`; capture streams publish as stream sources.

    readonly property var audioSinks: {
        var list = candidateSinks.slice();
        if (sink && list.indexOf(sink) < 0)
            list.unshift(sink);
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
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (n && n.isSink && !n.isStream)
                list.push(n);
        }
        return list;
    }
    readonly property var candidateSources: {
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (n && !n.isSink && !n.isStream && Model.isAudioSource(n)) {
                var name = n.name || "";
                if (name === "quickshell")
                    continue;
                list.push(n);
            }
        }
        return list;
    }
    readonly property var candidateStreams: {
        var list = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (!n || !n.isStream || !Model.isPlaybackStream(n))
                continue;
            list.push(n);
        }
        return list;
    }
    required property var controller
    property bool cursorActive: false

    // Feed Repeaters with panel-local snapshots instead of the live PipeWire
    // model. PipeWire can remove nodes while Quickshell is dispatching the
    // removal signal; rebuilding a Repeater from that signal path has crashed
    // in Quickshell's PipeWire service. The snapshot timer lets that mutation
    // settle first, and closed panels keep their repeaters detached entirely.
    property var displayAudioSinks: []
    property var displayAudioSources: []
    property var displayAudioStreams: []

    // Single cursor model shared by keyboard and mouse. Sections:
    //   "output"  — output slider + sink device list
    //   "input"   — input slider + source device list
    //   "streams" — per-app playback streams
    // selectedIndex semantics within a section:
    //   -1            → on the slider row (h/l adjusts volume, m/Enter mute)
    //   0..N-1        → on the Nth device/stream row
    // Visuals derive from hasCursor/current via SelectRow, never
    // from containsMouse — that's what keeps the highlight unique across
    // keyboard + mouse.
    property string focusSection: "output"
    // The hero switch mirrors the output mute only. It used to track
    // output+input combined, which left it stuck on whenever the mic stayed
    // unmuted even though the output had muted.
    readonly property bool hasOutput: !!(volumeSink && volumeSink.audio)

    // "header" is a virtual section for the hero output mute toggle; it sits
    // above the output section so the speaker can be muted from the keyboard.
    readonly property bool headerHasCursor: cursorActive && focusSection === "header"
    readonly property bool inputMuted: source && source.audio ? source.audio.muted : false
    readonly property real inputVolume: source && source.audio ? source.audio.volume : 0
    readonly property int menuHeight: Math.min(panelColumn.implicitHeight + A.Appearance.dialogPadding * 2, A.Appearance.popupMaxHeight)

    // `opened` stays true whenever loaded: the window only loads this while
    // the controller selects audio, and unloading tears down the PipeWire
    // repeaters and peak monitors with it.
    readonly property int menuWidth: A.Appearance.popupWidthStandard
    readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property bool opened: controller.current === "audio"
    readonly property bool outputMuted: volumeSink && volumeSink.audio ? volumeSink.audio.muted : false
    readonly property real outputVolume: volumeSink && volumeSink.audio ? volumeSink.audio.volume : 0
    property int selectedIndex: -1
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Order of visible sections, recomputed reactively so dropping a section
    // (e.g. no input devices) doesn't leave the cursor pointing at it.
    readonly property var visibleSections: {
        var list = [];
        if (sectionVisible("output"))
            list.push("output");
        if (sectionVisible("input"))
            list.push("input");
        if (sectionVisible("streams"))
            list.push("streams");
        return list;
    }
    readonly property PwNode volumeSink: sink

    // Enter/Space: activate whatever the cursor is on.
    function activateCursor(): void {
        if (focusSection === "header") {
            toggleOutputMute();
            return;
        }
        if (focusSection === "output") {
            if (selectedIndex === -1) {
                toggleOutputMute();
                return;
            }
            var sink = displayAudioSinks[selectedIndex];
            if (sink)
                setDefaultSink(sink);
            return;
        }
        if (focusSection === "input") {
            if (selectedIndex === -1) {
                toggleInputMute();
                return;
            }
            var src = displayAudioSources[selectedIndex];
            if (src)
                setDefaultSource(src);
            return;
        }
        if (focusSection === "streams" && selectedIndex >= 0) {
            var st = displayAudioStreams[selectedIndex];
            if (st && st.audio)
                st.audio.muted = !st.audio.muted;
        }
    }

    // Adjust the slider associated with the focused section. Output and
    // input sliders are real volume controls; on stream rows h/l adjusts
    // that stream's volume (so keyboard parity with the inline slider).
    // For device rows (selectedIndex >= 0 in output/input) h/l is a no-op
    // — the cursor is on a discrete row, not on the slider, and silently
    // moving the global slider would surprise the user.
    function adjustVolume(delta: real): void {
        if (focusSection === "output" && selectedIndex === -1) {
            setOutputVolume(outputVolume + delta);
            return;
        }
        if (focusSection === "input" && selectedIndex === -1) {
            setInputVolume(inputVolume + delta);
            return;
        }
        if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < displayAudioStreams.length) {
            var s = displayAudioStreams[selectedIndex];
            if (s && s.audio)
                s.audio.volume = Math.max(0, Math.min(1.5, s.audio.volume + delta));
        }
    }

    function clampCursor(): void {
        var sections = visibleSections;
        if (!sections || !sections.length)
            return;
        // "header" is virtual and never appears in visibleSections, so it has to
        // be let through: muting republishes the PipeWire snapshot, and clamping
        // would knock the cursor off the hero switch on every toggle.
        if (focusSection === "header")
            return;
        if (sections.indexOf(focusSection) < 0) {
            focusSection = visibleSections[0];
            selectedIndex = sectionHasSlider(focusSection) ? -1 : 0;
            return;
        }
        var count = sectionCount(focusSection);
        var hasSlider = sectionHasSlider(focusSection);
        var floor = hasSlider ? -1 : 0;
        if (selectedIndex > count - 1)
            selectedIndex = Math.max(floor, count - 1);
        if (selectedIndex < floor)
            selectedIndex = floor;
    }

    function clearDisplayAudioModels(): void {
        audioModelRefreshTimer.stop();
        displayAudioSinks = [];
        displayAudioSources = [];
        displayAudioStreams = [];
    }

    // Tab keeps navigation at the section level: output, input, then app
    // sources. Each switch lands on that section's primary control.
    function cycleFocusSection(direction: int): void {
        var sections = visibleSections;
        if (sections.length === 0)
            return;
        var index = sections.indexOf(focusSection);
        if (index < 0)
            index = direction > 0 ? -1 : 0;
        index = (index + direction + sections.length) % sections.length;
        focusSection = sections[index];
        selectedIndex = sectionHasSlider(focusSection) ? -1 : 0;
        cursorActive = true;
    }

    function ensureCursorVisible(item: Item): void {
        if (!item || !scrollArea)
            return;
        var flick = scrollArea.contentItem as Flickable;
        if (!flick || flick.contentY === undefined)
            return;
        var margin = A.Appearance.space15;
        var maxY = Math.max(0, (flick.contentHeight || 0) - flick.height);
        if (maxY <= 24 || (root.focusSection === "output" && root.selectedIndex === -1)) {
            flick.contentY = 0;
            return;
        }
        var pt = item.mapToItem(flick.contentItem || flick, 0, 0);
        var top = pt.y;
        var bottom = top + (item.height || 0);
        var viewTop = flick.contentY;
        var viewBottom = viewTop + flick.height;
        if (top < viewTop + margin)
            flick.contentY = Math.max(0, Math.min(maxY, top - margin));
        else if (bottom > viewBottom - margin)
            flick.contentY = Math.max(0, Math.min(maxY, bottom + margin - flick.height));
    }

    function focusMenu(): void {
        Qt.callLater(function () {
            keyCatcher.forceActiveFocus();
        });
    }

    function moveCursor(delta: int): void {
        var sections = visibleSections;
        if (sections.length === 0)
            return;
        if (focusSection === "header") {
            if (delta > 0) {
                focusSection = sections[0];
                selectedIndex = sectionHasSlider(sections[0]) ? -1 : 0;
            }
            return;
        }
        var sIdx = sections.indexOf(focusSection);
        if (sIdx < 0) {
            focusSection = sections[0];
            selectedIndex = sectionHasSlider(focusSection) ? -1 : 0;
            return;
        }

        var idx = selectedIndex;
        var max = sectionCount(focusSection) - 1;  // last device index
        var hasSlider = sectionHasSlider(focusSection);
        var floor = hasSlider ? -1 : 0;  // -1 = slider row

        if (delta > 0) {
            if (idx < max) {
                selectedIndex = idx + 1;
                return;
            }
            // Fall through to next section.
            if (sIdx < sections.length - 1) {
                focusSection = sections[sIdx + 1];
                selectedIndex = sectionHasSlider(focusSection) ? -1 : 0;
            }
        } else {
            if (idx > floor) {
                selectedIndex = idx - 1;
                return;
            }
            // Escape upward.
            if (sIdx > 0) {
                focusSection = sections[sIdx - 1];
                var prevMax = sectionCount(focusSection) - 1;
                selectedIndex = prevMax >= 0 ? prevMax : (sectionHasSlider(focusSection) ? -1 : 0);
            } else {
                focusSection = "header";
            }
        }
    }

    function outputIcon(): string {
        if (!sink || !sink.audio)
            return "";
        if (Model.isHeadphones(sink))
            return "󰋋";
        if (outputMuted)
            return "";
        var v = outputVolume;
        if (v >= 0.67)
            return "";
        if (v >= 0.34)
            return "";
        if (v > 0)
            return "";
        return "";
    }

    function refreshDisplayAudioModels(): void {
        if (!opened)
            return;
        displayAudioSinks = Model.listSnapshot(audioSinks);
        displayAudioSources = Model.listSnapshot(audioSources);
        displayAudioStreams = Model.listSnapshot(audioStreams);
        clampCursor();
    }

    // Keep the keyboard-focused row inside the visible viewport of the
    // multi-section ScrollView.
    function resetScroll(): void {
        if (!scrollArea)
            return;
        var flick = scrollArea.contentItem as Flickable;
        if (flick && flick.contentY !== undefined)
            flick.contentY = 0;
    }

    function scheduleDisplayAudioModelRefresh(): void {
        if (!opened)
            return;
        audioModelRefreshTimer.restart();
    }

    function sectionCount(section: string): int {
        if (section === "output")
            return displayAudioSinks.length;
        if (section === "input")
            return displayAudioSources.length;
        if (section === "streams")
            return displayAudioStreams.length;
        return 0;
    }

    function sectionHasSlider(section: string): bool {
        if (section === "output")
            return true;
        if (section === "input")
            return !!source;
        return false;  // stream rows carry their own sliders inline; not a section-level slider
    }

    function sectionVisible(section: string): bool {
        if (section === "output")
            return true;
        if (section === "input")
            return displayAudioSources.length > 0 || !!source;
        if (section === "streams")
            return displayAudioStreams.length > 0;
        return false;
    }

    function setDefaultSink(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node: PwNode): void {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    function setHeaderCursor(): void {
        cursorActive = true;
        focusSection = "header";
        selectedIndex = -1;
    }

    function setInputVolume(v: real): void {
        if (!source || !source.audio)
            return;
        source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function setOutputVolume(v: real): real {
        if (!volumeSink || !volumeSink.audio)
            return outputVolume;
        var volume = Math.max(0, Math.min(1, v));
        volumeSink.audio.volume = volume;
        return volume;
    }

    function streamLabel(node: PwNode): string {
        return Model.streamLabel(node, mprisPlayers, displayAudioStreams);
    }

    function toggleFocusedMute(): void {
        if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < displayAudioStreams.length) {
            var stream = displayAudioStreams[selectedIndex];
            if (stream && stream.audio)
                stream.audio.muted = !stream.audio.muted;
        } else if (focusSection === "input") {
            toggleInputMute();
        } else {
            toggleOutputMute();
        }
    }

    function toggleInputMute(): void {
        if (source && source.audio)
            source.audio.muted = !source.audio.muted;
    }

    // The hero switch mirrors the output mute, so it always follows what the
    // output row below does. Input keeps its own mute in its section.
    function toggleOutputMute(): void {
        if (volumeSink && volumeSink.audio)
            volumeSink.audio.muted = !volumeSink.audio.muted;
    }

    // Fresh Loader instances start with empty display lists; PipeWire may
    // not publish a change after load, so snapshot once on completion.
    Component.onCompleted: refreshDisplayAudioModels()

    // Clamp / repair the cursor whenever any list refreshes underneath us.
    onAudioSinksChanged: scheduleDisplayAudioModelRefresh()
    onAudioSourcesChanged: scheduleDisplayAudioModelRefresh()
    onAudioStreamsChanged: scheduleDisplayAudioModelRefresh()
    onOpenedChanged: {
        if (opened) {
            refreshDisplayAudioModels();
            focusSection = "output";
            selectedIndex = -1;  // first keyboard cursor reveal starts on the output slider
            cursorActive = false;
            Qt.callLater(resetScroll);
        } else {
            clearDisplayAudioModels();
        }
    }

    PwObjectTracker {
        objects: root.candidateSinks
    }

    PwObjectTracker {
        objects: root.candidateSources
    }

    PwObjectTracker {
        objects: root.audioStreams
    }

    PwNodePeakMonitor {
        id: inputPeakMonitor

        enabled: root.opened && !!root.source
        node: root.source
    }

    PwNodePeakMonitor {
        id: outputPeakMonitor

        enabled: root.opened && !!root.sink
        node: root.sink
    }

    Timer {
        id: audioModelRefreshTimer

        interval: 75
        repeat: false

        onTriggered: root.refreshDisplayAudioModels()
    }

    Ui.KeyCatcher {
        id: keyCatcher

        anchors.fill: parent

        onActivateRequested: if (root.cursorActive)
            root.activateCursor()
        onCloseRequested: root.controller.close()
        onMoveRequested: function (dx, dy) {
            if (!root.cursorActive)
                root.cursorActive = true;
            if (dy !== 0)
                root.moveCursor(dy);
            else if (dx !== 0)
                root.adjustVolume(dx * 0.02);
        }
        onTabRequested: function (direction) {
            root.cycleFocusSection(direction);
        }
        onTextKey: function (t) {
            // 'm' always toggles the active channel; the popup defaults to output.
            if (t === "m" || t === "M") {
                root.toggleFocusedMute();
            }
        }

        ScrollView {
            id: scrollArea

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            anchors.fill: parent
            clip: true

            Binding {
                property: "interactive"
                target: scrollArea.contentItem
                value: panelColumn.implicitHeight > scrollArea.height
            }

            Column {
                id: panelColumn

                spacing: A.Appearance.space4
                width: scrollArea.availableWidth

                // ---------- Hero: speaker icon · title/status ----------
                Item {
                    id: heroItem

                    implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)
                    width: parent.width

                    // Status only — the switch owns muting, mouse and keyboard alike.
                    Text {
                        id: heroIcon

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: A.Appearance.foreground
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: 24
                        opacity: root.outputMuted ? 0.5 : 1.0
                        text: root.outputIcon()
                        textFormat: Text.PlainText
                    }

                    // Compact on/off switch on the trailing edge of the hero, and the
                    // header's only cursor target. Checked means output is audible.
                    Ui.Switch {
                        id: powerSwitch

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: root.hasOutput && !root.outputMuted
                        hasCursor: root.headerHasCursor

                        onHovered: function (on) {
                            if (on)
                                root.setHeaderCursor();
                        }
                        onToggled: root.toggleOutputMute()
                    }

                    Column {
                        id: heroLabels

                        anchors.left: heroIcon.right
                        anchors.leftMargin: A.Appearance.space4
                        anchors.right: parent.right
                        anchors.rightMargin: powerSwitch.width + A.Appearance.space3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: A.Appearance.space05

                        Text {
                            color: A.Appearance.foreground
                            elide: Text.ElideRight
                            font.bold: true
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeTitle
                            text: qsTr("Audio")
                            width: parent.width
                        }

                        Text {
                            id: heroLabel

                            color: Qt.darker(A.Appearance.foreground, 1.4)
                            elide: Text.ElideRight
                            font.bold: true
                            font.family: A.Appearance.fontFamily
                            font.letterSpacing: 1.2
                            font.pixelSize: A.Appearance.fontSizeBody
                            text: Model.outputVolumeName(outputSlider.dragging ? outputSlider.liveValue : root.outputVolume, root.outputMuted).toUpperCase()
                            textFormat: Text.PlainText
                            width: parent.width
                        }
                    }
                }

                // ---- Output devices ----
                Ui.Separator {
                }

                Column {
                    spacing: A.Appearance.space15
                    width: parent.width

                    Item {
                        implicitHeight: Math.max(outputHeader.implicitHeight, outputPercent.implicitHeight)
                        width: parent.width

                        Ui.SectionHeader {
                            id: outputHeader

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            foreground: A.Appearance.foreground
                            text: qsTr("OUTPUT")
                        }

                        Text {
                            id: outputPercent

                            anchors.right: parent.right
                            anchors.rightMargin: A.Appearance.space15
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.darker(A.Appearance.foreground, 1.4)
                            font.bold: true
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            opacity: root.outputMuted ? 0.5 : 1.0
                            text: Math.round((outputSlider.dragging ? outputSlider.liveValue : root.outputVolume) * 100) + "%"
                            textFormat: Text.PlainText
                        }
                    }

                    Ui.SelectRow {
                        id: outputSliderRow

                        contentPadding: 0
                        hasCursor: root.cursorActive && root.focusSection === "output" && root.selectedIndex === -1
                        height: outputSlider.implicitHeight + A.Appearance.space2
                        width: parent.width

                        onHasCursorChanged: if (hasCursor)
                            root.ensureCursorVisible(outputSliderRow)

                        Item {
                            id: outputControls

                            anchors.fill: parent
                            implicitHeight: outputSlider.implicitHeight

                            Ui.Slider {
                                id: outputSlider

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                enabled: !!root.sink
                                height: implicitHeight
                                maximum: 1
                                minimum: 0
                                opacity: root.outputMuted ? 0.5 : 1.0
                                step: 0.02
                                value: root.outputVolume

                                onMoved: function (v) {
                                    root.setOutputVolume(v);
                                }
                                onRightClicked: root.toggleOutputMute()
                            }

                            // Output level meter docked under the slider so this row
                            // keeps the exact geometry of the input slider row.
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: outputSlider.bottom
                                color: Qt.rgba(A.Appearance.foreground.r, A.Appearance.foreground.g, A.Appearance.foreground.b, 0.18)
                                height: A.Appearance.space05
                                opacity: root.outputMuted ? 0.35 : 1.0

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    color: A.Appearance.foreground
                                    width: parent.width * Math.max(0, Math.min(1, outputPeakMonitor.peak))

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 70
                                        }
                                    }
                                }
                            }
                        }

                        HoverHandler {
                            onHoveredChanged: if (hovered) {
                                root.cursorActive = true;
                                root.focusSection = "output";
                                root.selectedIndex = -1;
                            }
                        }
                    }

                    Repeater {
                        model: root.displayAudioSinks

                        DeviceRow {
                            required property int index
                            required property PwNode modelData

                            node: modelData
                            rowIndex: index
                            section: "output"
                            width: panelColumn.width
                        }
                    }
                }

                // ---- Input ----
                Ui.Separator {
                    visible: root.displayAudioSources.length > 0 || !!root.source
                }

                Column {
                    spacing: A.Appearance.space15
                    visible: root.displayAudioSources.length > 0 || !!root.source
                    width: parent.width

                    Item {
                        implicitHeight: Math.max(microphoneHeader.implicitHeight, microphonePercent.implicitHeight)
                        width: parent.width

                        Ui.SectionHeader {
                            id: microphoneHeader

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            foreground: A.Appearance.foreground
                            text: qsTr("INPUT")
                        }

                        Text {
                            id: microphonePercent

                            anchors.right: parent.right
                            anchors.rightMargin: A.Appearance.space15
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.darker(A.Appearance.foreground, 1.4)
                            font.bold: true
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeBody
                            opacity: root.inputMuted ? 0.5 : 1.0
                            text: Math.round((inputSlider.dragging ? inputSlider.liveValue : root.inputVolume) * 100) + "%"
                            textFormat: Text.PlainText
                        }
                    }

                    Ui.SelectRow {
                        id: inputSliderRow

                        contentPadding: 0
                        hasCursor: root.cursorActive && root.focusSection === "input" && root.selectedIndex === -1
                        height: inputControls.implicitHeight + A.Appearance.space2
                        visible: !!root.source
                        width: parent.width

                        onHasCursorChanged: if (hasCursor)
                            root.ensureCursorVisible(inputSliderRow)

                        Item {
                            id: inputControls

                            anchors.fill: parent
                            implicitHeight: inputSlider.implicitHeight

                            Ui.Slider {
                                id: inputSlider

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                enabled: !!root.source
                                height: implicitHeight
                                maximum: 1
                                minimum: 0
                                opacity: root.inputMuted ? 0.5 : 1.0
                                step: 0.05
                                value: root.inputVolume

                                onMoved: function (v) {
                                    root.setInputVolume(v);
                                }
                                onRightClicked: root.toggleInputMute()
                            }

                            // Mic level meter docked under the slider so this row
                            // keeps the exact geometry of the output slider row.
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: inputSlider.bottom
                                color: Qt.rgba(A.Appearance.foreground.r, A.Appearance.foreground.g, A.Appearance.foreground.b, 0.18)
                                height: A.Appearance.space05
                                opacity: root.inputMuted ? 0.35 : 1.0

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    color: A.Appearance.foreground
                                    width: parent.width * Math.max(0, Math.min(1, inputPeakMonitor.peak))

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 70
                                        }
                                    }
                                }
                            }
                        }

                        HoverHandler {
                            onHoveredChanged: if (hovered) {
                                root.cursorActive = true;
                                root.focusSection = "input";
                                root.selectedIndex = -1;
                            }
                        }
                    }

                    Repeater {
                        model: root.displayAudioSources

                        DeviceRow {
                            required property int index
                            required property PwNode modelData

                            node: modelData
                            rowIndex: index
                            section: "input"
                            width: panelColumn.width
                        }
                    }
                }

                // ---- Per-app streams ----
                Ui.Separator {
                    visible: root.displayAudioStreams.length > 0
                }

                Column {
                    spacing: A.Appearance.space25
                    visible: root.displayAudioStreams.length > 0
                    width: parent.width

                    Ui.SectionHeader {
                        foreground: A.Appearance.foreground
                        text: qsTr("SOURCES")
                    }

                    Repeater {
                        model: root.displayAudioStreams

                        StreamRow {
                            required property int index
                            required property PwNode modelData

                            node: modelData
                            rowIndex: index
                            width: panelColumn.width
                        }
                    }
                }
            }
        }
    }

    // ---- Reusable inline components ----

    // Device row — cursor target inside the "output" or "input" section.
    // Mouse hover updates the menu cursor at the root; visuals come
    // entirely from hasCursor/current via SelectRow, never from containsMouse.
    component DeviceRow: Ui.SelectRow {
        id: deviceRow

        readonly property PwNode defaultNode: section === "output" ? root.sink : root.source
        readonly property bool isActive: defaultNode && node && defaultNode.id === node.id
        required property PwNode node
        required property int rowIndex
        required property string section

        current: isActive
        hasCursor: root.cursorActive && root.focusSection === section && root.selectedIndex === rowIndex
        implicitHeight: deviceInner.implicitHeight + A.Appearance.space2

        onHasCursorChanged: if (hasCursor)
            root.ensureCursorVisible(deviceRow)

        Row {
            id: deviceInner

            anchors.left: parent.left
            anchors.leftMargin: A.Appearance.space15
            anchors.right: parent.right
            anchors.rightMargin: A.Appearance.space15
            anchors.verticalCenter: parent.verticalCenter
            spacing: A.Appearance.space2

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: A.Appearance.foreground
                font.family: A.Appearance.iconFontFamily
                font.pixelSize: A.Appearance.fontSizeTitle
                horizontalAlignment: Text.AlignHCenter
                text: deviceRow.section === "output" ? Model.sinkGlyph(deviceRow.node) : Model.sourceGlyph(deviceRow.node)
                textFormat: Text.PlainText
                width: A.Appearance.iconColumnWidth
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: A.Appearance.foreground
                elide: Text.ElideRight
                font.bold: deviceRow.isActive
                font.family: A.Appearance.fontFamily
                font.pixelSize: A.Appearance.fontSizeBody
                text: Model.nodeLabel(deviceRow.node)
                textFormat: Text.PlainText
                width: parent.width - A.Appearance.iconColumnWidth - A.Appearance.space2
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: {
                if (deviceRow.section === "output")
                    root.setDefaultSink(deviceRow.node);
                else
                    root.setDefaultSource(deviceRow.node);
            }
            onContainsMouseChanged: if (containsMouse) {
                root.cursorActive = true;
                root.focusSection = deviceRow.section;
                root.selectedIndex = deviceRow.rowIndex;
            }
        }
    }

    // Per-app stream row — cursor target inside the "streams" section.
    // The stream has its own slider inline, so h/l from the keyboard
    // adjusts THIS stream's volume (not the global output) when the cursor
    // sits on this row. Enter/Space mutes the stream.
    component StreamRow: Ui.SelectRow {
        id: streamRow

        required property PwNode node
        required property int rowIndex
        readonly property bool streamMuted: node && node.audio ? node.audio.muted : false
        readonly property real streamVolume: node && node.audio ? node.audio.volume : 0

        hasCursor: root.cursorActive && root.focusSection === "streams" && root.selectedIndex === rowIndex
        implicitHeight: streamColumn.implicitHeight + A.Appearance.space2

        onHasCursorChanged: if (hasCursor)
            root.ensureCursorVisible(streamRow)

        Column {
            id: streamColumn

            anchors.left: parent.left
            anchors.leftMargin: A.Appearance.space15
            anchors.right: parent.right
            anchors.rightMargin: A.Appearance.space15
            anchors.verticalCenter: parent.verticalCenter
            spacing: A.Appearance.space05

            Row {
                spacing: A.Appearance.space2
                width: parent.width

                Text {
                    id: streamMuteIcon

                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeTitle
                    horizontalAlignment: Text.AlignHCenter
                    opacity: streamRow.streamMuted ? 0.5 : 1.0
                    text: streamRow.streamMuted ? "󰝟" : "󰕾"
                    textFormat: Text.PlainText
                    width: A.Appearance.iconColumnWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (streamRow.node && streamRow.node.audio)
                                streamRow.node.audio.muted = !streamRow.node.audio.muted;
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.foreground
                    elide: Text.ElideRight
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    text: root.streamLabel(streamRow.node)
                    textFormat: Text.PlainText
                    width: parent.width - streamMuteIcon.width - streamPct.width - A.Appearance.space4
                }

                Text {
                    id: streamPct

                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.darker(A.Appearance.foreground, 1.5)
                    font.bold: true
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    horizontalAlignment: Text.AlignRight
                    opacity: streamRow.streamMuted ? 0.5 : 1.0
                    text: Math.round(streamRow.streamVolume * 100) + "%"
                    textFormat: Text.PlainText
                    width: 36
                }
            }

            Ui.Slider {
                maximum: 1.5
                minimum: 0
                opacity: streamRow.streamMuted ? 0.5 : 1.0
                step: 0.05
                value: streamRow.streamVolume
                width: parent.width

                onMoved: function (v) {
                    if (streamRow.node && streamRow.node.audio)
                        streamRow.node.audio.volume = v;
                }
                onRightClicked: {
                    if (streamRow.node && streamRow.node.audio)
                        streamRow.node.audio.muted = !streamRow.node.audio.muted;
                }
            }
        }

        MouseArea {
            acceptedButtons: Qt.NoButton
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true

            onContainsMouseChanged: if (containsMouse) {
                root.cursorActive = true;
                root.focusSection = "streams";
                root.selectedIndex = streamRow.rowIndex;
            }
        }
    }
}
