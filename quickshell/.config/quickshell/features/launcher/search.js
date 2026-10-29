function path(item, items) {
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

function title(id, items) {
    var found = items.find(function (item) {
        return item.id === id;
    });
    return found ? found.label : qsTr("Go");
}

function within(item, category, items) {
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

function score(label, needle) {
    var name = label.toLowerCase();
    if (name === needle)
        return 0;
    if (name.indexOf(needle) === 0)
        return 1;
    if (name.indexOf(needle) >= 0)
        return 2;
    return -1;
}

function search(query, category, apps, items) {
    var needle = query.trim().toLowerCase();
    if (!needle) {
        if (category === "apps")
            return apps.map(function (row) {
                return {
                    kind: "app",
                    label: row.entry.name,
                    entry: row.entry,
                    path: title("apps", items)
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
                path: path(item, items)
            };
        });
    }
    var rows = [];
    for (var item of items) {
        if (item.parent === "screenrecord" || !within(item, category, items))
            continue;
        var rank = score(item.label, needle);
        if (rank < 0)
            continue;
        rows.push({
            kind: "action",
            label: item.label,
            icon: item.icon,
            id: item.id,
            path: path(item, items),
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
                path: title("apps", items),
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
    var items = [
        {id: "settings", label: "Settings", parent: "root"},
        {id: "test", label: "Test", parent: "settings"}
    ];
    var rows = search("test", "root", [], items);
    var recordingItems = [
        {id: "screenrecord", label: "Screenrecord", parent: "root"},
        {id: "recordSilent", label: "With no audio", parent: "screenrecord"}
    ];
    var totals = Array.from({length: 12}, function (_, index) { return (index + 1) * 53 - 3; });
    return rows.length === 1 && rows[0].id === "test" && rows[0].path === "Settings"
        && search("", "root", [], items).length === 1
        && search("missing", "root", [], items).length === 0
        && search("screenrecord", "root", [], recordingItems)[0].id === "screenrecord"
        && search("audio", "root", [], recordingItems).length === 0
        && search("", "screenrecord", [], recordingItems)[0].id === "recordSilent"
        && listHeight(totals.slice(0, 10), 1000, 50) === 527
        && listHeight(totals.slice(0, 3), 1000, 50) === 156
        && listHeight(totals.slice(0, 5), 262, 50) === 262
        && listHeight(totals, 250, 50) === 209
        && listHeight([], 1000, 50) === 50;
}

function isSubmenu(id, items) {
    return id === "apps" || id === "files" || items.some(function (item) { return item.parent === id; });
}

function listHeight(totals, available, rowHeight) {
    var count = totals.length;
    if (!count)
        return rowHeight;
    if (totals[count - 1] <= available)
        return totals[count - 1];
    var full = 0;
    while (full < count && totals[full] <= available)
        full++;
    if (full < 1)
        return totals[0];
    return totals[full - 1];
}
