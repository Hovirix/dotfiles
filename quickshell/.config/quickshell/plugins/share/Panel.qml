pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import "../.."
import "../../ui" as Ui
import "../../core" as Core

Ui.Panel {
    id: root

    required property var sources
    property int selectedIndex: 0
    readonly property var results: sources.map((line, index) => ({
                label: line.replace(/^Window: /, ""),
                index: index
            })).filter(entry => entry.label.toLowerCase().includes(search.text.toLowerCase()))
    title: qsTr("Share a window or screen")
    readonly property alias search: searchLayout.input

    signal selected(int index)
    signal cancelled

    function focusMenu(): void {
        Qt.callLater(() => search.forceActiveFocus());
    }

    function move(delta: int): void {
        if (!results.length)
            return;
        selectedIndex = (selectedIndex + delta + results.length) % results.length;
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function activate(): void {
        if (results.length)
            selected(results[selectedIndex].index);
    }

    Ui.Navigation {
        id: keys
        anchors.fill: parent
        qCloses: false
        spaceActivates: false
        textInputBackspace: true
        textInputEdits: true
        vimNavigation: false
        onActivateRequested: root.activate()
        onCloseRequested: search.text ? search.text = "" : root.cancelled()
        onClearTextRequested: search.text = ""
        onMoveRequested: (dx, dy) => {
            if (dy)
                root.move(dy);
        }
        onTabRequested: direction => root.move(direction)
        onPageRequested: direction => root.move(direction * Math.min(searchLayout.visibleRows, root.results.length))

        Core.SearchLayout {
            id: searchLayout
            anchors.fill: parent
            input.keyHandler: keys
            input.placeholderText: qsTr("Search…")
            Connections {
                target: searchLayout.input
                function onTextChanged(): void {
                    root.selectedIndex = 0;
                    list.positionViewAtBeginning();
                }
            }

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.results
                spacing: searchLayout.rowSpacing
                snapMode: ListView.SnapToItem
                Controls.ScrollBar.vertical: Controls.ScrollBar {
                    policy: Controls.ScrollBar.AlwaysOff
                }

                delegate: Ui.CursorSurface {
                    id: row
                    required property var modelData
                    required property int index
                    width: list.width
                    height: Theme.menuRowHeight
                    hasCursor: index === root.selectedIndex
                    Accessible.role: Accessible.ListItem
                    Accessible.name: modelData.label
                    Accessible.onPressAction: root.selected(row.modelData.index)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.selected(row.modelData.index)
                    }

                    Controls.Label {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.space3
                        anchors.rightMargin: Theme.space3
                        text: row.modelData.label
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Theme.fontSizeBody
                    }
                }

                Controls.Label {
                    anchors.centerIn: parent
                    text: qsTr("No matching sources")
                    color: Theme.mutedForeground
                    visible: !root.results.length
                }
            }
        }
    }
}
