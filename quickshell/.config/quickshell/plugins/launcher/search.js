function score(label, needle) {
    var name = label.toLowerCase();
    if (!needle || name === needle) return 0;
    if (name.indexOf(needle) === 0) return 1;
    return name.indexOf(needle) >= 0 ? 2 : 3;
}

function search(query, apps, actions) {
    var needle = query.trim().toLowerCase();
    var terms = needle.split(/\s+/);
    var rows = apps.map((app) => ({
        kind: "app",
        label: app.entry.name,
        entry: app.entry,
        rank: score(app.entry.name, needle),
        appScore: app.score,
    }));
    for (var action of actions) {
        var text = [action.label, action.keywords || ""]
            .join(" ")
            .toLowerCase();
        if (!terms.every((term) => text.includes(term))) continue;
        rows.push({
            kind: "action",
            id: action.id,
            label: action.label,
            icon: action.icon,
            action: action,
            rank: score(action.label, needle),
        });
    }
    rows.sort(
        (a, b) =>
            a.rank - b.rank ||
            (a.kind === "app" ? 0 : 1) - (b.kind === "app" ? 0 : 1) ||
            (b.appScore || 0) - (a.appScore || 0) ||
            a.label.localeCompare(b.label),
    );
    return rows;
}
