import QtQuick
import "../../core" as Core
import "outputs.js" as Utils
import Quickshell.Io

// Live wlroots output state, queried and changed through wlr-randr.
QtObject {
    id: root

    property Process applyProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.loading = false;
            if (root.reverting) {
                root.reverting = false;
                if (exitCode === 0 && exitStatus === 0) {
                    root.previousOutputs = [];
                    root.error = "";
                } else {
                    root.error = qsTr("Could not restore displays. Try Revert again.");
                }
            } else if (exitCode !== 0 || exitStatus !== 0) {
                root.error = qsTr("Display change failed; restoring previous settings.");
                Qt.callLater(root.revert);
            } else if (root.revertRequested) {
                Qt.callLater(root.revert);
            }
            refreshTimer.restart();
        }
    }
    property var previousOutputs: []
    readonly property bool pending: previousOutputs.length > 0
    property int secondsRemaining: 0
    property bool reverting: false
    property bool revertRequested: false
    property string error: ""
    property Timer confirmationTimer: Timer {
        interval: 1000
        repeat: true
        onTriggered: {
            root.secondsRemaining--;
            if (root.secondsRemaining <= 0)
                root.revert();
        }
    }

    function keep(): void {
        if (!pending || loading || reverting)
            return;
        confirmationTimer.stop();
        previousOutputs = [];
        error = "";
    }

    function revert(): void {
        if (!pending || reverting)
            return;
        confirmationTimer.stop();
        if (applyProcess.running || query.running) {
            revertRequested = true;
            return;
        }
        revertRequested = false;
        reverting = true;
        loading = true;
        applyProcess.exec(Utils.restoreCommand(previousOutputs));
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
    readonly property Component panel: Component {
        Panel {
            controller: root.popup
            display: root
        }
    }
    required property Core.Popup popup
    readonly property var actions: [
        {
            id: "display",
            label: qsTr("Display"),
            icon: "󰍹",
            run: () => root.open()
        }
    ]

    function open(): void {
        popup.toggle(panel);
        if (popup.content === panel)
            refresh();
    }
    property Process query: Process {
        onExited: if (root.revertRequested)
            Qt.callLater(root.revert)
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
        if (revertRequested)
            revert();
    }

    function refresh(): void {
        if (query.running || applyProcess.running)
            return;
        loading = true;
        query.exec(["wlr-randr"]);
    }

    function applyChanges(command: list<string>): void {
        if (pending || loading || query.running || applyProcess.running || !outputs.some(output => output.enabled))
            return;
        previousOutputs = outputs.map(output => Object.assign({}, output));
        error = "";
        secondsRemaining = 15;
        confirmationTimer.start();
        loading = true;
        applyProcess.exec(command);
    }

    // Reposition active outputs together so layout selection is atomic.
    // The currently selected output is the anchor for the extended desktop.
    function setLayout(anchor: var, layout: string): void {
        if (!anchor || !anchor.enabled || ["Mirror", "Extend left", "Extend right"].indexOf(layout) < 0)
            return;
        var active = outputs.filter(function (output) {
            return output.enabled;
        });
        if (active.length < 2)
            return;
        if (active.some(function (output) {
            return Utils.logicalWidth(output) <= 0;
        }))
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
        applyChanges(args);
    }

    function setMode(output: var, mode: string): void {
        if (output && mode)
            applyChanges(["wlr-randr", "--output", output.name, "--mode", mode]);
    }

    function setOutputEnabled(output: var, enabled: bool): void {
        if (!output || (!enabled && output.enabled && enabledCount <= 1))
            return;
        applyChanges(["wlr-randr", "--output", output.name, enabled ? "--on" : "--off"]);
    }

    function setScale(output: var, scale: string): void {
        if (output && scale)
            applyChanges(["wlr-randr", "--output", output.name, "--scale", String(scale)]);
    }

    function setTransform(output: var, transform: string): void {
        if (output && transform)
            applyChanges(["wlr-randr", "--output", output.name, "--transform", transform]);
    }

    function toggleOutput(output: var): void {
        if (!output)
            return;
        setOutputEnabled(output, !output.enabled);
    }
}
