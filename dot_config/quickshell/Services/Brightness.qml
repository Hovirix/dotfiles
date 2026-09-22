import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property real step: 0.05
    property real value: 0

    function increase(): void {
        query.exec(["brightnessctl", "set", `+${Math.round(step * 100)}%`, "-m"])
    }

    function decrease(): void {
        query.exec(["brightnessctl", "set", `${Math.round(step * 100)}%-`, "-m"])
    }

    Component.onCompleted: query.exec(["brightnessctl", "-m"])

    property var query: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.trim().match(/(\d+(?:\.\d+)?)%/)
                if (match)
                    root.value = Math.max(0, Math.min(1, Number(match[1]) / 100))
            }
        }
    }
}
