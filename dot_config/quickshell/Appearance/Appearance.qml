pragma Singleton

import QtQuick

// The only place where the design system exists.
//
// shadcn/ui Lyra component style, JetBrains Mono for text, Symbols Nerd Font
// Mono for icon glyphs, Catppuccin Mocha mapped onto shadcn semantic tokens.
//
// Panels never hardcode visual values; shared Ui primitives in this folder
// consume these tokens, and overlays compose the primitives.
QtObject {
    id: root

    // ================================================================
    // TYPOGRAPHY
    // ================================================================

    // Keep normal text metrics independent from private-use icon glyphs.
    readonly property string fontFamily: "JetBrains Mono"
    readonly property string iconFontFamily: "Symbols Nerd Font Mono"

    // Slightly above Lyra's default xs/sm scale for comfortable desktop
    // legibility while keeping menu density compact.
    readonly property int fontSizeBody: 13
    readonly property int fontSizeTitle: 15
    readonly property int fontSizeOsd: 18

    // Display sizes are purpose-driven exceptions to the Lyra xs/sm scale
    // (e.g. clock faces), never body text.
    readonly property int fontSizeDisplaySmall: 20
    readonly property int fontSizeHero: 64

    readonly property int fontWeightNormal: Font.Normal      // 400
    readonly property int fontWeightMedium: Font.Medium      // 500
    readonly property int fontWeightStrong: Font.DemiBold    // 600

    // ================================================================
    // CATPPUCCIN MOCHA -> SHADCN SEMANTIC TOKENS
    // ================================================================

    // Table: Background Pane.
    readonly property color background: "#1e1e2e"            // base
    // Table: Body Copy, Main Headline.
    readonly property color foreground: "#cdd6f4"            // text

    // Table: Secondary Panes (Mantle).
    readonly property color popover: "#181825"               // mantle

    // User accent. Indicators, icons, toggles, today-cell.
    readonly property color primary: "#fab387"               // peach
    // Table: On Accent.
    readonly property color primaryForeground: "#1e1e2e"     // base

    // Table: Surface Elements (Surface 0).
    readonly property color secondary: "#313244"             // surface0

    // Table: Surface Elements (Surface 0).
    readonly property color muted: "#313244"                 // surface0
    // Table: Sub-Headlines, Labels.
    readonly property color mutedForeground: "#a6adc8"       // subtext0

    // Table: Selection Background (Overlay 2, use at 20-30% opacity).
    readonly property color selection: "#9399b2"             // overlay2
    // Table: Links, URLs, Tags, Pills.
    readonly property color link: "#89b4fa"                  // blue

    // Table: Errors.
    readonly property color destructive: "#f38ba8"           // red

    // Style guide: structural dividers inside a surface use bg-border
    // at 1px (Ui.Separator). Neutral, never the accent color.
    readonly property color border: "#45475a"                // surface1
    readonly property color input: "#45475a"                 // surface1

    readonly property color success: "#a6e3a1"               // green
    readonly property color warning: "#f9e2af"               // yellow

    // Floating popover ring (Lyra ring-foreground/10). Structural
    // separators use the solid `border` token instead.
    readonly property color subtleRing: Qt.rgba(
        foreground.r,
        foreground.g,
        foreground.b,
        0.10
    )

    // ================================================================
    // SPACING
    //
    // Tailwind spacing translated at 16px root:
    //
    // 0.5 = 2px
    // 1   = 4px
    // 1.5 = 6px
    // 2   = 8px
    // 2.5 = 10px
    // 3   = 12px
    // 4   = 16px
    // ================================================================

    readonly property int space05: 2
    readonly property int space1: 4
    readonly property int space15: 6
    readonly property int space2: 8
    readonly property int space25: 10
    readonly property int space3: 12
    readonly property int space4: 16

    // ================================================================
    // GEOMETRY
    // ================================================================

    // Lyra uses rounded-none throughout.
    readonly property int radius: 0

    readonly property int borderWidth: 1
    readonly property int separatorSize: 1

    // Standard Lyra popover.
    readonly property int dialogPadding: 16
    readonly property int dialogGap: 16

    // ================================================================
    // COMMON COMPONENT DIMENSIONS
    // ================================================================

    // Window sizing scale. Widgets choose by information density, never by
    // one-off pixel values:
    // compact   — small pickers (emoji)
    // standard  — single-column menus (audio, battery, power)
    // wide      — content browsers and calendar
    // workspace — multi-column control surfaces (display)
    readonly property int popupWidthCompact: 400
    readonly property int popupWidthStandard: 480
    readonly property int popupWidthWide: 640
    readonly property int popupWidthWorkspace: 880
    readonly property int popupMaxHeight: 560

    readonly property int rowHeight: 32
    // h-14 two-line list rows (output cards).
    readonly property int rowHeightLarge: 56

    readonly property int iconSize: 16
    readonly property int iconColumnWidth: 20
    readonly property int iconLabelGap: 10

    // Stat-card hero glyph (battery, power). Rows keep iconSize.
    readonly property int batteryGlyphSize: 28
    // Menu hero glyph, matching the audio panel.
    readonly property int heroGlyphSize: 24

    readonly property int notificationWidth: 400
    readonly property int notificationIconSize: 36
    readonly property int notificationGlyphSize: 24
    readonly property int notificationTimeout: 5000

    // Lyra h-1
    readonly property int progressHeight: 4

    readonly property int buttonHeight: 32

    // ================================================================
    // OSD
    // ================================================================

    readonly property int osdWidth: 440
    readonly property int osdPadding: 16
    readonly property int osdGap: 12
    readonly property int osdProgressHeight: 6

    // ================================================================
    // ANIMATION
    // ================================================================

    // Lyra duration-100.
    readonly property int durationFast: 100
    // Matches Mango's 0.215,0.61,0.355,1 cubic-bezier curve.
    readonly property int easingOut: Easing.OutCubic

    // ================================================================
    // SEMANTIC BATTERY COLORS
    // ================================================================

    function batteryColor(percent, charging) {
        if (charging)
            return success

        if (percent <= 15)
            return destructive

        if (percent <= 30)
            return warning

        return foreground
    }
}
