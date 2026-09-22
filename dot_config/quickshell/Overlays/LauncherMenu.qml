import QtQuick
import Quickshell
import Quickshell.Io

import "../Appearance" as A
import "../Ui" as Ui

Item {
    id: root

    required property var controller

    property string mode: ""
    property string query: ""
    property int selectedIndex: 0
    property var allItems: []

    readonly property var emojis: [
        "😀  grinning face", "😂  joy", "😍  heart eyes", "😎  sunglasses",
        "🤔  thinking", "🥳  partying", "😴  sleepy", "😭  loudly crying",
        "😡  angry", "🤯  exploding head", "💀  skull", "👻  ghost",
        "🤖  robot", "👽  alien", "👍  thumbs up", "👎  thumbs down",
        "👏  clapping", "🙏  folded hands", "💪  flexed biceps", "🔥  fire",
        "✨  sparkles", "⭐  star", "💯  hundred points", "✅  check mark",
        "❌  cross mark", "⚡  lightning", "🎉  party popper", "🚀  rocket",
        "💡  light bulb", "☕  hot beverage", "🍕  pizza", "🎵  musical note"
    ]
    readonly property var screenshotItems: [
        "󰆏  Copy selection", "󰹑  Save selection",
        "  Copy screen", "󰍹  Save screen"
    ]
    readonly property var filteredItems: {
        var needle = query.trim().toLowerCase()
        if (mode === "apps")
            return applicationItems(needle)
        if (!needle)
            return allItems
        return allItems.filter(function(item) {
            return String(item).toLowerCase().indexOf(needle) >= 0
        })
    }
    readonly property int pageSize: mode === "emoji" ? 16 : 12
    readonly property int pageStart: Math.floor(selectedIndex / pageSize) * pageSize
    readonly property var visibleItems: filteredItems.slice(pageStart, pageStart + pageSize)

    function applicationText(entry) {
        var keywords = ""
        try {
            keywords = entry.keywords.join(" ")
        } catch (error) {
        }
        return [entry.name, entry.genericName, entry.comment, keywords, entry.id].join(" ").toLowerCase()
    }

    function applicationItems(needle) {
        var values = DesktopEntries.applications.values || []
        var entries = []
        for (var index = 0; index < values.length; index++)
            entries.push(values[index])
        entries = entries.filter(function(entry) {
            return entry && entry.name && !entry.noDisplay
                && (!needle || applicationText(entry).indexOf(needle) >= 0)
        })
        entries.sort(function(left, right) {
            var leftName = String(left.name).toLowerCase()
            var rightName = String(right.name).toLowerCase()
            if (needle) {
                var leftAt = leftName.indexOf(needle)
                var rightAt = rightName.indexOf(needle)
                var leftScore = leftAt === 0 ? 0 : (leftAt > 0 ? 1 : 2)
                var rightScore = rightAt === 0 ? 0 : (rightAt > 0 ? 1 : 2)
                if (leftScore !== rightScore)
                    return leftScore - rightScore
            }
            return leftName.localeCompare(rightName)
        })
        return entries
    }

    function applicationIcon(entry) {
        var icon = String((entry && entry.icon) || "")
        if (icon.indexOf("file://") === 0 || icon.indexOf("image://") === 0)
            return icon
        if (icon.charAt(0) === "/")
            return "file://" + icon
        return Quickshell.iconPath(icon || "application-x-executable", true)
    }

    function open(nextMode) {
        mode = nextMode
        query = ""
        selectedIndex = 0
        allItems = nextMode === "emoji" ? emojis : nextMode === "screenshot" ? screenshotItems : []
        controller.current = "launcher"
        if (nextMode === "open") {
            recentQuery.exec(["sh", "-c",
                "fd --type f --hidden --exclude .git --exclude .cache . \"$HOME/Documents\" \"$HOME/Downloads\" \"$HOME/Pictures\" \"$HOME/Videos\" \"$HOME/Music\" 2>/dev/null"])
        }
    }

    function setQuery(next) {
        query = next
        selectedIndex = 0
    }

    function move(dx, dy) {
        var delta = mode === "emoji" ? (dy !== 0 ? dy * 4 : dx) : dy
        if (delta === 0 || filteredItems.length === 0)
            return
        selectedIndex = Math.max(0, Math.min(filteredItems.length - 1, selectedIndex + delta))
    }

    function fileName(path) {
        var parts = String(path).split("/")
        return parts[parts.length - 1]
    }

    function fileIcon(path) {
        var name = fileName(path).toLowerCase()
        var ext = name.indexOf(".") >= 0 ? name.split(".").pop() : ""
        if (["jpg", "jpeg", "png", "webp", "gif", "svg", "bmp", "avif"].indexOf(ext) >= 0) return ""
        if (["mp4", "mkv", "webm", "mov", "avi"].indexOf(ext) >= 0) return "󰕧"
        if (["mp3", "flac", "wav", "ogg", "m4a"].indexOf(ext) >= 0) return ""
        if (["pdf", "epub", "djvu", "ps"].indexOf(ext) >= 0) return ""
        if (["md", "txt", "log"].indexOf(ext) >= 0) return "󰍔"
        if (["doc", "docx", "odt", "rtf"].indexOf(ext) >= 0) return "󰈬"
        if (["xls", "xlsx", "ods", "csv"].indexOf(ext) >= 0) return "󰈛"
        if (["zip", "tar", "gz", "xz", "7z", "rar"].indexOf(ext) >= 0) return ""
        return "󰈙"
    }

    function activate() {
        if (filteredItems.length === 0)
            return
        var item = filteredItems[selectedIndex]
        if (mode === "emoji") {
            copy.exec(["wl-copy", item.substring(0, item.indexOf("  "))])
        } else if (mode === "open") {
            openFile.exec(["xdg-open", item])
        } else if (mode === "apps") {
            item.execute()
        } else {
            if (selectedIndex === 0) capture.exec(["grimlite", "--notify", "copy", "anything"])
            if (selectedIndex === 1) capture.exec(["grimlite", "--notify", "save", "anything"])
            if (selectedIndex === 2) capture.exec(["grimlite", "--notify", "copy", "screen"])
            if (selectedIndex === 3) capture.exec(["grimlite", "--notify", "save", "screen"])
        }
        controller.close()
    }

    property var recentQuery: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                root.allItems = lines.length === 1 && lines[0] === "" ? [] : lines
            }
        }
    }
    property var copy: Process {}
    property var openFile: Process {}
    property var capture: Process {}

    Ui.Popup {
        visible: root.controller.current === "launcher"
        contentWidth: root.mode === "emoji"
            ? A.Appearance.popupWidthCompact
            : (root.mode === "open"
                ? A.Appearance.popupWidthWide
                : A.Appearance.popupWidthStandard)
        contentHeight: panel.implicitHeight + A.Appearance.dialogPadding * 2
        onCloseRequested: root.controller.close()
        onVisibleChanged: if (visible)
            Qt.callLater(function() { keys.forceActiveFocus() })

        Ui.KeyCatcher {
            id: keys
            anchors.fill: parent
            vimNavigation: false
            spaceActivates: root.mode === "screenshot"
            onMoveRequested: function(dx, dy) { root.move(dx, dy) }
            onActivateRequested: root.activate()
            onCloseRequested: root.controller.close()
            onBackspaceRequested: root.setQuery(root.query.slice(0, -1))
            onTextKey: function(text) {
                if (root.mode !== "screenshot" && text.length === 1)
                    root.setQuery(root.query + text)
            }

            Column {
                id: panel
                width: parent.width
                spacing: A.Appearance.space2

                Item {
                    visible: root.mode !== "screenshot"
                    width: parent.width
                    height: A.Appearance.buttonHeight

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.mode === "emoji" ? "Search:" : (root.mode === "apps" ? "Launch:" : "Open:")
                        color: A.Appearance.mutedForeground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        font.weight: A.Appearance.fontWeightMedium
                        renderType: Text.NativeRendering
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: root.mode === "emoji" ? 76 : (root.mode === "apps" ? 74 : 54)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.query + "▌"
                        color: A.Appearance.foreground
                        font.family: A.Appearance.fontFamily
                        font.pixelSize: A.Appearance.fontSizeTitle
                        elide: Text.ElideRight
                        renderType: Text.NativeRendering
                    }
                }

                Ui.Separator { visible: root.mode !== "screenshot"; width: parent.width }

                Text {
                    visible: root.filteredItems.length === 0
                    width: parent.width
                    height: 40
                    text: root.mode === "open" ? "No files"
                        : (root.mode === "apps" ? "No applications" : "No emoji")
                    color: A.Appearance.mutedForeground
                    font.family: A.Appearance.fontFamily
                    font.pixelSize: A.Appearance.fontSizeBody
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                }

                Grid {
                    visible: root.mode === "emoji"
                    width: parent.width
                    columns: 4
                    columnSpacing: A.Appearance.space1
                    rowSpacing: A.Appearance.space1

                    Repeater {
                        model: root.mode === "emoji" ? root.visibleItems : []
                        Ui.SelectRow {
                            required property var modelData
                            required property int index
                            width: (parent.width - A.Appearance.space1 * 3) / 4
                            height: 48
                            hasCursor: root.selectedIndex === root.pageStart + index
                            Text {
                                anchors.centerIn: parent
                                text: String(modelData).split("  ")[0]
                                color: A.Appearance.foreground
                                font.pixelSize: 24
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }

                Column {
                    visible: root.mode !== "emoji"
                    width: parent.width
                    spacing: A.Appearance.space1

                    Repeater {
                        model: root.mode !== "emoji" ? root.visibleItems : []
                        Ui.SelectRow {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: root.mode === "apps" ? (root.query.length > 0 ? 48 : 42) : 38
                            hasCursor: root.selectedIndex === root.pageStart + index
                            contentPadding: root.mode === "apps" ? 0 : A.Appearance.space2

                            Text {
                                id: rowIcon
                                visible: root.mode !== "apps"
                                anchors.left: parent.left
                                anchors.leftMargin: A.Appearance.space2
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.mode === "open" ? root.fileIcon(modelData) : String(modelData).split("  ")[0]
                                color: hasCursor ? A.Appearance.primary : A.Appearance.mutedForeground
                                font.family: A.Appearance.fontFamily
                                font.pixelSize: A.Appearance.iconSize
                                renderType: Text.NativeRendering
                            }

                            Image {
                                id: appIcon
                                visible: root.mode === "apps"
                                width: 28
                                height: 28
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                source: visible ? root.applicationIcon(modelData) : ""
                                sourceSize.width: width
                                sourceSize.height: height
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Column {
                                anchors.left: root.mode === "apps" ? appIcon.right : rowIcon.right
                                anchors.leftMargin: A.Appearance.space3
                                anchors.right: parent.right
                                anchors.rightMargin: A.Appearance.space2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    width: parent.width
                                    text: root.mode === "open" ? root.fileName(modelData)
                                        : (root.mode === "apps" ? modelData.name : modelData.substring(modelData.indexOf("  ") + 2))
                                    color: A.Appearance.foreground
                                    font.family: A.Appearance.fontFamily
                                    font.pixelSize: root.mode === "apps"
                                        ? A.Appearance.fontSizeTitle
                                        : A.Appearance.fontSizeBody
                                    elide: root.mode === "open" ? Text.ElideMiddle : Text.ElideRight
                                    renderType: Text.NativeRendering
                                }
                                Text {
                                    visible: root.mode === "apps" && root.query.length > 0 && String(modelData.genericName || "").length > 0
                                    width: parent.width
                                    text: visible ? modelData.genericName : ""
                                    color: A.Appearance.mutedForeground
                                    font.family: A.Appearance.fontFamily
                                    font.pixelSize: A.Appearance.fontSizeLabel
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
