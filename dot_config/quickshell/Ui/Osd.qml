import QtQuick
import "../Appearance" as A

Rectangle {
    id: root

    property string icon: ""
    readonly property int padding: A.Appearance.space4 + border.width
    property real value: 0
    property string valueText: ""

    border.color: A.Appearance.primary
    border.width: A.Appearance.popupBorderWidth
    color: Qt.rgba(A.Appearance.popover.r, A.Appearance.popover.g, A.Appearance.popover.b, 0.97)
    height: implicitHeight
    implicitHeight: padding * 2 + A.Appearance.batteryGlyphSize
    implicitWidth: padding * 2 + iconColumn.width + A.Appearance.space4 * 2 + A.Appearance.osdBarWidth + valueMetrics.advanceWidth
    radius: A.Appearance.radius
    width: implicitWidth

    TextMetrics {
        id: valueMetrics

        font.bold: true
        font.family: A.Appearance.fontFamily
        font.pixelSize: A.Appearance.fontSizeOsd
        text: "100%"
    }

    TextMetrics {
        id: iconMetrics

        font.family: A.Appearance.iconFontFamily
        font.pixelSize: A.Appearance.batteryGlyphSize
        text: root.icon
    }

    TextMetrics {
        id: widestIconMetrics

        font: iconMetrics.font
        text: ""
    }

    Row {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: A.Appearance.space4

        Item {
            id: iconColumn

            height: parent.height
            width: Math.ceil(Math.max(iconMetrics.tightBoundingRect.width, widestIconMetrics.tightBoundingRect.width))

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: A.Appearance.foreground
                font: iconMetrics.font
                text: root.icon
                x: Math.round((iconColumn.width - iconMetrics.tightBoundingRect.width) / 2 - iconMetrics.tightBoundingRect.x)
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(A.Appearance.foreground.r, A.Appearance.foreground.g, A.Appearance.foreground.b, 0.45)
            height: A.Appearance.osdProgressHeight
            width: A.Appearance.osdBarWidth

            Rectangle {
                color: A.Appearance.primary
                height: parent.height
                width: parent.width * Math.max(0, Math.min(1, root.value))

                Behavior on width {
                    NumberAnimation {
                        duration: A.Appearance.durationFast
                        easing.type: A.Appearance.easingOut
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: A.Appearance.foreground
            font: valueMetrics.font
            horizontalAlignment: Text.AlignRight
            text: root.valueText
            width: valueMetrics.advanceWidth
        }
    }
}
