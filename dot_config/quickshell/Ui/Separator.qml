import QtQuick
import "../Appearance" as A

Rectangle {
    color: A.Appearance.border
    height: A.Appearance.borderWidth
    implicitHeight: A.Appearance.borderWidth
    implicitWidth: 100
    width: parent ? parent.width : implicitWidth
}
