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

    required property var audio
    required property var controller
    property VolumeControl volumeEditor: null

    // -1 selects the section controls; non-negative indices select devices/streams.
    property string focusSection: "output"
    readonly property bool hasOutput: !!(audio.output && audio.output.audio)

    title: qsTr("Audio")
    implicitHeight: panelColumn.implicitHeight
    property int selectedIndex: -1

    readonly property var visibleSections: ["output", "input", "streams"].filter(sectionVisible)

    // Enter/Space: activate whatever the cursor is on.
    function activateCursor(): void {
        if (focusSection === "output") {
            if (selectedIndex === -1) {
                outputRow.edit();
                return;
            }
            var selectedSink = audio.displayAudioSinks[selectedIndex];
            if (selectedSink)
                audio.setDefaultSink(selectedSink);
            return;
        }
        if (focusSection === "input") {
            if (selectedIndex === -1) {
                inputRow.edit();
                return;
            }
            var src = audio.displayAudioSources[selectedIndex];
            if (src)
                audio.setDefaultSource(src);
            return;
        }
        if (focusSection === "streams" && selectedIndex >= 0) {
            streamRows.itemAt(selectedIndex)?.editVolume();
        }
    }

    // Device selection must not silently adjust the global volume.
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

    function editVolume(): void {
        if (focusSection === "output" && selectedIndex === -1)
            outputRow.edit();
        else if (focusSection === "input" && selectedIndex === -1)
            inputRow.edit();
        else if (focusSection === "streams")
            streamRows.itemAt(selectedIndex)?.editVolume();
    }

    function clampCursor(): void {
        var sections = visibleSections;
        if (!sections || !sections.length)
            return;
        if (sections.indexOf(focusSection) < 0) {
            focusSection = visibleSections[0];
            selectedIndex = sectionHasControls(focusSection) ? -1 : 0;
            return;
        }
        var count = sectionCount(focusSection);
        var floor = sectionHasControls(focusSection) ? -1 : 0;
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
        selectedIndex = sectionHasControls(focusSection) ? -1 : 0;
    }

    function ensureCursorVisible(item: Item): void {
        if (!item || !scrollArea)
            return;
        var flick = scrollArea.contentItem as Flickable;
        if (!flick || flick.contentY === undefined)
            return;
        var margin = Theme.space15;
        var maxY = Math.max(0, (flick.contentHeight || 0) - flick.height);
        if (maxY === 0 || (root.focusSection === "output" && root.selectedIndex === -1)) {
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

    function revealCursor(): void {
        let item = null;
        if (focusSection === "output")
            item = selectedIndex === -1 ? outputRow : outputDevices.itemAt(selectedIndex);
        else if (focusSection === "input")
            item = selectedIndex === -1 ? inputRow : inputDevices.itemAt(selectedIndex);
        else if (focusSection === "streams")
            item = streamRows.itemAt(selectedIndex);
        ensureCursorVisible(item);
    }

    onFocusSectionChanged: Qt.callLater(revealCursor)
    onSelectedIndexChanged: Qt.callLater(revealCursor)

    function selectControls(section: string, index: int): void {
        focusSection = section;
        selectedIndex = index;
    }

    function trackEditor(control: VolumeControl): void {
        if (control.editing)
            volumeEditor = control;
        else if (volumeEditor === control)
            volumeEditor = null;
    }

    function moveCursor(delta: int): void {
        var sections = visibleSections;
        if (sections.length === 0)
            return;
        var sIdx = sections.indexOf(focusSection);
        if (sIdx < 0) {
            focusSection = sections[0];
            selectedIndex = sectionHasControls(focusSection) ? -1 : 0;
            return;
        }

        var idx = selectedIndex;
        var max = sectionCount(focusSection) - 1;  // last device index
        var floor = sectionHasControls(focusSection) ? -1 : 0;

        if (delta > 0) {
            if (idx < max) {
                selectedIndex = idx + 1;
                return;
            }
            // Fall through to next section.
            if (sIdx < sections.length - 1) {
                focusSection = sections[sIdx + 1];
                selectedIndex = sectionHasControls(focusSection) ? -1 : 0;
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
                selectedIndex = prevMax >= 0 ? prevMax : (sectionHasControls(focusSection) ? -1 : 0);
            }
        }
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

    function sectionHasControls(section: string): bool {
        if (section === "output")
            return true;
        if (section === "input")
            return !!audio.source;
        return false;  // Each application has its own controls.
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
            Qt.callLater(root.revealCursor);
        }

        target: root.audio
    }

    Ui.Navigation {
        id: keyCatcher

        anchors.fill: parent
        Keys.enabled: root.volumeEditor === null

        onActivateRequested: root.activateCursor()
        onCloseRequested: root.controller.back()
        onMoveRequested: function (dx, dy) {
            if (dy !== 0)
                root.moveCursor(dy);
            else if (dx !== 0)
                root.adjustVolume(dx * 0.02);
        }
        onTabRequested: function (direction) {
            root.cycleFocusSection(direction);
            keyCatcher.forceActiveFocus();
        }
        onTextKey: function (t) {
            // 'm' always toggles the active channel; the popup defaults to output.
            if (t === "m" || t === "M") {
                root.toggleFocusedMute();
            } else if (t === "e" || t === "E") {
                root.editVolume();
            }
        }

        ScrollView {
            id: scrollArea
            objectName: "audioScroll"

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            anchors.fill: parent
            clip: true

            Binding {
                property: "interactive"
                target: scrollArea.contentItem
                value: panelColumn.implicitHeight > scrollArea.height
            }

            Column {
                id: panelColumn

                spacing: Theme.space3
                width: scrollArea.availableWidth

                Column {
                    spacing: Theme.space15
                    width: parent.width

                    MainVolumeRow {
                        id: outputRow
                        section: "output"
                        width: parent.width
                    }

                    Controls.Label {
                        visible: !root.hasOutput
                        text: qsTr("No output device available")
                        color: Theme.mutedForeground
                    }

                    Repeater {
                        id: outputDevices
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

                    MainVolumeRow {
                        id: inputRow
                        section: "input"
                        width: parent.width
                    }

                    Repeater {
                        id: inputDevices
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
                        text: qsTr("Applications")
                    }

                    Repeater {
                        id: streamRows
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

    component MainVolumeRow: Ui.MenuRow {
        id: volumeRow
        required property string section
        readonly property bool isOutput: section === "output"
        readonly property bool available: isOutput ? root.hasOutput : !!(audio.source && audio.source.audio)
        objectName: isOutput ? "outputVolumeRow" : "inputVolumeRow"
        contentPadding: 0
        hasCursor: root.focusSection === section && root.selectedIndex === -1
        height: controls.implicitHeight

        function edit(): void {
            controls.edit();
        }

        MouseArea {
            anchors.fill: parent
            enabled: volumeRow.available
            onClicked: controls.edit()
        }
        Ui.SectionHeader {
            anchors.left: parent.left
            anchors.right: controls.left
            anchors.rightMargin: Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Theme.space2
            text: volumeRow.isOutput ? qsTr("Output") : qsTr("Input")
            elide: Text.ElideRight
        }
        VolumeControl {
            id: controls
            objectName: volumeRow.isOutput ? "outputVolume" : "inputVolume"
            anchors.right: toggle.left
            anchors.rightMargin: Theme.space1
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            label: volumeRow.isOutput ? qsTr("Output") : qsTr("Input")
            value: volumeRow.isOutput ? audio.outputVolume : audio.inputVolume
            enabled: volumeRow.available
            onVolumeRequested: value => {
                if (volumeRow.isOutput)
                    audio.setOutputVolume(value);
                else
                    audio.setInputVolume(value);
            }
            onActivated: root.selectControls(volumeRow.section, -1)
            onEditingChanged: root.trackEditor(controls)
            onFinished: keyCatcher.forceActiveFocus()
        }
        Ui.ToggleIndicator {
            id: toggle
            objectName: volumeRow.isOutput ? "outputToggle" : "inputToggle"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: volumeRow.isOutput ? root.hasOutput && !audio.outputMuted : !!audio.source && !audio.inputMuted
            enabled: volumeRow.available
            Accessible.name: volumeRow.isOutput ? qsTr("Output enabled") : qsTr("Input enabled")
            onClicked: {
                root.selectControls(volumeRow.section, -1);
                keyCatcher.forceActiveFocus();
                if (volumeRow.isOutput)
                    audio.toggleMute();
                else
                    audio.toggleInputMute();
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

        hasCursor: root.focusSection === section && root.selectedIndex === rowIndex
        color: hasCursor ? Theme.cursorFill : isActive ? Theme.normalFill : deviceHover.hovered ? Theme.normalFill : "transparent"
        HoverHandler {
            id: deviceHover
        }
        implicitHeight: Theme.menuRowHeight
        Accessible.role: Accessible.RadioButton
        Accessible.name: Utils.nodeLabel(node)
        Accessible.checked: isActive
        Accessible.onPressAction: deviceRow.activate()

        function activate(): void {
            root.selectControls(section, rowIndex);
            keyCatcher.forceActiveFocus();
            root.activateCursor();
        }

        MouseArea {
            anchors.fill: parent
            onClicked: deviceRow.activate()
        }

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
                font.weight: deviceRow.isActive ? Theme.fontWeightMedium : Theme.fontWeightNormal
                font.pixelSize: Theme.fontSizeBody
                text: Utils.nodeLabel(deviceRow.node)
                textFormat: Text.PlainText
                width: Math.max(0, parent.width - Theme.iconColumnWidth * 2 - Theme.space2 * 2)
            }

            Controls.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "✓"
                color: Theme.primary
                opacity: deviceRow.isActive ? 1 : 0
                width: Theme.iconColumnWidth
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Application controls keep keyboard adjustments scoped to that stream.
    component StreamRow: Ui.MenuRow {
        id: streamRow

        required property PwNode node
        required property int rowIndex
        contentPadding: 0
        readonly property bool streamMuted: node && node.audio ? node.audio.muted : false
        readonly property real streamVolume: node && node.audio ? node.audio.volume : 0

        hasCursor: root.focusSection === "streams" && root.selectedIndex === rowIndex
        implicitHeight: streamControls.implicitHeight

        function editVolume(): void {
            streamControls.edit();
        }

        MouseArea {
            anchors.fill: parent
            onClicked: streamControls.edit()
        }

        Controls.Label {
            anchors.left: parent.left
            anchors.leftMargin: Theme.space15
            anchors.right: streamControls.left
            anchors.rightMargin: Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: audio.streamLabel(streamRow.node)
            textFormat: Text.PlainText
        }
        VolumeControl {
            id: streamControls
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            label: audio.streamLabel(streamRow.node)
            maximum: 1.5
            value: streamRow.streamVolume
            muted: streamRow.streamMuted
            enabled: !!(streamRow.node && streamRow.node.audio)
            onVolumeRequested: value => audio.setStreamVolume(streamRow.node, value)
            onActivated: root.selectControls("streams", streamRow.rowIndex)
            onEditingChanged: root.trackEditor(streamControls)
            onFinished: keyCatcher.forceActiveFocus()
        }
    }
}
