import QtQuick
import Quickshell
import Quickshell.Io
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    required property bool active
    property bool recording: false
    readonly property var actions: [
        {
            id: "screenshotSave",
            label: qsTr("Screenshot"),
            icon: "",
            run: () => root.run(["hx-screenshot", "--save"])
        },
        {
            id: "screenshot",
            label: qsTr("Screenshot to clipboard"),
            icon: "",
            run: () => root.run(["hx-screenshot"])
        },
        {
            id: "ocr",
            label: qsTr("OCR"),
            icon: "󰈙",
            run: () => root.run(["hx-ocr"])
        },
        {
            id: "recordSilent",
            label: qsTr("Screenrecord without audio"),
            icon: "",
            run: () => root.run(["hx-record"])
        },
        {
            id: "recordDesktop",
            label: qsTr("Screenrecord with desktop audio"),
            icon: "",
            run: () => root.run(["hx-record", "--desktop-audio"])
        },
        {
            id: "recordMicrophone",
            label: qsTr("Screenrecord with desktop and microphone audio"),
            icon: "",
            run: () => root.run(["hx-record", "--audio"])
        },
        {
            id: "recordStop",
            label: qsTr("Stop recording"),
            icon: "",
            run: () => root.run(["hx-record", "--stop"])
        }
    ].filter(action => action.id !== "recordStop" || recording)

    function run(command: list<string>): void {
        popup.close();
        Quickshell.execDetached(command);
    }

    Process {
        id: status
        command: ["hx-record", "--status"]
        onExited: (exitCode, exitStatus) => root.recording = exitCode === 0
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: if (!status.running)
            status.running = true
    }
}
