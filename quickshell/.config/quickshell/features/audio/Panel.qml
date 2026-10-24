pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Controls.Basic
import Quickshell.Services.Pipewire
import "../.."
import "../../ui" as Ui
import "labels.js" as Utils

Ui.Panel {
    id: root

    required property Main audio
    required property var controller
    property bool cursorActive: false

    // -1 selects a section's slider; non-negative indices select devices/streams.
    property string focusSection: "output"
    readonly property bool hasOutput: !!(audio.output && audio.output.audio)

    // "header" is a virtual section for the hero output mute toggle; it sits
    // above the output section so the speaker can be muted from the keyboard.
    readonly property bool headerHasCursor: cursorActive && focusSection === "header"
    readonly property int menuHeight: Math.min(panelColumn.implicitHeight + Theme.dialogPadding * 2, Theme.popupMaxHeight)
    readonly property int menuWidth: Theme.popupWidthStandard
    property int selectedIndex: -1

    readonly property var visibleSections: ["output", "input", "streams"].filter(sectionVisible)

    // Enter/Space: activate whatever the cursor is on.
    function activateCursor(): void {
        if (focusSection === "header") {
            audio.toggleMute();
            return;
        }
        if (focusSection === "output") {
            if (selectedIndex === -1) {
                audio.toggleMute();
                return;
            }
            var selectedSink = audio.displayAudioSinks[selectedIndex];
            if (selectedSink)
                audio.setDefaultSink(selectedSink);
            return;
        }
        if (focusSection === "input") {
            if (selectedIndex === -1) {
                audio.toggleInputMute();
                return;
            }
            var src = audio.displayAudioSources[selectedIndex];
            if (src)
                audio.setDefaultSource(src);
            return;
        }
        if (focusSection === "streams" && selectedIndex >= 0) {
            var st = audio.displayAudioStreams[selectedIndex];
            if (st && st.audio)
                audio.toggleStreamMute(st);
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
            audio.setOutputVolume(audio.outputVolume + delta);
            return;
        }
        if (focusSection === "input" && selectedIndex === -1) {
            audio.setInputVolume(audio.inputVolume + delta);
            return;
        }
        if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < audio.displayAudioStreams.length) {
            var s = audio.displayAudioStreams[selectedIndex];
            if (s && s.audio)
                audio.setStreamVolume(s, s.audio.volume + delta);
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
        var floor = sectionHasSlider(focusSection) ? -1 : 0;
        selectedIndex = Math.max(floor, Math.min(count - 1, selectedIndex));
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
        var margin = Theme.space15;
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
        if (!audio.output || !audio.output.audio)
            return "";
        if (Utils.isHeadphones(audio.output))
            return "󰋋";
        if (audio.outputMuted)
            return "";
        var v = audio.outputVolume;
        if (v >= 0.67)
            return "";
        if (v >= 0.34)
            return "";
        if (v > 0)
            return "";
        return "";
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

    function sectionCount(section: string): int {
        if (section === "output")
            return audio.displayAudioSinks.length;
        if (section === "input")
            return audio.displayAudioSources.length;
        if (section === "streams")
            return audio.displayAudioStreams.length;
        return 0;
    }

    function sectionHasSlider(section: string): bool {
        if (section === "output")
            return true;
        if (section === "input")
            return !!audio.source;
        return false;  // stream rows carry their own sliders inline; not a section-level slider
    }

    function sectionVisible(section: string): bool {
        if (section === "output")
            return true;
        if (section === "input")
            return audio.displayAudioSources.length > 0 || !!audio.source;
        if (section === "streams")
            return audio.displayAudioStreams.length > 0;
        return false;
    }

    function toggleFocusedMute(): void {
        if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < audio.displayAudioStreams.length) {
            var stream = audio.displayAudioStreams[selectedIndex];
            if (stream && stream.audio)
                audio.toggleStreamMute(stream);
        } else if (focusSection === "input") {
            audio.toggleInputMute();
        } else {
            audio.toggleMute();
        }
    }

    Component.onCompleted: Qt.callLater(resetScroll)

    Connections {
        function onModelsChanged() {
            root.clampCursor();
        }

        target: root.audio
    }

    Ui.Navigation {
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

                spacing: Theme.space4
                width: scrollArea.availableWidth

                // ---------- Hero: speaker icon · title/status ----------
                Item {
                    id: heroItem

                    implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)
                    width: parent.width

                    Controls.Label {
                        id: heroIcon

                        color: Theme.primary
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 24
                        opacity: audio.outputMuted ? 0.5 : 1.0
                        text: root.outputIcon()
                        textFormat: Text.PlainText
                    }

                    // Compact on/off switch on the trailing edge of the hero, and the
                    // header's only cursor target. Checked means output is audible.
                    Ui.ToggleIndicator {
                        id: powerSwitch

                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: root.hasOutput && !audio.outputMuted
                        hasCursor: root.headerHasCursor
                    }

                    Column {
                        id: heroLabels

                        anchors.left: heroIcon.right
                        anchors.leftMargin: Theme.space4
                        anchors.right: parent.right
                        anchors.rightMargin: powerSwitch.width + Theme.space3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.space05

                        Controls.Label {
                            elide: Text.ElideRight
                            font.bold: true
                            font.pixelSize: Theme.fontSizeTitle
                            text: qsTr("Audio")
                            width: parent.width
                        }

                        Controls.Label {
                            id: heroLabel

                            color: Qt.darker(Theme.foreground, 1.4)
                            elide: Text.ElideRight
                            font.bold: true
                            font.letterSpacing: 1.2
                            font.pixelSize: Theme.fontSizeBody
                            text: Utils.outputVolumeName(audio.outputVolume, audio.outputMuted).toUpperCase()
                            textFormat: Text.PlainText
                            width: parent.width
                        }
                    }
                }

                // ---- Output devices ----
                Ui.Separator {
                }

                Column {
                    spacing: Theme.space15
                    width: parent.width

                    Item {
                        implicitHeight: Math.max(outputHeader.implicitHeight, outputPercent.implicitHeight)
                        width: parent.width

                        Ui.SectionHeader {
                            id: outputHeader

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            foreground: Theme.foreground
                            text: qsTr("OUTPUT")
                        }

                        Controls.Label {
                            id: outputPercent

                            anchors.right: parent.right
                            anchors.rightMargin: Theme.space15
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.darker(Theme.foreground, 1.4)
                            font.bold: true
                            font.pixelSize: Theme.fontSizeBody
                            opacity: audio.outputMuted ? 0.5 : 1.0
                            text: Math.round((audio.outputVolume) * 100) + "%"
                            textFormat: Text.PlainText
                        }
                    }

                    Ui.MenuRow {
                        id: outputSliderRow

                        contentPadding: 0
                        hasCursor: root.cursorActive && root.focusSection === "output" && root.selectedIndex === -1
                        height: outputSlider.implicitHeight + Theme.space2
                        width: parent.width

                        onHasCursorChanged: if (hasCursor)
                            root.ensureCursorVisible(outputSliderRow)

                        Item {
                            id: outputControls

                            anchors.fill: parent
                            implicitHeight: outputSlider.implicitHeight

                            Ui.Level {
                                id: outputSlider

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                enabled: !!audio.output
                                height: implicitHeight
                                maximum: 1
                                minimum: 0
                                opacity: audio.outputMuted ? 0.5 : 1.0
                                value: audio.outputVolume
                            }

                            LevelMeter {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: outputSlider.bottom
                                opacity: audio.outputMuted ? 0.35 : 1.0
                                peak: audio.outputPeak
                            }
                        }
                    }

                    Repeater {
                        model: audio.displayAudioSinks

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
                    visible: audio.displayAudioSources.length > 0 || !!audio.source
                }

                Column {
                    spacing: Theme.space15
                    visible: audio.displayAudioSources.length > 0 || !!audio.source
                    width: parent.width

                    Item {
                        implicitHeight: Math.max(microphoneHeader.implicitHeight, microphonePercent.implicitHeight)
                        width: parent.width

                        Ui.SectionHeader {
                            id: microphoneHeader

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            foreground: Theme.foreground
                            text: qsTr("INPUT")
                        }

                        Controls.Label {
                            id: microphonePercent

                            anchors.right: parent.right
                            anchors.rightMargin: Theme.space15
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.darker(Theme.foreground, 1.4)
                            font.bold: true
                            font.pixelSize: Theme.fontSizeBody
                            opacity: audio.inputMuted ? 0.5 : 1.0
                            text: Math.round((audio.inputVolume) * 100) + "%"
                            textFormat: Text.PlainText
                        }
                    }

                    Ui.MenuRow {
                        id: inputSliderRow

                        contentPadding: 0
                        hasCursor: root.cursorActive && root.focusSection === "input" && root.selectedIndex === -1
                        height: inputControls.implicitHeight + Theme.space2
                        visible: !!audio.source
                        width: parent.width

                        onHasCursorChanged: if (hasCursor)
                            root.ensureCursorVisible(inputSliderRow)

                        Item {
                            id: inputControls

                            anchors.fill: parent
                            implicitHeight: inputSlider.implicitHeight

                            Ui.Level {
                                id: inputSlider

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                enabled: !!audio.source
                                height: implicitHeight
                                maximum: 1
                                minimum: 0
                                opacity: audio.inputMuted ? 0.5 : 1.0
                                value: audio.inputVolume
                            }

                            LevelMeter {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: inputSlider.bottom
                                opacity: audio.inputMuted ? 0.35 : 1.0
                                peak: audio.inputPeak
                            }
                        }
                    }

                    Repeater {
                        model: audio.displayAudioSources

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
                    visible: audio.displayAudioStreams.length > 0
                }

                Column {
                    spacing: Theme.space25
                    visible: audio.displayAudioStreams.length > 0
                    width: parent.width

                    Ui.SectionHeader {
                        foreground: Theme.foreground
                        text: qsTr("SOURCES")
                    }

                    Repeater {
                        model: audio.displayAudioStreams

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

    component LevelMeter: Rectangle {
        id: meter

        required property real peak

        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.18)
        height: Theme.space05

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width * Math.max(0, Math.min(1, meter.peak))

            Behavior on width {
                NumberAnimation {
                    duration: 70
                }
            }
        }
    }

    // Device row — cursor target inside the "output" or "input" section.

    component DeviceRow: Ui.MenuRow {
        id: deviceRow

        readonly property PwNode defaultNode: section === "output" ? audio.output : audio.source
        readonly property bool isActive: defaultNode && node && defaultNode.id === node.id
        required property PwNode node
        required property int rowIndex
        required property string section

        current: isActive
        hasCursor: root.cursorActive && root.focusSection === section && root.selectedIndex === rowIndex
        implicitHeight: deviceInner.implicitHeight + Theme.space2

        onHasCursorChanged: if (hasCursor)
            root.ensureCursorVisible(deviceRow)

        Row {
            id: deviceInner

            anchors.left: parent.left
            anchors.leftMargin: Theme.space15
            anchors.right: parent.right
            anchors.rightMargin: Theme.space15
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space2

            Controls.Label {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeTitle
                horizontalAlignment: Text.AlignHCenter
                text: deviceRow.section === "output" ? Utils.sinkGlyph(deviceRow.node) : Utils.sourceGlyph(deviceRow.node)
                textFormat: Text.PlainText
                width: Theme.iconColumnWidth
            }

            Controls.Label {
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                font.bold: deviceRow.isActive
                font.pixelSize: Theme.fontSizeBody
                text: Utils.nodeLabel(deviceRow.node)
                textFormat: Text.PlainText
                width: parent.width - Theme.iconColumnWidth - Theme.space2
            }
        }
    }

    // Per-app stream row — cursor target inside the "streams" section.
    // The stream has its own slider inline, so h/l from the keyboard
    // adjusts THIS stream's volume (not the global output) when the cursor
    // sits on this row. Enter/Space mutes the stream.
    component StreamRow: Ui.MenuRow {
        id: streamRow

        required property PwNode node
        required property int rowIndex
        readonly property bool streamMuted: node && node.audio ? node.audio.muted : false
        readonly property real streamVolume: node && node.audio ? node.audio.volume : 0

        hasCursor: root.cursorActive && root.focusSection === "streams" && root.selectedIndex === rowIndex
        implicitHeight: streamColumn.implicitHeight + Theme.space2

        onHasCursorChanged: if (hasCursor)
            root.ensureCursorVisible(streamRow)

        Column {
            id: streamColumn

            anchors.left: parent.left
            anchors.leftMargin: Theme.space15
            anchors.right: parent.right
            anchors.rightMargin: Theme.space15
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space05

            Row {
                spacing: Theme.space2
                width: parent.width

                Controls.Label {
                    id: streamMuteIcon

                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeTitle
                    horizontalAlignment: Text.AlignHCenter
                    opacity: streamRow.streamMuted ? 0.5 : 1.0
                    text: streamRow.streamMuted ? "󰝟" : "󰕾"
                    textFormat: Text.PlainText
                    width: Theme.iconColumnWidth
                }

                Controls.Label {
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    font.pixelSize: Theme.fontSizeBody
                    text: audio.streamLabel(streamRow.node)
                    textFormat: Text.PlainText
                    width: parent.width - streamMuteIcon.width - streamPct.width - Theme.space4
                }

                Controls.Label {
                    id: streamPct

                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.darker(Theme.foreground, 1.5)
                    font.bold: true
                    font.pixelSize: Theme.fontSizeBody
                    horizontalAlignment: Text.AlignRight
                    opacity: streamRow.streamMuted ? 0.5 : 1.0
                    text: Math.round(streamRow.streamVolume * 100) + "%"
                    textFormat: Text.PlainText
                    width: 36
                }
            }

            Ui.Level {
                maximum: 1.5
                minimum: 0
                opacity: streamRow.streamMuted ? 0.5 : 1.0
                value: streamRow.streamVolume
                width: parent.width
            }
        }
    }
}
