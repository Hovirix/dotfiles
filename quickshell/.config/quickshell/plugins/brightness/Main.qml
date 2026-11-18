import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string monitor: ""
    property real value: 0
    property string bus: ""
    property int maximum: 0
    property int confirmed: 0
    property int target: 0
    property int pendingSteps: 0
    property string runningOperation: ""
    property int runningTarget: 0
    property int monitorGeneration: 0
    property int runningGeneration: 0
    readonly property var actions: [
        {
            id: "brightnessUp",
            label: qsTr("Increase brightness"),
            icon: "󰍹",
            run: () => root.increase()
        },
        {
            id: "brightnessDown",
            label: qsTr("Decrease brightness"),
            icon: "󰍹",
            run: () => root.decrease()
        }
    ]
    signal adjusted

    property Process query: Process {
        property string output: ""
        stdout: StdioCollector {
            onStreamFinished: query.output = text.trim()
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim())
                console.warn("Brightness:", text.trim())
        }
        onExited: (exitCode, exitStatus) => {
            const operation = root.runningOperation;
            root.runningOperation = "";
            if (root.runningGeneration !== root.monitorGeneration) {
                root.runNext();
                return;
            }
            const parts = query.output.split(" ");
            const current = Number(parts[0]), maximum = Number(parts[1]);
            if (exitCode !== 0 || exitStatus !== 0 || parts.length !== 3 || !Number.isInteger(current) || !Number.isInteger(maximum) || maximum <= 0 || current < 0 || current > maximum) {
                root.maximum = 0;
                root.pendingSteps = 0;
                if (operation === "set")
                    root.runNext();
                return;
            }
            root.bus = parts[2];
            root.maximum = maximum;
            root.confirmed = current;
            if (operation === "get") {
                root.target = current;
                root.applySteps();
            }
            root.value = root.target / root.maximum;
            root.runNext();
        }
    }

    function applySteps(): void {
        const step = Math.max(1, Math.round(maximum / 20));
        target = Math.max(0, Math.min(maximum, target + pendingSteps * step));
        pendingSteps = 0;
        value = target / maximum;
    }

    function runNext(): void {
        if (!monitor || runningOperation)
            return;
        runningGeneration = monitorGeneration;
        runningOperation = maximum ? (target !== confirmed ? "set" : "") : "get";
        if (!runningOperation)
            return;
        runningTarget = target;
        query.output = "";
        query.exec(["bash", decodeURIComponent(Qt.resolvedUrl("backend.sh").toString().slice(7)), monitor, runningOperation, bus, String(maximum), String(runningTarget)]);
    }

    function request(direction: int): void {
        if (!monitor)
            return;
        pendingSteps += direction;
        if (maximum)
            applySteps();
        runNext();
        adjusted();
    }

    function decrease(): void {
        request(-1);
    }
    function increase(): void {
        request(1);
    }

    onMonitorChanged: {
        monitorGeneration++;
        maximum = 0;
        bus = "";
        pendingSteps = 0;
        value = 0;
        runNext();
    }
}
