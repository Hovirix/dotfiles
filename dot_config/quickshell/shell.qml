//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Io
import "Components/Audio" as Audio
import "Components/Battery" as Battery
import "Components/Brightness" as Brightness
import "Components/Clock" as Clock
import "Components/Display" as Display
import "Components/Launcher" as Launcher
import "Components/Notifications" as Notifications
import "Appearance" as A
import "Ui" as Ui

ShellRoot {
    Audio.Service { id: audio }
    Brightness.Service { id: brightness }
    Battery.Service { id: battery }
    Display.Service { id: display }
    Notifications.Service { id: notifications }

    // Aliases so Component blocks can assign same-named required props
    // without RHS self-shadowing (`battery: battery` reads null there).
    readonly property var batteryService: battery
    readonly property var displayService: display

    // The only menu window: content swaps per overlays.current, inactive
    // menus fully unload (cursor/scroll state resets on switch).
    Ui.Popup {
        shown: overlays.current !== ""
        contentWidth: menuLoader.item ? menuLoader.item.menuWidth : A.Appearance.popupWidthStandard
        contentHeight: menuLoader.item ? menuLoader.item.menuHeight : A.Appearance.buttonHeight
        onCloseRequested: overlays.close()

        Loader {
            id: menuLoader
            anchors.fill: parent
            sourceComponent: {
                if (overlays.current === "audio") return audioComp
                if (overlays.current === "battery") return batteryComp
                if (overlays.current === "display") return displayComp
                if (overlays.current === "clock") return clockComp
                if (overlays.current === "launcher") return launcherComp
                return null
            }
            onLoaded: item.focusMenu()
        }
    }

    Component {
        id: audioComp
        Audio.AudioMenu { controller: overlays }
    }
    Component {
        id: batteryComp
        Battery.BatteryPanel { controller: overlays; battery: batteryService }
    }
    Component {
        id: displayComp
        Display.DisplayPanel { controller: overlays; display: displayService }
    }
    Component {
        id: clockComp
        Clock.ClockPanel { controller: overlays }
    }
    Component {
        id: launcherComp
        Launcher.LauncherPanel { controller: overlays }
    }

    Ui.OsdWindow {
        id: osd
        audio: audio
        brightness: brightness
    }
    Notifications.NotificationsPanel { notifications: notifications }

    // Minimal overlay controller: which Appearance-based overlay is open.
    QtObject {
        id: overlays

        property string current: ""

        function toggle(name: string): void {
            current = current === name ? "" : name
        }

        function close(): void {
            current = ""
        }
    }

    property var ipc: IpcHandler {
        target: "shell"

        function audio(): void { overlays.toggle("audio") }
        function battery(): void { overlays.toggle("battery") }
        function display(): void {
            overlays.toggle("display")
            if (overlays.current === "display")
                display.refresh()
        }
        function clock(): void { overlays.toggle("clock") }
        // Loader instantiates synchronously, so the menu item exists on
        // the next line and open() can set its mode immediately.
        function launcherMenu(mode: string): void {
            overlays.current = "launcher"
            menuLoader.item.open(mode)
        }
        function emoji(): void { launcherMenu("emoji") }
        function openRecent(): void { launcherMenu("open") }
        function launcher(): void { launcherMenu("apps") }
        function close(): void { overlays.close() }

        function volumeUp(): void {
            audio.volumeUp()
            osd.showVolume()
        }

        function volumeDown(): void {
            audio.volumeDown()
            osd.showVolume()
        }

        function volumeMute(): void {
            audio.toggleMute()
            osd.showVolume()
        }

        function brightnessUp(): void {
            brightness.increase()
            osd.showBrightness()
        }

        function brightnessDown(): void {
            brightness.decrease()
            osd.showBrightness()
        }
    }
}
