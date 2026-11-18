pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../core" as Core

Scope {
    id: root

    required property Core.Popup popup
    property string token: ""
    property var sources: []
    property string result: "pending"

    function dismiss(): void {
        if (popup.content === panel)
            popup.close();
        token = "";
        sources = [];
        lease.stop();
    }

    function finish(index: int): void {
        if (result !== "pending")
            return;
        result = index >= 0 && index < sources.length ? String(index) : "cancelled";
        if (popup.content === panel) {
            if (result === "cancelled")
                popup.back();
            else
                popup.close();
        }
    }

    Timer {
        id: lease
        interval: 5000
        onTriggered: root.dismiss()
    }

    IpcHandler {
        target: "sharePicker"

        function open(token: string, text: string): string {
            if (root.token || !/^share-picker\.[a-zA-Z0-9-]+$/.test(token) || !text || text.length > 65536)
                return "rejected";
            var lines = text.split("\n");
            if (lines.some(line => !line || line.includes("\r")))
                return "rejected";
            root.token = token;
            root.sources = lines;
            root.result = "pending";
            lease.restart();
            root.popup.open(panel);
            return "ready";
        }

        function poll(token: string): string {
            if (token !== root.token || !root.token)
                return "unknown";
            lease.restart();
            return root.result;
        }

        function dismiss(token: string): void {
            if (token === root.token)
                root.dismiss();
        }
    }

    Connections {
        target: root.popup
        function onContentChanged() {
            if (root.popup.content !== panel && root.token && root.result === "pending")
                root.result = "cancelled";
        }
    }

    Component {
        id: panel
        Panel {
            sources: root.sources
            onSelected: index => root.finish(index)
            onCancelled: root.finish(-1)
        }
    }
}
