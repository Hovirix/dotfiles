pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import "../.."
import "../../ui" as Ui
import "../../core" as Core
import "search.js" as Utils

Ui.Panel {
    id: root

    required property var items
    required property string placeholderText
    readonly property int columns: Math.max(1, Math.floor(width / Theme.emojiCellSize))
    property string query: ""
    property int selectedIndex: 0
    readonly property var entries: Utils.filterEmojis(items, query, 1000)
    readonly property alias filterInput: searchLayout.input
    signal selected(string value)
    signal cancelled

    function activate(): void {
        var item = entries[selectedIndex];
        if (item)
            selected(item.e);
    }

    function focusMenu(): void {
        Qt.callLater(() => filterInput.forceActiveFocus());
    }

    function move(delta: int, wrap: bool): void {
        if (!entries.length)
            return;
        var next = selectedIndex + delta;
        selectedIndex = wrap ? (next + entries.length) % entries.length : Math.max(0, Math.min(entries.length - 1, next));
        resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain);
    }

    function setQuery(text: string): void {
        query = text;
        selectedIndex = 0;
        resultGrid.positionViewAtBeginning();
    }

    onQueryChanged: if (filterInput.text !== query)
        filterInput.text = query

    Ui.Navigation {
        id: keys
        anchors.fill: parent
        qCloses: false
        spaceActivates: false
        textInputBackspace: !!root.query || !!filterInput.preeditText
        textInputEdits: true
        vimNavigation: false
        onActivateRequested: root.activate()
        onClearTextRequested: root.setQuery("")
        onCloseRequested: root.query ? root.setQuery("") : root.cancelled()
        onMoveRequested: (dx, dy) => root.move(dy ? dy * root.columns : dx, !dy)
        onPageRequested: direction => root.move(direction * root.columns * Math.max(1, Math.floor(resultGrid.height / resultGrid.cellHeight)), false)

        Core.SearchLayout {
            id: searchLayout
            anchors.fill: parent
            input.keyHandler: keys
            input.placeholderText: root.placeholderText
            Connections {
                target: searchLayout.input
                function onTextChanged(): void {
                    if (searchLayout.input.text !== root.query)
                        root.setQuery(searchLayout.input.text);
                }
            }

            Item {
                anchors.fill: parent

                GridView {
                    id: resultGrid
                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    cellHeight: searchLayout.cellHeight
                    cellWidth: Theme.emojiCellSize
                    clip: true
                    model: root.entries
                    snapMode: GridView.SnapToRow
                    Controls.ScrollBar.vertical: Controls.ScrollBar {
                        policy: Controls.ScrollBar.AlwaysOff
                    }
                    delegate: Ui.CursorSurface {
                        id: cell
                        required property int index
                        required property var modelData
                        hasCursor: index === root.selectedIndex
                        height: resultGrid.cellHeight
                        width: resultGrid.cellWidth

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selected(cell.modelData.e)
                        }

                        Controls.Label {
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeDisplaySmall
                            horizontalAlignment: Text.AlignHCenter
                            text: cell.modelData ? cell.modelData.e : ""
                            textFormat: Text.PlainText
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Controls.Label {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: root.entries.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("No matches for “%1”").arg(root.query)
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Theme.mutedForeground
                }
            }
        }
    }
}
