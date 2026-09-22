import QtQuick
import "../Appearance" as A

Item {
    id: root

    property string title: ""
    property string value: ""
    property color valueColor: A.Appearance.foreground

    height: A.Appearance.headerHeight

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        text: root.title

        color: A.Appearance.foreground

        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeTitle
        font.weight: A.Appearance.fontWeightMedium

        renderType: Text.NativeRendering
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: root.value

        color: root.valueColor

        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeTitle
        font.weight: A.Appearance.fontWeightMedium

        renderType: Text.NativeRendering
    }
}
