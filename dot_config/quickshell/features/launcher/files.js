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
    var parts = String(path).split("/");
    return parts[parts.length - 1];
}

