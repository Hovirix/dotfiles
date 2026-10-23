import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var allItems: []
    readonly property var entries: query.trim() ? allItems.filter(function (path) {
        return path.toLowerCase().indexOf(query.trim().toLowerCase()) >= 0;
    }) : allItems
    property string query: ""
    property Process scan: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                root.allItems = lines.length === 1 && lines[0] === "" ? [] : lines;
            }
        }
    }

    function open(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function refresh(): void {
        allItems = [];
        scan.exec(["sh", "-c", "fd --type f --hidden --exclude .git --exclude .cache . \"$HOME/Documents\" \"$HOME/Downloads\" \"$HOME/Pictures\" \"$HOME/Videos\" \"$HOME/Music\" 2>/dev/null"]);
    }
}
