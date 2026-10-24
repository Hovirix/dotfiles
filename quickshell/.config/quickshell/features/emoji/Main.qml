pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import "search.js" as Utils
import "../.."
import "../../ui" as Ui

Scope {
    id: feature

    readonly property Component panel: Component {
        Ui.Panel {
            id: root

            readonly property int columns: Math.max(1, Math.floor(width / Theme.emojiCellSize))
            readonly property var controller: feature.popup
            readonly property int menuHeight: Theme.emojiHeight - Theme.popupBorderWidth * 2
            readonly property bool menuStyle: true
            readonly property int menuWidth: Theme.popupWidthPicker
            property string query: ""
            property int selectedIndex: 0

            function activate(): void {
                var item = emoji.entries[selectedIndex];
                if (!item)
                    return;
                emoji.copy(item.e);
                controller.close();
            }

            function focusMenu(): void {
                Qt.callLater(function () {
                    filterInput.forceActiveFocus();
                });
            }

            function move(delta: int, wrap: bool): void {
                if (!emoji.entries.length)
                    return;
                var next = selectedIndex + delta;
                selectedIndex = wrap ? (next + emoji.entries.length) % emoji.entries.length : Math.max(0, Math.min(emoji.entries.length - 1, next));
                resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain);
            }

            function setQuery(text: string): void {
                query = text;
                selectedIndex = 0;
                resultGrid.positionViewAtBeginning();
            }

            onQueryChanged: if (filterInput.text !== query)
                filterInput.text = query

            Item {
                id: emoji

                property var allItems: []
                readonly property var entries: Utils.filterEmojis(allItems, query, 1000)
                property string query: root.query

                function copy(item: string): void {
                    Quickshell.execDetached(["wl-copy", item]);
                }

                FileView {
                    path: Qt.resolvedUrl("emojis.json")

                    onLoaded: emoji.allItems = Utils.parseEmojis(text())
                }
            }

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
                onCloseRequested: root.query ? root.setQuery("") : root.controller.close()
                onMoveRequested: function (dx, dy) {
                    root.move(dy ? dy * root.columns : dx, !dy);
                }
                onPageRequested: function (direction) {
                    root.move(direction * root.columns * Math.max(1, Math.floor(resultGrid.height / resultGrid.cellHeight)), false);
                }

                Column {
                    anchors.fill: parent
                    spacing: Theme.space15

                    Item {
                        height: Theme.menuHeaderHeight
                        width: parent.width

                        Ui.SearchField {
                            id: filterInput

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Theme.fontSizeHeading
                            keyHandler: keys

                            onTextChanged: if (text !== root.query)
                                root.setQuery(text)
                        }

                        Controls.Label {
                            anchors.fill: filterInput
                            font.pixelSize: Theme.fontSizeHeading
                            opacity: 0.58
                            text: qsTr("Search emojis…")
                            textFormat: Text.PlainText
                            verticalAlignment: Text.AlignVCenter
                            visible: !root.query && !filterInput.preeditText
                        }
                    }

                    Item {
                        height: parent.height - Theme.menuHeaderHeight - Theme.space15
                        width: parent.width

                        GridView {
                            id: resultGrid

                            anchors.fill: parent
                            boundsBehavior: Flickable.StopAtBounds
                            cellHeight: Theme.emojiCellSize
                            cellWidth: Theme.emojiCellSize
                            clip: true
                            interactive: false
                            model: emoji.entries

                            delegate: Rectangle {
                                id: cell

                                required property int index
                                required property var modelData

                                color: index === root.selectedIndex ? Theme.cursorFill : "transparent"
                                height: resultGrid.cellHeight
                                radius: Theme.radius
                                width: resultGrid.cellWidth

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

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.space2
                            visible: emoji.entries.length === 0

                            Controls.Label {
                                color: Theme.primary
                                font.family: Theme.iconFontFamily
                                font.pixelSize: Theme.batteryGlyphSize
                                horizontalAlignment: Text.AlignHCenter
                                opacity: 0.8
                                text: "󰈉"
                                width: parent.width
                            }

                            Controls.Label {
                                font.pixelSize: Theme.fontSizeTitle
                                horizontalAlignment: Text.AlignHCenter
                                opacity: 0.7
                                text: qsTr("No matches for “%1”").arg(root.query)
                                textFormat: Text.PlainText
                                width: Math.min(implicitWidth, root.width)
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
        }
    }
    required property Ui.Popup popup
}
