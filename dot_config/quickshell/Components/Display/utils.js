function logicalWidth(output) {
    if (!output)
        return 0;
    var match = String(output.resolution || "").match(/^(\d+)x/);
    var scale = Number(output.scale);
    if (!match || !isFinite(scale) || scale <= 0)
        return 0;
    return Math.round(Number(match[1]) / scale);
}

function parse(text) {
    var next = [];
    var current = null;
    var lines = text.split("\n");

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var output = line.match(/^(\S+)\s+"([^"]*)"/);
        if (output) {
            current = {
                name: output[1],
                description: output[2],
                make: "",
                model: "",
                enabled: false,
                resolution: qsTr("No signal"),
                refresh: "",
                modes: [],
                scale: "1",
                position: "",
                transform: "normal"
            };
            next.push(current);
            continue;
        }
        if (!current)
            continue;
        var enabled = line.match(/^\s+Enabled:\s+(yes|no)$/);
        if (enabled) {
            current.enabled = enabled[1] === "yes";
            continue;
        }
        var make = line.match(/^\s+Make:\s*(.+)$/);
        if (make) {
            current.make = make[1];
            continue;
        }
        var model = line.match(/^\s+Model:\s*(.+)$/);
        if (model) {
            current.model = model[1];
            continue;
        }
        var listedMode = line.match(/^\s+(\d+x\d+) px,\s*([\d.]+) Hz(?: \([^)]*\))?$/);
        if (listedMode) {
            current.modes.push({
                resolution: listedMode[1],
                refresh: Math.round(Number(listedMode[2]))
            });
        }
        var mode = line.match(/^\s+(\d+x\d+) px,\s*([\d.]+) Hz \([^)]*current[^)]*\)$/);
        if (mode) {
            current.resolution = mode[1];
            current.refresh = `${Math.round(Number(mode[2]))} Hz`;
            continue;
        }
        var scale = line.match(/^\s+Scale:\s*([\d.]+)$/);
        if (scale)
            current.scale = Number(scale[1]).toFixed(2).replace(/\.00$/, "");
        var position = line.match(/^\s+Position:\s*(.+)$/);
        if (position)
            current.position = position[1];
        var transform = line.match(/^\s+Transform:\s*(.+)$/);
        if (transform)
            current.transform = transform[1];
    }
    return next;
}
