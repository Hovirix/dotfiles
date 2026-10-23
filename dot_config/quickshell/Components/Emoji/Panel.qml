pragma ComponentBehavior: Bound

import QtQuick
import "../../Appearance" as A
import "../../Ui" as Ui

Item {
    id: root

    readonly property int columns: Math.max(1, Math.floor(width / A.Appearance.emojiCellSize))
    required property var controller
    readonly property int menuHeight: A.Appearance.emojiHeight - A.Appearance.popupBorderWidth * 2
    readonly property int menuWidth: A.Appearance.popupWidthPicker
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

    Service {
        id: emoji

        query: root.query
    }

    Ui.KeyCatcher {
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
            spacing: A.Appearance.space15

            Item {
                height: A.Appearance.menuHeaderHeight
                width: parent.width

                Ui.FilterInput {
                    id: filterInput

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeHeading
                    keyHandler: keys

                    onTextChanged: if (text !== root.query)
                        root.setQuery(text)
                }

                Text {
                    anchors.fill: filterInput
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeHeading
                    opacity: 0.58
                    text: qsTr("Search emojis…")
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignVCenter
                    visible: !root.query && !filterInput.preeditText
                }
            }

            Item {
                height: parent.height - A.Appearance.menuHeaderHeight - A.Appearance.space15
                width: parent.width

                GridView {
                    id: resultGrid

                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    cellHeight: A.Appearance.emojiCellSize
                    cellWidth: A.Appearance.emojiCellSize
                    clip: true
                    model: emoji.entries

                    delegate: Rectangle {
                        id: cell

                        required property int index
                        required property var modelData

                        color: index === root.selectedIndex ? A.Appearance.cursorFill : "transparent"
                        height: resultGrid.cellHeight
                        radius: A.Appearance.radius
                        width: resultGrid.cellWidth

                        Text {
                            anchors.centerIn: parent
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeDisplaySmall
                            horizontalAlignment: Text.AlignHCenter
                            text: cell.modelData ? cell.modelData.e : ""
                            textFormat: Text.PlainText
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                root.selectedIndex = cell.index;
                                root.activate();
                            }
                            onContainsMouseChanged: if (containsMouse)
                                root.selectedIndex = cell.index
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: A.Appearance.space2
                    visible: emoji.entries.length === 0

                    Text {
                        color: A.Appearance.primary
                        font.family: A.Appearance.iconFontFamily
                        font.pixelSize: A.Appearance.batteryGlyphSize
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 0.8
                        text: "󰈉"
                        width: parent.width
                    }

                    Text {
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
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
