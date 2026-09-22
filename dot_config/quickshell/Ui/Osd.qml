import QtQuick
import "../Appearance" as A

// Generic Lyra OSD card. Embed in a window; drive `value` from it.
Rectangle {
    id: root

    property string title: ""
    property string valueText: ""
    property real value: 0

    width: A.Appearance.osdWidth
    implicitWidth: width

    implicitHeight:
        A.Appearance.osdPadding * 2
        + Math.max(title.implicitHeight, value.implicitHeight)
        + A.Appearance.osdGap
        + A.Appearance.osdProgressHeight

    color: A.Appearance.popover

    border.width: A.Appearance.borderWidth
    border.color: A.Appearance.subtleRing

    radius: A.Appearance.radius

    Item {
        anchors.fill: parent
        anchors.margins: A.Appearance.osdPadding

        Column {
            anchors.fill: parent
            spacing: A.Appearance.osdGap

            Row {
                width: parent.width
                height: Math.max(title.implicitHeight, value.implicitHeight)

                Text {
                    id: title
                    text: root.title
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeOsd
                    font.weight: A.Appearance.fontWeightMedium
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                }

                Item { width: parent.width - title.width - value.width; height: 1 }

                Text {
                    id: value
                    text: root.valueText
                    color: A.Appearance.foreground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeOsd
                    font.weight: A.Appearance.fontWeightMedium
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                }
            }

            Rectangle {
                width: parent.width
                height: A.Appearance.osdProgressHeight
                color: A.Appearance.muted
                radius: A.Appearance.radius

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.value))
                    height: parent.height
                    color: A.Appearance.primary
                    radius: A.Appearance.radius
                }
            }
        }
    }
}
