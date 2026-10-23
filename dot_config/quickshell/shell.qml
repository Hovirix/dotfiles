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
import "ui" as Ui

ShellRoot {
    id: root

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
        id: battery

        popup: popup
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
                parent: "root"
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
                id: "idle",
                label: qsTr("Toggle Idle Lock"),
                icon: "󰒲",
                parent: "system"
            },
            {
                id: "screenshot",
                label: qsTr("Screenshot"),
                icon: "",
                parent: "system"
            },
            {
                id: "screenshotSave",
                label: qsTr("Save Screenshot"),
                icon: "",
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
            },
            {
                id: "battery",
                label: qsTr("Battery"),
                icon: "󰁹",
                parent: "settings"
            },
            {
                id: "brightnessUp",
                label: qsTr("Brightness Up"),
                icon: "󰃟",
                parent: "settings"
            },
            {
                id: "brightnessDown",
                label: qsTr("Brightness Down"),
                icon: "󰃞",
                parent: "settings"
            },
            {
                id: "clock",
                label: qsTr("Clock"),
                icon: "󰥔",
                parent: "settings"
            },
            {
                id: "keyboardLayout",
                label: qsTr("Toggle Keyboard Layout"),
                icon: "󰌌",
                parent: "settings"
            }
        ]
        popup: popup
    }

    Ui.Popup {
        id: popup

        actions: ({
                audio: function () {
                    popup.toggle(audio.panel);
                },
                battery: function () {
                    popup.toggle(battery.panel);
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

        function battery(): void {
            popup.activate("battery");
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
