import QtQuick
import ".."
import "../ui" as Ui

Item {
    id: root

    property alias input: search
    default property alias content: viewport.data
    readonly property int visibleRows: Math.max(1, Math.floor((viewport.height + Theme.menuRowGap) / (Theme.menuRowHeight + Theme.menuRowGap)))
    readonly property real rowSpacing: visibleRows > 1 ? Math.max(Theme.menuRowGap, (viewport.height - visibleRows * Theme.menuRowHeight) / (visibleRows - 1)) : Theme.menuRowGap
    readonly property real cellHeight: viewport.height / visibleRows

    Ui.SearchField {
        id: search
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.menuHeaderHeight
        font.pixelSize: Theme.fontSizeHeading
    }

    Ui.Separator {
        anchors.top: search.bottom
        anchors.topMargin: Theme.space2
        width: parent.width
    }

    Item {
        id: viewport
        anchors.left: parent.left
        anchors.right: parent.right
        y: Theme.menuHeaderHeight + Theme.borderWidth + Theme.space2 * 2
        height: Math.max(0, root.height - y)
    }
}
