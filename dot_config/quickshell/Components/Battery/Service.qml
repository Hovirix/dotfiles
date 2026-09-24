import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

// UPower-backed battery service. Feeds Overlays/Battery.qml.
//
// Percentage, state, and time come from the aggregate display device.
// Capacity and health come from the physical laptop battery: the
// display device does not expose energy-full-design, so health and
// capacity rows would otherwise stay empty.
//
// Threshold alerts (low <= 30, critical <= 15 while discharging, plus
// charger-plugged) are emitted here via notify-send so they render
// through Components/Notifications like every other notification.
QtObject {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool available: !!(device && device.isPresent)

    readonly property var laptopBattery: {
        const list = (UPower.devices && UPower.devices.values) || []
        for (let i = 0; i < list.length; i++) {
            const candidate = list[i]
            if (candidate && candidate.ready && candidate.isLaptopBattery && candidate.isPresent)
                return candidate
        }
        return null
    }

    // Physical-battery value first, display-device fallback, else 0.
    function batteryNumber(name: string): real {
        const physical = root.laptopBattery ? Number(root.laptopBattery[name]) : NaN
        if (isFinite(physical) && physical > 0)
            return physical
        const composite = root.device ? Number(root.device[name]) : NaN
        if (isFinite(composite) && composite > 0)
            return composite
        return 0
    }

    // 0..100 scale (UPower reports 0..1).
    readonly property real percentage: {
        if (!available)
            return 0
        const p = Number(device.percentage)
        if (!isFinite(p))
            return 0
        return Math.max(0, Math.min(100, p <= 1 ? p * 100 : p))
    }

    readonly property bool discharging: {
        return !!(device && device.isPresent && UPower.onBattery)
    }

    readonly property string state: {
        if (!device || !device.isPresent)
            return "Unavailable"
        switch (device.state) {
        case UPowerDeviceState.Charging:
            return "Charging"
        case UPowerDeviceState.Discharging:
            return "Discharging"
        case UPowerDeviceState.FullyCharged:
            return "Fully charged"
        case UPowerDeviceState.PendingCharge:
            return "Pending charge"
        case UPowerDeviceState.Empty:
            return "Empty"
        default:
            return "Unknown"
        }
    }

    // Seconds remaining (to empty while discharging, to full otherwise).
    readonly property real timeRemaining: {
        if (!available)
            return 0
        const t = root.discharging ? Number(device.timeToEmpty) : Number(device.timeToFull)
        return isFinite(t) && t > 0 ? t : 0
    }

    // 0..100 design-health; 0 when unknown (overlay hides the row).
    readonly property real healthPercentage: {
        if (!available)
            return 0
        const sources = [root.laptopBattery, device]
        for (let i = 0; i < sources.length; i++) {
            const source = sources[i]
            if (source && source.healthSupported) {
                const health = Number(source.healthPercentage)
                if (isFinite(health) && health > 0)
                    return Math.max(0, Math.min(100, health))
            }
        }
        return 0
    }

    // Current power draw in watts (absolute rate).
    readonly property real powerUsage: {
        if (!available)
            return 0
        const sources = [root.laptopBattery, device]
        for (let i = 0; i < sources.length; i++) {
            const rate = sources[i] ? Number(sources[i].changeRate) : NaN
            if (isFinite(rate))
                return Math.abs(rate)
        }
        return 0
    }

    readonly property real energy: {
        if (!available)
            return 0
        return root.batteryNumber("energy")
    }

    // Maximum capacity in Wh; 0 when unknown (overlay hides the row).
    readonly property real energyCapacity: {
        if (!available)
            return 0
        return root.batteryNumber("energyCapacity")
    }

    // Alert thresholds mirror Appearance.batteryColor (30 warning, 15 critical).
    // Emergency (5) resends a final warning when discharge continues.
    readonly property int lowThreshold: 30
    readonly property int criticalThreshold: 15
    readonly property int emergencyThreshold: 5

    // Latched so each threshold notifies once per discharge cycle.
    // Cleared on charger-plug and when the level recovers with hysteresis.
    property bool lowNotified: false
    property bool criticalNotified: false
    property bool emergencyNotified: false
    property bool lastDischarging: false

    Component.onCompleted: {
        root.lastDischarging = root.discharging
        root.checkBattery()
    }
    onAvailableChanged: {
        root.lastDischarging = root.discharging
        root.checkBattery()
    }
    onPercentageChanged: root.checkBattery()
    onDischargingChanged: {
        if (root.available && root.lastDischarging && !root.discharging) {
            root.lowNotified = false
            root.criticalNotified = false
            root.emergencyNotified = false
            root.sendPlugged()
        }
        root.lastDischarging = root.discharging
        root.checkBattery()
    }

    function checkBattery(): void {
        if (!root.available || !root.discharging)
            return
        const pct = root.percentage
        // UPower reports 0 while initializing (NaN maps to 0 above);
        // treat non-positive as unknown so reloads never false-alarm.
        // A genuine 0% is seconds from forced shutdown anyway.
        if (!(pct > 0))
            return
        if (pct > root.lowThreshold + 2)
            root.lowNotified = false
        if (pct > root.criticalThreshold + 2)
            root.criticalNotified = false
        if (pct > root.emergencyThreshold + 2)
            root.emergencyNotified = false
        if (pct <= root.emergencyThreshold && !root.emergencyNotified) {
            root.emergencyNotified = true
            root.criticalNotified = true
            root.lowNotified = true
            root.sendDischargeAlert("Critical", "critical")
        } else if (pct <= root.criticalThreshold && !root.criticalNotified) {
            root.criticalNotified = true
            root.lowNotified = true
            root.sendDischargeAlert("Critical", "critical")
        } else if (pct <= root.lowThreshold && !root.lowNotified) {
            root.lowNotified = true
            root.sendDischargeAlert("Low", "normal")
        }
    }

    function sendDischargeAlert(label: string, urgency: string): void {
        const pct = Math.round(root.percentage)
        const remaining = root.timeShort(root.timeRemaining)
        const body = remaining !== "" ? `${label} · ${pct}% · ${remaining} remaining` : `${label} · ${pct}% remaining`
        root.notifier.exec(["notify-send", "-a", "Battery", "-u", urgency, "-i", root.levelIcon(false), "Battery", body])
    }

    function sendPlugged(): void {
        const pct = Math.round(root.percentage)
        const remaining = root.timeShort(root.timeRemaining)
        let body = `Charging · ${pct}%`
        if (root.state === "Fully charged")
            body = `Fully charged · ${pct}%`
        else if (remaining !== "")
            body = `Charging · ${pct}% · ${remaining} to full`
        // battery-state hint lets the panel paint title and border green.
        root.notifier.exec(["notify-send", "-a", "Battery", "-u", "low", "-i", root.levelIcon(true), "-h", "string:battery-state:charging", "Battery", body])
    }

    // Icon per alert: the battery level while discharging (battery-020),
    // a plug (ac-adapter) while charging so the event never reads as
    // a level. NotificationsPanel falls back to its glyph when a name
    // does not resolve.
    function levelIcon(charging: bool): string {
        if (charging)
            return "ac-adapter"
        const raw = Math.round(root.percentage / 10) * 10
        const tag = ("00" + Math.max(0, Math.min(100, raw))).slice(-3)
        return `battery-${tag}`
    }

    property var notifier: Process {
    }

    // "3h 42m" / "42m" / "" when unknown.
    function timeShort(seconds): string {
        const s = Math.floor(Number(seconds))
        if (!isFinite(s) || s <= 0)
            return ""
        const h = Math.floor(s / 3600)
        const m = Math.floor((s % 3600) / 60)
        if (h > 0)
            return `${h}h ${m}m`
        if (m > 0)
            return `${m}m`
        return ""
    }
}
