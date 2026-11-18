function focusedMonitor(text) {
    if (typeof text !== "string" || text.length > 1048576) return "";
    try {
        var data = JSON.parse(text);
        if (!data || !Array.isArray(data.monitors)) return "";
        var monitor = data.monitors.find(
            (item) => item && item.active === true,
        );
        return monitor && typeof monitor.name === "string"
            ? monitor.name.slice(0, 256)
            : "";
    } catch (error) {
        return "";
    }
}
