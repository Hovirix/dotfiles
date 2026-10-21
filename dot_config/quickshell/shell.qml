//@ pragma IconTheme Papirus-Dark

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "Components/Audio" as Audio
import "Components/Battery" as Battery
import "Components/Brightness" as Brightness
import "Components/Clock" as Clock
import "Components/Display" as Display
import "Components/Menu" as Menu
import "Components/Notifications" as Notifications
import "Appearance" as A
import "Ui" as Ui

ShellRoot {
    id: root

    // Aliases so Component blocks can assign same-named required props
    // without RHS self-shadowing (`battery: battery` reads null there).
    readonly property Battery.Service batteryService: battery
    readonly property Display.Service displayService: display
    property IpcHandler ipc: IpcHandler {
        function audio(): void {
            overlays.toggle("audio");
        }

        function battery(): void {
            overlays.toggle("battery");
        }

        function brightnessDown(): void {
            brightness.decrease();
            osd.showBrightness();
        }

        function brightnessUp(): void {
            brightness.increase();
            osd.showBrightness();
        }

        function clock(): void {
            overlays.toggle("clock");
        }

        function close(): void {
            overlays.close();
        }

        function display(): void {
            overlays.toggle("display");
            if (overlays.current === "display")
                display.refresh();
        }

        function emoji(): void {
            overlays.toggle("emoji");
        }

        function launcher(): void {
            launcherMenu("apps");
        }

        // Loader instantiates synchronously, so the menu item exists on
        // the next line and open() can set its mode immediately.
        function launcherMenu(mode: string): void {
            overlays.current = "menu";
            menuLoader.item.open(mode);
        }

        function menu(): void {
            launcherMenu("go");
        }

        function openRecent(): void {
            launcherMenu("open");
        }

        function volumeDown(): void {
            audio.volumeDown();
            osd.showVolume();
        }

        function volumeMute(): void {
            audio.toggleMute();
            osd.showVolume();
        }

        function volumeUp(): void {
            audio.volumeUp();
            osd.showVolume();
        }

        target: "shell"
    }

    Audio.Service {
        id: audio
    }

    Brightness.Service {
        id: brightness
    }

    Battery.Service {
        id: battery
    }

    Display.Service {
        id: display
    }

    Notifications.Service {
        id: notifications
    }

    // The only menu window: content swaps per overlays.current, inactive
    // menus fully unload (cursor/scroll state resets on switch).
    Ui.Popup {
        id: popupWindow

        contentHeight: menuLoader.item ? menuLoader.item.menuHeight : A.Appearance.buttonHeight
        contentPadding: menuStyle ? A.Appearance.menuPadding : A.Appearance.dialogPadding
        contentTop: overlays.current === "menu" && menuLoader.item ? menuLoader.item.cardTop : -1
        contentWidth: menuLoader.item ? menuLoader.item.menuWidth : A.Appearance.popupWidthStandard
        menuStyle: overlays.current === "menu" || overlays.current === "emoji"
        shown: overlays.current !== ""

        onCloseRequested: overlays.close()

        Loader {
            id: menuLoader

            anchors.fill: parent
            sourceComponent: {
                if (overlays.current === "audio")
                    return audioComp;
                if (overlays.current === "battery")
                    return batteryComp;
                if (overlays.current === "display")
                    return displayComp;
                if (overlays.current === "clock")
                    return clockComp;
                if (overlays.current === "menu")
                    return menuComp;
                if (overlays.current === "emoji")
                    return emojiComp;
                return null;
            }

            onLoaded: item.focusMenu()
        }
    }

    Component {
        id: audioComp

        Audio.AudioMenu {
            controller: overlays
        }
    }

    Component {
        id: batteryComp

        Battery.BatteryPanel {
            battery: root.batteryService
            controller: overlays
        }
    }

    Component {
        id: displayComp

        Display.DisplayPanel {
            controller: overlays
            display: root.displayService
        }
    }

    Component {
        id: clockComp

        Clock.ClockPanel {
            controller: overlays
        }
    }

    Component {
        id: menuComp

        Menu.MenuPanel {
            controller: overlays
            popup: popupWindow
        }
    }

    Component {
        id: emojiComp

        Menu.EmojiPanel {
            controller: overlays
        }
    }

    Ui.OsdWindow {
        id: osd

        audio: audio
        brightness: brightness
    }

    Notifications.NotificationsPanel {
        notifications: notifications
    }

    // Minimal overlay controller: which Appearance-based overlay is open.
    QtObject {
        id: overlays

        property string current: ""

        function activate(name: string): void {
            if (["audio", "battery", "display", "clock"].indexOf(name) >= 0) {
                current = name;
                if (name === "display")
                    display.refresh();
            } else {
                close();
                if (name === "brightnessUp" || name === "brightnessDown") {
                    if (name === "brightnessUp")
                        brightness.increase();
                    else
                        brightness.decrease();
                    osd.showBrightness();
                } else if (name === "screenshot")
                    Quickshell.execDetached(["hx-screenshot"]);
                else if (name === "screenshotSave")
                    Quickshell.execDetached(["hx-screenshot", "--save"]);
                else if (name === "idle")
                    Quickshell.execDetached(["hx-idle-toggle"]);
                else if (name === "keyboardLayout")
                    Quickshell.execDetached(["keyboard-layout-toggle"]);
                else if (name === "network")
                    Quickshell.execDetached(["foot", "--app-id", "tui", "-e", "impala"]);
                else if (name === "bluetooth")
                    Quickshell.execDetached(["foot", "--app-id", "tui", "-e", "bluetui"]);
                else if (name === "lock")
                    Quickshell.execDetached(["hx-lock"]);
                else if (name === "suspend")
                    Quickshell.execDetached(["hx-suspend"]);
                else if (name === "reboot")
                    Quickshell.execDetached(["systemctl", "reboot"]);
                else if (name === "shutdown")
                    Quickshell.execDetached(["systemctl", "poweroff"]);
            }
        }

        function close(): void {
            current = "";
        }

        function toggle(name: string): void {
            current = current === name ? "" : name;
        }
    }
}
