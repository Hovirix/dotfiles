import QtQuick
import Quickshell

Image {
    id: root

    readonly property var candidates: fallback ? sources.concat([fallback]) : sources
    property int failed: 0
    property string fallback: ""
    readonly property var resolvedSources: candidates.map(resolve).filter(function (value) {
        return value !== "";
    })
    property var sources: []

    function resolve(value): string {
        var source = String(value || "");
        if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0)
            return source;
        if (source.charAt(0) === "/")
            return "file://" + source;
        return source ? Quickshell.iconPath(source, true) : "";
    }

    asynchronous: true
    fillMode: Image.PreserveAspectFit
    source: resolvedSources[failed] || ""
    sourceSize.height: height * Screen.devicePixelRatio
    sourceSize.width: width * Screen.devicePixelRatio

    onResolvedSourcesChanged: failed = 0
    onStatusChanged: if (status === Image.Error && failed < resolvedSources.length)
        failed++
}
