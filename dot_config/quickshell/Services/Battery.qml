import QtQuick
import Quickshell.Services.UPower

// UPower-backed battery service. Feeds Overlays/Battery.qml.
QtObject {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool available: !!(device && device.isPresent)

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

    // 0..100 design-health; 0 when unknown (overlay shows "Unavailable").
    readonly property real healthPercentage: {
        if (!available)
            return 0
        const full = Number(device.energyFull)
        const design = Number(device.energyFullDesign)
        if (!isFinite(full) || !isFinite(design) || design <= 0)
            return 0
        return Math.max(0, Math.min(100, full / design * 100))
    }

    // Current power draw in watts.
    readonly property real powerUsage: {
        if (!available)
            return 0
        const rate = Number(device.energyRate)
        if (isFinite(rate))
            return Math.max(0, rate)
        const change = Number(device.changeRate)
        return isFinite(change) ? Math.max(0, change) : 0
    }

    readonly property real energy: {
        if (!available)
            return 0
        const value = Number(device.energy)
        return isFinite(value) && value >= 0 ? value : 0
    }

    readonly property real energyFull: {
        if (!available)
            return 0
        const value = Number(device.energyFull)
        return isFinite(value) && value > 0 ? value : 0
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
