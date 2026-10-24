import QtQuick
import Quickshell
import Quickshell.Io
import "files.js" as Utils

Item {
    id: root

    property var allItems: []
    readonly property var entries: Utils.search(allItems, query)
    property string query: ""
    property double lastScan: 0
    property Process scan: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                root.allItems = Utils.entries(text);
                root.lastScan = Date.now();
            }
        }
    }

    function open(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function refresh(): void {
        if (scan.running || Date.now() - lastScan < 30000)
            return;
        var home = Quickshell.env("HOME");
        scan.exec(["fd", "--type", "f", "--print0", "--hidden", "--exclude", ".git", "--exclude", ".cache", ".", home + "/Documents", home + "/Downloads", home + "/Pictures", home + "/Videos", home + "/Music"]);
    }
}
