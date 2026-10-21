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

    function icon(path: string): string {
        var filename = name(path).toLowerCase();
        var ext = filename.indexOf(".") >= 0 ? filename.split(".").pop() : "";
        if (["jpg", "jpeg", "png", "webp", "gif", "svg", "bmp", "avif"].indexOf(ext) >= 0)
            return "";
        if (["mp4", "mkv", "webm", "mov", "avi"].indexOf(ext) >= 0)
            return "󰕧";
        if (["mp3", "flac", "wav", "ogg", "m4a"].indexOf(ext) >= 0)
            return "";
        if (["pdf", "epub", "djvu", "ps"].indexOf(ext) >= 0)
            return "";
        if (["md", "txt", "log"].indexOf(ext) >= 0)
            return "󰍔";
        if (["doc", "docx", "odt", "rtf"].indexOf(ext) >= 0)
            return "󰈬";
        if (["xls", "xlsx", "ods", "csv"].indexOf(ext) >= 0)
            return "󰈛";
        if (["zip", "tar", "gz", "xz", "7z", "rar"].indexOf(ext) >= 0)
            return "";
        return "󰈙";
    }

    function name(path: string): string {
        var parts = String(path).split("/");
        return parts[parts.length - 1];
    }

    function open(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function refresh(): void {
        allItems = [];
        scan.exec(["sh", "-c", "fd --type f --hidden --exclude .git --exclude .cache . \"$HOME/Documents\" \"$HOME/Downloads\" \"$HOME/Pictures\" \"$HOME/Videos\" \"$HOME/Music\" 2>/dev/null"]);
    }
}
