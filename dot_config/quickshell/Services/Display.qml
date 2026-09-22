import QtQuick
import Quickshell.Io

// Live wlroots output state, queried and changed through wlr-randr.
QtObject {
    id: root

    property var outputs: []
    property bool loading: false

    readonly property int enabledCount: {
        var count = 0
        for (var i = 0; i < outputs.length; i++) {
            if (outputs[i].enabled)
                count++
        }
        return count
    }

    function refresh() {
        if (query.running)
            return
        loading = true
        query.exec(["wlr-randr"])
    }

    function toggleOutput(output) {
        if (!output)
            return
        setOutputEnabled(output, !output.enabled)
    }

    function setOutputEnabled(output, enabled) {
        if (!output || (!enabled && output.enabled && enabledCount <= 1))
            return
        apply.exec(["wlr-randr", "--output", output.name, enabled ? "--on" : "--off"])
    }

    function setMode(output, mode) {
        if (output && mode)
            apply.exec(["wlr-randr", "--output", output.name, "--mode", mode])
    }

    function setScale(output, scale) {
        if (output && scale)
            apply.exec(["wlr-randr", "--output", output.name, "--scale", String(scale)])
    }

    function setTransform(output, transform) {
        if (output && transform)
            apply.exec(["wlr-randr", "--output", output.name, "--transform", transform])
    }

    function logicalWidth(output) {
        if (!output)
            return 0
        var match = String(output.resolution || "").match(/^(\d+)x/)
        var scale = Number(output.scale)
        if (!match || !isFinite(scale) || scale <= 0)
            return 0
        return Math.round(Number(match[1]) / scale)
    }

    // Reposition active outputs together so layout selection is atomic.
    // The currently selected output is the anchor for the extended desktop.
    function setLayout(anchor, layout) {
        if (!anchor)
            return
        var active = outputs.filter(function(output) { return output.enabled })
        if (active.length < 2)
            return

        var others = active.filter(function(output) { return output.name !== anchor.name })
        var args = ["wlr-randr"]
        var x = 0

        if (layout === "Mirror") {
            for (var i = 0; i < active.length; i++)
                args.push("--output", active[i].name, "--pos", "0,0")
        } else if (layout === "Extend left") {
            for (var j = 0; j < others.length; j++) {
                args.push("--output", others[j].name, "--pos", `${x},0`)
                x += logicalWidth(others[j])
            }
            args.push("--output", anchor.name, "--pos", `${x},0`)
        } else {
            args.push("--output", anchor.name, "--pos", "0,0")
            x = logicalWidth(anchor)
            for (var k = 0; k < others.length; k++) {
                args.push("--output", others[k].name, "--pos", `${x},0`)
                x += logicalWidth(others[k])
            }
        }
        apply.exec(args)
    }

    function parse(text) {
        var next = []
        var current = null
        var lines = text.split("\n")

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var output = line.match(/^(\S+)\s+"([^"]*)"/)
            if (output) {
                current = {
                    name: output[1],
                    description: output[2],
                    make: "",
                    model: "",
                    enabled: false,
                    resolution: "No signal",
                    refresh: "",
                    modes: [],
                    scale: "1",
                    position: "",
                    transform: "normal"
                }
                next.push(current)
                continue
            }
            if (!current)
                continue

            var enabled = line.match(/^\s+Enabled:\s+(yes|no)$/)
            if (enabled) {
                current.enabled = enabled[1] === "yes"
                continue
            }
            var make = line.match(/^\s+Make:\s*(.+)$/)
            if (make) {
                current.make = make[1]
                continue
            }
            var model = line.match(/^\s+Model:\s*(.+)$/)
            if (model) {
                current.model = model[1]
                continue
            }
            var listedMode = line.match(/^\s+(\d+x\d+) px,\s*([\d.]+) Hz(?: \([^)]*\))?$/)
            if (listedMode) {
                current.modes.push({
                    resolution: listedMode[1],
                    refresh: Math.round(Number(listedMode[2]))
                })
            }
            var mode = line.match(/^\s+(\d+x\d+) px,\s*([\d.]+) Hz \([^)]*current[^)]*\)$/)
            if (mode) {
                current.resolution = mode[1]
                current.refresh = `${Math.round(Number(mode[2]))} Hz`
                continue
            }
            var scale = line.match(/^\s+Scale:\s*([\d.]+)$/)
            if (scale)
                current.scale = Number(scale[1]).toFixed(2).replace(/\.00$/, "")
            var position = line.match(/^\s+Position:\s*(.+)$/)
            if (position)
                current.position = position[1]
            var transform = line.match(/^\s+Transform:\s*(.+)$/)
            if (transform)
                current.transform = transform[1]
        }
        outputs = next
        loading = false
    }

    property var query: Process {
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    property var apply: Process {
        onRunningChanged: if (!running)
            refreshTimer.restart()
    }

    property var refreshTimer: Timer {
        id: refreshTimer
        interval: 350
        onTriggered: root.refresh()
    }
}
