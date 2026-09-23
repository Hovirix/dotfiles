import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "../../Appearance" as A
import "../../Ui" as Ui
import "./audio-model.js" as Model

Item {
 id: root

 property bool opened: false

 function open() { opened = true }
 function close() { opened = false }
 function toggle() { opened ? close() : open() }

 readonly property var sink: Pipewire.defaultAudioSink
 readonly property var source: Pipewire.defaultAudioSource
 readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
 readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []

 readonly property var candidateSinks: {
   var list = []
   for (var i = 0; i < nodes.length; i++) {
     var n = nodes[i]
     if (n && n.isSink && !n.isStream) list.push(n)
   }
   return list
 }

 readonly property var candidateSources: {
   var list = []
   for (var i = 0; i < nodes.length; i++) {
     var n = nodes[i]
     if (n && !n.isSink && !n.isStream && isAudioSource(n)) {
       var name = n.name || ""
       if (name === "quickshell") continue
       list.push(n)
     }
   }
   return list
 }

 readonly property var candidateStreams: {
   var list = []
   for (var i = 0; i < nodes.length; i++) {
     var n = nodes[i]
     if (!n || !n.isStream || !isPlaybackStream(n)) continue
     list.push(n)
   }
   return list
 }

 // Identify true playback streams without reading node.properties here:
 // PwNode.properties is invalid until the node is bound, and reading it while
 // capture streams are appearing (for example, when Voxtype starts recording)
 // can destabilize Quickshell's Pipewire service. Quickshell versions differ
 // in how \`type\` is exposed (media.class, enum name, or numeric enum), but
 // playback streams consistently accept audio input from clients and publish
 // \`isSink: true\`; capture streams publish as stream sources.
 function isPlaybackStream(node) {
   return Model.isPlaybackStream(node)
 }

 function isAudioSource(node) {
   return Model.isAudioSource(node)
 }

 readonly property var audioSinks: {
   var list = candidateSinks.slice()
   if (sink && list.indexOf(sink) < 0) list.unshift(sink)
   return list
 }

 readonly property var audioSources: {
   var list = candidateSources.slice()
   if (source && list.indexOf(source) < 0) list.unshift(source)
   return list
 }

 readonly property var audioStreams: {
   var list = []
   for (var i = 0; i < candidateStreams.length; i++)
     if (candidateStreams[i].audio) list.push(candidateStreams[i])
   return list
 }

 // Feed Repeaters with panel-local snapshots instead of the live PipeWire
 // model. PipeWire can remove nodes while Quickshell is dispatching the
 // removal signal; rebuilding a Repeater from that signal path has crashed
 // in Quickshell's PipeWire service. The snapshot timer lets that mutation
 // settle first, and closed panels keep their repeaters detached entirely.
 property var displayAudioSinks: []
 property var displayAudioSources: []
 property var displayAudioStreams: []

 readonly property var volumeSink: sink

 readonly property real outputVolume: volumeSink && volumeSink.audio ? volumeSink.audio.volume : 0
 readonly property bool outputMuted: volumeSink && volumeSink.audio ? volumeSink.audio.muted : false
 readonly property real inputVolume: source && source.audio ? source.audio.volume : 0
 readonly property bool inputMuted: source && source.audio ? source.audio.muted : false

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
 property int selectedIndex: -1
 property bool cursorActive: false

 // "header" is a virtual section for the hero output mute toggle; it sits
 // above the output section so the speaker can be muted from the keyboard.
 readonly property bool headerHasCursor: cursorActive && focusSection === "header"
 // Only channels that actually exist get a vote. A box with no default source
 // would otherwise report "input unmuted" forever, leaving the hero switch
 // able to mute but never to unmute.
 readonly property bool hasOutput: !!(volumeSink && volumeSink.audio)
 readonly property bool hasInput: !!(source && source.audio)
 readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)

 function sectionCount(section) {
   if (section === "output") return displayAudioSinks.length
   if (section === "input") return displayAudioSources.length
   if (section === "streams") return displayAudioStreams.length
   return 0
 }

 function sectionVisible(section) {
   if (section === "output") return true
   if (section === "input") return displayAudioSources.length > 0 || !!source
   if (section === "streams") return displayAudioStreams.length > 0
   return false
 }

 function sectionHasSlider(section) {
   if (section === "output") return true
   if (section === "input") return !!source
   return false  // stream rows carry their own sliders inline; not a section-level slider
 }

 // Order of visible sections, recomputed reactively so dropping a section
 // (e.g. no input devices) doesn't leave the cursor pointing at it.
 readonly property var visibleSections: {
   var list = []
   if (sectionVisible("output")) list.push("output")
   if (sectionVisible("input")) list.push("input")
   if (sectionVisible("streams")) list.push("streams")
   return list
 }

 // Tab keeps navigation at the section level: output, input, then app
 // sources. Each switch lands on that section's primary control.
 function cycleFocusSection(direction) {
   var sections = visibleSections
   if (sections.length === 0) return
   var index = sections.indexOf(focusSection)
   if (index < 0) index = direction > 0 ? -1 : 0
   index = (index + direction + sections.length) % sections.length
   focusSection = sections[index]
   selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
   cursorActive = true
 }

 function moveCursor(delta) {
   var sections = visibleSections
   if (sections.length === 0) return
   if (focusSection === "header") {
     if (delta > 0) { focusSection = sections[0]; selectedIndex = sectionHasSlider(sections[0]) ? -1 : 0 }
     return
   }
   var sIdx = sections.indexOf(focusSection)
   if (sIdx < 0) { focusSection = sections[0]; selectedIndex = sectionHasSlider(focusSection) ? -1 : 0; return }

   var idx = selectedIndex
   var max = sectionCount(focusSection) - 1  // last device index
   var hasSlider = sectionHasSlider(focusSection)
   var floor = hasSlider ? -1 : 0  // -1 = slider row

   if (delta > 0) {
     if (idx < max) { selectedIndex = idx + 1; return }
     // Fall through to next section.
     if (sIdx < sections.length - 1) {
       focusSection = sections[sIdx + 1]
       selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
     }
   } else {
     if (idx > floor) { selectedIndex = idx - 1; return }
     // Escape upward.
     if (sIdx > 0) {
       focusSection = sections[sIdx - 1]
       var prevMax = sectionCount(focusSection) - 1
       selectedIndex = prevMax >= 0 ? prevMax : (sectionHasSlider(focusSection) ? -1 : 0)
     } else {
       focusSection = "header"
     }
   }
 }

 function setHeaderCursor() {
   cursorActive = true
   focusSection = "header"
   selectedIndex = -1
 }

 // Adjust the slider associated with the focused section. Output and
 // input sliders are real volume controls; on stream rows h/l adjusts
 // that stream's volume (so keyboard parity with the inline slider).
 // For device rows (selectedIndex >= 0 in output/input) h/l is a no-op
 // — the cursor is on a discrete row, not on the slider, and silently
 // moving the global slider would surprise the user.
 function adjustVolume(delta) {
   if (focusSection === "output" && selectedIndex === -1) {
     setOutputVolume(outputVolume + delta)
     return
   }
   if (focusSection === "input" && selectedIndex === -1) {
     setInputVolume(inputVolume + delta)
     return
   }
   if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < displayAudioStreams.length) {
     var s = displayAudioStreams[selectedIndex]
     if (s && s.audio) s.audio.volume = Math.max(0, Math.min(1.5, s.audio.volume + delta))
   }
 }

 // Enter/Space: activate whatever the cursor is on.
 function activateCursor() {
   if (focusSection === "header") { toggleAllMuted(); return }
   if (focusSection === "output") {
     if (selectedIndex === -1) { toggleOutputMute(); return }
     var sink = displayAudioSinks[selectedIndex]
     if (sink) setDefaultSink(sink)
     return
   }
   if (focusSection === "input") {
     if (selectedIndex === -1) { toggleInputMute(); return }
     var src = displayAudioSources[selectedIndex]
     if (src) setDefaultSource(src)
     return
   }
   if (focusSection === "streams" && selectedIndex >= 0) {
     var st = displayAudioStreams[selectedIndex]
     if (st && st.audio) st.audio.muted = !st.audio.muted
   }
 }

 function toggleFocusedMute() {
   if (focusSection === "streams" && selectedIndex >= 0
       && selectedIndex < displayAudioStreams.length) {
     var stream = displayAudioStreams[selectedIndex]
     if (stream && stream.audio) stream.audio.muted = !stream.audio.muted
   } else if (focusSection === "input") {
     toggleInputMute()
   } else {
     toggleOutputMute()
   }
 }

 onOpenedChanged: {
   if (opened) {
     refreshDisplayAudioModels()
     focusSection = "output"
     selectedIndex = -1  // first keyboard cursor reveal starts on the output slider
     cursorActive = false
     Qt.callLater(resetScroll)
   } else {
     clearDisplayAudioModels()
   }
 }

 // Clamp / repair the cursor whenever any list refreshes underneath us.
 onAudioSinksChanged: scheduleDisplayAudioModelRefresh()
 onAudioSourcesChanged: scheduleDisplayAudioModelRefresh()
 onAudioStreamsChanged: scheduleDisplayAudioModelRefresh()

 function listSnapshot(list) {
   return Model.listSnapshot(list)
 }

 function refreshDisplayAudioModels() {
   if (!opened) return
   displayAudioSinks = listSnapshot(audioSinks)
   displayAudioSources = listSnapshot(audioSources)
   displayAudioStreams = listSnapshot(audioStreams)
   clampCursor()
 }

 function scheduleDisplayAudioModelRefresh() {
   if (!opened) return
   audioModelRefreshTimer.restart()
 }

 function clearDisplayAudioModels() {
   audioModelRefreshTimer.stop()
   displayAudioSinks = []
   displayAudioSources = []
   displayAudioStreams = []
 }

 // Keep the keyboard-focused row inside the visible viewport of the
 // multi-section ScrollView.
 function resetScroll() {
   if (!scrollArea) return
   var flick = scrollArea.contentItem
   if (flick && flick.contentY !== undefined) flick.contentY = 0
 }

 function ensureCursorVisible(item) {
   if (!item || !scrollArea) return
   var flick = scrollArea.contentItem
   if (!flick || flick.contentY === undefined) return
   var margin = A.Appearance.space15
   var maxY = Math.max(0, (flick.contentHeight || 0) - flick.height)
   if (maxY <= 24 || (root.focusSection === "output" && root.selectedIndex === -1)) {
     flick.contentY = 0
     return
   }
   var pt = item.mapToItem(flick.contentItem || flick, 0, 0)
   var top = pt.y
   var bottom = top + (item.height || 0)
   var viewTop = flick.contentY
   var viewBottom = viewTop + flick.height
   if (top < viewTop + margin) flick.contentY = Math.max(0, Math.min(maxY, top - margin))
   else if (bottom > viewBottom - margin)
     flick.contentY = Math.max(0, Math.min(maxY, bottom + margin - flick.height))
 }

 function clampCursor() {
   var sections = visibleSections
   if (!sections || !sections.length) return
   // "header" is virtual and never appears in visibleSections, so it has to
   // be let through: muting republishes the PipeWire snapshot, and clamping
   // would knock the cursor off the hero switch on every toggle.
   if (focusSection === "header") return
   if (sections.indexOf(focusSection) < 0) {
     focusSection = visibleSections[0]
     selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
     return
   }
   var count = sectionCount(focusSection)
   var hasSlider = sectionHasSlider(focusSection)
   var floor = hasSlider ? -1 : 0
   if (selectedIndex > count - 1) selectedIndex = Math.max(floor, count - 1)
   if (selectedIndex < floor) selectedIndex = floor
 }

 function outputIcon() {
   if (!sink || !sink.audio) return ""
   if (isHeadphones(sink)) return "󰋋"
   if (outputMuted) return ""
   var v = outputVolume
   if (v >= 0.67) return ""
   if (v >= 0.34) return ""
   if (v > 0) return ""
   return ""
 }

 function outputVolumeName(volume, muted) {
   return Model.outputVolumeName(volume, muted)
 }

 function setOutputVolume(v) {
   if (!volumeSink || !volumeSink.audio) return outputVolume
   var volume = Math.max(0, Math.min(1, v))
   volumeSink.audio.volume = volume
   return volume
 }

 function setInputVolume(v) {
   if (!source || !source.audio) return
   source.audio.volume = Math.max(0, Math.min(1, v))
 }

 function toggleOutputMute() {
   if (volumeSink && volumeSink.audio) volumeSink.audio.muted = !volumeSink.audio.muted
 }

 function toggleInputMute() {
   if (source && source.audio) source.audio.muted = !source.audio.muted
 }

 // The hero switch is the whole panel's on/off, so it carries both channels
 // at once. It reads as on while anything is still audible, which keeps
 // muting a single channel from the row below flipping the master switch.
 function toggleAllMuted() {
   var mute = anyAudible
   if (hasOutput) volumeSink.audio.muted = mute
   if (hasInput) source.audio.muted = mute
 }

 function setDefaultSink(node) {
   if (node) Pipewire.preferredDefaultAudioSink = node
 }

 function setDefaultSource(node) {
   if (node) Pipewire.preferredDefaultAudioSource = node
 }

 function nodeLabel(node) {
   return Model.nodeLabel(node)
 }

 function isHeadphones(node) {
   return Model.isHeadphones(node)
 }

 function sinkGlyph(node) {
   return Model.sinkGlyph(node)
 }

 function sourceGlyph(node) {
   return Model.sourceGlyph(node)
 }

 function streamLabel(node) {
   return Model.streamLabel(node, mprisPlayers, displayAudioStreams)
 }

 PwObjectTracker { objects: root.candidateSinks }
 PwObjectTracker { objects: root.candidateSources }
 PwObjectTracker { objects: root.audioStreams }

  PwNodePeakMonitor {
    id: inputPeakMonitor
    node: root.source
    enabled: root.opened && !!root.source
  }

  PwNodePeakMonitor {
    id: outputPeakMonitor
    node: root.sink
    enabled: root.opened && !!root.sink
  }

 Timer {
   id: audioModelRefreshTimer
   interval: 75
   repeat: false
   onTriggered: root.refreshDisplayAudioModels()
 }

 Ui.Popup {
   shown: root.opened
   contentHeight: Math.min(panelColumn.implicitHeight + A.Appearance.dialogPadding * 2,
                           A.Appearance.popupMaxHeight)
   onCloseRequested: root.close()
   onVisibleChanged: if (visible) Qt.callLater(function() {
     keyCatcher.forceActiveFocus()
   })

 Ui.KeyCatcher {
     id: keyCatcher
     anchors.fill: parent
     onMoveRequested: function(dx, dy) {
       if (!root.cursorActive) root.cursorActive = true
       if (dy !== 0) root.moveCursor(dy)
       else if (dx !== 0) root.adjustVolume(dx * 0.05)
     }
     onActivateRequested: if (root.cursorActive) root.activateCursor()
     onCloseRequested: root.close()
     onTabRequested: function(direction) { root.cycleFocusSection(direction) }
     onTextKey: function(t) {
       // 'm' always toggles the active channel; the popup defaults to output.
       if (t === "m" || t === "M") {
         root.toggleFocusedMute()
       }
     }

     ScrollView {
       id: scrollArea
       anchors.fill: parent
       clip: true
       ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
       ScrollBar.vertical.policy: panelColumn.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
       Binding {
         target: scrollArea.contentItem
         property: "interactive"
         value: panelColumn.implicitHeight > scrollArea.height
       }

       Column {
         id: panelColumn
         width: scrollArea.availableWidth
         spacing: A.Appearance.space4

         // ---------- Hero: speaker icon · title/status ----------
         Item {
           id: heroItem
           width: parent.width
           implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)

           // Status only — the switch owns muting, mouse and keyboard alike.
           Text {
             id: heroIcon
             textFormat: Text.PlainText
             text: root.outputIcon()
             color: A.Appearance.foreground
             font.family: A.Appearance.iconFontFamily
             font.pixelSize: 24
             opacity: root.outputMuted ? 0.5 : 1.0
             anchors.left: parent.left
             anchors.verticalCenter: parent.verticalCenter
           }

           // Compact on/off switch on the trailing edge of the hero, and the
           // header's only cursor target. Checked means something is still
           // audible, so muting everything reads as switching audio off.
           Ui.Switch {
             id: powerSwitch
             checked: root.anyAudible
             hasCursor: root.headerHasCursor
             foreground: A.Appearance.foreground
             anchors.right: parent.right
             anchors.verticalCenter: parent.verticalCenter
             onHovered: function(on) { if (on) root.setHeaderCursor() }
             onToggled: root.toggleAllMuted()
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
               text: "Audio"
               color: A.Appearance.foreground
               font.family: A.Appearance.fontFamily
               font.pixelSize: A.Appearance.fontSizeTitle
               font.bold: true
               elide: Text.ElideRight
               width: parent.width
             }

             Text {
               id: heroLabel
               textFormat: Text.PlainText
               text: root.outputVolumeName(
                 outputSlider.dragging ? outputSlider.liveValue : root.outputVolume,
                 root.outputMuted
               ).toUpperCase()
               color: Qt.darker(A.Appearance.foreground, 1.4)
               font.family: A.Appearance.fontFamily
               font.pixelSize: A.Appearance.fontSizeBody
               font.bold: true
               font.letterSpacing: 1.2
               elide: Text.ElideRight
               width: parent.width
             }
           }
         }

         // ---- Output devices ----
         Ui.Separator {
         }

         Column {
           width: parent.width
           spacing: A.Appearance.space15

           Item {
             width: parent.width
             implicitHeight: Math.max(outputHeader.implicitHeight, outputPercent.implicitHeight)

             Ui.SectionHeader {
               id: outputHeader
               text: "OUTPUT"
               foreground: A.Appearance.foreground
               fontFamily: A.Appearance.fontFamily
               anchors.left: parent.left
               anchors.verticalCenter: parent.verticalCenter
             }

             Text {
               id: outputPercent
               textFormat: Text.PlainText
               text: Math.round((outputSlider.dragging ? outputSlider.liveValue : root.outputVolume) * 100) + "%"
               color: Qt.darker(A.Appearance.foreground, 1.4)
               font.family: A.Appearance.fontFamily
               font.pixelSize: A.Appearance.fontSizeBody
               font.bold: true
               anchors.right: parent.right
               anchors.rightMargin: A.Appearance.space15
               anchors.verticalCenter: parent.verticalCenter
               opacity: root.outputMuted ? 0.5 : 1.0
             }
           }

           Ui.SelectRow {
             id: outputSliderRow
             width: parent.width
             height: outputSlider.implicitHeight + A.Appearance.space2
             contentPadding: 0
             hasCursor: root.cursorActive && root.focusSection === "output" && root.selectedIndex === -1
             onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(outputSliderRow)

              Item {
                id: outputControls
                anchors.fill: parent
                implicitHeight: outputSlider.implicitHeight

                Ui.Slider {
                  id: outputSlider
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.top: parent.top
                  height: implicitHeight
                  minimum: 0
                  maximum: 1
                  step: 0.05
                  value: root.outputVolume
                  opacity: root.outputMuted ? 0.5 : 1.0
                  enabled: !!root.sink

                  onMoved: function(v) { root.setOutputVolume(v) }
                  onRightClicked: root.toggleOutputMute()
                }

                // Output level meter docked under the slider so this row
                // keeps the exact geometry of the input slider row.
                Rectangle {
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.top: outputSlider.bottom
                  height: A.Appearance.space05
                  color: Qt.rgba(A.Appearance.foreground.r, A.Appearance.foreground.g, A.Appearance.foreground.b, 0.18)
                  opacity: root.outputMuted ? 0.35 : 1.0

                  Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(1, outputPeakMonitor.peak))
                    color: A.Appearance.foreground
                    Behavior on width { NumberAnimation { duration: 70 } }
                  }
                }
              }

             HoverHandler {
               onHoveredChanged: if (hovered) {
                 root.cursorActive = true
                 root.focusSection = "output"
                 root.selectedIndex = -1
               }
             }
           }

           Repeater {
             model: root.displayAudioSinks

             DeviceRow {
               required property var modelData
               required property int index
               width: panelColumn.width
               node: modelData
               rowIndex: index
               section: "output"
             }
           }
         }

         // ---- Input ----
         Ui.Separator {
           visible: root.displayAudioSources.length > 0 || !!root.source
         }

         Column {
           width: parent.width
           spacing: A.Appearance.space15
           visible: root.displayAudioSources.length > 0 || !!root.source

           Item {
             width: parent.width
             implicitHeight: Math.max(microphoneHeader.implicitHeight, microphonePercent.implicitHeight)

             Ui.SectionHeader {
               id: microphoneHeader
               text: "INPUT"
               foreground: A.Appearance.foreground
               fontFamily: A.Appearance.fontFamily
               anchors.left: parent.left
               anchors.verticalCenter: parent.verticalCenter
             }

             Text {
               id: microphonePercent
               textFormat: Text.PlainText
               text: Math.round((inputSlider.dragging ? inputSlider.liveValue : root.inputVolume) * 100) + "%"
               color: Qt.darker(A.Appearance.foreground, 1.4)
               font.family: A.Appearance.fontFamily
               font.pixelSize: A.Appearance.fontSizeBody
               font.bold: true
               anchors.right: parent.right
               anchors.rightMargin: A.Appearance.space15
               anchors.verticalCenter: parent.verticalCenter
               opacity: root.inputMuted ? 0.5 : 1.0
             }
           }

           Ui.SelectRow {
             id: inputSliderRow
             visible: !!root.source
             width: parent.width
             height: inputControls.implicitHeight + A.Appearance.space2
             contentPadding: 0
             hasCursor: root.cursorActive && root.focusSection === "input" && root.selectedIndex === -1
             onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(inputSliderRow)

             Item {
               id: inputControls
               anchors.fill: parent
               implicitHeight: inputSlider.implicitHeight

               Ui.Slider {
                 id: inputSlider
                 anchors.left: parent.left
                 anchors.right: parent.right
                 anchors.top: parent.top
                 height: implicitHeight
                 minimum: 0
                 maximum: 1
                 step: 0.05
                 value: root.inputVolume
                 opacity: root.inputMuted ? 0.5 : 1.0
                 enabled: !!root.source

                 onMoved: function(v) { root.setInputVolume(v) }
                 onRightClicked: root.toggleInputMute()
               }

               // Mic level meter docked under the slider so this row
               // keeps the exact geometry of the output slider row.
               Rectangle {
                 anchors.left: parent.left
                 anchors.right: parent.right
                 anchors.top: inputSlider.bottom
                 height: A.Appearance.space05
                 color: Qt.rgba(A.Appearance.foreground.r, A.Appearance.foreground.g, A.Appearance.foreground.b, 0.18)
                 opacity: root.inputMuted ? 0.35 : 1.0

                 Rectangle {
                   anchors.left: parent.left
                   anchors.top: parent.top
                   anchors.bottom: parent.bottom
                   width: parent.width * Math.max(0, Math.min(1, inputPeakMonitor.peak))
                   color: A.Appearance.foreground
                   Behavior on width { NumberAnimation { duration: 70 } }
                 }
               }
             }

             HoverHandler {
               onHoveredChanged: if (hovered) {
                 root.cursorActive = true
                 root.focusSection = "input"
                 root.selectedIndex = -1
               }
             }
           }

           Repeater {
             model: root.displayAudioSources

             DeviceRow {
               required property var modelData
               required property int index
               width: panelColumn.width
               node: modelData
               rowIndex: index
               section: "input"
             }
           }
         }

         // ---- Per-app streams ----
         Ui.Separator {
           visible: root.displayAudioStreams.length > 0
         }

         Column {
           width: parent.width
           spacing: A.Appearance.space25
           visible: root.displayAudioStreams.length > 0

           Ui.SectionHeader {
             text: "SOURCES"
             foreground: A.Appearance.foreground
             fontFamily: A.Appearance.fontFamily
           }

           Repeater {
             model: root.displayAudioStreams

             StreamRow {
               required property var modelData
               required property int index
               width: panelColumn.width
               node: modelData
               rowIndex: index
             }
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
   required property var node
   required property int rowIndex
   required property string section

   readonly property var defaultNode: section === "output" ? root.sink : root.source
   readonly property bool isActive: defaultNode && node && defaultNode.id === node.id
   hasCursor: root.cursorActive && root.focusSection === section && root.selectedIndex === rowIndex
   onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(deviceRow)
   current: isActive
   implicitHeight: deviceInner.implicitHeight + A.Appearance.space2

   Row {
     id: deviceInner
     anchors.left: parent.left
     anchors.right: parent.right
     anchors.verticalCenter: parent.verticalCenter
     anchors.leftMargin: A.Appearance.space15
     anchors.rightMargin: A.Appearance.space15
     spacing: A.Appearance.space2

     Text {
       textFormat: Text.PlainText
       text: deviceRow.section === "output" ? root.sinkGlyph(deviceRow.node) : root.sourceGlyph(deviceRow.node)
       color: A.Appearance.foreground
       font.family: A.Appearance.iconFontFamily
       font.pixelSize: A.Appearance.fontSizeTitle
       width: A.Appearance.iconColumnWidth
       horizontalAlignment: Text.AlignHCenter
       anchors.verticalCenter: parent.verticalCenter
     }

     Text {
       textFormat: Text.PlainText
       text: root.nodeLabel(deviceRow.node)
       color: A.Appearance.foreground
       font.family: A.Appearance.fontFamily
       font.pixelSize: A.Appearance.fontSizeBody
       font.bold: deviceRow.isActive
       elide: Text.ElideRight
       width: parent.width - A.Appearance.iconColumnWidth - A.Appearance.space2
       anchors.verticalCenter: parent.verticalCenter
     }
   }

   MouseArea {
     anchors.fill: parent
     hoverEnabled: true
     cursorShape: Qt.PointingHandCursor
     onContainsMouseChanged: if (containsMouse) {
       root.cursorActive = true
       root.focusSection = deviceRow.section
       root.selectedIndex = deviceRow.rowIndex
     }
     onClicked: {
       if (deviceRow.section === "output") root.setDefaultSink(deviceRow.node)
       else root.setDefaultSource(deviceRow.node)
     }
   }
 }

 // Per-app stream row — cursor target inside the "streams" section.
 // The stream has its own slider inline, so h/l from the keyboard
 // adjusts THIS stream's volume (not the global output) when the cursor
 // sits on this row. Enter/Space mutes the stream.
 component StreamRow: Ui.SelectRow {
   id: streamRow
   required property var node
   required property int rowIndex

   readonly property real streamVolume: node && node.audio ? node.audio.volume : 0
   readonly property bool streamMuted: node && node.audio ? node.audio.muted : false

   hasCursor: root.cursorActive && root.focusSection === "streams" && root.selectedIndex === rowIndex
   onHasCursorChanged: if (hasCursor) root.ensureCursorVisible(streamRow)
   implicitHeight: streamColumn.implicitHeight + A.Appearance.space2

   Column {
     id: streamColumn
     anchors.left: parent.left
     anchors.right: parent.right
     anchors.verticalCenter: parent.verticalCenter
     anchors.leftMargin: A.Appearance.space15
     anchors.rightMargin: A.Appearance.space15
     spacing: A.Appearance.space05

     Row {
       width: parent.width
       spacing: A.Appearance.space2

       Text {
         id: streamMuteIcon
         textFormat: Text.PlainText
         text: streamRow.streamMuted ? "󰝟" : "󰕾"
         color: A.Appearance.foreground
         font.family: A.Appearance.fontFamily
         font.pixelSize: A.Appearance.fontSizeTitle
         width: A.Appearance.iconColumnWidth
         horizontalAlignment: Text.AlignHCenter
         anchors.verticalCenter: parent.verticalCenter
         opacity: streamRow.streamMuted ? 0.5 : 1.0

         MouseArea {
           anchors.fill: parent
           cursorShape: Qt.PointingHandCursor
           onClicked: {
             if (streamRow.node && streamRow.node.audio)
               streamRow.node.audio.muted = !streamRow.node.audio.muted
           }
         }
       }

       Text {
         textFormat: Text.PlainText
         text: root.streamLabel(streamRow.node)
         color: A.Appearance.foreground
         font.family: A.Appearance.fontFamily
         font.pixelSize: A.Appearance.fontSizeBody
         elide: Text.ElideRight
         width: parent.width - streamMuteIcon.width - streamPct.width - A.Appearance.space4
         anchors.verticalCenter: parent.verticalCenter
       }

       Text {
         id: streamPct
         textFormat: Text.PlainText
         text: Math.round(streamRow.streamVolume * 100) + "%"
         color: Qt.darker(A.Appearance.foreground, 1.5)
         font.family: A.Appearance.fontFamily
         font.pixelSize: A.Appearance.fontSizeBody
         font.bold: true
         width: 36
         horizontalAlignment: Text.AlignRight
         anchors.verticalCenter: parent.verticalCenter
         opacity: streamRow.streamMuted ? 0.5 : 1.0
       }
     }

     Ui.Slider {
       width: parent.width
       minimum: 0
       maximum: 1.5
       step: 0.05
       value: streamRow.streamVolume
       opacity: streamRow.streamMuted ? 0.5 : 1.0

       onMoved: function(v) {
         if (streamRow.node && streamRow.node.audio) streamRow.node.audio.volume = v
       }
       onRightClicked: {
         if (streamRow.node && streamRow.node.audio)
           streamRow.node.audio.muted = !streamRow.node.audio.muted
       }
     }
   }

   MouseArea {
     anchors.fill: parent
     hoverEnabled: true
     acceptedButtons: Qt.NoButton
     propagateComposedEvents: true
     onContainsMouseChanged: if (containsMouse) {
       root.cursorActive = true
       root.focusSection = "streams"
       root.selectedIndex = streamRow.rowIndex
     }
   }
 }
}
