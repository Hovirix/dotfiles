function displayName(output) {
    if (!output) return "";
    return /^(eDP|LVDS|DSI)-/.test(output.name)
        ? qsTr("Built-in display")
        : output.model || output.name;
}

function logicalWidth(output) {
    if (!output) return 0;
    var match = String(output.resolution || "").match(/^(\d+)x(\d+)$/);
    var scale = Number(output.scale);
    if (!match || !isFinite(scale) || scale <= 0) return 0;
    var rotated = /^(?:flipped-)?(?:90|270)$/.test(output.transform);
    return Math.round(Number(match[rotated ? 2 : 1]) / scale);
}

function layout(anchor, outputs) {
    if (!anchor || !anchor.enabled) return "";
    var active = outputs.filter(function (output) {
        return output.enabled;
    });
    if (active.length < 2) return "";
    var position = String(anchor.position).match(/^(-?\d+),\s*(-?\d+)$/);
    if (!position) return "Custom";
    if (
        active.every(function (output) {
            return output.position === anchor.position;
        })
    )
        return "Mirror";
    var left = true,
        right = true;
    for (var output of active) {
        if (output.name === anchor.name) continue;
        var other = String(output.position).match(/^(-?\d+),\s*(-?\d+)$/);
        if (!other || Number(other[2]) !== Number(position[2])) return "Custom";
        left =
            left &&
            Number(other[1]) + logicalWidth(output) <= Number(position[1]);
        right =
            right &&
            Number(other[1]) >= Number(position[1]) + logicalWidth(anchor);
    }
    return left ? "Extend left" : right ? "Extend right" : "Custom";
}

function layoutLabel(value, anchor, outputs) {
    if (!anchor) return "";
    const others = outputs.filter(
        (output) => output.enabled && output.name !== anchor.name,
    );
    // Layout values describe where the other outputs extend from the selected display.
    if (
        others.length === 1 &&
        (value === "Extend left" || value === "Extend right")
    )
        return (
            value === "Extend right" ? qsTr("Left of %1") : qsTr("Right of %1")
        ).arg(displayName(others[0]));
    if (value === "Extend left") return qsTr("Extend left");
    if (value === "Extend right") return qsTr("Extend right");
    return value === "Mirror" ? qsTr("Mirror") : qsTr("Custom");
}

function settingOptions(output, index, enabledCount) {
    if (!output) return [];
    var modes = output.modes || [];
    if (index === 0) return [...new Set(modes.map((mode) => mode.resolution))];
    if (index === 1)
        return [
            ...new Set(
                modes
                    .filter((mode) => mode.resolution === output.resolution)
                    .map((mode) => `${mode.refresh} Hz`),
            ),
        ];
    if (index === 2) return ["1", "1.25", "1.5", "2"];
    if (index === 3) return ["normal", "90", "180", "270"];
    return output.enabled && enabledCount > 1
        ? ["Extend right", "Extend left", "Mirror"]
        : [];
}

function settingValue(output, index, outputs) {
    if (!output) return "";
    if (index === 0) return output.resolution;
    if (index === 1) return output.refresh;
    if (index === 2) return output.scale;
    if (index === 3) return output.transform;
    return layout(output, outputs);
}

function restoreCommand(outputs) {
    var args = ["wlr-randr"];
    for (const output of outputs) {
        args.push("--output", output.name, output.enabled ? "--on" : "--off");
        if (output.enabled) {
            args.push(
                "--mode",
                output.resolution + "@" + output.refresh.replace(" Hz", ""),
                "--scale",
                output.scale,
                "--transform",
                output.transform,
                "--pos",
                output.position,
            );
        }
    }
    return args;
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
                transform: "normal",
            };
            next.push(current);
            continue;
        }
        if (!current) continue;
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
        var listedMode = line.match(
            /^\s+(\d+x\d+) px,\s*([\d.]+) Hz(?: \([^)]*\))?$/,
        );
        if (listedMode) {
            current.modes.push({
                resolution: listedMode[1],
                refresh: Number(listedMode[2]),
            });
        }
        var mode = line.match(
            /^\s+(\d+x\d+) px,\s*([\d.]+) Hz \([^)]*current[^)]*\)$/,
        );
        if (mode) {
            current.resolution = mode[1];
            current.refresh = `${Number(mode[2])} Hz`;
            continue;
        }
        var scale = line.match(/^\s+Scale:\s*([\d.]+)$/);
        if (scale) current.scale = String(Number(scale[1]));
        var position = line.match(/^\s+Position:\s*(.+)$/);
        if (position) current.position = position[1];
        var transform = line.match(/^\s+Transform:\s*(.+)$/);
        if (transform) current.transform = transform[1];
    }
    return next;
}
