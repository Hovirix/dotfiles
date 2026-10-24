import QtQuick
import Quickshell
import Quickshell.Io
import "files.js" as Utils

Item {
    id: root

    property var allItems: []
    readonly property var entries: Utils.search(allItems, query)
    property string query: ""
    property Process scan: Process {
        stdout: StdioCollector {
            onStreamFinished: root.allItems = Utils.entries(text)
        }
    }

    function open(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function refresh(): void {
        if (!scan.running)
            scan.exec(["sh", "-c", "exec fd --type f --print0 --hidden --exclude .git --exclude .cache . \"$HOME/Documents\" \"$HOME/Downloads\" \"$HOME/Pictures\" \"$HOME/Videos\" \"$HOME/Music\" 2>/dev/null"]);
    }
}
