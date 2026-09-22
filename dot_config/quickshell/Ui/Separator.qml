import QtQuick
import "../Appearance" as A

Rectangle {
    width: parent ? parent.width : implicitWidth
    implicitWidth: 100
    implicitHeight: A.Appearance.separatorSize
    height: A.Appearance.separatorSize

    color: A.Appearance.border
}
