pragma ComponentBehavior: Bound

import QtQuick
import "../Apps" as Apps
import "../Files" as Files
import "../Files/utils.js" as FileUtils
import Quickshell
import "../../Appearance" as A
import "../../Ui" as Ui
import "utils.js" as Utils

Item {
    id: root

    readonly property real availableRowsHeight: Math.max(0, Math.min(popup.screenH * 0.7, popup.screenH - (cardTop >= 0 ? cardTop : A.Appearance.menuScreenMargin) - A.Appearance.menuScreenMargin - A.Appearance.menuPadding * 2 - A.Appearance.menuHeaderHeight - A.Appearance.space15, maxRowsHeight >= 0 ? maxRowsHeight : Infinity))
    property int cardTop: -1
    property string category: "root"
    required property var controller
    property var history: []
    property real maxRowsHeight: -1
    readonly property int menuHeight: A.Appearance.menuPadding * 2 + A.Appearance.menuHeaderHeight + A.Appearance.space15 + rowsHeight
    readonly property int menuWidth: A.Appearance.popupWidthCompact
    property string mode: "go"
    required property var popup
    property string query: ""
    readonly property var results: {
        if (mode === "open" || mode === "go" && category === "files")
            return files.entries.map(function (path) {
                return {
                    kind: "file",
                    label: FileUtils.name(path),
                    path: path
                };
            });
        if (mode === "apps")
            return apps.entries.map(function (entry) {
                return {
                    kind: "app",
                    label: entry.name,
                    entry: entry,
                    path: qsTr("Apps")
                };
            });
        return Utils.search(query, category, apps.matches);
    }
    readonly property int rowPeek: Math.round(A.Appearance.menuRowHeight * 0.55)
    readonly property var rowTotals: {
        var totals = [], total = 0;
        for (var i = 0; i < results.length; i++) {
            if (i)
                total += A.Appearance.menuRowGap;
            total += rowHeight(results[i]);
            totals.push(total);
        }
        return totals;
    }
    readonly property int rowsHeight: Utils.foldedListHeight(rowTotals, availableRowsHeight, A.Appearance.menuRowGap, rowPeek, A.Appearance.menuRowHeight)
    property int selectedIndex: 0

    function activate(fromPointer: bool): void {
        var row = results[selectedIndex];
        if (!row)
            return;
        if (row.kind === "app") {
            apps.launch(row.entry);
            controller.close();
        } else if (row.kind === "file") {
            files.open(row.path);
            controller.close();
        } else if (row.id === "emoji") {
            controller.current = "emoji";
        } else if (Utils.isSubmenu(row.id)) {
            history = history.concat([category]);
            enter(row.id, fromPointer);
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
        enter(previous, false);
    }

    function enter(id: string, fromPointer: bool): void {
        freezeCardTop();
        category = id;
        query = "";
        selectedIndex = 0;
        if (fromPointer)
            pointerGate.allowInitialSample();
        else
            pointerGate.reset();
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
        if (cardTop >= 0)
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
        pointerGate.reset();
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
        var reach = rowPeek + A.Appearance.menuRowGap;
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
        return query && row && row.path ? A.Appearance.menuRowHeightDetail : A.Appearance.menuRowHeight;
    }

    function select(delta: int): void {
        if (!results.length)
            return;
        pointerGate.reset();
        selectedIndex = ((selectedIndex + delta) % results.length + results.length) % results.length;
        revealCursor();
    }

    function selectFromPointer(index: int, item: Item, mouse): void {
        if (pointerGate.moved(item, mouse))
            selectedIndex = index;
    }

    function setQuery(text: string): void {
        freezeCardTop();
        query = text;
        selectedIndex = 0;
        pointerGate.reset();
        resultList.positionViewAtBeginning();
    }

    Component.onCompleted: console.assert(Utils.selfCheck(), "menu search self-check failed")
    onQueryChanged: if (filterInput.text !== query)
        filterInput.text = query
    onResultsChanged: Qt.callLater(function () {
        selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 1));
        revealCursor();
    })

    Apps.Service {
        id: apps

        query: root.mode === "apps" || root.category === "apps" || root.mode === "go" && root.category === "root" ? root.query : ""
    }

    Files.Service {
        id: files

        query: root.query
    }

    Ui.PointerMoveGate {
        id: pointerGate

        referenceItem: root
    }

    Ui.KeyCatcher {
        id: keys

        anchors.fill: parent
        qCloses: false
        spaceActivates: false
        textInputBackspace: !!root.query || !!filterInput.preeditText
        textInputEdits: true
        vimNavigation: false

        onActivateRequested: root.activate(false)
        onBackspaceRequested: root.back()
        onClearTextRequested: root.setQuery("")
        onCloseRequested: root.query ? root.setQuery("") : root.controller.close()
        onMoveRequested: function (dx, dy) {
            if (dy)
                root.select(dy);
            else if (dx > 0)
                root.activate(false);
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
                    renderType: Text.NativeRendering

                    onTextChanged: if (text !== root.query)
                        root.setQuery(text)
                }

                Text {
                    anchors.fill: filterInput
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeHeading
                    opacity: 0.58
                    renderType: Text.NativeRendering
                    text: (root.mode === "apps" ? qsTr("Launch") : root.mode === "open" ? qsTr("Open") : Utils.title(root.category)) + "…"
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
                    model: root.results
                    spacing: A.Appearance.menuRowGap

                    delegate: Rectangle {
                        id: resultRow

                        readonly property bool hasCursor: root.selectedIndex === index
                        required property int index
                        readonly property bool isApp: !!modelData && modelData.kind === "app"
                        required property var modelData
                        readonly property bool submenu: !!modelData && Utils.isSubmenu(modelData.id)

                        color: hasCursor ? A.Appearance.cursorFill : "transparent"
                        height: root.rowHeight(modelData)
                        radius: A.Appearance.radius
                        width: resultList.width

                        Item {
                            id: iconSlot

                            anchors.left: parent.left
                            anchors.leftMargin: A.Appearance.space2
                            height: A.Appearance.launcherIconSize * 2
                            width: A.Appearance.launcherIconSize * 2
                            y: contentColumn.y + labelText.y + (labelText.height - height) / 2

                            Text {
                                anchors.centerIn: parent
                                color: resultRow.hasCursor ? A.Appearance.primary : A.Appearance.foreground
                                font.family: A.Appearance.iconFontFamily
                                font.pixelSize: A.Appearance.launcherIconSize
                                text: !resultRow.modelData ? "" : resultRow.modelData.kind === "file" ? FileUtils.icon(resultRow.modelData.path) : resultRow.modelData.icon || ""
                                textFormat: Text.PlainText
                                visible: !resultRow.isApp
                            }

                            Ui.Icon {
                                id: appIcon

                                anchors.centerIn: parent
                                height: A.Appearance.launcherIconSize
                                sources: resultRow.isApp ? [resultRow.modelData.entry.icon] : []
                                fallback: "application-x-executable"
                                visible: resultRow.isApp
                                width: height
                            }
                        }

                        Column {
                            id: contentColumn

                            anchors.left: iconSlot.right
                            anchors.leftMargin: A.Appearance.space15
                            anchors.right: trail.left
                            anchors.rightMargin: A.Appearance.space15
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: A.Appearance.menuRowGap

                            Text {
                                id: labelText

                                color: resultRow.hasCursor ? A.Appearance.primary : A.Appearance.foreground
                                elide: Text.ElideRight
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeHeading
                                font.weight: A.Appearance.fontWeightMedium
                                text: resultRow.modelData ? String(resultRow.modelData.label || "") : ""
                                textFormat: Text.PlainText
                                width: parent.width
                            }

                            Text {
                                color: A.Appearance.foreground
                                elide: Text.ElideRight
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.fontSizeBodySmall
                                opacity: 0.52
                                text: resultRow.modelData ? String(resultRow.modelData.path || "") : ""
                                textFormat: Text.PlainText
                                visible: !!root.query && !!text
                                width: parent.width
                            }
                        }

                        Text {
                            id: trail

                            anchors.right: parent.right
                            anchors.rightMargin: A.Appearance.space2
                            color: resultRow.hasCursor ? A.Appearance.primary : A.Appearance.foreground
                            font.family: A.Appearance.fontFamily
                            font.pixelSize: A.Appearance.fontSizeHeading
                            opacity: 0.36
                            text: resultRow.submenu ? "›" : ""
                            width: A.Appearance.iconSize
                            y: contentColumn.y + labelText.y + (labelText.height - height) / 2
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                root.selectedIndex = resultRow.index;
                                root.activate(true);
                            }
                            onEntered: root.selectFromPointer(resultRow.index, resultRow, {
                                x: mouseX,
                                y: mouseY
                            })
                            onPositionChanged: function (mouse) {
                                root.selectFromPointer(resultRow.index, resultRow, mouse);
                            }
                        }
                    }

                    WheelHandler {
                        target: null

                        onWheel: function (event) {
                            var delta = event.pixelDelta.y || event.angleDelta.y / 120 * A.Appearance.menuRowHeight * 3;
                            var bottom = resultList.originY + Math.max(0, resultList.contentHeight - resultList.height);
                            resultList.contentY = Math.max(resultList.originY, Math.min(bottom, resultList.contentY - delta));
                            event.accepted = true;
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Math.min(A.Appearance.rowHeight, parent.height / 2)
                    opacity: resultList.contentHeight > resultList.height ? Math.max(0, Math.min(1, (resultList.contentY - resultList.originY) / height)) : 0
                    visible: opacity > 0

                    gradient: Gradient {
                        GradientStop {
                            color: A.Appearance.popover
                            position: 0
                        }

                        GradientStop {
                            color: Qt.alpha(A.Appearance.popover, 0)
                            position: 1
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.min(A.Appearance.rowHeight, parent.height / 2)
                    opacity: resultList.contentHeight > resultList.height ? Math.max(0, Math.min(1, (resultList.originY + resultList.contentHeight - resultList.height - resultList.contentY) / height)) : 0
                    visible: opacity > 0

                    gradient: Gradient {
                        GradientStop {
                            color: Qt.alpha(A.Appearance.popover, 0)
                            position: 0
                        }

                        GradientStop {
                            color: A.Appearance.popover
                            position: 1
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: A.Appearance.space2
                    visible: root.results.length === 0
                    width: parent.width

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
