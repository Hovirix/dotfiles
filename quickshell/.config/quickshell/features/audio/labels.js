function isPlaybackStream(node) {
    if (!node || !node.isStream)
        return false;
    if (node.isSink === true)
        return true;

    var mediaClass = String(node.type || "");
    return mediaClass.indexOf("Stream/Output/Audio") !== -1 || mediaClass.indexOf("AudioOutStream") !== -1 || mediaClass.indexOf("Output") !== -1;
}

function isAudioSource(node) {
    if (!node)
        return false;
    if (node.audio)
        return true;

    var mediaClass = String(node.type || "");
    return mediaClass.indexOf("Audio/Source") !== -1 || mediaClass.indexOf("AudioSource") !== -1 || mediaClass.indexOf("Source") !== -1;
}

function outputVolumeName(volume, muted) {
    if (muted)
        return qsTr("Muted");
    var p = Math.round(volume * 100);
    if (p === 0)
        return qsTr("Silenced");
    if (p >= 100)
        return qsTr("Concert hall");
    if (p >= 85)
        return qsTr("Party mode");
    if (p >= 70)
        return qsTr("Cranked up");
    if (p >= 50)
        return qsTr("Steady groove");
    if (p >= 30)
        return qsTr("Easy listening");
    if (p >= 15)
        return qsTr("Murmur");
    return qsTr("Whisper");
}

function friendlyDeviceLabel(text) {
    var label = String(text || "").trim();
    label = label.replace(/^sof-soundwire\s+/i, "");
    label = label.replace(/^built-?in audio\s+/i, "");
    label = label.replace(/\s+Output$/i, "");
    label = label.replace(/\s+Input$/i, "");
    label = label.replace(/\bMicrophones\b/g, "Microphone");
    return label;
}

function nodeProps(node) {
    return node && node.ready && node.properties ? node.properties : {};
}

function nodeLabel(node) {
    if (!node)
        return qsTr("Unknown");
    var p = nodeProps(node);
    var nickname = friendlyDeviceLabel(node.nickname || node.nick || p["node.nick"] || p["device.profile.description"] || "");
    if (nickname)
        return nickname;
    return friendlyDeviceLabel(node.description || p["node.description"] || node.name || qsTr("Unknown"));
}

function nodeBlob(node) {
    if (!node)
        return "";
    var p = nodeProps(node);
    return String([node.name, node.description, node.nickname, node.nick, p["device.icon-name"] || "", p["device.product.name"] || "", p["node.description"] || "", p["node.nick"] || ""].join(" ")).toLowerCase();
}

function isHeadphones(node) {
    if (!node)
        return false;
    var blob = nodeBlob(node);
    return blob.indexOf("headphone") !== -1 || blob.indexOf("headset") !== -1 || blob.indexOf("earbud") !== -1 || blob.indexOf("earphone") !== -1 || blob.indexOf("airpod") !== -1;
}

function sinkGlyph(node) {
    if (!node)
        return "󰓃";
    if (isHeadphones(node))
        return "󰋋";
    var blob = nodeBlob(node);
    if (blob.indexOf("bluetooth") !== -1)
        return "󰂯";
    if (blob.indexOf("hdmi") !== -1 || blob.indexOf("display") !== -1)
        return "󰍹";
    return "󰓃";
}

function sourceGlyph(node) {
    if (!node)
        return "󰍬";
    var blob = nodeBlob(node);
    if (blob.indexOf("headset") !== -1)
        return "󰋋";
    if (blob.indexOf("bluetooth") !== -1)
        return "󰂯";
    if (blob.indexOf("webcam") !== -1 || blob.indexOf("camera") !== -1)
        return "󰄀";
    return "󰍬";
}

function friendlyStreamLabel(label) {
    label = String(label || "").trim();
    if (!label)
        return "";
    if (label.toLowerCase() === "spotify")
        return "Spotify";
    return label;
}

function streamLabelKey(label) {
    return String(label || "").trim().toLowerCase();
}

function streamLabelIsGeneric(label) {
    return streamLabelKey(label) === "audio-src";
}

function rawStreamLabel(node) {
    if (!node)
        return "";
    var p = nodeProps(node);
    return p["application.name"] || node.description || p["media.name"] || p["node.name"] || node.name;
}

function streamRepresentsMprisPlayer(streamLabel, playerLabel) {
    var streamKey = streamLabelKey(friendlyStreamLabel(streamLabel));
    var playerKey = streamLabelKey(playerLabel);
    if (!streamKey || !playerKey)
        return false;
    return streamKey === playerKey || streamKey.indexOf(playerKey) !== -1 || playerKey.indexOf(streamKey) !== -1;
}

function mprisLabelsFor(players, predicate) {
    var values = Array.isArray(players) ? players : [];
    var playingCandidates = [];
    var candidates = [];
    var playingProxyCandidates = [];
    var proxyCandidates = [];

    for (var i = 0; i < values.length; i++) {
        var player = values[i];
        if (!player)
            continue;
        if (!player.isPlaying && !player.canPlay)
            continue;
        var playerLabel = player ? friendlyStreamLabel(player.identity || player.desktopEntry || "") : "";
        if (!playerLabel || !predicate(playerLabel))
            continue;
        var dbusName = String(player.dbusName || "").toLowerCase();
        var isProxy = dbusName.indexOf("playerctld") !== -1 || String(player.desktopEntry || "").toLowerCase() === "playerctld";
        if (isProxy) {
            if (player.isPlaying)
                playingProxyCandidates.push(playerLabel);
            proxyCandidates.push(playerLabel);
        } else {
            if (player.isPlaying)
                playingCandidates.push(playerLabel);
            candidates.push(playerLabel);
        }
    }

    if (playingCandidates.length === 1)
        return playingCandidates[0];
    if (playingCandidates.length === 0 && playingProxyCandidates.length === 1)
        return playingProxyCandidates[0];
    if (candidates.length === 1)
        return candidates[0];
    if (candidates.length === 0 && proxyCandidates.length === 1)
        return proxyCandidates[0];
    return "";
}

function matchingMprisStreamLabel(label, players) {
    if (streamLabelIsGeneric(label))
        return "";
    return mprisLabelsFor(players, function (playerLabel) {
        return streamRepresentsMprisPlayer(label, playerLabel);
    });
}

function unmatchedMprisStreamLabel(label, players, streams) {
    if (!streamLabelIsGeneric(label))
        return "";

    return mprisLabelsFor(players, function (playerLabel) {
        var values = Array.isArray(streams) ? streams : [];
        for (var i = 0; i < values.length; i++) {
            var stream = values[i];
            var streamLabel = rawStreamLabel(stream);
            if (!streamLabelIsGeneric(streamLabel) && streamRepresentsMprisPlayer(streamLabel, playerLabel))
                return false;
        }
        return true;
    });
}

function streamLabel(node, players, streams) {
    if (!node)
        return qsTr("Stream");
    var label = rawStreamLabel(node);
    return friendlyStreamLabel(matchingMprisStreamLabel(label, players) || unmatchedMprisStreamLabel(label, players, streams) || label) || qsTr("Stream");
}
