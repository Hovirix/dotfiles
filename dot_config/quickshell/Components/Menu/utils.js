var items = [
    {
        id: "apps",
        label: qsTr("Apps"),
        icon: "󰀻",
        parent: "root"
    },
    {
        id: "files",
        label: qsTr("Files"),
        icon: "󰈙",
        parent: "root"
    },
    {
        id: "emoji",
        label: qsTr("Emoji"),
        icon: "",
        parent: "root"
    },
    {
        id: "system",
        label: qsTr("System"),
        icon: "",
        parent: "root"
    },
    {
        id: "settings",
        label: qsTr("Settings"),
        icon: "",
        parent: "root"
    },
    {
        id: "lock",
        label: qsTr("Lock"),
        icon: "",
        parent: "system"
    },
    {
        id: "suspend",
        label: qsTr("Suspend"),
        icon: "󰒲",
        parent: "system"
    },
    {
        id: "reboot",
        label: qsTr("Reboot"),
        icon: "",
        parent: "system"
    },
    {
        id: "shutdown",
        label: qsTr("Shutdown"),
        icon: "",
        parent: "system"
    },
    {
        id: "idle",
        label: qsTr("Toggle Idle Lock"),
        icon: "󰒲",
        parent: "system"
    },
    {
        id: "screenshot",
        label: qsTr("Screenshot"),
        icon: "",
        parent: "system"
    },
    {
        id: "screenshotSave",
        label: qsTr("Save Screenshot"),
        icon: "",
        parent: "system"
    },
    {
        id: "audio",
        label: qsTr("Audio"),
        icon: "",
        parent: "settings"
    },
    {
        id: "display",
        label: qsTr("Display"),
        icon: "󰍹",
        parent: "settings"
    },
    {
        id: "network",
        label: qsTr("Network"),
        icon: "󰖩",
        parent: "settings"
    },
    {
        id: "bluetooth",
        label: qsTr("Bluetooth"),
        icon: "󰂯",
        parent: "settings"
    },
    {
        id: "battery",
        label: qsTr("Battery"),
        icon: "󰁹",
        parent: "settings"
    },
    {
        id: "brightnessUp",
        label: qsTr("Brightness Up"),
        icon: "󰃟",
        parent: "settings"
    },
    {
        id: "brightnessDown",
        label: qsTr("Brightness Down"),
        icon: "󰃞",
        parent: "settings"
    },
    {
        id: "clock",
        label: qsTr("Clock"),
        icon: "󰥔",
        parent: "settings"
    },
    {
        id: "keyboardLayout",
        label: qsTr("Toggle Keyboard Layout"),
        icon: "󰌌",
        parent: "settings"
    }
];

function path(item) {
    var labels = [];
    var parent = item.parent;
    while (parent && parent !== "root") {
        var found = items.find(function (row) {
            return row.id === parent;
        });
        if (!found)
            break;
        labels.unshift(found.label);
        parent = found.parent;
    }
    return labels.join(" › ");
}

function title(id) {
    var found = items.find(function (item) {
        return item.id === id;
    });
    return found ? found.label : qsTr("Go");
}

function within(item, category) {
    var parent = item.parent;
    while (parent && parent !== "root") {
        if (parent === category)
            return true;
        var found = items.find(function (row) {
            return row.id === parent;
        });
        parent = found ? found.parent : "";
    }
    return category === "root";
}

function score(label, query) {
    var name = label.toLowerCase();
    var needle = query.toLowerCase();
    if (name === needle)
        return 0;
    if (name.indexOf(needle) === 0)
        return 1;
    if (name.indexOf(needle) >= 0)
        return 2;
    return -1;
}

function search(query, category, apps) {
    var needle = query.trim().toLowerCase();
    if (!needle) {
        if (category === "apps")
            return apps.map(function (row) {
                return {
                    kind: "app",
                    label: row.entry.name,
                    entry: row.entry,
                    path: title("apps")
                };
            });
        return items.filter(function (item) {
            return item.parent === category;
        }).map(function (item) {
            return {
                kind: "action",
                label: item.label,
                icon: item.icon,
                id: item.id,
                path: path(item)
            };
        });
    }
    var rows = [];
    for (var item of items) {
        if (!within(item, category))
            continue;
        var rank = score(item.label, needle);
        if (rank < 0)
            continue;
        rows.push({
            kind: "action",
            label: item.label,
            icon: item.icon,
            id: item.id,
            path: path(item),
            rank: rank
        });
    }
    if (category === "root" || category === "apps") {
        for (var app of apps) {
            var rank = score(String(app.entry.name), needle);
            rows.push({
                kind: "app",
                label: app.entry.name,
                entry: app.entry,
                path: title("apps"),
                rank: rank < 0 ? 3 : rank,
                appScore: app.score
            });
        }
    }
    rows.sort(function (a, b) {
        return a.rank - b.rank || (a.kind === "app" ? -1 : 1) - (b.kind === "app" ? -1 : 1) || (b.appScore || 0) - (a.appScore || 0) || String(a.label).localeCompare(String(b.label));
    });
    return rows;
}

function selfCheck() {
    var rows = search(title("audio"), "root", []);
    return rows.length > 0 && rows[0].id === "audio" && rows[0].path === title("settings") && search("", "root", []).map(function (row) {
        return row.id;
    }).join(",") === "apps,files,emoji,system,settings" && search(title("brightnessUp"), "settings", []).some(function (row) {
        return row.id === "brightnessUp";
    }) && search(title("keyboardLayout"), "root", []).some(function (row) {
        return row.id === "keyboardLayout";
    });
}

function isSubmenu(id) {
    return ["apps", "files", "system", "settings"].indexOf(id) >= 0;
}

function foldedListHeight(totals, available, spacing, peek, rowHeight) {
    var count = totals.length;
    if (!count)
        return rowHeight;
    if (totals[count - 1] <= available)
        return totals[count - 1];
    var full = 0;
    while (full < count && totals[full] <= available)
        full++;
    while (full > 1 && totals[full - 1] + spacing + peek > available)
        full--;
    if (full < 1)
        return Math.max(available, rowHeight);
    return totals[full - 1] + spacing + peek;
}
