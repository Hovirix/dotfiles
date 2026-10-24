import QtQuick
import ".."

CursorSurface {
    id: root

    default property alias content: inner.data
    property int contentPadding: Theme.space2

    Item {
        id: inner

        anchors.fill: parent
        anchors.leftMargin: root.contentPadding
        anchors.rightMargin: root.contentPadding
    }
}
