import QtQuick
import Quickshell

Image {
    id: root

    property var sources: []
    property string fallback: ""
    property int failed: 0
    readonly property var candidates: fallback ? sources.concat([fallback]) : sources
    readonly property var resolvedSources: candidates.map(resolve).filter(function(value) { return value !== ""; })

    function resolve(value): string {
        var source = String(value || "");
        if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0) return source;
        if (source.charAt(0) === "/") return "file://" + source;
        return source ? Quickshell.iconPath(source, true) : "";
    }

    source: resolvedSources[failed] || ""
    asynchronous: true
    fillMode: Image.PreserveAspectFit
    sourceSize.width: width * Screen.devicePixelRatio
    sourceSize.height: height * Screen.devicePixelRatio
    onResolvedSourcesChanged: failed = 0
    onStatusChanged: if (status === Image.Error && failed < resolvedSources.length) failed++
}
