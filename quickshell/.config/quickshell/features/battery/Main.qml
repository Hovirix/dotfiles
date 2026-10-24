import QtQuick
import "format.js" as Utils
import Quickshell.Io
import Quickshell.Services.UPower

// UPower-backed battery service.
//
// Percentage, state, and time come from the aggregate display device.
// Threshold alerts (low <= 30, critical <= 15 while discharging, plus
// charger-plugged) are emitted here via notify-send so they render
// through the notification server like every other notification.
QtObject {
    id: root

    readonly property bool available: !!(device && device.isPresent)
    property bool criticalNotified: false
    readonly property int criticalThreshold: 15
    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool discharging: {
        return !!(device && device.isPresent && UPower.onBattery);
    }
    property bool emergencyNotified: false
    readonly property int emergencyThreshold: 5
    property bool lastDischarging: false

    // Latched so each threshold notifies once per discharge cycle.
    // Cleared on charger-plug and when the level recovers with hysteresis.
    property bool lowNotified: false

    // Emergency (5) resends a final warning after low (30) and critical (15).
    readonly property int lowThreshold: 30
    property Process notifier: Process {
    }

    // 0..100 scale (UPower reports 0..1).
    readonly property real percentage: {
        if (!available)
            return 0;
        const p = Number(device.percentage);
        if (!isFinite(p))
            return 0;
        return Math.max(0, Math.min(100, p <= 1 ? p * 100 : p));
    }
    readonly property int state: device ? device.state : UPowerDeviceState.Unknown

    // Seconds remaining (to empty while discharging, to full otherwise).
    readonly property real timeRemaining: {
        if (!available)
            return 0;
        const t = root.discharging ? Number(device.timeToEmpty) : Number(device.timeToFull);
        return isFinite(t) && t > 0 ? t : 0;
    }

    function checkBattery(): void {
        if (!root.available || !root.discharging)
            return;
        const pct = root.percentage;
        // UPower reports 0 while initializing (NaN maps to 0 above);
        // treat non-positive as unknown so reloads never false-alarm.
        // A genuine 0% is seconds from forced shutdown anyway.
        if (!(pct > 0))
            return;
        if (pct > root.lowThreshold + 2)
            root.lowNotified = false;
        if (pct > root.criticalThreshold + 2)
            root.criticalNotified = false;
        if (pct > root.emergencyThreshold + 2)
            root.emergencyNotified = false;
        if (pct <= root.emergencyThreshold && !root.emergencyNotified) {
            root.emergencyNotified = true;
            root.criticalNotified = true;
            root.lowNotified = true;
            root.sendDischargeAlert(qsTr("Critical"), "critical");
        } else if (pct <= root.criticalThreshold && !root.criticalNotified) {
            root.criticalNotified = true;
            root.lowNotified = true;
            root.sendDischargeAlert(qsTr("Critical"), "critical");
        } else if (pct <= root.lowThreshold && !root.lowNotified) {
            root.lowNotified = true;
            root.sendDischargeAlert(qsTr("Low"), "normal");
        }
    }

    // Icon per alert: the battery level while discharging (battery-020),
    // a plug (ac-adapter) while charging so the event never reads as
    // a level. The notification card falls back to its glyph when a name
    // does not resolve.
    function levelIcon(charging: bool): string {
        if (charging)
            return "ac-adapter";
        const raw = Math.round(root.percentage / 10) * 10;
        const tag = ("00" + Math.max(0, Math.min(100, raw))).slice(-3);
        return `battery-${tag}`;
    }

    function sendDischargeAlert(label: string, urgency: string): void {
        const pct = Math.round(root.percentage);
        const remaining = Utils.timeShort(root.timeRemaining);
        const body = remaining !== "" ? qsTr("%1 · %2% · %3 remaining").arg(label).arg(pct).arg(remaining) : qsTr("%1 · %2% remaining").arg(label).arg(pct);
        root.notifier.exec(["notify-send", "-a", "Battery", "-u", urgency, "-i", root.levelIcon(false), qsTr("%1 battery").arg(label), body]);
    }

    function sendPlugged(): void {
        const pct = Math.round(root.percentage);
        const remaining = Utils.timeShort(root.timeRemaining);
        let body = qsTr("Charging · %1%").arg(pct);
        if (root.state === UPowerDeviceState.FullyCharged)
            body = qsTr("Fully charged · %1%").arg(pct);
        else if (remaining !== "")
            body = qsTr("Charging · %1% · %2 to full").arg(pct).arg(remaining);
        const title = root.state === UPowerDeviceState.FullyCharged ? qsTr("Battery fully charged") : qsTr("Battery charging");
        // battery-state hint lets the panel paint title and border green.
        root.notifier.exec(["notify-send", "-a", "Battery", "-u", "low", "-i", root.levelIcon(true), "-h", "string:battery-state:charging", title, body]);
    }

    Component.onCompleted: {
        root.lastDischarging = root.discharging;
        root.checkBattery();
    }
    onAvailableChanged: {
        root.lastDischarging = root.discharging;
        root.checkBattery();
    }
    onDischargingChanged: {
        if (root.available && root.lastDischarging && !root.discharging) {
            root.lowNotified = false;
            root.criticalNotified = false;
            root.emergencyNotified = false;
            root.sendPlugged();
        }
        root.lastDischarging = root.discharging;
        root.checkBattery();
    }
    onPercentageChanged: root.checkBattery()
}
