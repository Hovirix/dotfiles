import QtQuick
import Quickshell
import ".."

// The only OSD window: bottom-center, auto-dismissing, non-focusable.
// The shell supplies presentation properties; this window only owns dismissal.
PanelWindow {
    id: window

    property string icon: ""
    property bool shown: false
    property real value: 0
    property string valueText: ""

    function show(): void {
        shown = true;
        dismiss.restart();
    }

    aboveWindows: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: card.implicitHeight
    implicitWidth: card.implicitWidth
    screen: Quickshell.screens[0]
    visible: shown

    mask: Region {
    }

    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: Theme.osdBottomMargin
        left: (screen.width - width) / 2
    }

    Timer {
        id: dismiss

        interval: Theme.osdTimeout

        onTriggered: window.shown = false
    }

    Rectangle {
        id: card

        readonly property string icon: window.icon
        readonly property int padding: Theme.space4 + border.width
        readonly property real value: window.value
        readonly property string valueText: window.valueText

        border.color: Theme.primary
        border.width: Theme.popupBorderWidth
        color: Qt.rgba(Theme.popover.r, Theme.popover.g, Theme.popover.b, 0.97)
        height: implicitHeight
        implicitHeight: padding * 2 + Theme.batteryGlyphSize
        implicitWidth: padding * 2 + iconColumn.width + Theme.space4 * 2 + Theme.osdBarWidth + valueMetrics.advanceWidth
        radius: Theme.radius
        width: implicitWidth

        TextMetrics {
            id: valueMetrics

            font.bold: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeOsd
            text: "100%"
        }

        TextMetrics {
            id: iconMetrics

            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.batteryGlyphSize
            text: card.icon
        }

        TextMetrics {
            id: widestIconMetrics

            font: iconMetrics.font
            text: ""
        }

        Row {
            anchors.fill: parent
            anchors.margins: card.padding
            spacing: Theme.space4

            Item {
                id: iconColumn

                height: parent.height
                width: Math.ceil(Math.max(iconMetrics.tightBoundingRect.width, widestIconMetrics.tightBoundingRect.width))

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.foreground
                    font: iconMetrics.font
                    text: card.icon
                    x: Math.round((iconColumn.width - iconMetrics.tightBoundingRect.width) / 2 - iconMetrics.tightBoundingRect.x)
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.45)
                height: Theme.osdProgressHeight
                width: Theme.osdBarWidth

                Rectangle {
                    color: Theme.primary
                    height: parent.height
                    width: parent.width * Math.max(0, Math.min(1, card.value))

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.durationFast
                            easing.type: Theme.easingOut
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.foreground
                font: valueMetrics.font
                horizontalAlignment: Text.AlignRight
                text: card.valueText
                width: valueMetrics.advanceWidth
            }
        }
    }
}
