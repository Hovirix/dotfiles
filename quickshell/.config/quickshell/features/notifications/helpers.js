// URL, image and markup policies adapted from Omarchy's notification plugin.
// See LICENSE.omarchy. No sender-controlled remote resources are loaded.

function bounded(value, max) {
    return typeof value === "string" ? value.slice(0, max) : "";
}

function hostname(raw) {
    if (typeof raw !== "string" || raw.length > 253)
        return "";
    var host = raw.toLowerCase().replace(/\.$/, "");
    if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$/.test(host))
        return "";
    return /^(?:0x[0-9a-f]*|[0-9]+)$/i.test(host.split(".").pop()) ? "" : host;
}

function safeUrl(raw) {
    if (typeof raw !== "string" || raw.length > 4096 || /[\x00-\x20\x7f-\x9f\\<>"']/.test(raw))
        return "";
    if (/%(?:0[0-9a-f]|1[0-9a-f]|7f|25|5c)/i.test(raw) || /%(?![0-9a-f]{2})/i.test(raw))
        return "";
    var match = raw.match(/^(https?):\/\/([^/?#]+)([^]*)$/i);
    if (!match)
        return "";
    var authority = match[2].match(/^([^:%@]+)(?::([0-9]{1,5}))?$/);
    if (!authority)
        return "";
    var host = hostname(authority[1]);
    if (!host || (authority[2] && (+authority[2] < 1 || +authority[2] > 65535)))
        return "";
    return match[1].toLowerCase() + "://" + host + (authority[2] ? ":" + String(+authority[2]) : "") + (match[3] || "/");
}

function localImage(raw) {
    var path = bounded(raw, 3072);
    if (path !== raw)
        return "";
    if (path.indexOf("image://icon/") === 0)
        path = path.slice("image://icon/".length);
    if (/^file:\/\//i.test(path)) {
        if (!/^file:\/\/\//i.test(path) || /[?#]/.test(path))
            return "";
        try { path = decodeURIComponent(path.slice(7)); } catch (error) { return ""; }
    }
    if (!path || path.length > 1024 || path.charAt(0) !== "/" || /[\x00-\x1f\x7f-\x9f]/.test(path))
        return "";
    var parts = path.slice(1).split("/");
    if (parts.some(function (part) { return part === "" || part === "." || part === ".."; }))
        return "";
    if (/^\/(?:proc|sys|dev)(?:\/|$)/.test(path))
        return "";
    if (/^\/(?:var\/)?run(?:\/|$)/.test(path) && !/^\/run\/user\/[0-9]+\/./.test(path))
        return "";
    return "file://" + path.split("/").map(encodeURIComponent).join("/");
}

function imageSource(raw) {
    return /^image:\/\/qsimage\/[0-9]+\/[0-9]+$/.test(raw) ? raw : localImage(raw);
}

function iconName(raw) {
    var name = bounded(raw, 256);
    if (name.indexOf("image://icon/") === 0)
        name = name.slice("image://icon/".length);
    return /^[A-Za-z0-9_][A-Za-z0-9_.-]{0,255}$/.test(name) ? name : "";
}

function decode(text) {
    var entities = { amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " " };
    var out = bounded(text, 32768);
    for (var i = 0; i < 3; i++) {
        var once = out.replace(/&#(x[0-9a-f]{1,6}|[0-9]{1,7});/gi, function (whole, value) {
            var code = value[0].toLowerCase() === "x" ? parseInt(value.slice(1), 16) : parseInt(value, 10);
            return code > 0 && code < 0x110000 && !(code >= 0xd800 && code <= 0xdfff) ? String.fromCodePoint(code) : whole;
        }).replace(/&(amp|lt|gt|quot|apos|nbsp);/gi, function (_, name) { return entities[name.toLowerCase()]; });
        if (once === out)
            break;
        out = once;
    }
    return out;
}

function escapeText(text) {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function render(body) {
    // Escape first; only attribute-free formatting is restored, never images.
    return escapeText(decode(body))
        .replace(/&lt;(\/?)(b|i|u|s|strong|em)&gt;/gi, function (_, close, tag) {
            tag = tag.toLowerCase();
            return "<" + close + (tag === "em" ? "i" : tag) + ">";
        })
        .replace(/&lt;br\s*\/?&gt;/gi, "<br/>")
        .replace(/&lt;a\s+href=(?:&quot;|")([^"<>]*?)(?:&quot;|")\s*&gt;([\s\S]*?)&lt;\/a&gt;/gi,
                 function (_, href, label) { return safeUrl(decode(href)) ? "<u>" + label + "</u>" : label; })
        .replace(/\r?\n/g, "<br/>");
}

function firstUrl(text) {
    var matches = decode(text).match(/https?:\/\/[^\s<>"']+/gi) || [];
    for (var i = 0; i < matches.length; i++) {
        var url = safeUrl(matches[i].replace(/[.,;:!?)\]}'"]+$/, ""));
        if (url)
            return url;
    }
    return "";
}

function duration(urgency, low, normal, critical) {
    return urgency === 2 ? critical : urgency === 0 ? low : normal;
}

function groups(values, order) {
    var result = [], byApp = Object.create(null);
    for (var i = 0; i < values.length; i++) {
        var notification = values[i];
        var key = (iconName(notification.desktopEntry) || bounded(notification.appName, 256) || "Notification").toLowerCase();
        var group = byApp[key];
        if (!group) {
            group = {id: notification.id, key: key, count: 0, index: i, notification: notification};
            byApp[key] = group;
            result.push(group);
        }
        group.count++;
        if ((order[notification.id] || 0) > (order[group.id] || 0)) {
            group.id = notification.id;
            group.index = i;
            group.notification = notification;
        }
    }
    result.sort(function (a, b) { return (order[b.id] || 0) - (order[a.id] || 0); });
    return result;
}

function focusedMonitor(text) {
    if (typeof text !== "string" || text.length > 1048576)
        return "";
    try {
        var data = JSON.parse(text);
        if (!data || !Array.isArray(data.monitors))
            return "";
        var monitor = data.monitors.find(function (item) { return item && item.active === true; });
        return monitor ? bounded(monitor.name, 256) : "";
    } catch (error) { return ""; }
}
