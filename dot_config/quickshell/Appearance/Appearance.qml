pragma Singleton

import QtQuick

QtObject {
    readonly property int batteryGlyphSize: 28
    readonly property color border: Qt.alpha(foreground, 0.12)
    readonly property int borderWidth: 1
    readonly property int buttonHeight: 28
    readonly property color currentFill: Qt.alpha(foreground, 0.18)
    readonly property color cursorBorder: Qt.alpha(foreground, 0.25)
    readonly property color cursorFill: Qt.alpha(foreground, 0.08)
    readonly property color destructive: "#f38ba8"
    readonly property int dialogPadding: 14
    readonly property int durationControl: 120
    readonly property int durationCursor: 60
    readonly property int durationFast: 140
    readonly property int easingOut: Easing.OutCubic
    readonly property int emojiCellSize: 44
    readonly property int emojiHeight: 500

    readonly property string fontFamily: "JetBrains Mono"
    readonly property int fontSizeBody: 12
    readonly property int fontSizeBodySmall: 11
    readonly property int fontSizeCaption: 10
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
    readonly property color link: primary
    readonly property int menuHeaderHeight: 34
    readonly property int menuPadding: 18
    readonly property int menuRowGap: 3
    readonly property int menuRowHeight: 50
    readonly property int menuRowHeightDetail: 58
    readonly property int menuScreenMargin: 5
    readonly property color muted: "#313244"
    readonly property color mutedForeground: Qt.darker(foreground, 1.4)
    readonly property color normalBorder: Qt.alpha(foreground, 0.4)
    readonly property color normalFill: Qt.alpha(foreground, 0.04)
    readonly property int notificationImageSize: 40
    readonly property int osdBarWidth: 142
    readonly property int osdBottomMargin: 67
    readonly property int osdProgressHeight: 6
    readonly property int osdTimeout: 1200
    readonly property color popover: "#1e1e2e"
    readonly property int popupBorderWidth: 2
    readonly property int popupMaxHeight: 560
    readonly property int popupWidthCalendar: 560
    readonly property int popupWidthCompact: 300
    readonly property int popupWidthPicker: 400
    readonly property int popupWidthStandard: 380
    readonly property int popupWidthWorkspace: 880
    readonly property color primary: "#fab387"
    readonly property color primaryForeground: popover
    readonly property int progressHeight: 4
    readonly property int radius: 0
    readonly property int rowHeight: 28
    readonly property int rowHeightLarge: 56
    readonly property int sliderHeight: 22
    readonly property int sliderKnobSize: 14
    readonly property int sliderWidth: 200
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

    function batteryStatusColor(percent: real, available: bool, discharging: bool): color {
        if (!available)
            return mutedForeground;
        if (discharging && percent <= 15)
            return destructive;
        if (discharging && percent <= 30)
            return "#f9e2af";
        return success;
    }
}
