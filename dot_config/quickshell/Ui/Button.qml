import QtQuick
import "../Appearance" as A

// Compact labeled button for menu rows (e.g. power profile picker).
Item {
    id: root

    property string text: ""
    property string iconText: ""
    property real iconSize: A.Appearance.fontSizeTitle
    property real fontSize: A.Appearance.fontSizeBody
    property color foreground: A.Appearance.foreground
    property string fontFamily: A.Appearance.fontFamily
    property int horizontalPadding: A.Appearance.space25
    property int verticalPadding: A.Appearance.space15
    property bool bordered: false
    property bool active: false
    property bool hasCursor: false

    signal clicked()
    signal hovered(bool isHovered)

    readonly property bool hot: hasCursor || mouseArea.containsMouse

    implicitWidth: Math.max(label.implicitWidth, 48) + horizontalPadding * 2
    implicitHeight: label.implicitHeight + verticalPadding * 2

    Rectangle {
        anchors.fill: parent
        radius: A.Appearance.radius
        color: root.hot ? A.Appearance.accent : (root.active ? Qt.rgba(A.Appearance.primary.r, A.Appearance.primary.g, A.Appearance.primary.b, 0.12) : "transparent")
        border.width: root.bordered ? A.Appearance.borderWidth : 0
        border.color: A.Appearance.border

        Behavior on color {
            ColorAnimation {
                duration: A.Appearance.durationFast
            }
        }
    }

    Text {
        id: label

        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: (root.iconText !== "" ? root.iconText + " " : "") + root.text
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        font.weight: root.active ? A.Appearance.fontWeightMedium : A.Appearance.fontWeightNormal
        elide: Text.ElideRight
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.hovered(containsMouse)
        onClicked: root.clicked()
    }
}
