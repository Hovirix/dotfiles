function icon(path) {
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

function name(path) {
    return path.slice(path.lastIndexOf("/") + 1);
}

function entries(text) {
    var paths = text.split("\0");
    if (paths[paths.length - 1] === "")
        paths.pop();
    return paths.map(function (path) {
        return {kind: "file", label: name(path), path: path, searchText: path.toLowerCase()};
    });
}

function search(items, query) {
    var needle = query.trim().toLowerCase();
    return needle ? items.filter(function (item) { return item.searchText.indexOf(needle) >= 0; }) : items;
}
