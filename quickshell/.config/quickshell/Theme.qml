pragma Singleton

import QtQuick

QtObject {
    readonly property int batteryGlyphSize: 28
    readonly property color border: Qt.alpha(foreground, 0.12)
    readonly property int borderWidth: 1
    readonly property int buttonHeight: 28
    readonly property color cursorBorder: primary
    readonly property color cursorFill: Qt.alpha(primary, 0.12)
    readonly property color destructive: "#f38ba8"
    readonly property int dialogPadding: 14
    readonly property int durationCursor: 60
    readonly property int durationFast: 140
    readonly property int easingOut: Easing.OutCubic
    readonly property int emojiCellSize: 44
    readonly property string fontFamily: "JetBrains Mono"
    readonly property int fontSizeBody: 14
    readonly property int fontSizeBodySmall: 12
    readonly property int fontSizeCaption: 11
    readonly property int fontSizeDisplaySmall: 24
    readonly property int fontSizeHeading: 16
    readonly property int fontSizeHero: 64
    readonly property int fontSizeOsd: 14
    readonly property int fontSizeTitle: 14
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightNormal: Font.Normal
    readonly property int fontWeightStrong: Font.DemiBold
    readonly property color foreground: "#cdd6f4"
    readonly property int heroGlyphSize: 24
    readonly property int iconColumnWidth: 20
    readonly property string iconFontFamily: "Symbols Nerd Font Mono"
    readonly property int iconLabelGap: 8
    readonly property int iconSize: 14
    readonly property int launcherIconSize: 18
    readonly property int menuHeaderHeight: 36
    readonly property int menuPadding: 20
    readonly property int menuRowGap: 4
    readonly property int menuRowHeight: 40
    readonly property int menuRowHeightDetail: 58
    readonly property color muted: "#313244"
    readonly property color mutedForeground: Qt.darker(foreground, 1.4)
    readonly property color normalBorder: Qt.alpha(foreground, 0.22)
    readonly property color normalFill: Qt.alpha(foreground, 0.04)
    readonly property int notificationImageSize: 40
    readonly property int osdBarWidth: 142
    readonly property int osdBottomMargin: 67
    readonly property int osdProgressHeight: 6
    readonly property int osdTimeout: 1200
    readonly property color popover: "#1e1e2e"
    readonly property int popupBorderWidth: 1
    readonly property int popupWidth: 680
    readonly property int popupHeight: 460
    readonly property int popupMaxHeight: 560
    readonly property int popupWidthStandard: 380
    readonly property color primary: "#fab387"
    readonly property color primaryForeground: popover
    readonly property int radius: 0
    readonly property int rowHeight: 28
    readonly property int rowHeightLarge: 56
    readonly property int space05: 2
    readonly property int space1: 4
    readonly property int space15: 6
    readonly property int space2: 8
    readonly property int space25: 10
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property color subtleRing: Qt.darker(foreground, 1.4)
    readonly property color success: "#a6e3a1"
    readonly property int switchHeight: 22
}
