function timeShort(seconds) {
    const s = Math.floor(Number(seconds));
    if (!isFinite(s) || s <= 0)
        return "";
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    if (h > 0)
        return qsTr("%1h %2m").arg(h).arg(m);
    if (m > 0)
        return qsTr("%1m").arg(m);
    return "";
}

function batteryStatusColor(percent, available, discharging, theme) {
    if (!available)
        return theme.mutedForeground;
    if (discharging && percent <= 15)
        return theme.destructive;
    if (discharging && percent <= 30)
        return "#f9e2af";
    return theme.success;
}
