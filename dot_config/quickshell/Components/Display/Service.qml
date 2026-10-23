import QtQuick
import "utils.js" as Utils
import Quickshell.Io

// Live wlroots output state, queried and changed through wlr-randr.
QtObject {
    id: root

    property Process apply: Process {
        onRunningChanged: if (!running)
            refreshTimer.restart()
    }
    readonly property int enabledCount: {
        var count = 0;
        for (var i = 0; i < outputs.length; i++) {
            if (outputs[i].enabled)
                count++;
        }
        return count;
    }
    property bool loading: false
    property var outputs: []
    property Process query: Process {
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }
    property Timer refreshTimer: Timer {
        id: refreshTimer

        interval: 350

        onTriggered: root.refresh()
    }

    function parse(text: string): void {
        outputs = Utils.parse(text);
        loading = false;
    }

    function refresh(): void {
        if (query.running)
            return;
        loading = true;
        query.exec(["wlr-randr"]);
    }

    // Reposition active outputs together so layout selection is atomic.
    // The currently selected output is the anchor for the extended desktop.
    function setLayout(anchor: var, layout: string): void {
        if (!anchor)
            return;
        var active = outputs.filter(function (output) {
            return output.enabled;
        });
        if (active.length < 2)
            return;
        var others = active.filter(function (output) {
            return output.name !== anchor.name;
        });
        var args = ["wlr-randr"];
        var x = 0;

        if (layout === "Mirror") {
            for (var i = 0; i < active.length; i++)
                args.push("--output", active[i].name, "--pos", "0,0");
        } else if (layout === "Extend left") {
            for (var j = 0; j < others.length; j++) {
                args.push("--output", others[j].name, "--pos", `${x},0`);
                x += Utils.logicalWidth(others[j]);
            }
            args.push("--output", anchor.name, "--pos", `${x},0`);
        } else {
            args.push("--output", anchor.name, "--pos", "0,0");
            x = Utils.logicalWidth(anchor);
            for (var k = 0; k < others.length; k++) {
                args.push("--output", others[k].name, "--pos", `${x},0`);
                x += Utils.logicalWidth(others[k]);
            }
        }
        apply.exec(args);
    }

    function setMode(output: var, mode: string): void {
        if (output && mode)
            apply.exec(["wlr-randr", "--output", output.name, "--mode", mode]);
    }

    function setOutputEnabled(output: var, enabled: bool): void {
        if (!output || (!enabled && output.enabled && enabledCount <= 1))
            return;
        apply.exec(["wlr-randr", "--output", output.name, enabled ? "--on" : "--off"]);
    }

    function setScale(output: var, scale: string): void {
        if (output && scale)
            apply.exec(["wlr-randr", "--output", output.name, "--scale", String(scale)]);
    }

    function setTransform(output: var, transform: string): void {
        if (output && transform)
            apply.exec(["wlr-randr", "--output", output.name, "--transform", transform]);
    }

    function toggleOutput(output: var): void {
        if (!output)
            return;
        setOutputEnabled(output, !output.enabled);
    }
}
