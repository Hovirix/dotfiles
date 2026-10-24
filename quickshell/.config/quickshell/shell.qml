//@ pragma IconTheme Papirus-Dark
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "features/audio" as Audio
import "features/battery" as Battery
import "features/brightness" as Brightness
import "features/clock" as Clock
import "features/display" as Display
import "features/launcher" as Launcher
import "features/emoji" as Emoji
import "features/notifications" as Notifications
import "features/reminder" as Reminder
import "ui" as Ui

ShellRoot {
    id: root

    readonly property var focusedScreen: Quickshell.screens.find(output => output.name === notifications.focusedMonitor) || Quickshell.screens[0] || null

    function changeBrightness(direction: int): void {
        if (direction > 0)
            brightness.increase();
        else
            brightness.decrease();
        osd.showBrightness();
    }

    function changeVolume(direction: int): void {
        if (direction > 0)
            audio.volumeUp();
        else if (direction < 0)
            audio.volumeDown();
        else
            audio.toggleMute();
        osd.showVolume();
    }

    function openLauncher(mode: string): void {
        launcher.open(mode);
    }

    function run(command: list<string>): void {
        popup.close();
        Quickshell.execDetached(command);
    }

    Audio.Main {
        id: audio

        popup: popup
    }

    Battery.Main {
    }

    Brightness.Main {
        id: brightness
    }

    Clock.Main {
        id: clock

        popup: popup
    }

    Display.Main {
        id: display

        popup: popup
    }

    Emoji.Main {
        id: emoji

        popup: popup
    }

    Notifications.Main {
        id: notifications
    }

    Launcher.Main {
        id: launcher

        property bool recording: false

        Process {
            id: recordingStatus

            command: ["hx-record", "--status"]
            onExited: (exitCode, exitStatus) => launcher.recording = exitCode === 0
        }

        Timer {
            interval: 1000
            repeat: true
            running: popup.content === launcher.panel
            triggeredOnStart: true
            onTriggered: if (!recordingStatus.running) recordingStatus.running = true
        }

        items: [
            {
                id: "apps",
                label: qsTr("Apps"),
                icon: "󰀻",
                parent: "root"
            },
            {
                id: "files",
                label: qsTr("Files"),
                icon: "󰈙",
                parent: "root"
            },
            {
                id: "emoji",
                label: qsTr("Emoji"),
                icon: "",
                parent: "utilities"
            },
            {
                id: "reminder",
                label: qsTr("Reminder"),
                icon: "󰃭",
                parent: "utilities"
            },
            {
                id: "system",
                label: qsTr("System"),
                icon: "",
                parent: "root"
            },
            {
                id: "settings",
                label: qsTr("Settings"),
                icon: "",
                parent: "root"
            },
            {
                id: "utilities",
                label: qsTr("Utilities"),
                icon: "",
                parent: "root"
            },
            {
                id: "screenshotSave",
                label: qsTr("Screenshot"),
                icon: "",
                parent: "utilities"
            },
            {
                id: "screenrecording",
                label: qsTr("Screenrecording"),
                icon: "",
                parent: "utilities"
            },
            {
                id: "recordStop",
                label: qsTr("Stop recording"),
                icon: "",
                parent: "screenrecording"
            },
            {
                id: "recordSilent",
                label: qsTr("With no audio"),
                icon: "",
                parent: "screenrecording"
            },
            {
                id: "recordDesktop",
                label: qsTr("With desktop audio"),
                icon: "",
                parent: "screenrecording"
            },
            {
                id: "recordMicrophone",
                label: qsTr("With desktop + microphone audio"),
                icon: "",
                parent: "screenrecording"
            },
            {
                id: "lock",
                label: qsTr("Lock"),
                icon: "",
                parent: "system"
            },
            {
                id: "suspend",
                label: qsTr("Suspend"),
                icon: "󰒲",
                parent: "system"
            },
            {
                id: "reboot",
                label: qsTr("Reboot"),
                icon: "",
                parent: "system"
            },
            {
                id: "shutdown",
                label: qsTr("Shutdown"),
                icon: "",
                parent: "system"
            },
            {
                id: "audio",
                label: qsTr("Audio"),
                icon: "",
                parent: "settings"
            },
            {
                id: "display",
                label: qsTr("Display"),
                icon: "󰍹",
                parent: "settings"
            },
            {
                id: "network",
                label: qsTr("Network"),
                icon: "󰖩",
                parent: "settings"
            },
            {
                id: "bluetooth",
                label: qsTr("Bluetooth"),
                icon: "󰂯",
                parent: "settings"
            }
        ].filter(item => item.id !== "recordStop" || launcher.recording)
        popup: popup
    }

    Component {
        id: reminderPanel

        Reminder.Panel {
            controller: popup
        }
    }

    Ui.Popup {
        id: popup

        screen: root.focusedScreen

        actions: ({
                audio: function () {
                    popup.toggle(audio.panel);
                },
                display: function () {
                    popup.toggle(display.panel);
                    if (popup.content === display.panel)
                        display.refresh();
                },
                clock: function () {
                    popup.toggle(clock.panel);
                },
                emoji: function () {
                    popup.toggle(emoji.panel);
                },
                brightnessUp: function () {
                    popup.close();
                    brightness.increase();
                    osd.showBrightness();
                },
                brightnessDown: function () {
                    popup.close();
                    brightness.decrease();
                    osd.showBrightness();
                },
                screenshot: function () {
                    root.run(["hx-screenshot"]);
                },
                recordSilent: function () {
                    root.run(["hx-record"]);
                },
                recordStop: function () {
                    root.run(["hx-record", "--stop"]);
                },
                reminder: function () {
                    popup.open(reminderPanel);
                },
                recordDesktop: function () {
                    root.run(["hx-record", "--desktop-audio"]);
                },
                recordMicrophone: function () {
                    root.run(["hx-record", "--audio"]);
                },
                screenshotSave: function () {
                    root.run(["hx-screenshot", "--save"]);
                },
                idle: function () {
                    root.run(["hx-idle-toggle"]);
                },
                keyboardLayout: function () {
                    root.run(["keyboard-layout-toggle"]);
                },
                network: function () {
                    root.run(["foot", "--app-id", "tui", "-e", "impala"]);
                },
                bluetooth: function () {
                    root.run(["foot", "--app-id", "tui", "-e", "bluetui"]);
                },
                lock: function () {
                    root.run(["hx-lock"]);
                },
                suspend: function () {
                    root.run(["hx-suspend"]);
                },
                reboot: function () {
                    root.run(["systemctl", "reboot"]);
                },
                shutdown: function () {
                    root.run(["systemctl", "poweroff"]);
                }
            })
    }

    Ui.Osd {
        id: osd

        screen: root.focusedScreen

        property bool isVolume: true

        function showBrightness(): void {
            isVolume = false;
            show();
        }

        function showVolume(): void {
            isVolume = true;
            show();
        }

        icon: !isVolume ? "󰍹" : audio.outputMuted ? "" : ""
        value: isVolume ? (audio.outputMuted ? 0 : audio.outputVolume) : brightness.value
        valueText: `${Math.round(value * 100)}%`
    }

    IpcHandler {
        function activateNotification(): string {
            return notifications.activateNewest();
        }

        function audio(): void {
            popup.activate("audio");
        }

        function brightnessDown(): void {
            root.changeBrightness(-1);
        }

        function brightnessUp(): void {
            root.changeBrightness(1);
        }

        function clock(): void {
            popup.activate("clock");
        }

        function close(): void {
            popup.close();
        }

        function display(): void {
            popup.activate("display");
        }

        function emoji(): void {
            popup.activate("emoji");
        }

        function launcher(): void {
            root.openLauncher("apps");
        }

        function launcherMenu(mode: string): void {
            root.openLauncher(mode);
        }

        function menu(): void {
            root.openLauncher("go");
        }

        function openRecent(): void {
            root.openLauncher("open");
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

        target: "shell"
    }
}
