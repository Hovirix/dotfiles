import QtQuick
import Quickshell
import Quickshell.Wayland
import "AppSearch.js" as AppSearch

Item {
    id: root

    readonly property var entries: matches.map(function (row) {
        return row.entry;
    })
    readonly property var matches: AppSearch.sortedEntries(DesktopEntries.applications.values || [], query)
    property string query: ""
    readonly property var runningWindows: ToplevelManager.toplevels

    function icon(entry: DesktopEntry): string {
        var name = String((entry && entry.icon) || "");
        if (name.indexOf("file://") === 0 || name.indexOf("image://") === 0)
            return name;
        if (name.charAt(0) === "/")
            return "file://" + name;
        return Quickshell.iconPath(name || "application-x-executable", true);
    }

    function launch(entry: DesktopEntry): void {
        var id = String(entry.id).toLowerCase();
        var startupClass = String(entry.startupClass || "").toLowerCase();
        var webApp = "";
        // shortcut: host matching assumes one web app per host; use StartupWMClass if that changes.
        for (var argument of entry.command || []) {
            var match = /^--app=https?:\/\/([^/:?#]+)/.exec(argument);
            if (match) {
                webApp = "chrome-" + match[1].toLowerCase() + "_";
                break;
            }
        }
        for (var window of runningWindows.values || []) {
            var appId = String(window.appId || "").toLowerCase();
            if (appId === id || (startupClass && appId === startupClass) || (!startupClass && webApp && appId.indexOf(webApp) === 0)) {
                window.activate();
                return;
            }
        }
        entry.execute();
    }

    Component.onCompleted: console.assert(AppSearch.sortedEntries([
        {
            name: "Terminal",
            genericName: "Shell",
            id: "terminal"
        }
    ], "shell").length === 1 && AppSearch.sortedEntries([
        {
            name: "Foot Browser",
            id: "foot-browser"
        }
    ], "fb").length === 1, "app search self-check failed")
}
