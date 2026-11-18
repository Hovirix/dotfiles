import QtQuick
import Quickshell
import Quickshell.Wayland
import "apps.js" as Utils

Item {
    id: root

    readonly property var matches: Utils.matchEntries(DesktopEntries.applications.values || [], query)
    property string query: ""
    readonly property var runningWindows: ToplevelManager.toplevels

    function launch(entry: DesktopEntry): void {
        if (!focusExisting(entry))
            entry.execute();
    }

    function focusExisting(entry: DesktopEntry): bool {
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
                return true;
            }
        }
        return false;
    }

    Component.onCompleted: console.assert(Utils.matchEntries([
        {
            name: "Terminal",
            genericName: "Shell",
            id: "terminal"
        }
    ], "shell").length === 1 && Utils.matchEntries([
        {
            name: "Foot Browser",
            id: "foot-browser"
        }
    ], "fb").length === 1, "app search self-check failed")
}
