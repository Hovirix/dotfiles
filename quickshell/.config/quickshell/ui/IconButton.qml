import QtQuick
import ".."

Button {
    id: root

    required property url source
    required property string label

    implicitWidth: Theme.menuHeaderHeight
    flat: true
    Accessible.name: label
    contentItem: Item {
        Icon {
            objectName: "buttonIcon"
            anchors.centerIn: parent
            width: 20
            height: 20
            asynchronous: false
            sources: [root.source]
            Accessible.ignored: true
        }
    }
}
