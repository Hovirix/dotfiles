//@ pragma IconTheme Papirus-Dark
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "core" as Core
import "plugins/apps" as Apps
import "plugins/audio" as Audio
import "plugins/battery" as Battery
import "plugins/brightness" as Brightness
import "plugins/capture" as Capture
import "plugins/clock" as Clock
import "plugins/display" as Display
import "plugins/emoji" as Emoji
import "plugins/files" as Files
import "plugins/launcher" as Launcher
import "plugins/notifications" as Notifications
import "plugins/reminder" as Reminder
import "plugins/share" as Share
import "plugins/system" as System

ShellRoot {
    id: root

    function changeVolume(direction: int): void {
        if (direction > 0)
            audioPlugin.volumeUp();
        else if (direction < 0)
            audioPlugin.volumeDown();
        else
            audioPlugin.toggleMute();
        osd.isVolume = true;
        osd.show();
    }

    Core.Compositor {
        id: compositor
    }
    Core.Popup {
        id: popup
        screen: compositor.focusedScreen
        home: launcherPlugin.panel
    }
    Core.Osd {
        id: osd
        screen: compositor.focusedScreen
        property bool isVolume: true
        icon: !isVolume ? "󰍹" : audioPlugin.outputMuted ? "" : ""
        value: isVolume ? (audioPlugin.outputMuted ? 0 : audioPlugin.outputVolume) : brightness.value
        valueText: `${Math.round(value * 100)}%`
    }

    Apps.Main {
        id: apps
    }
    Files.Main {
        id: files
    }
    Audio.Main {
        id: audioPlugin
        popup: popup
    }
    Battery.Main {
        id: batteryService
    }
    Brightness.Main {
        id: brightness
        monitor: compositor.focusedScreen?.name ?? ""
        onAdjusted: {
            popup.close();
            osd.isVolume = false;
            osd.show();
        }
    }
    Capture.Main {
        id: capture
        popup: popup
        active: popup.content === launcherPlugin.panel
    }
    Clock.Main {
        id: clockPlugin
        popup: popup
    }
    Display.Main {
        id: displayPlugin
        popup: popup
    }
    Emoji.Main {
        id: emojiPlugin
        popup: popup
    }
    Emoji.Main {
        id: characters
        popup: popup
        dataSource: Qt.resolvedUrl("plugins/emoji/characters.json")
        searchPlaceholder: qsTr("Search special characters…")
        actionId: "characters"
        actionLabel: qsTr("Special characters")
        actionIcon: "é"
    }
    Notifications.Main {
        id: notifications
        focusedMonitor: compositor.focusedMonitor
        apps: apps
    }
    Reminder.Main {
        id: reminder
        popup: popup
    }
    Share.Main {
        popup: popup
    }
    System.Main {
        id: system
        popup: popup
    }
    Launcher.Main {
        id: launcherPlugin
        popup: popup
        apps: apps
        files: files
        actions: [].concat(audioPlugin.actions, brightness.actions, capture.actions, clockPlugin.actions, displayPlugin.actions, emojiPlugin.actions, characters.actions, reminder.actions, system.actions)
    }

    // Keep compositor bindings and external scripts compatible with existing IPC names.
    IpcHandler {
        target: "shell"
        function battery(): void {
            batteryService.showStatus();
        }
        function activateNotification(): string {
            return notifications.activateNewest();
        }
        function audio(): void {
            popup.toggle(audioPlugin.panel);
        }
        function brightnessDown(): void {
            brightness.decrease();
        }
        function brightnessUp(): void {
            brightness.increase();
        }
        function clock(): void {
            popup.toggle(clockPlugin.panel);
        }
        function close(): void {
            popup.close();
        }
        function display(): void {
            displayPlugin.open();
        }
        function emoji(): void {
            popup.toggle(emojiPlugin.panel);
        }
        function launcher(): void {
            launcherPlugin.open("apps");
        }
        function launcherMenu(mode: string): void {
            launcherPlugin.open(mode);
        }
        function menu(): void {
            launcherPlugin.open("go");
        }
        function openRecent(): void {
            launcherPlugin.open("open");
        }
        function volumeDown(): void {
            root.changeVolume(-1);
        }
        function volumeMute(): void {
            root.changeVolume(0);
        }
        function volumeUp(): void {
            root.changeVolume(1);
        }
    }
}
