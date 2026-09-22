pragma Singleton

import QtQuick

// The only place where the design system exists.
//
// shadcn/ui Lyra component style, JetBrainsMono Nerd Font Mono (single family
// for text and icons), Catppuccin Mocha mapped onto shadcn semantic tokens.
//
// Panels never hardcode visual values; shared Ui primitives in this folder
// consume these tokens, and overlays compose the primitives.
QtObject {
    id: root

    // ================================================================
    // TYPOGRAPHY
    // ================================================================

    // Single family for everything, text and Nerd Font icons alike.
    readonly property string fontFamily: "JetBrainsMono Nerd Font Mono"

    // Slightly above Lyra's default xs/sm scale for comfortable desktop
    // legibility while keeping menu density compact.
    readonly property int fontSizeBody: 13
    readonly property int fontSizeLabel: 13
    readonly property int fontSizeValue: 13
    readonly property int fontSizeTitle: 15
    readonly property int fontSizeOsd: 18

    // Display sizes are purpose-driven exceptions to the Lyra xs/sm scale
    // (e.g. clock faces), never body text.
    readonly property int fontSizeDisplay: 44
    readonly property int fontSizeDisplaySmall: 20
    readonly property int fontSizeHero: 64

    readonly property int fontWeightNormal: Font.Normal      // 400
    readonly property int fontWeightMedium: Font.Medium      // 500
    readonly property int fontWeightStrong: Font.DemiBold    // 600

    // ================================================================
    // CATPPUCCIN MOCHA -> SHADCN SEMANTIC TOKENS
    // ================================================================

    readonly property color background: "#1e1e2e"            // base
    readonly property color foreground: "#cdd6f4"            // text

    readonly property color card: "#1e1e2e"                  // base
    readonly property color cardForeground: "#cdd6f4"        // text

    readonly property color popover: "#181825"               // mantle
    readonly property color popoverForeground: "#cdd6f4"     // text

    readonly property color primary: "#cba6f7"               // mauve
    readonly property color primaryForeground: "#11111b"     // crust

    readonly property color secondary: "#313244"             // surface0
    readonly property color secondaryForeground: "#cdd6f4"   // text

    readonly property color muted: "#313244"                 // surface0
    readonly property color mutedForeground: "#a6adc8"       // subtext0

    readonly property color accent: "#45475a"                // surface1
    readonly property color accentForeground: "#cdd6f4"      // text

    readonly property color destructive: "#f38ba8"           // red

    readonly property color border: "#45475a"                // surface1
    readonly property color input: "#45475a"                 // surface1

    readonly property color ring: "#cba6f7"                  // mauve

    readonly property color success: "#a6e3a1"               // green
    readonly property color warning: "#f9e2af"               // yellow
    readonly property color peach: "#fab387"                 // mocha peach

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
    readonly property int panelPadding: 10
    readonly property int panelGap: 10

    // Larger dialog-like surfaces if ever required.
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

    readonly property int headerHeight: 42

    readonly property int rowHeight: 32

    readonly property int iconSize: 16
    readonly property int iconColumnWidth: 20
    readonly property int iconLabelGap: 10

    readonly property int sectionGap: 10

    // Lyra h-1
    readonly property int progressHeight: 4

    readonly property int buttonHeightXs: 24
    readonly property int buttonHeightSm: 28
    readonly property int buttonHeight: 32
    readonly property int buttonHeightLg: 36

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

    readonly property real enterScale: 0.95
    readonly property real normalScale: 1.0

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

    // ================================================================
    // SHARED BEHAVIOR
    // ================================================================

    // Fold touchpad wheel deltas into full 120-unit steps. Returns
    // { steps, remainder }; carry the remainder between wheel events.
    function wheelSteps(accumulator, delta) {
        delta = Math.max(-120, Math.min(120, delta))
        if (accumulator * delta < 0)
            accumulator = 0
        var total = accumulator + delta
        var steps = total < 0 ? Math.ceil(total / 120) : Math.floor(total / 120)
        return {
            steps: steps,
            remainder: total - steps * 120
        }
    }
}
