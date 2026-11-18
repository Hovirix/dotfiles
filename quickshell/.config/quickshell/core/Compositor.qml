import QtQuick
import Quickshell
import Quickshell.Io
import "compositor.js" as Utils

Scope {
    id: root

    property string focusedMonitor: ""
    readonly property var focusedScreen: Quickshell.screens.find(output => output.name === focusedMonitor) || Quickshell.screens[0] || null

    Process {
        id: watch
        command: ["mmsg", "watch", "all-monitors"]
        running: true
        stdout: SplitParser {
            onRead: data => root.focusedMonitor = Utils.focusedMonitor(data)
        }
        onExited: {
            root.focusedMonitor = "";
            reconnect.restart();
        }
    }

    Timer {
        id: reconnect
        interval: 2000
        onTriggered: watch.running = true
    }
}
