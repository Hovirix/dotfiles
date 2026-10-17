import QtQuick
import "../Appearance" as A

Rectangle {
    width: parent ? parent.width : implicitWidth
    implicitWidth: 100
    implicitHeight: A.Appearance.borderWidth
    height: A.Appearance.borderWidth

    color: A.Appearance.border
}
