mod = "SUPER"

-----
--- https://wiki.hypr.land/Configuring/Basics/Variables
---

border_size = 2
gaps_in = 5
gaps_out = 5
col.inactive_border =
col.active_border =
layout = dwindle

input {
    touchpad {
        disable_while_typing = true
        tap_to_click = true
        natural_scroll = true
    }

    device {
        name = type:touchpad
        sensitivity = 1.0
        accel_profile = flat
    }

    device {
        name = type:mouse
        sensitivity = 0.4
        accel_profile = flat
    }
}

-----
--- https://wiki.hypr.land/Configuring/Basics/Variables
---

hl.monitor({
  output = "eDP-1",
  mode = "2880x1800@120",
  position = "auto",
  scale = 1.5,
  bitdepth = 10,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "2560x1440",
  position = "auto-left",
  scale = 1.25,
})

-----
--- https://wiki.hypr.land/Configuring/Basics/Binds
---

-- Workspaces / scratchpad
hl.bind(mod .. " + code:9",  hl.dsp.togglespecialworkspace())
hl.bind(mod .. " + code:10", hl.dsp.workspace("1"))
hl.bind(mod .. " + code:11", hl.dsp.workspace("2"))
hl.bind(mod .. " + code:12", hl.dsp.workspace("3"))
hl.bind(mod .. " + code:13", hl.dsp.workspace("4"))
hl.bind(mod .. " + code:14", hl.dsp.workspace("5"))
hl.bind(mod .. " + code:15", hl.dsp.workspace("6"))
hl.bind(mod .. " + code:16", hl.dsp.workspace("7"))
hl.bind(mod .. " + code:17", hl.dsp.workspace("8"))
hl.bind(mod .. " + code:18", hl.dsp.workspace("9"))
hl.bind(mod .. " + code:19", hl.dsp.workspace("10"))

hl.bind(mod .. " + SHIFT + code:9",  hl.dsp.movetoworkspace("special"))
hl.bind(mod .. " + SHIFT + code:10", hl.dsp.movetoworkspace("1"))
hl.bind(mod .. " + SHIFT + code:11", hl.dsp.movetoworkspace("2"))
hl.bind(mod .. " + SHIFT + code:12", hl.dsp.movetoworkspace("3"))
hl.bind(mod .. " + SHIFT + code:13", hl.dsp.movetoworkspace("4"))
hl.bind(mod .. " + SHIFT + code:14", hl.dsp.movetoworkspace("5"))
hl.bind(mod .. " + SHIFT + code:15", hl.dsp.movetoworkspace("6"))
hl.bind(mod .. " + SHIFT + code:16", hl.dsp.movetoworkspace("7"))
hl.bind(mod .. " + SHIFT + code:17", hl.dsp.movetoworkspace("8"))
hl.bind(mod .. " + SHIFT + code:18", hl.dsp.movetoworkspace("9"))
hl.bind(mod .. " + SHIFT + code:19", hl.dsp.movetoworkspace("10"))

-- Apps
hl.bind(mod .. " + R",      hl.dsp.exec_cmd("fuzzel"))
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("wezterm-gui"))
hl.bind("CTRL + 1",         hl.dsp.exec_cmd("flatpak run io.gitlab.librewolf-community"))
hl.bind("CTRL + 2",         hl.dsp.exec_cmd("wezterm-gui -e yazi"))

-- Scripts
hl.bind(mod .. " + C", hl.dsp.exec_cmd("toggle-swayidle"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("toggle-tailscale"))

-- Screenshots
hl.bind(mod .. " + S",                 hl.dsp.exec_cmd("grimlite --notify copy anything"))
hl.bind(mod .. " + CTRL + S",          hl.dsp.exec_cmd("grimlite --notify save anything"))
hl.bind(mod .. " + CTRL + ALT + S",    hl.dsp.exec_cmd("grimlite --notify save screen"))

-- Brightness
hl.bind(mod .. " + B",       hl.dsp.exec_cmd("brightnessctl --quiet --save set 100%"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("brightnessctl --quiet --save set 0%"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-osd up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-osd down"))

-- Audio
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1"))

-- Window management
hl.bind(mod .. " + Q", hl.dsp.killactive())
hl.bind(mod .. " + T", hl.dsp.togglefloating())
hl.bind(mod .. " + F", hl.dsp.fullscreen())

-- Hyprland
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- System
hl.bind(mod .. " + SHIFT + CTRL + R", hl.dsp.exec_cmd("reboot"))
hl.bind(mod .. " + SHIFT + CTRL + P", hl.dsp.exec_cmd("poweroff"))
hl.bind(mod .. " + SHIFT + CTRL + S", hl.dsp.exec_cmd("loginctl suspend"))

-- Focus
hl.bind(mod .. " + H", hl.dsp.movefocus("l"))
hl.bind(mod .. " + L", hl.dsp.movefocus("r"))
hl.bind(mod .. " + K", hl.dsp.movefocus("u"))
hl.bind(mod .. " + J", hl.dsp.movefocus("d"))

-- Move windows
hl.bind(mod .. " + SHIFT + H", hl.dsp.movewindow("l"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.movewindow("r"))
hl.bind(mod .. " + SHIFT + K", hl.dsp.movewindow("u"))
hl.bind(mod .. " + SHIFT + J", hl.dsp.movewindow("d"))

-- Resize
hl.bind(mod .. " + CTRL + H", hl.dsp.resizeactive("-10 0"))
hl.bind(mod .. " + CTRL + L", hl.dsp.resizeactive("10 0"))
hl.bind(mod .. " + CTRL + K", hl.dsp.resizeactive("0 -10"))
hl.bind(mod .. " + CTRL + J", hl.dsp.resizeactive("0 10"))

-----
--- https://wiki.hypr.land/Configuring/Basics/Binds
---

for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end

for i = 6, 10 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1", default = true })
