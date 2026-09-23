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

ShellRoot {
    Audio.Service { id: audio }
    Brightness.Service { id: brightness }
    Battery.Service { id: battery }
    Display.Service { id: display }
    Notifications.Service { id: notifications }

    Battery.BatteryPanel { controller: overlays; battery: battery }
    Display.DisplayPanel { id: displayOverlay; controller: overlays; display: display }
    Clock.ClockPanel { controller: overlays }
    Audio.VolumeOsd { id: volumeOsd; audio: audio }
    Brightness.BrightnessOsd { id: brightnessOsd; brightness: brightness }
    Audio.AudioMenu { id: audioMenu }
    Launcher.LauncherPanel { id: launcherMenu; controller: overlays }
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

        function audio(): void { audioMenu.toggle() }
        function battery(): void { overlays.toggle("battery") }
        function display(): void { displayOverlay.open() }
        function clock(): void { overlays.toggle("clock") }
        function emoji(): void { launcherMenu.open("emoji") }
        function openRecent(): void { launcherMenu.open("open") }
        function launcher(): void { launcherMenu.open("apps") }
        function close(): void { overlays.close() }

        function volumeUp(): void {
            audio.volumeUp()
            volumeOsd.show()
        }

        function volumeDown(): void {
            audio.volumeDown()
            volumeOsd.show()
        }

        function volumeMute(): void {
            audio.toggleMute()
            volumeOsd.show()
        }

        function brightnessUp(): void {
            brightness.increase()
            brightnessOsd.show()
        }

        function brightnessDown(): void {
            brightness.decrease()
            brightnessOsd.show()
        }
    }
}
