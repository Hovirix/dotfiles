pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as Controls
import "../.."
import "../../ui" as Ui
import "../../core" as Core
import "search.js" as Utils

Ui.Panel {
    id: root

    property bool fileMenu: false
    title: fileMenu ? qsTr("Files") : ""
    required property var apps
    required property var files
    required property var actions
    required property var popup
    property string query: ""
    readonly property var results: fileMenu ? files.entries : Utils.search(query, apps.matches, actions)
    property int selectedIndex: 0
    readonly property alias filterInput: searchLayout.input

    function activate(): void {
        var row = results[selectedIndex];
        if (!row)
            return;
        if (row.kind === "app") {
            apps.launch(row.entry);
            popup.close();
        } else if (row.kind === "file") {
            files.open(row.path);
            popup.close();
        } else {
            row.action.run();
        }
    }

    function focusMenu(): void {
        Qt.callLater(() => filterInput.forceActiveFocus());
    }

    function revealCursor(): void {
        if (results.length)
            resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function select(delta: int): void {
        if (!results.length)
            return;
        selectedIndex = ((selectedIndex + delta) % results.length + results.length) % results.length;
        revealCursor();
    }

    function setQuery(text: string): void {
        query = text;
        selectedIndex = 0;
        resultList.positionViewAtBeginning();
    }

    onQueryChanged: if (filterInput.text !== query)
        filterInput.text = query
    onResultsChanged: Qt.callLater(() => {
        selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 1));
        revealCursor();
    })

    Binding {
        target: root.apps
        property: "query"
        value: root.fileMenu ? "" : root.query
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: root.files
        property: "query"
        value: root.fileMenu ? root.query : ""
        restoreMode: Binding.RestoreBindingOrValue
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
        onCloseRequested: root.query ? root.setQuery("") : root.popup.back()
        onMoveRequested: (dx, dy) => {
            if (dy)
                root.select(dy);
        }
        onPageRequested: direction => root.select(direction * searchLayout.visibleRows)
        onTabRequested: direction => root.select(direction)

        Core.SearchLayout {
            id: searchLayout
            anchors.fill: parent
            input.keyHandler: keys
            input.placeholderText: root.fileMenu ? qsTr("Search files…") : qsTr("Search apps and commands…")
            Connections {
                target: searchLayout.input
                function onTextChanged(): void {
                    if (searchLayout.input.text !== root.query)
                        root.setQuery(searchLayout.input.text);
                }
            }

            ListView {
                id: resultList
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                model: root.results
                spacing: searchLayout.rowSpacing
                snapMode: ListView.SnapToItem
                onHeightChanged: Qt.callLater(root.revealCursor)
                Controls.ScrollBar.vertical: Controls.ScrollBar {
                    policy: Controls.ScrollBar.AlwaysOff
                }

                delegate: Ui.CursorSurface {
                    id: row
                    required property int index
                    required property var modelData
                    readonly property bool isApp: modelData.kind === "app"
                    hasCursor: root.selectedIndex === index
                    width: resultList.width
                    height: Theme.menuRowHeight
                    Accessible.role: Accessible.ListItem
                    Accessible.name: modelData.label
                    Accessible.onPressAction: row.activate()
                    HoverHandler {
                        id: rowHover
                    }
                    Controls.ToolTip {
                        id: fileTooltip
                        visible: root.fileMenu && rowHover.hovered
                        text: root.fileMenu ? row.modelData.path : ""
                        delay: 500
                        enter: null
                        exit: null
                        contentItem: Controls.Label {
                            text: fileTooltip.text
                            textFormat: Text.PlainText
                            wrapMode: Text.WrapAnywhere
                        }
                        width: Math.min(implicitWidth, root.width)
                    }

                    function activate(): void {
                        root.selectedIndex = index;
                        root.activate();
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: row.activate()
                    }

                    Item {
                        id: iconSlot
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.space2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: width

                        Controls.Label {
                            anchors.centerIn: parent
                            visible: !row.isApp
                            text: row.modelData.icon || ""
                            textFormat: Text.PlainText
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.launcherIconSize
                        }
                        Ui.Icon {
                            anchors.fill: parent
                            fallback: "application-x-executable"
                            sources: row.isApp ? [row.modelData.entry.icon] : []
                            visible: row.isApp
                        }
                    }

                    Controls.Label {
                        anchors.left: iconSlot.right
                        anchors.leftMargin: Theme.space3
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.space3
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.label
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        font.pixelSize: Theme.fontSizeBody
                        font.weight: row.hasCursor ? Theme.fontWeightMedium : Theme.fontWeightNormal
                    }
                }

                Controls.Label {
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root.fileMenu ? qsTr("No files found") : qsTr("No results found")
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Theme.mutedForeground
                    visible: root.results.length === 0
                }
            }
        }
    }
}
