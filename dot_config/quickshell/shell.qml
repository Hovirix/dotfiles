//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Io
import "Services" as Services
import "Overlays" as Overlays

// Zero framework code: Appearance tokens + Ui blocks + overlays only.
// The audio/power menus are local forks (same logic as omarchy's panels,
// rendered through local blocks in centered floating popups).
ShellRoot {
    Services.Audio { id: audio }
    Services.Brightness { id: brightness }
    Services.Battery { id: battery }
    Services.Display { id: display }
    Services.Notifications { id: notifications }

    Overlays.Battery { id: batteryOverlay; controller: overlays; battery: battery }
    Overlays.Display { id: displayOverlay; controller: overlays; display: display; brightness: brightness }
    Overlays.Clock { id: clockOverlay; controller: overlays }
    Overlays.VolumeOsd { id: volumeOsd; audio: audio }
    Overlays.BrightnessOsd { id: brightnessOsd; brightness: brightness }
    Overlays.AudioMenu { id: audioMenu; volumeOsd: volumeOsd }
    Overlays.PowerMenu { id: powerMenu }
    Overlays.LauncherMenu { id: launcherMenu; controller: overlays }
    Overlays.Notifications { notifications: notifications }

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
        function power(): void { powerMenu.toggle() }
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
