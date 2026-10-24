pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import "files.js" as FileUtils
import Quickshell
import "../.."
import "../../ui" as Ui
import "search.js" as Utils

Ui.Panel {
    id: root

    readonly property bool appMenu: mode === "apps" || category === "apps"
    readonly property bool fileMenu: mode === "open" || category === "files"
    readonly property real availableRowsHeight: Math.max(0, Math.min(popup.screenH * 0.7, popup.screenH - (cardTop >= 0 ? cardTop : Theme.menuScreenMargin) - Theme.menuScreenMargin - Theme.menuPadding * 2 - Theme.menuHeaderHeight - Theme.space15, maxRowsHeight >= 0 ? maxRowsHeight : Infinity))
    property int cardTop: -1
    property string category: "root"
    required property var controller
    property var history: []
    required property var items
    property real maxRowsHeight: -1
    readonly property int menuHeight: Theme.menuPadding * 2 + Theme.menuHeaderHeight + Theme.space15 + rowsHeight
    readonly property bool menuStyle: true
    readonly property int menuWidth: fileMenu ? Theme.popupWidthPicker : Theme.popupWidthCompact
    property string mode: "go"
    required property var popup
    property string query: ""
    readonly property var results: {
        if (fileMenu)
            return files.entries;
        if (mode === "apps")
            return apps.entries.map(function (entry) {
                return {
                    kind: "app",
                    label: entry.name,
                    entry: entry,
                    path: qsTr("Apps")
                };
            });
        return Utils.search(query, category, apps.matches, items);
    }
    readonly property int rowPeek: Math.round(Theme.menuRowHeight * 0.55)
    readonly property var rowTotals: {
        var totals = [], total = 0;
        var count = appMenu || fileMenu ? Math.min(10, results.length) : results.length;
        for (var i = 0; i < count; i++) {
            if (i)
                total += Theme.menuRowGap;
            total += rowHeight(results[i]);
            totals.push(total);
        }
        return totals;
    }
    readonly property int rowsHeight: Utils.foldedListHeight(rowTotals, availableRowsHeight, Theme.menuRowGap, rowPeek, Theme.menuRowHeight)
    property int selectedIndex: 0

    function activate(): void {
        var row = results[selectedIndex];
        if (!row)
            return;
        if (row.kind === "app") {
            apps.launch(row.entry);
            controller.close();
        } else if (row.kind === "file") {
            files.open(row.path);
            controller.close();
        } else if (Utils.isSubmenu(row.id, items)) {
            history = history.concat([category]);
            enter(row.id);
        } else {
            controller.activate(row.id);
        }
    }

    function back(): void {
        if (query)
            return;
        if (mode !== "go" || category === "root")
            return;
        var previous = history.length ? history[history.length - 1] : "root";
        history = history.slice(0, -1);
        enter(previous);
    }

    function enter(id: string): void {
        freezeCardTop();
        category = id;
        if (appMenu || fileMenu) {
            cardTop = -1;
            maxRowsHeight = -1;
        }
        query = "";
        selectedIndex = 0;

        if (id === "files")
            files.refresh();
        resultList.positionViewAtBeginning();
    }

    function focusMenu(): void {
        Qt.callLater(function () {
            filterInput.forceActiveFocus();
        });
    }

    function freezeCardTop(): void {
        if (appMenu || fileMenu || cardTop >= 0)
            return;
        cardTop = popup.cardTop;
        maxRowsHeight = rowsHeight;
    }

    function open(nextMode: string): void {
        mode = nextMode;
        category = "root";
        query = "";
        selectedIndex = 0;
        cardTop = -1;
        maxRowsHeight = -1;
        history = [];

        if (nextMode === "open")
            files.refresh();
        focusMenu();
    }

    function revealCursor(): void {
        if (!results.length)
            return;
        resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
        var item = resultList.itemAtIndex(selectedIndex);
        if (!item)
            return;
        var reach = rowPeek + Theme.menuRowGap;
        if (selectedIndex < results.length - 1) {
            var maxY = Math.max(resultList.originY, resultList.originY + resultList.contentHeight - resultList.height);
            var overhang = item.y + item.height + reach - (resultList.contentY + resultList.height);
            if (overhang > 0)
                resultList.contentY = Math.min(resultList.contentY + overhang, maxY);
        }
        if (selectedIndex > 0) {
            var underhang = resultList.contentY - (item.y - reach);
            if (underhang > 0)
                resultList.contentY = Math.max(resultList.contentY - underhang, resultList.originY);
        }
    }

    function rowHeight(row): int {
        return !fileMenu && query && row && row.path ? Theme.menuRowHeightDetail : Theme.menuRowHeight;
    }

    function select(delta: int): void {
        if (!results.length)
            return;

        selectedIndex = ((selectedIndex + delta) % results.length + results.length) % results.length;
        revealCursor();
    }

    function setQuery(text: string): void {
        freezeCardTop();
        query = text;
        selectedIndex = 0;

        resultList.positionViewAtBeginning();
    }

    Component.onCompleted: console.assert(Utils.selfCheck(), "menu search self-check failed")
    onQueryChanged: if (filterInput.text !== query)
        filterInput.text = query
    onResultsChanged: Qt.callLater(function () {
        selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 1));
        revealCursor();
    })

    Apps {
        id: apps

        query: root.mode === "apps" || root.category === "apps" || root.mode === "go" && root.category === "root" ? root.query : ""
    }

    Files {
        id: files

        query: root.query
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
        onBackspaceRequested: root.back()
        onClearTextRequested: root.setQuery("")
        onCloseRequested: root.query ? root.setQuery("") : root.controller.close()
        onMoveRequested: function (dx, dy) {
            if (dy)
                root.select(dy);
            else if (dx > 0)
                root.activate();
            else
                root.back();
        }
        onPageRequested: function (direction) {
            root.select(direction * 6);
        }
        onTabRequested: function (direction) {
            root.select(direction);
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
                    renderType: Text.NativeRendering

                    onTextChanged: if (text !== root.query)
                        root.setQuery(text)
                }

                Controls.Label {
                    anchors.fill: filterInput
                    font.pixelSize: Theme.fontSizeHeading
                    opacity: 0.58
                    renderType: Text.NativeRendering
                    text: (root.mode === "apps" ? qsTr("Launch") : root.mode === "open" ? qsTr("Open") : Utils.title(root.category, root.items)) + "…"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignVCenter
                    visible: !root.query && !filterInput.preeditText
                }
            }

            Item {
                height: root.rowsHeight
                width: parent.width

                ListView {
                    id: resultList

                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    interactive: false
                    model: root.results
                    spacing: Theme.menuRowGap

                    delegate: Rectangle {
                        id: resultRow

                        readonly property bool hasCursor: root.selectedIndex === index
                        required property int index
                        readonly property bool isApp: !!modelData && modelData.kind === "app"
                        required property var modelData
                        readonly property bool submenu: !!modelData && Utils.isSubmenu(modelData.id, root.items)

                        color: hasCursor ? Theme.cursorFill : "transparent"
                        height: root.rowHeight(modelData)
                        radius: Theme.radius
                        width: resultList.width

                        Item {
                            id: iconSlot

                            anchors.left: parent.left
                            anchors.leftMargin: Theme.space2
                            height: Theme.launcherIconSize * 2
                            width: Theme.launcherIconSize * 2
                            y: contentColumn.y + labelText.y + (labelText.height - height) / 2

                            Controls.Label {
                                anchors.centerIn: parent
                                color: resultRow.hasCursor ? Theme.primary : Theme.foreground
                                font.family: Theme.iconFontFamily
                                font.pixelSize: Theme.launcherIconSize
                                text: !resultRow.modelData ? "" : resultRow.modelData.kind === "file" ? FileUtils.icon(resultRow.modelData.path) : resultRow.modelData.icon || ""
                                textFormat: Text.PlainText
                                visible: !resultRow.isApp
                            }

                            Ui.Icon {
                                id: appIcon

                                anchors.centerIn: parent
                                fallback: "application-x-executable"
                                height: Theme.launcherIconSize * 1.25
                                sources: resultRow.isApp ? [resultRow.modelData.entry.icon] : []
                                visible: resultRow.isApp
                                width: height
                            }
                        }

                        Column {
                            id: contentColumn

                            anchors.left: iconSlot.right
                            anchors.leftMargin: Theme.space15
                            anchors.right: trail.left
                            anchors.rightMargin: Theme.space15
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.menuRowGap

                            Controls.Label {
                                id: labelText

                                color: resultRow.hasCursor ? Theme.primary : Theme.foreground
                                elide: Text.ElideRight
                                font.pixelSize: Theme.fontSizeHeading
                                font.weight: Theme.fontWeightMedium
                                text: resultRow.modelData ? String(resultRow.modelData.label || "") : ""
                                textFormat: Text.PlainText
                                width: parent.width
                            }

                            Controls.Label {
                                elide: Text.ElideRight
                                font.pixelSize: Theme.fontSizeBodySmall
                                opacity: 0.52
                                text: resultRow.modelData ? String(resultRow.modelData.path || "") : ""
                                textFormat: Text.PlainText
                                visible: !root.fileMenu && !!root.query && !!text
                                width: parent.width
                            }
                        }

                        Controls.Label {
                            id: trail

                            anchors.right: parent.right
                            anchors.rightMargin: Theme.space2
                            color: resultRow.hasCursor ? Theme.primary : Theme.foreground
                            font.pixelSize: Theme.fontSizeHeading
                            opacity: 0.36
                            text: resultRow.submenu ? "›" : ""
                            width: Theme.iconSize
                            y: contentColumn.y + labelText.y + (labelText.height - height) / 2
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Math.min(Theme.rowHeight, parent.height / 2)
                    opacity: resultList.contentHeight > resultList.height ? Math.max(0, Math.min(1, (resultList.contentY - resultList.originY) / height)) : 0
                    visible: opacity > 0

                    gradient: Gradient {
                        GradientStop {
                            color: Theme.popover
                            position: 0
                        }

                        GradientStop {
                            color: Qt.alpha(Theme.popover, 0)
                            position: 1
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.min(Theme.rowHeight, parent.height / 2)
                    opacity: resultList.contentHeight > resultList.height ? Math.max(0, Math.min(1, (resultList.originY + resultList.contentHeight - resultList.height - resultList.contentY) / height)) : 0
                    visible: opacity > 0

                    gradient: Gradient {
                        GradientStop {
                            color: Qt.alpha(Theme.popover, 0)
                            position: 0
                        }

                        GradientStop {
                            color: Theme.popover
                            position: 1
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.space2
                    visible: root.results.length === 0
                    width: parent.width

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
                        text: root.query ? qsTr("No matches for “%1”").arg(root.query) : qsTr("Nothing here yet")
                        textFormat: Text.PlainText
                        width: parent.width
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
