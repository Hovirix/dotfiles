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
